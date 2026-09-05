# CREXX and platform integration issues

These are current boundaries. Any source-level containment used by the product
is stated explicitly.

## Worker execution architecture

CREXX now supports declared native-provider discovery and isolated RXPA
sessions in attached task VMs, including the installed `rxsqlite` provider.
The former discovery integration gap is closed upstream.

`crexxrag` continues to use operating-system worker processes by product
design. Every process starts a fresh VM and opens its own SQLite connection,
which is supported and covered by regression tests. Moving work into attached
tasks would be a separate architecture and recovery-policy decision; native
SQLite handles would remain VM-local and must never be transferred.

## Provider lifetime

The application currently uses one operation-scoped provider pool/process per
adapter invocation. It does not claim long-lived reuse, streaming, or
cancellation across operations.

## Installed Linux replay

The exact installed-package Linux replay of the hosted-provider path remains a
separate platform qualification. macOS evidence must not be represented as
Linux qualification.

## CREXX project-build scaling

The installed `crexx --program` project wrapper is functionally correct for
this application, but its incremental and optimiser scaling needs an upstream
CREXX investigation. A one-file `ragimprove.crexx` edit caused the supported
`crexxrag_application` target to compile many unaffected project members.
Smaller members completed in parallel, while `crexxrag_cli`, `ragproduct`,
`ragmcp`, and the one-member ADDRESS environment each consumed a full core for
minutes and hundreds of MB.

A macOS process sample of `rxc` compiling `crexxrag_cli` placed essentially all
samples in `optimise`, `rxcp_inline_pass`, `rxcp_inline_prepare`, and
`inline_analyse_callable_eligibility`, beneath repeated AST walks while an
imported file was being loaded. The members did eventually complete, so the
current evidence is pathological inline-eligibility scaling and timeout risk,
not a demonstrated infinite loop. The upstream report must include the exact
installed command, application member list, per-member elapsed/RSS evidence,
and the captured stack sample. Disabling optimisation is not a product
workaround; users should receive normally built installed artifacts.

## cREXX lexical scope at mixed branches

The earlier branch-local value-merge diagnosis was incorrect. A grouped `DO`
arm creates a local scope while a single-statement arm executes in the
enclosing scope, so implicit first assignments with the same spelling can
legally create different variables. CREXX now reports `#NOT_IN_SAME_SCOPE` for
that ambiguous implicit-binding shape; this is source scoping plus diagnostic
coverage, not a register-allocation defect.

`crexxrag` explicitly declares the provider-result object in the enclosing
scope when both branches are intended to assign one joined value. The existing
application regression retains that source-level contract.

## Interactive input

The current CREXX line-input behavior can require an additional Enter after a
confirmation prompt on affected builds. This is a known CREXX issue; the
product does not carry a duplicate roadmap entry. Interactive use remains safe
because no apply begins before an affirmative answer is read. After reviewing
the displayed plan, use `--yes` for automation and repeatable smoke tests; that
path does not read stdin and is not affected by the extra-Enter behavior.

## RexxScript configuration boundary

RexxScript can be called as a function and is relevant to future configuration
or rule authoring. The current product does not need it: strict declarative
configuration and bounded TSV glossary/profile data cover all present operator
controls without executable selection. Introducing RexxScript solely because
it may become more powerful would add a second authoring path without a current
requirement, so integration is intentionally deferred rather than treated as a
missing capability.
