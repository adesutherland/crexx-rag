#!/usr/bin/env python3
"""Bounded blinded hosted qualification for frozen Phase-5 evidence packets."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import statistics
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path
from typing import Any


QUESTIONS = [
    ("it-ho-01-path", "Trace the approved dependency path from Parcel API to destination records and identify the replica risk."),
    ("it-ho-02-alias", "What is ADX, and which component reads it?"),
    ("it-ho-03-ambiguity", "What datastore does Orion use?"),
    ("it-ho-04-stance", "Does the design claim every destination replica is current during regional failover?"),
    ("scot-01-agency-stance", "What role did Rannoch play in the Glen Mora removals, and how do the sources judge it?"),
    ("scot-02-direct-phrase", "Why were the Brannochs called the Children of the Rain?"),
    ("scot-03-northwatch-timeline", "Trace the origin of the Northwatch Regiment and explain An Freiceadan Gorm."),
    ("scot-04-direct-versus-adjacent", "Were the Houses of Brannoch and Rannoch allied, and which northern claims are direct rather than graph-adjacent?"),
    ("scot-05-nuanced-conflict", "Can the Glen Mora removals be described simply as lawful or unlawful from this source set?"),
]

SOURCES = [
    "it-auth-decision-v1.md",
    "it-auth-decision-v2.md",
    "it-held-out.md",
    "it-operations-note.md",
    "scotland-shaped-chronicle.md",
    "scotland-shaped-ledger.md",
]

ANSWER_SCHEMA = {
    "type": "object",
    "required": ["answer", "citations", "gaps"],
    "properties": {
        "answer": {"type": "string"},
        "citations": {"type": "array", "items": {"type": "string"}},
        "gaps": {"type": "array", "items": {"type": "string"}},
    },
    "additionalProperties": False,
}

SCORE_SCHEMA = {
    "type": "object",
    "required": [
        "answer_1_score",
        "answer_2_score",
        "answer_1_critical_failure",
        "answer_2_critical_failure",
        "preference",
        "rationale",
    ],
    "properties": {
        "answer_1_score": {"type": "integer", "minimum": 0, "maximum": 16},
        "answer_2_score": {"type": "integer", "minimum": 0, "maximum": 16},
        "answer_1_critical_failure": {"type": "integer", "minimum": 0, "maximum": 1},
        "answer_2_critical_failure": {"type": "integer", "minimum": 0, "maximum": 1},
        "preference": {"type": "string", "enum": ["answer_1", "answer_2", "tie"]},
        "rationale": {"type": "string"},
    },
    "additionalProperties": False,
}


def sha256_text(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def read_text(path: Path, ceiling: int = 1_048_576) -> str:
    data = path.read_bytes()
    if len(data) > ceiling:
        raise ValueError(f"{path} exceeds the {ceiling}-byte qualification ceiling")
    return data.decode("utf-8")


def validate_answer(value: Any) -> None:
    if not isinstance(value, dict) or set(value) != {"answer", "citations", "gaps"}:
        raise ValueError("answer response does not match the frozen object shape")
    if not isinstance(value["answer"], str) or not all(
        isinstance(item, str) for item in value["citations"]
    ) or not all(isinstance(item, str) for item in value["gaps"]):
        raise ValueError("answer response contains an invalid member type")


def validate_score(value: Any) -> None:
    required = set(SCORE_SCHEMA["required"])
    if not isinstance(value, dict) or set(value) != required:
        raise ValueError("scorer response does not match the frozen object shape")
    for name in ("answer_1_score", "answer_2_score"):
        if type(value[name]) is not int or not 0 <= value[name] <= 16:
            raise ValueError(f"{name} is outside 0..16")
    for name in ("answer_1_critical_failure", "answer_2_critical_failure"):
        if type(value[name]) is not int or value[name] not in (0, 1):
            raise ValueError(f"{name} is not 0 or 1")
    if value["preference"] not in ("answer_1", "answer_2", "tie") or not isinstance(
        value["rationale"], str
    ):
        raise ValueError("scorer preference or rationale is invalid")


class GeminiClient:
    def __init__(self, api_key: str, model: str, output_dir: Path) -> None:
        self._api_key = api_key
        self.model = model
        self.output_dir = output_dir
        self.calls = 0
        self.input_tokens = 0
        self.output_tokens = 0

    def structured(
        self,
        *,
        call_id: str,
        system: str,
        user: str,
        schema: dict[str, Any],
        max_output_tokens: int,
    ) -> tuple[dict[str, Any], dict[str, Any]]:
        self.calls += 1
        payload = {
            "systemInstruction": {"parts": [{"text": system}]},
            "contents": [{"role": "user", "parts": [{"text": user}]}],
            "generationConfig": {
                "temperature": 0,
                "thinkingConfig": {"thinkingLevel": "minimal"},
                "maxOutputTokens": max_output_tokens,
                "responseMimeType": "application/json",
                "responseJsonSchema": schema,
            },
        }
        encoded = json.dumps(payload, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
        request = urllib.request.Request(
            f"https://generativelanguage.googleapis.com/v1beta/models/{self.model}:generateContent",
            data=encoded,
            headers={
                "Content-Type": "application/json",
                "x-goog-api-key": self._api_key,
                "X-Client-Request-Id": call_id,
            },
            method="POST",
        )
        started = time.monotonic_ns()
        try:
            with urllib.request.urlopen(request, timeout=120) as response:
                response_bytes = response.read(1_048_577)
                status = response.status
        except urllib.error.HTTPError as exc:
            body = exc.read(16_385).decode("utf-8", "replace")
            raise RuntimeError(f"{call_id} HTTP {exc.code}: {body[:1000]}") from exc
        if status != 200 or len(response_bytes) > 1_048_576:
            raise RuntimeError(f"{call_id} returned status {status} or exceeded one MiB")
        response_document = json.loads(response_bytes)
        (self.output_dir / f"raw-{call_id}.json").write_text(
            json.dumps(response_document, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        candidate = response_document["candidates"][0]
        text_parts = [part["text"] for part in candidate["content"]["parts"] if "text" in part]
        if not text_parts:
            raise ValueError(f"{call_id} returned no textual structured output")
        raw_text = text_parts[-1]
        content = json.loads(raw_text)
        usage = response_document.get("usageMetadata", {})
        input_tokens = int(usage.get("promptTokenCount", 0))
        output_tokens = int(usage.get("candidatesTokenCount", 0))
        self.input_tokens += input_tokens
        self.output_tokens += output_tokens
        metadata = {
            "call_id": call_id,
            "provider": "gemini",
            "model": self.model,
            "credential_reference": "env:GEMINI_API_KEY",
            "temperature_millionths": 0,
            "thinking_level": "minimal",
            "max_attempts": 1,
            "request_sha256": hashlib.sha256(encoded).hexdigest(),
            "response_id": response_document.get("responseId", ""),
            "model_version": response_document.get("modelVersion", ""),
            "input_tokens": input_tokens,
            "output_tokens": output_tokens,
            "total_tokens": int(usage.get("totalTokenCount", input_tokens + output_tokens)),
            "latency_us": (time.monotonic_ns() - started) // 1000,
        }
        return content, metadata


def producer_prompt(question: str, context: str) -> str:
    return f"QUESTION:\n{question}\n\nCONTEXT:\n{context}"


def scorer_prompt(
    question: str,
    judgement_material: str,
    typed_context: str,
    full_context: str,
    answer_1: dict[str, Any],
    answer_2: dict[str, Any],
) -> str:
    return (
        f"QUESTION:\n{question}\n\nFIXED JUDGEMENT MATERIAL:\n{judgement_material}"
        f"\n\nTYPED PASSAGE MAP:\n{typed_context}\n\nFULL SOURCE CONTROL:\n{full_context}"
        f"\n\nANSWER 1:\n{json.dumps(answer_1, ensure_ascii=False)}"
        f"\n\nANSWER 2:\n{json.dumps(answer_2, ensure_ascii=False)}"
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--packet-dir", type=Path, required=True)
    parser.add_argument("--fixture-dir", type=Path, required=True)
    parser.add_argument("--judgement-dir", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--model", default=os.environ.get("CPRAG_GEMINI_MODEL", "gemini-3.5-flash"))
    parser.add_argument("--confirm-hosted-public-fixtures", action="store_true")
    args = parser.parse_args()
    if not args.confirm_hosted_public_fixtures:
        parser.error("--confirm-hosted-public-fixtures is required for outbound qualification")
    api_key = os.environ.get("GEMINI_API_KEY", "").strip()
    if not api_key:
        parser.error("symbolic credential env:GEMINI_API_KEY is unavailable")
    args.output_dir.mkdir(parents=True, exist_ok=False)

    full_context = "".join(
        f"\n\nSOURCE LABEL: source:{name}\n{read_text(args.fixture_dir / name)}" for name in SOURCES
    )
    judgement_material = "\n".join(
        [
            "IT JUDGEMENTS:\n" + read_text(args.judgement_dir / "it-held-out-judgements.jsonl"),
            "SCOTLAND JUDGEMENTS:\n" + read_text(args.judgement_dir / "scotland-shaped-judgements.jsonl"),
            "RUBRIC:\n" + read_text(args.judgement_dir / "rubric.md"),
            "PASSAGE MAP:\n" + read_text(args.judgement_dir / "passage-map.tsv"),
        ]
    )
    client = GeminiClient(api_key, args.model, args.output_dir)
    answer_system = (
        "You are an evidence-bound analyst. Answer only from the supplied CONTEXT. Preserve attribution, "
        "time, ambiguity, conflicts, explicit absence and uncertainty. Cite only citation strings or source "
        "labels present in CONTEXT. Never use outside knowledge. Keep the answer under 180 words and return "
        "only the requested JSON object."
    )
    scorer_system = (
        "You are a reset, blinded evidence judge. The two candidate answers are anonymously ordered. Score "
        "each independently from 0 through 16 using the fixed rubric. A critical failure is 1 only for a "
        "fabricated decisive claim, a graph lead asserted as fact, a citation that does not entail its attached "
        "claim, or an expected gap erased; otherwise 0. Do not reward style or verbosity. Return only the "
        "requested JSON object."
    )
    case_summaries: list[dict[str, Any]] = []
    typed_total = control_total = critical_failures = passing = adjudications = 0
    for index, (case_id, question) in enumerate(QUESTIONS, start=1):
        typed_context = read_text(args.packet_dir / f"case-{index}.context.json", 65_536)
        typed_answer, typed_meta = client.structured(
            call_id=f"p5-answer-{case_id}-typed",
            system=answer_system,
            user=producer_prompt(question, typed_context),
            schema=ANSWER_SCHEMA,
            max_output_tokens=768,
        )
        control_answer, control_meta = client.structured(
            call_id=f"p5-answer-{case_id}-full",
            system=answer_system,
            user=producer_prompt(question, full_context),
            schema=ANSWER_SCHEMA,
            max_output_tokens=768,
        )
        validate_answer(typed_answer)
        validate_answer(control_answer)
        if index % 2:
            blind_order = ["typed", "full"]
            answer_1, answer_2 = typed_answer, control_answer
        else:
            blind_order = ["full", "typed"]
            answer_1, answer_2 = control_answer, typed_answer
        scores: list[dict[str, Any]] = []
        score_meta: list[dict[str, Any]] = []
        for reset in (1, 2):
            score, metadata = client.structured(
                call_id=f"p5-score-{case_id}-reset-{reset}",
                system=scorer_system,
                user=scorer_prompt(
                    question, judgement_material, typed_context, full_context, answer_1, answer_2
                ),
                schema=SCORE_SCHEMA,
                max_output_tokens=512,
            )
            validate_score(score)
            scores.append(score)
            score_meta.append(metadata)
        needs_adjudication = (
            abs(scores[0]["answer_1_score"] - scores[1]["answer_1_score"]) > 2
            or abs(scores[0]["answer_2_score"] - scores[1]["answer_2_score"]) > 2
            or scores[0]["answer_1_critical_failure"] != scores[1]["answer_1_critical_failure"]
            or scores[0]["answer_2_critical_failure"] != scores[1]["answer_2_critical_failure"]
        )
        if needs_adjudication:
            score, metadata = client.structured(
                call_id=f"p5-score-{case_id}-adjudicator",
                system=scorer_system,
                user=scorer_prompt(
                    question, judgement_material, typed_context, full_context, answer_1, answer_2
                ),
                schema=SCORE_SCHEMA,
                max_output_tokens=512,
            )
            validate_score(score)
            scores.append(score)
            score_meta.append(metadata)
            adjudications += 1
        if len(scores) == 3:
            final_1 = int(statistics.median(item["answer_1_score"] for item in scores))
            final_2 = int(statistics.median(item["answer_2_score"] for item in scores))
            critical_1 = int(statistics.median(item["answer_1_critical_failure"] for item in scores))
            critical_2 = int(statistics.median(item["answer_2_critical_failure"] for item in scores))
        else:
            final_1 = sum(item["answer_1_score"] for item in scores) // 2
            final_2 = sum(item["answer_2_score"] for item in scores) // 2
            critical_1 = int(any(item["answer_1_critical_failure"] for item in scores))
            critical_2 = int(any(item["answer_2_critical_failure"] for item in scores))
        if blind_order[0] == "typed":
            typed_score, control_score = final_1, final_2
            typed_critical, control_critical = critical_1, critical_2
        else:
            typed_score, control_score = final_2, final_1
            typed_critical, control_critical = critical_2, critical_1
        typed_total += typed_score
        control_total += control_score
        critical_failures += typed_critical
        passing += int(typed_score >= 13 and typed_critical == 0)
        case_record = {
            "schema": "crexx-rag.hosted-judgement/1",
            "case_id": case_id,
            "question": question,
            "provider": "gemini",
            "model": args.model,
            "credential_reference": "env:GEMINI_API_KEY",
            "temperature_millionths": 0,
            "thinking_level": "minimal",
            "max_attempts": 1,
            "blind_order": blind_order,
            "typed_context_sha256": sha256_text(typed_context),
            "full_context_sha256": sha256_text(full_context),
            "typed_answer": typed_answer,
            "control_answer": control_answer,
            "scorers": scores,
            "typed_score": typed_score,
            "control_score": control_score,
            "typed_critical_failure": typed_critical,
            "control_critical_failure": control_critical,
            "calls": [typed_meta, control_meta, *score_meta],
        }
        (args.output_dir / f"case-{index}.json").write_text(
            json.dumps(case_record, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        summary_case = {
            "case_id": case_id,
            "typed_score": typed_score,
            "control_score": control_score,
            "typed_critical_failure": typed_critical,
            "adjudicated": needs_adjudication,
        }
        case_summaries.append(summary_case)
        print(
            f"P5_HOSTED_CASE case={index} id={case_id} typed_score={typed_score}/16 "
            f"control_score={control_score}/16 typed_critical={typed_critical} "
            f"adjudicated={int(needs_adjudication)}",
            flush=True,
        )
    accepted = passing >= 8 and typed_total * 100 >= 85 * 144 and critical_failures == 0
    summary = {
        "schema": "crexx-rag.hosted-qualification/1",
        "provider": "gemini",
        "model": args.model,
        "credential_reference": "env:GEMINI_API_KEY",
        "temperature_millionths": 0,
        "thinking_level": "minimal",
        "max_attempts": 1,
        "public_fixtures": True,
        "cases": case_summaries,
        "passing_cases": passing,
        "typed_score": typed_total,
        "control_score": control_total,
        "critical_failures": critical_failures,
        "calls": client.calls,
        "adjudications": adjudications,
        "input_tokens": client.input_tokens,
        "output_tokens": client.output_tokens,
        "accepted": accepted,
    }
    (args.output_dir / "summary.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    if not accepted:
        print(
            f"P5_HOSTED_FAIL passing={passing}/9 score={typed_total}/144 "
            f"critical_failures={critical_failures} calls={client.calls}",
            file=sys.stderr,
        )
        return 1
    print(
        f"P5_HOSTED_OK provider=gemini model={args.model} credential_reference=env:GEMINI_API_KEY "
        f"temperature_millionths=0 thinking_level=minimal max_attempts=1 public_fixtures=1 passing={passing}/9 "
        f"score={typed_total}/144 control_score={control_total}/144 critical_failures=0 "
        f"calls={client.calls} adjudications={adjudications} input_tokens={client.input_tokens} "
        f"output_tokens={client.output_tokens}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
