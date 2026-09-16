# Design-Tool Integrations (capability-first)

Design tools are **interchangeable, capability-defined integrations**: any tool sits behind the same two capabilities. The
generic protocol always works standalone; per-tool sections below refine it
where a tool's surface is known. A missing tool section never blocks a
strategy — apply the generic protocol. All tool variance stays inside this
skill: **downstream reads only the manifest**, so when any tool's surface
shifts (several are preview-grade), exactly one skill gets patched. Record
what a connected design tool actually exposes on first use (tool names/surface)
in the project's docs — that's the concrete contract and the drift detector.

## The two capabilities

- **Enumerate/export existing designs** (powers Strategy A): list screens/
  frames, fetch a screen's design data (structure, styles, values), yield a
  stable locator.
- **Generate from a system spec** (powers Strategy B): accept design.md
  excerpts + tokens + a screen brief; produce a design artifact with a
  locator.

A tool may have one, both, or neither (neither → it's not a design
tool; Strategy C carries the project).

## Generic protocol

- **Nothing connected, tool wanted**: state it, don't silently downgrade.
  Name the class of tool needed and guide connection via the runtime's own
  MCP mechanism — **check live docs for the current steps** (they're
  runtime-specific and drift; never recite remembered commands). Offer the
  code-native path as the no-blocker alternative; re-verification mode can
  register tool designs later.
- **Discovery**: list the connected MCP's tools; classify against the two
  capabilities; don't assume names. Match servers by **tool-name prefix
  substring** (`mcp__<server>__<tool>`, server names are mangled — `figma`,
  `design`), never an exact name. Listed tools prove presence, not
  authorization: one cheap identity call separates *connected* from
  *configured but unauthorized*, and only the first can fetch.
- **Matching** (Strategy A): find screens by SCR-ID naming in the tool
  (recommend designers put SCR IDs in frame names); otherwise match by
  screen name + surface and **confirm with the user** before registering —
  a wrong registration poisons the manifest. Record the tool-side ID so
  future lookups are exact.
- **Fetching**: prefer structured data (variables, styles, component refs)
  over pixels — values beat inspection. Screenshots are for human
  confirmation and conformance spot-checks, not as the primary source.
- **Generating**: compose the brief from authority (design.md sections,
  tokens, the screen's inventory entry, contract shapes); bounded retry on
  non-conformance; persistent failure → Strategy C for that screen.
- **Locators**: whatever the tool's stable reference is (URL, node ID,
  artifact ref) — verified resolvable before the manifest entry is written.

## Figma

Both capabilities (enumerate/export mature; generation via write-to-canvas).
Strategy A: match frames by SCR-ID naming; fetch via design-context/variables/
styles rather than screenshots where possible; prefer published-library
components as the conformance reference. Locator: file URL + node-id.
Strategy B: write-to-canvas generation exists; treat as preview-grade —
conformance-check output like any generated artifact.

## Claude Design

**Both capabilities** (research preview — surface may shift; keep every call in
this skill). Connection is its own server plus a *separate* design login; a
normal login token carries no access, so expect the configured-but-unauthorized
state on first use. Strategy A: list projects, list a project's files, read one
— enumeration is real here, not assumed, so prior screens can be registered
rather than regenerated. Strategy B: drive with design.md + tokens.json + the
screen brief; capture the artifact locator it yields. It is design-system
aware — prefer conforming to an existing system there over restating tokens in
every brief. On first use, list its exposed tools and note them in the project
docs as the working contract.

## Figma Make

**Same server and auth as Figma — nothing extra to connect** — but a much
narrower surface. Make files (`/make/` in the URL) hold generated code, and
**only the design-context fetch accepts them**: no variables, no structure
metadata, no screenshot.

- **Strategy A applies** to prior generations: the `/make/` URL is the locator,
  and the single context fetch is the read. Its node target is fixed for Make
  files — check the tool description rather than guessing.
- **Strategy B does not.** No write tool accepts a `/make/` file, and new-file
  creation offers no Make type — you cannot generate *into* Make. Generate into
  a Figma **design** file instead, or fall to Strategy C for that screen. Say
  which; don't let a screen silently go unbuilt.

Outputs carry an implicit system, so conformance-check firmly against
design.md — there are no published variables to check against.

## Open Design

Stub — refine as usage patterns emerge. Apply the generic protocol: discover
capabilities first, classify, proceed.

## Unlisted / future tools

Apply the generic protocol. If a tool becomes recurrent, add a section above
recording only what's durable: which capabilities it has, how matching works,
what its locators look like, fidelity quirks — never API minutiae that rot.
