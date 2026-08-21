# BSV Unified Identity

**Private, verifiable, unlinkable KYC — from a free passport scan to eIDAS.**

This repository holds the standards proposal and supporting papers for a unified
identity layer on the BSV blockchain. The goal is KYC that is **private but
verifiable**: a holder proves they are a real, current, sufficiently-assured human
who meets a relying party's condition — over 18, EU-resident, KYC'd to a given
level — *without revealing who they are*, and presents a **different identifier to
every service** so their activity cannot be correlated across services.

> **Status:** v0.2 — draft for discussion. Not yet a ratified BRC or eIDAS profile.
> v0.2 responds to two external review rounds: uniqueness moved from presentation-time
> nullifiers to an enrolment registry (tags off-chain per the EDPB blockchain guidelines,
> full state machine in Appendix F), the biometric input dropped from the uniqueness anchor,
> Tier-1 enrolment specified normatively, wallet-side scope derivation, a root-secret
> compromise path (s-migration), the corrected EUDI format baseline (ISO 18013-5 + W3C
> VCDM 1.1 in the binding acts), the AML scope carve-out, and the delegated-CDD-custody
> profile. Uniqueness claims are stated per-document, which is what the cryptography proves.

## Documents

Read in increasing depth:

| File | Audience | What it covers |
|---|---|---|
| [`summary.md`](summary.md) | Executives, non-technical | The idea, why now, the regulatory path, and the limits — in one sitting. |
| [`technical-whitepaper.md`](technical-whitepaper.md) | Engineers, architects | The architecture and cryptographic rationale: the `(s, n, pid)` model, KYC tiers, the zero-knowledge toolbox, and the threat model. |
| [`whitepaper.md`](whitepaper.md) | Implementers, standards reviewers | The normative proposal (RFC 2119 MUST/SHOULD): identity model, key derivation, tiers, presentation, revocation, the eIDAS interoperability profile, security analysis, and appendices with concrete constructions. |
| [`zk-proofs-and-poc.md`](zk-proofs-and-poc.md) | ZK engineers | The zero-knowledge design and buildable proof-of-concept: the exact presentation statement, circuit, TS-prover / Go-verifier split, known-answer vectors, and the enrolment registry on BSV. |

## The core idea

Three values do the work, kept deliberately separate:

- **`s` — presentation secret.** High-entropy, wallet-held, never disclosed. Generates a
  *different* pseudonym for every relying party and provides holder binding.
- **`n` — personhood nullifier (the "uniKey").** A deterministic, one-way value derived
  from passport chip data (document number, MRZ, SOD hash — no biometrics). Anchors
  **per-document** uniqueness (one account per identity document — not provably one per
  natural person), enforced once at enrolment in an anchored registry. It is *not* a
  secret, so nothing `n`-derived is ever shown to a service.
- **`pid` — scoped pseudonym.** `pid = PRF(s, scope)` — what a relying party sees and stores:
  stable for that party, uncorrelated across parties.

A zero-knowledge proof ties a presentation to a valid credential and proves the requested
facts without disclosing the underlying identity, the credential, or any extra attribute.

## Onboarding tiers

- **Tier 0** — bare identity key, no document.
- **Tier 1** — free self-read passport: the holder scans their own chip; the wallet verifies
  it against the issuing state's PKI (ICAO 9303). Self-sovereign, no third party.
- **Tier 2** — accountable issuer / qualified trust service provider with real identity proofing.
- **Tier 3** — in-person (or supervised-equivalent) proofing, toward government-grade assurance.

## What this is honest about

The proposal states its limits plainly, and so does this README:

- **Uniqueness is per-document, not per-person.** A renewed passport or a second lawful
  document yields a second valid identity. The free tier gives strong Sybil resistance, not
  provable one-human-one-account.
- **Unlinkability is cryptographic and conditional.** It holds on the non-custodial,
  zero-knowledge presentation path. It does **not** extend to a custodial wallet or the
  network layer (IP/timing/device); and a party with both a passport's chip data and query
  access to the (off-chain, rate-limited) uniqueness registry can test whether that document
  has *enrolled* — the bounded cost of attester-free uniqueness.
