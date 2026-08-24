#!/usr/bin/env python3
"""Two-call, secret-safe hosted generation and embedding qualification."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import os
from pathlib import Path
import time
import urllib.error
import urllib.request


def canonical_json(value: object) -> bytes:
    return json.dumps(value, ensure_ascii=False, separators=(",", ":"), sort_keys=True).encode("utf-8")


def post(api_key: str, path: str, body: dict[str, object]) -> tuple[dict[str, object], int, str]:
    encoded = canonical_json(body)
    request = urllib.request.Request(
        f"https://api.openai.com/v1/{path}",
        data=encoded,
        method="POST",
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
            "User-Agent": "crexx-rag-phase7-qualification/1",
        },
    )
    started = time.monotonic_ns()
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            payload = response.read(8 * 1024 * 1024 + 1)
    except urllib.error.HTTPError as error:
        safe_message = f"hosted provider returned HTTP {error.code}"
        raise RuntimeError(safe_message) from None
    elapsed_us = (time.monotonic_ns() - started) // 1000
    if len(payload) > 8 * 1024 * 1024:
        raise RuntimeError("hosted response exceeded the 8 MiB ceiling")
    decoded = json.loads(payload)
    if not isinstance(decoded, dict):
        raise RuntimeError("hosted response is not a JSON object")
    return decoded, elapsed_us, hashlib.sha256(encoded).hexdigest()


def extract_output_text(response: dict[str, object]) -> str:
    direct = response.get("output_text")
    if isinstance(direct, str):
        return direct
    output = response.get("output")
    if not isinstance(output, list):
        return ""
    for item in output:
        if not isinstance(item, dict):
            continue
        content = item.get("content")
        if not isinstance(content, list):
            continue
        for part in content:
            if isinstance(part, dict) and isinstance(part.get("text"), str):
                return str(part["text"])
    return ""


def usage(response: dict[str, object]) -> dict[str, int]:
    raw = response.get("usage")
    if not isinstance(raw, dict):
        return {"input_tokens": 0, "output_tokens": 0, "total_tokens": 0}
    result: dict[str, int] = {}
    for name in ("input_tokens", "output_tokens", "total_tokens"):
        value = raw.get(name, 0)
        if name == "input_tokens" and not isinstance(value, int):
            value = raw.get("prompt_tokens", 0)
        if name == "input_tokens" and value == 0:
            prompt_value = raw.get("prompt_tokens", 0)
            if isinstance(prompt_value, int):
                value = prompt_value
        result[name] = value if isinstance(value, int) and value >= 0 else 0
    return result


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--generation-model", default="gpt-5.6-luna")
    parser.add_argument("--embedding-model", default="text-embedding-3-small")
    parser.add_argument("--confirm-hosted-public-fixtures", action="store_true")
    args = parser.parse_args()
    if not args.confirm_hosted_public_fixtures:
        parser.error("--confirm-hosted-public-fixtures is required for outbound qualification")
    api_key = os.environ.get("OPENAI_API_KEY", "").strip()
    if not api_key:
        parser.error("env:OPENAI_API_KEY is required")

    generation_body: dict[str, object] = {
        "model": args.generation_model,
        "input": "Return a JSON object whose answer field is exactly ok.",
        "max_output_tokens": 32,
        "text": {
            "format": {
                "type": "json_schema",
                "name": "crexx_rag_phase7",
                "strict": True,
                "schema": {
                    "type": "object",
                    "required": ["answer"],
                    "properties": {"answer": {"type": "string", "enum": ["ok"]}},
                    "additionalProperties": False,
                },
            }
        },
    }
    generation, generation_us, generation_hash = post(
        api_key, "responses", generation_body
    )
    content = extract_output_text(generation)
    parsed_content = json.loads(content)
    if parsed_content != {"answer": "ok"}:
        raise RuntimeError("hosted structured generation did not return the exact schema value")

    embedding_body: dict[str, object] = {
        "model": args.embedding_model,
        "input": ["industrial vector indexing", "provider qualification"],
        "dimensions": 128,
        "encoding_format": "float",
    }
    embedding, embedding_us, embedding_hash = post(
        api_key, "embeddings", embedding_body
    )
    data = embedding.get("data")
    if not isinstance(data, list) or len(data) != 2:
        raise RuntimeError("hosted embedding response did not contain two vectors")
    dimensions: list[int] = []
    for expected_index, item in enumerate(data):
        if not isinstance(item, dict) or item.get("index") != expected_index:
            raise RuntimeError("hosted embedding order is invalid")
        vector = item.get("embedding")
        if not isinstance(vector, list) or len(vector) != 128:
            raise RuntimeError("hosted embedding dimension is invalid")
        if any(not isinstance(value, (int, float)) or not math.isfinite(value) for value in vector):
            raise RuntimeError("hosted embedding contains a non-finite value")
        dimensions.append(len(vector))

    retained = {
        "schema": "crexx-rag.phase7-hosted-qualification/1",
        "provider": "openai",
        "credential_reference": "env:OPENAI_API_KEY",
        "public_fixtures": True,
        "calls": 2,
        "max_attempts": 1,
        "request_or_response_bodies_retained": False,
        "generation": {
            "model": args.generation_model,
            "status": "ok",
            "request_sha256": generation_hash,
            "response_id_present": bool(generation.get("id")),
            "latency_us": generation_us,
            "usage": usage(generation),
        },
        "embedding": {
            "model": args.embedding_model,
            "status": "ok",
            "request_sha256": embedding_hash,
            "response_id_present": bool(embedding.get("id")),
            "latency_us": embedding_us,
            "input_count": 2,
            "dimensions": dimensions,
            "usage": usage(embedding),
        },
    }
    args.output_dir.mkdir(parents=True, exist_ok=True)
    (args.output_dir / "summary.json").write_bytes(canonical_json(retained) + b"\n")
    print(
        "P7_HOSTED_OK provider=openai "
        f"generation_model={args.generation_model} "
        f"embedding_model={args.embedding_model} "
        "credential_reference=env:OPENAI_API_KEY public_fixtures=1 "
        "calls=2 max_attempts=1 generation=ok embedding_batch=2x128 "
        f"generation_input_tokens={retained['generation']['usage']['input_tokens']} "
        f"generation_output_tokens={retained['generation']['usage']['output_tokens']} "
        f"embedding_input_tokens={retained['embedding']['usage']['input_tokens']}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
