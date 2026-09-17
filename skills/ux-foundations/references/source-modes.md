# Source Modes (Acquiring the Design Direction)

Four modes for where the design direction comes from. Everything downstream of
acquisition (tokens, surfaces, outputs) is identical — the mode only changes
how the direction is obtained. Two rules apply to **every** mode:

- **The SRS accessibility/usability NFRs override the source.** If an ingested
  palette fails the contrast bar (e.g., WCAG 2.2 AA per NFR-USE-001), adjust the
  offending tokens and record the adjustment in design.md's provenance section.
  The same applies to touch-target sizes and any compliance constraint.
- **End with a confirmed direction, never an assertion.** Play back the proposed
  palette, type, spacing, and component feel — extraction is approximation,
  ingestion has conflicts, research is a proposal. The user confirms or adjusts
  before anything is codified.

Record in design.md's **Provenance** section: the prose story, plus the
**structured `design_provenance` block — written in every mode** (mode and
fidelity always; `source` populated only in tool mode; see design-md-guide.md
§9) so the mode and source are machine-readable, never prose-only.

---

## Mode 1 — Research (no design source)

The user wants a direction proposed. Ground it, don't invent it:

1. From the SRS: the audience (§2.3), the product's domain and tone (§1.2), and
   any brand constraints (§2.5).
2. Research comparable products and current design-system conventions for this
   domain and audience (web access permitting; otherwise propose from expertise
   and say so). Look for what the audience already trusts — a healthcare portal
   and a gaming site earn trust differently.
3. Propose 1–2 candidate directions, each as: a feeling in two adjectives, a
   palette (with hex), a type pairing, a density/spacing character, and one
   reference product per direction. Let the user pick or blend.
4. Codify the confirmed direction into tokens.

## Mode 2 — Extract from images

Reference images of UI the user wants to match (also the mode for **existing
codebase** extraction — see variants).

**Where images come from (in priority order):**
1. **User-provided always wins** — paths named in the prompt, or images
   pasted/attached into the conversation. If provided, these *are* the set;
   skip detection.
2. **`docs/design-refs/` is the only detection location** — the pipeline's
   convention folder for reference images (`png/jpg/jpeg/webp`). If the folder
   doesn't exist or holds no images, images are treated as not present.
3. **Never scan the wider project** — `public/`, `assets/`, `src/`, etc. hold
   app content (product photos, logos, marketing), not design references;
   hunting there produces false positives.
4. **If this mode is chosen and no images are available**, ask the user to
   supply paths or paste them — don't search further.

1. Read every image. Extract: the palette (sample dominant and accent colors as
   hex), typography character (classify honestly — "geometric sans" is reliable,
   naming the exact font is often not), spacing/density feel, corner radii,
   elevation/shadow character, and recognizable component shapes.
2. **Present the extraction as approximation** with confidence levels. Offer
   corrections ("the font looks like a geometric sans — if you know the actual
   family, tell me").
3. Fill what images can't show (focus states, error states, breakpoints) from
   the elicitation defaults, and list them in Known Gaps.
4. Codify on confirmation.

## Mode 3 — Ingest a design file

An external design.md or similar document (also the mode for **brand
guidelines** — see variants). Assume **no standard schema** — files from
different generators structure things differently; map by meaning, not by
heading.

1. Parse the file. Map its content onto our structure: colors → role-based
   tokens, type specs → type scale, spacing/radius/shadow values → scales,
   component descriptions → component specs with states.
2. **Flag gaps** (states it never defines, no breakpoints, no accessibility
   rules → Known Gaps) and **conflicts** (values that violate the SRS NFRs →
   adjust and record; internal contradictions → ask).
3. Where the file names raw values without roles ("Forest Green #146128"),
   assign the semantic role from its described usage.
4. Play back the normalized system; confirm; codify.

## Mode 4 — Connect a design tool (MCP)

The highest-fidelity source **when the tool publishes values** — variables, or a
design system — because those are read, not approximated. A tool that only
emits generated artifacts (prompt-to-app output) is *not* automatically exact:
its tokens are inferred from code, which is `mapped` fidelity. Check the tool's
section before claiming precision. Generic mapping (works for any tool):

- **Variables/tokens** → our token set (colors, spacing, radii, type sizes).
- **Text styles** → the type scale.
- **Color/effect styles** → palette and elevation.
- **Published components** → the component inventory (names, variants, states).
- **Key frames/screens** → layout/grid rules and, opportunistically, early
  screen-inventory hints.

Detection, the connection paths, and per-tool specifics live in
`references/design-tool-integrations.md` — read it before this mode's first
fetch; it also covers the case where the mode is chosen and nothing is
connected. When the connected tool has no section there, apply the generic
mapping above. Fetch, map, play back (including anything the tool exposes that
we don't model — note it), confirm, codify.

---

## Folded variants

- **Brand guidelines (brand book, often PDF)** → Mode 3 variant. The input is
  brand-level (logo, brand colors, print typography), not a UI system — so this
  is *translation*, not mapping: derive UI tokens honoring the brand (brand
  colors → primary/accent roles; verify contrast; pick a UI-appropriate type
  relative to the brand face). Expect more Known Gaps: brand books rarely define
  states, spacing, or components.
- **Existing codebase** → Mode 2 variant, highest accuracy: read
  `tailwind.config.*`, CSS custom properties, theme files, and component
  directories directly — these are the *actual* values, no approximation.
  Prefer this over screenshots of the same product.
- **Mandated component framework** ("we use Material / Ant / shadcn") → not a
  mode; one elicitation question in any mode. The framework constrains the
  component layer (inventory maps to its components; tokens become its theme
  variables); record it in design.md so agents build with the framework, not
  around it.

## Multi-source situations

The user's explicit mode choice (Phase 1) is the priority resolution. Within the
chosen mode, if a secondary source is also relevant ("extract from these images,
but the logo colors in this brand PDF are canonical"), honor the stated
hierarchy and record it in Provenance. The SRS NFRs sit above all sources,
always.