- **Unlinkable KYC is not AML KYC.** Where customer-due-diligence law applies, the business
  must identify the customer and retain the record; this system then offers verified,
  minimized disclosure, not anonymity — or, under the optional delegated-custody profile
  (spec §10.10), a regulated custodian holds the record and the business holds only a proof
  of diligence plus a lawful retrieval right, so it stores no plaintext PII at all.
- **The free tier is bootstrap-grade.** A self-read passport proves the document is genuine,
  not that the person holding the phone is its rightful owner.
- **The heaviest zero-knowledge proofs are real engineering**, and the strongest privacy
  guarantees (Layer C/D) are a roadmap capability, not the first shipping milestone.

## Built on existing standards

`did:bsv`, W3C Verifiable Credentials, OpenID4VP/SIOP and ISO/IEC 18013-5 presentation,
BRC-42/43 key derivation, BRC-103 authentication, BRC-52/53 keyrings, SD-JWT VC, and a
pluggable zero-knowledge toolbox — bound into one layer rather than reinvented.

## Building the PDF and EPUB editions

`tools/build-docs.sh` regenerates both formats from the markdown into `pdf/` and
`epub/`. It rebuilds only what changed, keying on a SHA-256 of the source plus
every build input — including `diagrams/`, which the papers embed — so a fresh
clone or a stray `touch` does not trigger work while a real edit always does.

```sh
tools/build-docs.sh                 # rebuild whatever changed
tools/build-docs.sh --all           # rebuild everything
tools/build-docs.sh --pdf           # one format only (or --epub)
tools/build-docs.sh --watch         # rebuild on save
tools/build-docs.sh --check         # exit 1 if anything is stale (CI)
tools/build-docs.sh --install-hook  # rebuild and stage on every commit
```

Requires `pandoc` and `typst` (`brew install pandoc typst`), plus `mmdc`
(`npm i -g @mermaid-js/mermaid-cli`) for the documents carrying a ` ```mermaid `
block — currently only `zk-proofs-and-poc.md`; the others build without it. The
PDF path runs markdown through pandoc to typst and compiles with
`tools/template.typ`; the EPUB path is pandoc's epub3 writer with
`tools/epub.css`.

Mermaid blocks are rendered to SVG by `tools/mermaid.lua` and substituted for
the source, so a diagram GitHub renders natively is a diagram in both editions.
Renders are content-addressed by the SHA-1 of the block and cached under
`tools/.build-cache/mermaid/`, so an unchanged diagram never pays for another
headless Chromium launch. `tools/mermaid.json` disables mermaid's HTML labels:
mermaid 11 puts node text in `<foreignObject>`, which typst renders as blank
boxes. The title, the
optional subtitle beneath it, and the `**Status:**` / `**Editors:**` block are
lifted out of each document's front matter into the title block and the EPUB
metadata; the title block shows only the version, the part of the status line
before the first em dash.

### Fonts and the glyph guard

Typst falls back across every installed font *silently*, so a missing glyph
produces no warning, only a wrong-looking character on machines without
whatever font it borrowed. These papers use 19 non-ASCII characters, all
covered by the two fonts typst ships and the template targets: Libertinus Serif
for text, DejaVu Sans Mono for code. `tools/check-glyphs.sh` fails when a
document introduces a character that has not been verified by eye:

```sh
tools/check-glyphs.sh           # fail on unverified characters
tools/check-glyphs.sh --sheet   # render a coverage sheet to inspect
tools/check-glyphs.sh --accept  # record the current inventory as verified
```

## Contributing

This is an early draft intended to attract review. Issues and pull requests against the
documents are welcome; substantive cryptographic and normative feedback especially so.

---

*The `.md` files are the source of record. The PDF and EPUB editions in `pdf/` and `epub/`
are generated from them by `tools/build-docs.sh` (see “Building the PDF and EPUB
editions” above).*
