# Design-Tool Integrations

Per-tool guidance for Mode 4 (connected design tool). Structure: a **generic
protocol that always works standalone**, then per-tool sections that refine it.
A missing tool section never blocks the mode — apply the generic protocol.
Sections here record *what to fetch and how it maps to our token/component
structure*, not API minutiae (those rot; the MCP tool descriptions are the
authority for call shapes at run time).

## Detecting and connecting a tool

Mode 4 starts by finding out what's actually reachable. **Three states, not
two** — treat them differently:

1. **Connected and authorized** — proceed.
2. **Configured but unauthorized** — the server is registered and its tools are
   listed, but calls fail on auth. Looks identical to "connected" until you call
   something. Prove it with one cheap identity call (`whoami` for Figma,
   `list_projects` for Claude Design) before promising the user a fetch.
3. **Absent** — no tools for that server at all.

**Detect by capability, not by name.** Inspect the tools available to you in
this session — however your runtime exposes them — and look for ones that read
design data: variables or tokens, styles, components, screens/frames, design
systems, project or file listings. Runtimes name and namespace MCP tools
differently, and a server's registered name often differs from the product's
(a Figma connection may be registered under any label), so **never gate on an
exact server or tool name**. Classify what's actually there; if you can't tell
whether a tool is a design tool, its own description will say.

**Connection paths** (current shapes — **verify against live docs before
instructing the user; these drift, and reciting a stale command wastes their
time**):

- **Figma** — remote MCP server at `https://mcp.figma.com/mcp`, then authorize
  via the runtime's MCP panel (OAuth). Covers Figma Design *and* Figma Make.
- **Claude Design** — server `claude-design` at
  `https://api.anthropic.com/v1/design/mcp`, added explicitly, then
  authenticated with **`/design-login`** — a *separate* step from a normal
  login. A plain login token carries no Claude Design access, so a freshly
  added server commonly sits in state 2 above.

**Nothing connected but Mode 4 wanted: say so, never silently downgrade.** Name
the tool the project needs, offer to walk the user through connecting it, and
offer another mode (research / images / design file) as the no-blocker path.
Record which was chosen — a deferred integration is a legitimate outcome; a
quiet substitution is not.

## Generic protocol (any tool)

1. **Discover** what the connected tool exposes (list its MCP tools; look for
   variables/tokens, styles, components, and screen/frame access).
2. **Fetch and map**:
   - variables / design tokens → our token set (color, spacing, radius, size)
   - text styles → type scale (family, sizes, weights, line-heights)
   - color / effect styles → palette and elevation scale
   - published components (+ variants) → component inventory with states
   - representative frames/screens → layout & grid rules; early screen hints
3. **Normalize** into semantic role-based tokens (the tool may use raw names;
   assign roles from usage, confirm with the user).
4. **Record fidelity**: values pulled from a tool are exact — say so in
   Provenance; anything the tool doesn't expose goes to Known Gaps.
5. **Play back and confirm** before codifying.

If the tool exposes more than we model (prototypes, auto-layout rules, motion),
note its existence in Known Gaps rather than force-fitting it.

---

## Figma

Connected via the Figma MCP. The high-value fetches, mapped:

- **Variables** (Figma variables incl. modes) → tokens. Figma variable *modes*
  (e.g., light/dark) map to token themes — capture both if present.
- **get_variable_defs** on key nodes → the raw token values behind a design.
- **Styles** (text styles, color styles, effect styles) → type scale, palette,
  elevation.
- **Published library components** (and their variant properties) → component
  inventory: each Figma variant axis (size, state, kind) maps to our
  variant/state spec.
- **Screenshots / design context of key frames** → layout & grid rules; use
  sparingly, values from variables/styles beat pixel inspection.

Practical notes: prefer *published library* styles/components over ad-hoc local
ones (they represent the intended system); if the file has no variables and
only raw fills, treat it closer to Mode 2 fidelity and say so in Provenance.

## Claude Design

**Design systems are first-class here** — that's what makes it a strong Mode 4
source rather than a generator you screenshot. The high-value fetches:

- **The design system list** → the token source. One system is marked default;
  that's what a fresh project uses. Read it before anything else: it carries
  the palette, type scale and spacing as *values*, not as rendered pixels.
- **Projects and their files** → enumeration. List projects, list a project's
  files, read one — the same ingest path as any other tool, no screenshots
  needed.
- **Rendered previews** → layout and grid confirmation only; values from the
  design system beat inspection, as everywhere.

Fidelity: **`exact`** when the values came from a design system. If the project
has no design system and you are reading generated artifacts instead, it is
`mapped` — say so in Provenance rather than claiming precision you inferred.

A design system imported from a repo or codebase is *already* a round-trip of
someone's real implementation; prefer it over re-deriving from screens.

**The built-in design skill is not a substitute.** A runtime may offer canvas
creation without the MCP server connected; that path publishes artifacts but
exposes none of the fetches above. If the goal is pulling a system into
`tokens.json`, the MCP server is the requirement — say so plainly.

## Figma Make

**Same server and auth as Figma — nothing extra to connect.** What differs is
the capability surface, and it differs sharply: Make files (their URLs carry a
`/make/` segment) are **generated code, not a variable-backed design file**.

- **Variables/token extraction does not work on Make files.** Neither does
  structure metadata or screenshot capture — those tools reject `/make/` URLs
  outright. Do not plan a fetch around them.
- **One call works**: the design-context fetch, which returns the generated
  code (its node target is fixed for Make files — check the tool description
  rather than guessing a node id).
- **Tokens are therefore *derived from code*, not read from a system.** Pull
  the colors, spacing and type off the returned source and normalize them like
  any extraction.

Fidelity: **`mapped`, never `exact`** — the values were inferred from one
generated artifact, not published by a design system. Recording `exact` here
would claim a precision that isn't there, and `ui-design` reads that field to
decide how hard to lean on the system.

Known Gaps will be wider than usual: states, interaction and responsive
behavior that the single fetch didn't reveal. Say which, rather than inventing
them. If the project also has a real Figma *design* file, prefer it — same
connection, far better fetches.

## Open Design

Stub — refine as usage patterns emerge. Apply the generic protocol.

## Unlisted tools

Apply the generic protocol. If a tool proves recurrent, add a section above:
what it exposes, the mapping, and its fidelity quirks — nothing more.
