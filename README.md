# BSV Unified Identity

**Private, verifiable, unlinkable KYC — from a free passport scan to eIDAS.**

This repository holds the standards proposal and supporting papers for a unified
identity layer on the BSV blockchain. The goal is KYC that is **private but
verifiable**: a holder proves they are a real, current, sufficiently-assured human
who meets a relying party's condition — over 18, EU-resident, KYC'd to a given
level — *without revealing who they are*, and presents a **different identifier to
every service** so their activity cannot be correlated across services.

> **Status:** v0.2 — draft for discussion. Not yet a ratified BRC or eIDAS profile.
> v0.2 responds to external review: uniqueness moved from presentation-time nullifiers to an
> anchored enrolment registry, the biometric input dropped from the uniqueness anchor, Tier-1
> enrolment specified normatively, and the AML scope carve-out added.

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
  network layer (IP/timing/device); and anyone who has read a passport's chip can test
  whether that document has *enrolled* — the bounded cost of the public uniqueness registry.
- **Unlinkable KYC is not AML KYC.** Where customer-due-diligence law applies, the business
  must identify the customer and retain the record; this system then offers verified,
  minimized disclosure, not anonymity.
- **The free tier is bootstrap-grade.** A self-read passport proves the document is genuine,
  not that the person holding the phone is its rightful owner.
- **The heaviest zero-knowledge proofs are real engineering**, and the strongest privacy
  guarantees (Layer C/D) are a roadmap capability, not the first shipping milestone.

## Built on existing standards

`did:bsv`, W3C Verifiable Credentials, OpenID4VP/SIOP and ISO/IEC 18013-5 presentation,
BRC-42/43 key derivation, BRC-103 authentication, BRC-52/53 keyrings, SD-JWT VC, and a
pluggable zero-knowledge toolbox — bound into one layer rather than reinvented.

## Contributing

This is an early draft intended to attract review. Issues and pull requests against the
documents are welcome; substantive cryptographic and normative feedback especially so.

---

*The `.md` files are the source of record. PDF renderings are generated artifacts and are
not committed (see `.gitignore`).*
