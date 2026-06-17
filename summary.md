# BSV Unified Identity — Executive Summary
### Private, Verifiable, Unlinkable KYC, from a free passport scan to eIDAS

**Status:** v0.1 (companion to the full standards proposal and technical white paper)
**Editors:** Siggi (BSV Association); additional editors TBD

---

## The breakthrough, in one picture

Digital identity forces a choice no one should have to make. Either you prove who you are — and hand a copy of your documents to every service, which stores them, leaks them, and tracks you across the web — or you stay private and prove nothing a counterparty can actually trust. KYC makes it worse: the more thoroughly you are verified, the more widely you are exposed.

This proposal breaks that trade-off. A person proves they are a **real, current, uniquely-identified human who meets a stated condition** — over 18, EU-resident, KYC'd to a given level — **without revealing who they are**, and presents a **different identifier to every service**, so their activity cannot be joined up across services even if those services pool their data. (Two precise qualifiers, expanded under *Honest about the limits*: "uniquely-identified" means **one account per identity document**, and the cross-service unlinkability holds on the **non-custodial, zero-knowledge path**.)

<svg viewBox="0 0 720 348" width="720" height="348" style="max-width:100%;height:auto" xmlns="http://www.w3.org/2000/svg" font-family="ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif">
  <defs><marker id="e4arr" viewBox="0 0 10 10" refX="5" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 z" fill="#64748b"/></marker></defs>
  <rect x="0" y="0" width="720" height="348" rx="10" fill="#ffffff"/>
  <text x="24" y="26" font-size="15" font-weight="700" fill="#0f172a">One person, a different identifier per service — all verifiable, none linkable</text>
  <rect x="28" y="48" width="232" height="52" rx="8" fill="#e0f2fe" stroke="#0284c7"/>
  <text x="144" y="70" text-anchor="middle" font-size="12.5" font-weight="700" fill="#075985">Attestation source</text>
  <text x="144" y="88" text-anchor="middle" font-size="11" fill="#0c4a6e">passport (free) or accredited issuer</text>
  <line x1="144" y1="100" x2="144" y2="126" stroke="#64748b" stroke-width="1.5" marker-end="url(#e4arr)"/>
  <rect x="28" y="128" width="232" height="52" rx="8" fill="#dbeafe" stroke="#2563eb" stroke-width="2.5"/>
  <text x="144" y="150" text-anchor="middle" font-size="12.5" font-weight="700" fill="#1e3a8a">Personhood commitment</text>
  <text x="144" y="168" text-anchor="middle" font-size="11" fill="#1e40af">secret s · uniqueness anchor n</text>
  <line x1="144" y1="180" x2="144" y2="206" stroke="#64748b" stroke-width="1.5" marker-end="url(#e4arr)"/>
  <rect x="28" y="208" width="232" height="52" rx="8" fill="#ccfbf1" stroke="#0d9488"/>
  <text x="144" y="230" text-anchor="middle" font-size="12.5" font-weight="700" fill="#115e59">Credential + ZK proof</text>
  <text x="144" y="248" text-anchor="middle" font-size="11" fill="#134e4a">reveals only what is asked</text>
  <rect x="452" y="52" width="244" height="240" rx="10" fill="none" stroke="#ef4444" stroke-dasharray="6 4"/>
  <text x="574" y="70" text-anchor="middle" font-size="11.5" fill="#b91c1c">even if these services collude…</text>
  <rect x="470" y="84" width="208" height="46" rx="8" fill="#f8fafc" stroke="#94a3b8"/>
  <text x="574" y="112" text-anchor="middle" font-size="13" fill="#334155">Service A  →  <tspan font-weight="700" fill="#2563eb">pid_A</tspan></text>
  <rect x="470" y="156" width="208" height="46" rx="8" fill="#f8fafc" stroke="#94a3b8"/>
  <text x="574" y="184" text-anchor="middle" font-size="13" fill="#334155">Service B  →  <tspan font-weight="700" fill="#2563eb">pid_B</tspan></text>
  <rect x="470" y="228" width="208" height="46" rx="8" fill="#f8fafc" stroke="#94a3b8"/>
  <text x="574" y="256" text-anchor="middle" font-size="13" fill="#334155">Service C  →  <tspan font-weight="700" fill="#2563eb">pid_C</tspan></text>
  <path d="M260,234 C360,234 360,107 466,107" fill="none" stroke="#64748b" stroke-width="1.5" marker-end="url(#e4arr)"/>
  <path d="M260,234 C360,234 360,179 466,179" fill="none" stroke="#64748b" stroke-width="1.5" marker-end="url(#e4arr)"/>
  <path d="M260,234 C360,234 360,251 466,251" fill="none" stroke="#64748b" stroke-width="1.5" marker-end="url(#e4arr)"/>
  <text x="360" y="324" text-anchor="middle" font-size="12" fill="#475569">Every presentation is verifiable; the pseudonyms stay unlinkable across services.</text>
