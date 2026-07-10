# BSV Unified Identity — Executive Summary
### Private, Verifiable, Unlinkable KYC, from a free passport scan to eIDAS

**Status:** v0.1 (companion to the full standards proposal and technical white paper)
**Editors:** Siggi (BSV Association); additional editors TBD

---

## The breakthrough, in one picture

Digital identity forces a choice no one should have to make. Either you prove who you are — and hand a copy of your documents to every service, which stores them, leaks them, and tracks you across the web — or you stay private and prove nothing a counterparty can actually trust. KYC makes it worse: the more thoroughly you are verified, the more widely you are exposed.

This proposal breaks that trade-off. A person proves they are a **real, current, uniquely-identified human who meets a stated condition** — over 18, EU-resident, KYC'd to a given level — **without revealing who they are**, and presents a **different identifier to every service**, so their activity cannot be joined up across services even if those services pool their data.

![One person, a different identifier per service](diagrams/exec-figure-4-scoped-pseudonyms.svg)

That is the whole idea: **private, verifiable, and unlinkable at the same time.** Existing systems deliver at most two of the three.

## Why it matters now

Three forces converge. **Regulation:** eIDAS 2.0 obliges every EU member state to make a digital identity wallet available by late December 2026, with mandatory acceptance by regulated-sector relying parties and large platforms following about a year later — and with most member states currently behind schedule, the practical window for a standards-aligned entrant is widening, not closing. **AI:** as generated content and bots erode trust, proof that a counterparty is a unique real human becomes infrastructure. **Privacy fatigue:** breach after breach has made centralized identity stores a recognized liability, not an asset.

The gap none of the mainstream options closes is **unlinkability**. The EU's own baseline credential formats can be correlated across colluding verifiers. The EU has now written zero-knowledge requirements into its technical framework — but their deployment is deferred to *after* the December 2026 launch, layered onto credentials already issued in the linkable formats. So the launch ecosystem is linkable, and this design's edge is being unlinkable by default from day one. That gap is precisely where it leads.

## How it works, briefly

The design **reuses existing standards rather than inventing a new stack** — a registered, blockchain-native decentralized identifier (`did:bsv`), W3C Verifiable Credentials, the OpenID and ISO credential protocols the EU mandates, and BSV's established key and certificate primitives — and binds them with a thin new layer plus zero-knowledge proofs.

Three values do the work. A **secret** held only in the user's wallet generates a *different* pseudonym for every service. A separate, **passport-derived uniqueness anchor** lets the system enforce one-person-one-account without that anchor ever being a secret. A **zero-knowledge proof** ties a presentation to a valid credential and proves the requested facts — without disclosing the underlying identity, the credential, or any extra attribute.

Onboarding is **tiered and starts free**: a person scans their own passport's chip with a phone, the wallet verifies it against the issuing country's cryptography, and that becomes a usable, privacy-preserving identity with no third party involved. Higher tiers add an accountable verifier and, ultimately, government-grade assurance.

## Why this approach wins

| System | Verifiable KYC | Private (selective disclosure) | Unlinkable across services |
|---|---|---|---|
| Traditional KYC | Yes | No | No |
| EU Digital Identity Wallet (baseline formats) | Yes | Partial | Partial — only via batch issuance |
| Microsoft Entra Verified ID | Yes | Partial | No |
| SpruceID (mDL / state wallets) | Yes | Partial | No |
| Dock / Truvera | Yes | Yes | Partial (BBS+) |
| World ID | Personhood only — no attribute KYC | Partial | Yes (nullifiers) |
| Privado ID / Billions (ex-Polygon ID) | Yes | Yes | Yes |
| **This proposal** | **Yes (Tiers 1–3)** | **Yes** | **Yes (zero-knowledge path)** |

Read honestly: **World ID** proves you are a unique human but learns nothing about who you are — it cannot do attribute KYC (name, age, residency), and it depends on dedicated iris-scanning hardware. The **EU wallet** has unmatched regulatory force but ships linkable baseline formats. The closest peer is **Privado ID / Billions** (the former Polygon ID team), which also does passport-based zero-knowledge identity — but on an Ethereum-style ecosystem rather than a high-throughput public UTXO ledger, and without a defined path into eIDAS notification.

This proposal's distinctive combination is all four at once: **verifiable government-attribute KYC, proof-of-unique-personhood, unlinkability, and a concrete eIDAS path** — anchored on a low-fee, high-throughput public ledger, entered through a **free** self-serve passport scan. (The unlinkability advantage is realized on the zero-knowledge path and holds from day one; the EU has written zero-knowledge requirements into its framework but defers them to after the December 2026 launch, so its baseline-format presentations stay linkable in the meantime — and those same EU requirements make this design a natural conformant zero-knowledge layer for EU-issued credentials, not just a competitor.)

## The regulatory opportunity

The eIDAS alignment is staged, and each stage is independently useful.

![eIDAS maturity path](diagrams/exec-figure-5-eidas-roadmap.svg)

Stage 1 delivers value immediately and depends on no one's permission. Stage 2 brings regulated KYC through a qualified provider partnership. Stage 3 — a government-recognized scheme — is a long-horizon, politically-gated destination, not a near-term claim. (National wallets are due by late December 2026, with relying-party acceptance obligations about a year later; real-world rollout is running behind, into 2027.)

## Honest about the limits

This document does not trade in blockchain magic.

- **The free tier is bootstrap-grade, not government KYC.** A self-read passport proves the *document* is genuine; it does not prove the person holding the phone is its rightful owner. It resists casual fraud and bot armies, not a determined impostor with a borrowed or stolen passport. Accountable verification is exactly what the higher tiers add.
- **Cryptography is not network anonymity.** Unlinkable credentials do not hide your IP address or device. Real privacy requires network-level measures too, and the design says so.
- **The heaviest privacy proofs are real engineering.** Proving a passport's authenticity in zero knowledge is feasible on phones today (several production systems do it) but is computationally heavy; the design amortizes it into a one-time enrolment so everyday use stays fast.
- **Stage 3 carries a strategic, not just technical, risk:** whether EU regulators will anchor a notified scheme on a public, permissionless ledger at all. This is now evidenced, not hypothetical — at least one early national wallet pilot was dropped partly because a blockchain-and-zero-knowledge stack did not meet secure-hardware requirements, and the EU is expected to admit such cryptography only cautiously and late. The answer here is on-device proving, secure-element keys, and only blinded data on-chain; but Stages 1–2 are deliberately built to deliver value without depending on that answer.

## Status and what's next

The architecture is specified in full (a proposed standard plus an eIDAS interoperability profile) and a companion technical white paper. The near-term path: publish the standard, build the open reference implementation and conformance tests, prove out the free passport tier end-to-end, and engage a qualified trust provider for the regulated stage. The strongest near-term wedge is the **free, private, unique-per-person passport tier** — useful on day one for age-gating, Sybil-resistant accounts, and bot-resistant services, with a clean upgrade path to regulated KYC and, eventually, government identity.

*For the architecture and rationale, see the technical white paper; for normative detail, the full standards proposal.*