</svg>

That is the whole idea: **private, verifiable, and unlinkable at the same time.** Existing systems deliver at most two of the three.

## Why it matters now

Three forces converge. **Regulation:** eIDAS 2.0 obliges every EU member state to offer a digital identity wallet by the end of 2026, with relying-party obligations following — a rare, dated window in which a standards-aligned entrant can interoperate rather than fight the incumbent. **AI:** as generated content and bots erode trust, proof that a counterparty is a unique real human becomes infrastructure. **Privacy fatigue:** breach after breach has made centralized identity stores a recognized liability, not an asset.

The gap none of the mainstream options closes is **unlinkability**. The EU's own baseline credential formats can be correlated across colluding verifiers; the framework calls for privacy-preserving proofs (zero-knowledge) but has not yet standardized them. That gap is precisely where this design leads.

## How it works, briefly

The design **reuses existing standards rather than inventing a new stack** — a registered, blockchain-native decentralized identifier (`did:bsv`), W3C Verifiable Credentials, the OpenID and ISO credential protocols the EU mandates, and BSV's established key and certificate primitives — and binds them with a thin new layer plus zero-knowledge proofs.

Three values do the work. A **secret** held only in the user's wallet generates a *different* pseudonym for every service. A separate, **passport-derived uniqueness anchor** lets the system enforce one account per identity document without that anchor ever being a secret. A **zero-knowledge proof** ties a presentation to a valid credential and proves the requested facts — without disclosing the underlying identity, the credential, or any extra attribute.

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

This proposal's distinctive combination is all four at once: **verifiable government-attribute KYC, proof-of-unique-personhood, unlinkability, and a concrete eIDAS path** — anchored on a low-fee, high-throughput public ledger, entered through a **free** self-serve passport scan. (The unlinkability advantage is realized on the zero-knowledge path; presentations made in the EU's baseline formats inherit those formats' linkability until the EU's own zero-knowledge track matures.)

## The regulatory opportunity

The eIDAS alignment is staged, and each stage is independently useful.

<svg viewBox="0 0 760 270" width="760" height="270" style="max-width:100%;height:auto" xmlns="http://www.w3.org/2000/svg" font-family="ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif">
  <defs><marker id="e5arr" viewBox="0 0 10 10" refX="5" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 z" fill="#64748b"/></marker></defs>
  <rect x="0" y="0" width="760" height="270" rx="10" fill="#ffffff"/>
  <text x="24" y="26" font-size="15" font-weight="700" fill="#0f172a">eIDAS maturity path</text>
  <rect x="24" y="96" width="216" height="108" rx="8" fill="#e0f2fe" stroke="#0284c7"/>
  <text x="132" y="120" text-anchor="middle" font-size="13" font-weight="700" fill="#075985">Stage 1 · interop bridge</text>
  <text x="132" y="142" text-anchor="middle" font-size="11" fill="#0c4a6e">free passport tier</text>
  <text x="132" y="158" text-anchor="middle" font-size="11" fill="#0c4a6e">accept EU wallet credentials</text>
  <text x="132" y="188" text-anchor="middle" font-size="10.5" fill="#64748b">low cost · ship first</text>
  <line x1="240" y1="150" x2="264" y2="150" stroke="#64748b" stroke-width="1.5" marker-end="url(#e5arr)"/>
  <rect x="266" y="74" width="216" height="130" rx="8" fill="#dbeafe" stroke="#2563eb"/>
  <text x="374" y="98" text-anchor="middle" font-size="13" font-weight="700" fill="#1e3a8a">Stage 2 · qualified</text>
  <text x="374" y="120" text-anchor="middle" font-size="11" fill="#1e40af">issuer-verified KYC</text>
  <text x="374" y="136" text-anchor="middle" font-size="11" fill="#1e40af">via a regulated provider</text>
  <text x="374" y="152" text-anchor="middle" font-size="11" fill="#1e40af">EU Trusted Lists</text>
  <text x="374" y="188" text-anchor="middle" font-size="10.5" fill="#64748b">needs: qTSP partner</text>
  <line x1="482" y1="139" x2="506" y2="139" stroke="#64748b" stroke-width="1.5" marker-end="url(#e5arr)"/>
  <rect x="508" y="52" width="228" height="152" rx="8" fill="#c7d2fe" stroke="#4338ca"/>
  <text x="622" y="76" text-anchor="middle" font-size="13" font-weight="700" fill="#312e81">Stage 3 · notified eID</text>
  <text x="622" y="98" text-anchor="middle" font-size="11" fill="#3730a3">government-grade (LoA High)</text>
  <text x="622" y="114" text-anchor="middle" font-size="11" fill="#3730a3">recognized cross-border</text>
  <text x="622" y="130" text-anchor="middle" font-size="11" fill="#3730a3">EU wallet certification</text>
  <text x="622" y="166" text-anchor="middle" font-size="10.5" fill="#64748b">needs: certification +</text>
  <text x="622" y="180" text-anchor="middle" font-size="10.5" fill="#64748b">member-state sponsorship</text>
  <text x="380" y="238" text-anchor="middle" font-size="12" fill="#475569">Most adoption begins at Stage 1; Stage 3 is the destination, not the entry point.</text>
</svg>

Stage 1 delivers value immediately and depends on no one's permission. Stage 2 brings regulated KYC through a qualified provider partnership. Stage 3 — a government-recognized scheme — is a long-horizon, politically-gated destination, not a near-term claim.

## Honest about the limits

This document does not trade in blockchain magic.

- **The free tier is bootstrap-grade, not government KYC.** A self-read passport proves the *document* is genuine; it does not prove the person holding the phone is its rightful owner. It resists casual fraud and bot armies, not a determined impostor with a borrowed or stolen passport. Accountable verification is exactly what the higher tiers add.
- **"Unique" means one account per identity document, not one per person.** Uniqueness is anchored to the passport document, so a renewed passport or a second lawful document (e.g. dual citizenship) yields a second valid identity. The free tier delivers strong Sybil resistance, not provable one-human-one-account. Global de-duplication also has a privacy cost: a holder is linkable *within* the de-duplication set, the unavoidable price of proving uniqueness across the whole population.
- **Unlinkability assumes a non-custodial wallet.** A custodial wallet can correlate a holder across services internally even when the on-the-wire identifiers stay pairwise-distinct. The cross-service unlinkability claim holds only where the user controls their own keys.
- **Cryptography is not network anonymity.** Unlinkable credentials do not hide your IP address or device. Real privacy requires network-level measures too, and the design says so.
- **The heaviest privacy proofs are real engineering.** Proving a passport's authenticity in zero knowledge is feasible on phones today (several production systems do it) but is computationally heavy; the design amortizes it into a one-time enrolment so everyday use stays fast.
- **Stage 3 carries a strategic, not just technical, risk:** whether EU regulators will anchor a notified scheme on a public, permissionless ledger at all. Stages 1–2 are deliberately built to deliver value without depending on that answer.

## Status and what's next

The architecture is specified in full (a proposed standard plus an eIDAS interoperability profile) and a companion technical white paper. The near-term path: publish the standard, build the open reference implementation and conformance tests, prove out the free passport tier end-to-end, and engage a qualified trust provider for the regulated stage. The strongest near-term wedge is the **free, private, Sybil-resistant passport tier (one account per document)** — useful on day one for age-gating, Sybil-resistant accounts, and bot-resistant services, with a clean upgrade path to regulated KYC and, eventually, government identity.

*For the architecture and rationale, see the technical white paper; for normative detail, the full standards proposal.*
