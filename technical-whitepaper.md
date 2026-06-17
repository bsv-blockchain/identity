# BSV Unified Identity — Technical White Paper
### Private, Verifiable, Unlinkable KYC — from BRC-100 Wallets to eIDAS

**Status:** v0.1
**Editors:** Siggi (BSV Association); additional editors TBD
**Reading order:** This paper explains the architecture and the reasoning behind it for identity architects and developers evaluating adoption. It is deliberately explanatory, not normative — every "must" here is descriptive. The conformance language (MUST / SHOULD / MAY), the precise data schemas, and the `did:bsv` profile live in the companion *standards proposal*, which this paper references by section as "Spec §N". A five-page executive summary exists separately.

---

## 1. Introduction

Digital identity has a structural defect: it makes you choose between being verifiable and being private, and it almost never lets you be unlinkable. Prove who you are to a service and you typically hand over a document that is then stored, reused, and — across services — correlated into a profile. Stay private and you are reduced to self-asserted claims a counterparty cannot check. KYC sharpens the defect into a paradox: the more rigorously identity is verified, the more widely it leaks.

This work proposes a unified identity layer for the BSV blockchain whose defining property is **KYC that is private, verifiable, and unlinkable at once**. A holder proves they are a real, current, uniquely-identified person who satisfies stated predicates — over 18, EU-resident, assured to some level — without revealing who they are, and presents a *different* identifier to every relying party, so activity cannot be correlated across services even when those services collude.

Two design commitments run through the paper. The first is **reuse over reinvention**: the layer binds primitives that already exist — a registered DID method, W3C Verifiable Credentials, the OpenID and ISO presentation protocols the EU mandates, and BSV's own key and certificate schemes — rather than minting new ones. The second is **honesty about maturity**: the free entry tier is bootstrap-grade, the heaviest zero-knowledge proofs are real engineering, network privacy is a separate problem from cryptographic unlinkability, and government-grade recognition is a long-horizon, politically-gated destination. Each of these is stated plainly where it arises.

## 2. The problem and the regulatory window

Centralized identity fails in three predictable ways. Aggregated identity stores are breach honeypots whose compromise is catastrophic and irreversible. Paper and PDF credentials are forgeable and slow to verify. And because the same identifiers are presented everywhere, ordinary use produces pervasive cross-service correlation as a side effect. KYC compounds all three: establishing who a counterparty is normally requires surrendering a full document to each counterparty, where it is stored and exposed.

A UTXO blockchain is well suited to breaking this. Transaction chains give an immutable, timestamped, double-spend-protected record — exactly what credential issuance, key rotation, and revocation need — verifiable under simplified payment verification (SPV) without trusting a central index. BSV adds low-fee, high-throughput anchoring, and `did:bsv` is already registered and resolvable, so the identifier layer need not be invented.

The timing is set by regulation. eIDAS 2.0 (Regulation (EU) 2024/1183) requires every member state to offer an EU Digital Identity Wallet, with relying-party obligations following; the Architecture and Reference Framework (ARF) and its implementing acts continue to be refined. A standards-aligned identity layer can interoperate with this infrastructure rather than compete with it. The specific gap the work targets is **unlinkability**: the EU's mainstream selective-disclosure format is linkable across colluding verifiers, and the framework calls for — but has not yet standardized — privacy-preserving presentation. Unlinkable-yet-verifiable presentation is therefore the differentiator, not a refinement.

## 3. Architecture at a glance

BSV already carries most of the machinery an identity system needs, but it grew as **two largely separate stacks** that were never designed to interlock. The first is a wallet/attestation stack: per-protocol, per-counterparty key derivation (BRC-42/43), a vendor-neutral wallet-to-application interface (BRC-100), peer-to-peer mutual authentication with selective disclosure (BRC-103), and privacy-centric identity certificates (BRC-52/53). The second is a Verifiable-Credential / DID stack instantiated on BSV by TNG Identity: the registered `did:bsv` method, W3C Verifiable Credentials and Presentations, and OpenID/SIOP reach into the Web2 world. The first stack has excellent keys and authenticated sessions but no resolvable, standards-registered identifier and no native bridge to the VC/eIDAS world; the second has the identifier and the credentials but does not exploit type-42 derivation or keyring selective disclosure and inherits the linkability of mainstream credential formats. Neither, alone, delivers private-verifiable-unlinkable KYC.

The proposal is a single **binding layer** — a new BRC — that sits over both stacks and composes them, with a zero-knowledge toolbox that turns selective disclosure into unlinkable, predicate-bearing, uniqueness-aware presentation. The same identity serves a BSV-native application (over BRC-103) and an eIDAS relying party (over OpenID4VP/SIOP) without re-issuance.

<svg viewBox="0 0 760 424" width="760" height="424" style="max-width:100%;height:auto" xmlns="http://www.w3.org/2000/svg" font-family="ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif">
  <defs><marker id="t1arr" viewBox="0 0 10 10" refX="5" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 z" fill="#64748b"/></marker></defs>
  <rect x="0" y="0" width="760" height="424" rx="10" fill="#ffffff"/>
  <text x="24" y="26" font-size="15" font-weight="700" fill="#0f172a">Figure 1 · Layered architecture</text>
  <rect x="24" y="42" width="712" height="44" rx="8" fill="#ede9fe" stroke="#7c3aed"/>
  <text x="380" y="69" text-anchor="middle" font-size="13" fill="#4c1d95">eIDAS / EUDI interoperability profile · PID · QEAA · Trusted Lists</text>
  <line x1="380" y1="88" x2="380" y2="104" stroke="#64748b" stroke-width="1.5" marker-end="url(#t1arr)"/>
  <rect x="24" y="106" width="712" height="44" rx="8" fill="#fef3c7" stroke="#d97706"/>
  <text x="380" y="133" text-anchor="middle" font-size="13" fill="#92400e">Presentation edge · BRC-103 · OpenID4VP / SIOP</text>
  <line x1="380" y1="152" x2="380" y2="168" stroke="#64748b" stroke-width="1.5" marker-end="url(#t1arr)"/>
  <rect x="24" y="170" width="712" height="56" rx="8" fill="#dbeafe" stroke="#2563eb" stroke-width="2.5"/>
  <text x="380" y="194" text-anchor="middle" font-size="13" font-weight="700" fill="#1e3a8a">Unified binding layer — the new BRC</text>
  <text x="380" y="213" text-anchor="middle" font-size="12" fill="#1e40af">personhood commitment (s, n) · scoped pseudonyms · KYC tiers · ZK toolbox</text>
  <line x1="200" y1="226" x2="200" y2="250" stroke="#64748b" stroke-width="1.5" marker-end="url(#t1arr)"/>
  <line x1="560" y1="226" x2="560" y2="250" stroke="#64748b" stroke-width="1.5" marker-end="url(#t1arr)"/>
  <rect x="24" y="252" width="346" height="62" rx="8" fill="#e0f2fe" stroke="#0284c7"/>
  <text x="197" y="278" text-anchor="middle" font-size="13" font-weight="700" fill="#075985">Wallet / attestation stack</text>
  <text x="197" y="297" text-anchor="middle" font-size="11.5" fill="#0c4a6e">BRC-42/43 · BRC-100 · BRC-103 · BRC-52/53</text>
  <rect x="390" y="252" width="346" height="62" rx="8" fill="#ccfbf1" stroke="#0d9488"/>
  <text x="563" y="278" text-anchor="middle" font-size="13" font-weight="700" fill="#115e59">VC / DID stack</text>
  <text x="563" y="297" text-anchor="middle" font-size="11.5" fill="#134e4a">did:bsv · W3C VC/VP · OpenID4VCI/VP · SIOP</text>
  <line x1="200" y1="314" x2="200" y2="336" stroke="#64748b" stroke-width="1.5" marker-end="url(#t1arr)"/>
  <line x1="560" y1="314" x2="560" y2="336" stroke="#64748b" stroke-width="1.5" marker-end="url(#t1arr)"/>
  <rect x="24" y="338" width="712" height="62" rx="8" fill="#f1f5f9" stroke="#94a3b8"/>
  <text x="380" y="364" text-anchor="middle" font-size="13" font-weight="700" fill="#334155">BSV ledger · UTXO · SPV · overlay / Teranode</text>
  <text x="380" y="383" text-anchor="middle" font-size="11.5" fill="#475569">type-42 key derivation (BRC-42/43) — cryptographic substrate</text>
</svg>

*Figure 1 — The ledger and type-42 derivation form the foundation; the two native stacks are parallel pillars; the binding layer spans both and is where the personhood commitment, pseudonyms, tiers, and zero-knowledge proofs live; the presentation edge speaks both protocol worlds. (Spec §6.)*

## 4. The cryptographic core

The heart of the design is the separation of three values. Collapsing them is the classic mistake that quietly destroys either privacy or uniqueness; keeping them distinct is what lets the system be private, verifiable, and unlinkable simultaneously.

- The **presentation secret `s`** is a high-entropy value derived from the holder's root secret under a dedicated domain separator, held only in the wallet and never disclosed. It is the source of the holder's per-service pseudonyms and of holder binding. Because it is derived from the root secret, the same backup that protects signing keys restores it; because it is independent of any individual signing key, a holder's relationships survive key rotation and recovery unchanged. (Spec §8.4.)
- The **personhood nullifier `n`** — the "uniKey" — is a deterministic, one-way function of the holder's passport identity (document number, machine-readable-zone fields, the facial-image hash). It anchors **per-document** global uniqueness: the same passport always yields the same `n`, even from a fresh wallet, so uniqueness is enforced as *one account per identity document* rather than strictly one per person (renewals and second lawful documents each yield a fresh valid `n` — see §7). Crucially, **`n` is not a secret** — anyone who has read the passport chip can recompute it — so it is used only to derive further one-way, scope-bound nullifiers, and pseudonyms are never derivable from it. Treating a passport-derived value as if it were secret would let anyone who has handled your passport recompute your pseudonyms; that is the failure mode the split exists to prevent. One consequence shaped the design and is worth stating: a global uniqueness nullifier must be deterministic in `n` so two enrolments of the same passport collide for de-duplication — but a value keyed only on the recomputable `n` would itself be recomputable (and brute-forceable, since passport data is low-entropy) by any prior passport-handler. Global, private, brute-force-resistant de-duplication therefore cannot also be registry-free: privatising a shared comparison surface requires a high-entropy secret, which some party other than the wallet must hold. The spec resolves this (§10.7.1) with a blinded, threshold *Uniqueness Registry*: the global nullifier is `gnull = H(domain ‖ POPRF_k(domain; n))`, an oblivious-PRF evaluation under a registry-held secret `k`, gated on a live anti-clone (active/chip-authentication) proof and rate-limited. The registry learns neither `n` nor any identity (the input is blinded); offline brute-force is blocked (the secret `k` is required); recomputation from copied data groups is blocked (a data copier cannot pass active authentication); and the residual exposure narrows to a party holding the physical chip during a live session — the same lost/stolen-passport limit Tier 1 already carries. Per-RP uniqueness (`pid`) needs none of this and stays registry-free; only the optional *global* one-account-per-person guarantee touches the registry.
- The **scoped pseudonym `pid = PRF(s, scope)`** is what a relying party actually sees and stores: stable for that relying party (so one-account-per-person is enforceable locally), uncorrelated with the pseudonym the same person presents anywhere else, and one-way (a `pid` reveals nothing about `s`, the root identity, or any other `pid`).

A presentation proves, in zero knowledge, that the holder knows a secret `s` and a credential `C` such that `C` commits to `s` (and, where uniqueness applies, to `n`); `C` is validly attested at or above the required tier; `C` is current; the requested predicates hold; and `pid = PRF(s, scope)` — revealing only `pid`, the truth of the predicates, and the satisfied tier.

<svg viewBox="0 0 720 348" width="720" height="348" style="max-width:100%;height:auto" xmlns="http://www.w3.org/2000/svg" font-family="ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif">
  <defs><marker id="t4arr" viewBox="0 0 10 10" refX="5" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 z" fill="#64748b"/></marker></defs>
  <rect x="0" y="0" width="720" height="348" rx="10" fill="#ffffff"/>
  <text x="24" y="26" font-size="15" font-weight="700" fill="#0f172a">Figure 4 · One person, a different identifier per service</text>
  <rect x="28" y="48" width="232" height="52" rx="8" fill="#e0f2fe" stroke="#0284c7"/>
  <text x="144" y="70" text-anchor="middle" font-size="12.5" font-weight="700" fill="#075985">Attestation source</text>
  <text x="144" y="88" text-anchor="middle" font-size="11" fill="#0c4a6e">passport (Tier 1) or issuer (Tier 2/3)</text>
  <line x1="144" y1="100" x2="144" y2="126" stroke="#64748b" stroke-width="1.5" marker-end="url(#t4arr)"/>
  <rect x="28" y="128" width="232" height="52" rx="8" fill="#dbeafe" stroke="#2563eb" stroke-width="2.5"/>
  <text x="144" y="150" text-anchor="middle" font-size="12.5" font-weight="700" fill="#1e3a8a">Personhood commitment</text>
  <text x="144" y="168" text-anchor="middle" font-size="11" fill="#1e40af">secret s · nullifier n</text>
  <line x1="144" y1="180" x2="144" y2="206" stroke="#64748b" stroke-width="1.5" marker-end="url(#t4arr)"/>
  <rect x="28" y="208" width="232" height="52" rx="8" fill="#ccfbf1" stroke="#0d9488"/>
  <text x="144" y="230" text-anchor="middle" font-size="12.5" font-weight="700" fill="#115e59">Credential + ZK proof</text>
  <text x="144" y="248" text-anchor="middle" font-size="11" fill="#134e4a">reveals only predicates + pid</text>
  <rect x="452" y="52" width="244" height="240" rx="10" fill="none" stroke="#ef4444" stroke-dasharray="6 4"/>
  <text x="574" y="70" text-anchor="middle" font-size="11.5" fill="#b91c1c">even if these relying parties collude…</text>
  <rect x="470" y="84" width="208" height="46" rx="8" fill="#f8fafc" stroke="#94a3b8"/>
  <text x="574" y="112" text-anchor="middle" font-size="13" fill="#334155">RP A  →  <tspan font-weight="700" fill="#2563eb">pid_A</tspan></text>
  <rect x="470" y="156" width="208" height="46" rx="8" fill="#f8fafc" stroke="#94a3b8"/>
  <text x="574" y="184" text-anchor="middle" font-size="13" fill="#334155">RP B  →  <tspan font-weight="700" fill="#2563eb">pid_B</tspan></text>
  <rect x="470" y="228" width="208" height="46" rx="8" fill="#f8fafc" stroke="#94a3b8"/>
  <text x="574" y="256" text-anchor="middle" font-size="13" fill="#334155">RP C  →  <tspan font-weight="700" fill="#2563eb">pid_C</tspan></text>
  <path d="M260,234 C360,234 360,107 466,107" fill="none" stroke="#64748b" stroke-width="1.5" marker-end="url(#t4arr)"/>
  <path d="M260,234 C360,234 360,179 466,179" fill="none" stroke="#64748b" stroke-width="1.5" marker-end="url(#t4arr)"/>
  <path d="M260,234 C360,234 360,251 466,251" fill="none" stroke="#64748b" stroke-width="1.5" marker-end="url(#t4arr)"/>
  <text x="360" y="324" text-anchor="middle" font-size="12" fill="#475569">Every presentation verifiable; pseudonyms unlinkable across services, even under collusion.</text>
</svg>

*Figure 4 — The core pattern (Spec §10). One commitment, a distinct stable pseudonym per relying party, all verifiable, none correlatable.*

## 5. Identifier and keys

The root identity is a `did:bsv` DID — a UTXO-friendly, W3C-registered method in which creation, key rotation, controller change, and revocation are recorded as transaction-chain operations, each spending the prior state to give a unique, ordered, timestamped history. The method supports a 1-of-2 arrangement under which either the controller or the subject can revoke or rotate; in the self-sovereign default the holder is both. The current DID Document is reconstructed deterministically from the chain and verified under SPV. The reference resolver can load history from a public indexer, but the profile makes BSV-native resolution (overlay services / Teranode) the normative path so resolution does not depend on a single third party. (Spec §7, Appendix B.)

A crucial rule: **the root DID is never presented to relying parties.** It is the control and recovery anchor; relying parties receive only per-RP pseudonyms. This is load-bearing for unlinkability.

All keys are secp256k1. Bitcoin transaction signatures use ECDSA; the BRC-103 authentication handshake uses Schnorr. Keys derive under type-42 (BRC-42/43) from a single root secret: using the relying party as the derivation counterparty yields a distinct signing key per relationship, so signing keys, like pseudonyms, do not correlate across relying parties. Custody is **non-custodial by default**, and the design is candid that this is a place real deployments drift: convenience pressure pushes toward custodial wallets, and a custodial wallet can correlate a holder across relying parties internally even when the on-the-wire identifiers stay pairwise — so a custodial deployment must disclose that, and the non-custodial option must remain available at every tier. Recovery uses mechanisms that do not surrender custody (social recovery, threshold/MPC shares, hardware backup), expressed as controller-authorized key rotations. Optionally, a FIDO2/WebAuthn authenticator can gate access to the secure element holding the keys, raising the authenticator-assurance level without changing the identity tier. (Spec §8.)

## 6. Identity model

The model has three levels. The **root personhood identity** is one `did:bsv` per person, carrying the personhood commitment and never presented directly. **Per-RP pairwise identifiers** are the scoped pseudonym plus a per-RP presentation key — what relying parties see and store. **Personas** are optional context identities (professional versus personal), each able to hold its own credentials, optionally provable as sharing the same personhood commitment when uniqueness is required.

Two properties hold together. *Unlinkability:* on the non-custodial, zero-knowledge path, distinct relying parties receive uncorrelated identifiers, and cryptographic correlation stays infeasible even if they pool their data (the limits — custodial wallets, network-layer correlation, and the global-de-duplication set — are stated in §11). *Uniqueness:* because all of a holder's pseudonyms derive from one secret `s` and uniqueness rests on one nullifier `n`, the system can prove uniqueness-per-document while keeping the pseudonyms unlinkable — "per document" because each passport yields its own `n` (§7), so this is strong Sybil resistance rather than provable one-human-one-account. The scope of any uniqueness guarantee — per-RP or global — is a deliberate choice, discussed in §7. (Spec §9.)

## 7. KYC tiers and assurance

Identity is anchored to a single persistent `did:bsv` and, from Tier 1 upward, one persistent personhood commitment, over which assurance accrues as additive attestations. A holder may begin at any tier and upgrade; pseudonyms and relationships stay stable across upgrades. A central principle separates two ideas routinely conflated: **cryptographic authenticity is not identity assurance level.** A self-read passport can yield data that is provably genuine and provably from an un-cloned chip, yet still sit at the lowest assurance, because no accountable party has verified that the person presenting it is its rightful holder.

<svg viewBox="0 0 760 300" width="760" height="300" style="max-width:100%;height:auto" xmlns="http://www.w3.org/2000/svg" font-family="ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif">
  <defs><marker id="t2arr" viewBox="0 0 10 10" refX="5" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 z" fill="#64748b"/></marker></defs>
  <rect x="0" y="0" width="760" height="300" rx="10" fill="#ffffff"/>
  <text x="24" y="26" font-size="15" font-weight="700" fill="#0f172a">Figure 2 · Tier progression — assurance accrues over one identity</text>
  <rect x="24" y="120" width="160" height="80" rx="8" fill="#f1f5f9" stroke="#94a3b8"/>
  <text x="104" y="142" text-anchor="middle" font-size="12.5" font-weight="700" fill="#334155">Tier 0 · bare key</text>
  <text x="104" y="162" text-anchor="middle" font-size="10.5" fill="#475569">adds: key control</text>
  <text x="104" y="190" text-anchor="middle" font-size="10.5" fill="#64748b">below Low / IAL1</text>
  <line x1="188" y1="160" x2="204" y2="160" stroke="#64748b" stroke-width="1.5" marker-end="url(#t2arr)"/>
  <rect x="208" y="100" width="160" height="100" rx="8" fill="#e0f2fe" stroke="#0284c7"/>
  <text x="288" y="122" text-anchor="middle" font-size="12.5" font-weight="700" fill="#075985">Tier 1 · self-read</text>
  <text x="288" y="142" text-anchor="middle" font-size="10.5" fill="#0c4a6e">+ genuine document, n</text>
  <text x="288" y="158" text-anchor="middle" font-size="10.5" fill="#0c4a6e">(free, no issuer)</text>
  <text x="288" y="190" text-anchor="middle" font-size="10.5" fill="#64748b">≈ Low / IAL1 · DTC-1</text>
  <line x1="372" y1="150" x2="388" y2="150" stroke="#64748b" stroke-width="1.5" marker-end="url(#t2arr)"/>
  <rect x="392" y="80" width="160" height="120" rx="8" fill="#dbeafe" stroke="#2563eb"/>
  <text x="472" y="102" text-anchor="middle" font-size="12.5" font-weight="700" fill="#1e3a8a">Tier 2 · issuer</text>
  <text x="472" y="122" text-anchor="middle" font-size="10.5" fill="#1e40af">+ accountable issuer,</text>
  <text x="472" y="138" text-anchor="middle" font-size="10.5" fill="#1e40af">verified binding,</text>
  <text x="472" y="154" text-anchor="middle" font-size="10.5" fill="#1e40af">revocation</text>
  <text x="472" y="190" text-anchor="middle" font-size="10.5" fill="#64748b">Substantial / IAL2</text>
  <line x1="556" y1="140" x2="572" y2="140" stroke="#64748b" stroke-width="1.5" marker-end="url(#t2arr)"/>
  <rect x="576" y="60" width="160" height="140" rx="8" fill="#c7d2fe" stroke="#4338ca"/>
  <text x="656" y="82" text-anchor="middle" font-size="12.5" font-weight="700" fill="#312e81">Tier 3 · in-person</text>
  <text x="656" y="102" text-anchor="middle" font-size="10.5" fill="#3730a3">+ in-person binding,</text>
  <text x="656" y="118" text-anchor="middle" font-size="10.5" fill="#3730a3">qualified party</text>
  <text x="656" y="190" text-anchor="middle" font-size="10.5" fill="#64748b">High / IAL3 · DTC-2/3</text>
  <rect x="24" y="220" width="712" height="56" rx="8" fill="#ecfeff" stroke="#0891b2"/>
  <text x="380" y="244" text-anchor="middle" font-size="12" font-weight="700" fill="#155e75">One persistent did:bsv + personhood commitment (s, n)</text>
  <text x="380" y="263" text-anchor="middle" font-size="11" fill="#0e7490">assurance is additive; scoped pseudonyms and relationships stay stable across upgrades</text>
</svg>

*Figure 2 — Additive tiers over one identity (Spec §12).*

**Tier 0** is a bare identity key — proof of key control, no document, no commitment. **Tier 1** is the free self-read: the holder scans the passport's machine-readable zone to derive the chip access key (PACE, with BAC fallback), reads the chip, and the wallet performs ICAO 9303 passive authentication, verifying the Document Security Object signature *and* the full certificate chain behind it — the Document Signer Certificate (DSC) up to a trusted Country Signing CA (CSCA) — and checking the data-group hashes against that chain. Verifying only "the chip's signature" without anchoring the DSC→CSCA chain to a trusted CSCA would be unsound, since an attacker can mint their own signer. Where a uniqueness guarantee is relied upon, the wallet must also perform active/chip authentication — passive authentication alone does not detect a cloned chip. Note this protects against chip *cloning* for impersonation; it does not raise the uniqueness of `n` itself, whose inputs (document number, MRZ, DG2 hash) are readable and copyable regardless, which is why anyone who has read the chip can recompute `n` (§4). The genuine attributes derive the nullifier `n`; a fresh secret `s` is generated and held in the wallet. The trust anchor is the issuing state's document PKI; there is no third-party issuer, which is what makes the tier free. **Tier 2** adds an accountable issuer or qualified trust service provider performing real identity proofing with liveness binding, plus issuer-side revocation. **Tier 3** is in-person (or supervised-equivalent) proofing — the route toward government-grade assurance.

What Tier 1 does and does not establish is worth stating bluntly:

| Tier-1 property | Holds? |
|---|---|
| Genuine passport document | Yes |
| Genuine, un-cloned chip (with active / chip authentication) | Yes |
| Unique per document | Yes |
| Verified that the presenter is the rightful holder | No |
| Accountable issuer / regulatory KYC | No |

Tier 1 establishes *what the document is*, never *who is holding it*.

**Assurance crosswalk.** The tier is a *proofing* level and maps across frameworks: Tier 0 ≈ below eIDAS Low / NIST IAL1; Tier 1 ≈ Low (informal) / ≈ IAL1, and corresponds to an ICAO Digital Travel Credential Type 1; Tier 2 → Substantial / IAL2 / DTC Type 2; Tier 3 → High / IAL3 / DTC Type 2–3. NIST SP 800-63-4 deliberately separates identity proofing (IAL) from authenticator strength (AAL) and federation (FAL); only IAL maps to the tier, which is why custody and presentation mode are independent axes. (Spec §12.)

**Passport lifecycle — what `n` actually anchors.** Because `n` derives from chip data and electronic passports carry no reliable cross-document person identifier, `n` is *per-document, not per-person*. Renewing or replacing a passport yields a new document number and therefore a new `n`; a lawful second document (dual citizenship, or a pre-expiry replacement) yields a second valid `n`. So Tier-1 global uniqueness is, precisely, one-account-per-passport-document — which is the exact sense in which it resists casual but not determined Sybil behaviour. Reassuringly, this does not disturb a holder's relationships: per-RP pseudonyms derive from the wallet-held `s`, so renewing a passport leaves every existing pseudonym intact and only the global-uniqueness anchor `n` resets. Collapsing multiple documents to one person is exactly the accountable binding the higher tiers provide.

## 8. Credentials and presentation

The canonical credential is the W3C Verifiable Credential. A credential commits to both `s` and `n`, and is cryptographically bound to a holder key derived from the root identity — the sense in which it is "bound to `did:bsv`" is key/control binding, not embedding the DID string, and the resolvable root DID is never exposed at presentation. Each attribute is individually addressable so it can be selectively disclosed or proven by predicate without revealing its neighbours.

<svg viewBox="0 0 760 232" width="760" height="232" style="max-width:100%;height:auto" xmlns="http://www.w3.org/2000/svg" font-family="ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif">
  <defs><marker id="t3arr" viewBox="0 0 10 10" refX="5" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 z" fill="#64748b"/></marker></defs>
  <rect x="0" y="0" width="760" height="232" rx="10" fill="#ffffff"/>
  <text x="24" y="26" font-size="15" font-weight="700" fill="#0f172a">Figure 3 · Credential lifecycle</text>
  <rect x="24" y="48" width="128" height="64" rx="8" fill="#e0f2fe" stroke="#0284c7"/>
  <text x="88" y="76" text-anchor="middle" font-size="12" font-weight="700" fill="#075985">Enrol</text>
  <text x="88" y="94" text-anchor="middle" font-size="10" fill="#0c4a6e">passport read /</text>
  <text x="88" y="106" text-anchor="middle" font-size="10" fill="#0c4a6e">issuer proofing</text>
  <line x1="152" y1="80" x2="168" y2="80" stroke="#64748b" stroke-width="1.5" marker-end="url(#t3arr)"/>
  <rect x="170" y="48" width="128" height="64" rx="8" fill="#dbeafe" stroke="#2563eb" stroke-width="2.5"/>
  <text x="234" y="76" text-anchor="middle" font-size="12" font-weight="700" fill="#1e3a8a">Commit</text>
  <text x="234" y="94" text-anchor="middle" font-size="10" fill="#1e40af">blinded (s, n)</text>
  <text x="234" y="106" text-anchor="middle" font-size="10" fill="#1e40af">anchored on-chain</text>
  <line x1="298" y1="80" x2="314" y2="80" stroke="#64748b" stroke-width="1.5" marker-end="url(#t3arr)"/>
  <rect x="316" y="48" width="128" height="64" rx="8" fill="#ccfbf1" stroke="#0d9488"/>
  <text x="380" y="76" text-anchor="middle" font-size="12" font-weight="700" fill="#115e59">Issue</text>
  <text x="380" y="94" text-anchor="middle" font-size="10" fill="#134e4a">W3C VC · SD-JWT /</text>
  <text x="380" y="106" text-anchor="middle" font-size="10" fill="#134e4a">mdoc / keyring</text>
  <line x1="444" y1="80" x2="460" y2="80" stroke="#64748b" stroke-width="1.5" marker-end="url(#t3arr)"/>
  <rect x="462" y="48" width="128" height="64" rx="8" fill="#fef3c7" stroke="#d97706"/>
  <text x="526" y="76" text-anchor="middle" font-size="12" font-weight="700" fill="#92400e">Present</text>
  <text x="526" y="94" text-anchor="middle" font-size="10" fill="#92400e">ZK proof · pid ·</text>
  <text x="526" y="106" text-anchor="middle" font-size="10" fill="#92400e">predicates only</text>
  <line x1="590" y1="80" x2="606" y2="80" stroke="#64748b" stroke-width="1.5" marker-end="url(#t3arr)"/>
  <rect x="608" y="48" width="128" height="64" rx="8" fill="#ede9fe" stroke="#7c3aed"/>
  <text x="672" y="76" text-anchor="middle" font-size="12" font-weight="700" fill="#4c1d95">Status</text>
  <text x="672" y="94" text-anchor="middle" font-size="10" fill="#5b21b6">private revocation</text>
  <text x="672" y="106" text-anchor="middle" font-size="10" fill="#5b21b6">(accumulator, ZK)</text>
  <line x1="234" y1="112" x2="234" y2="150" stroke="#94a3b8" stroke-width="1.2" stroke-dasharray="4 3" marker-end="url(#t3arr)"/>
  <line x1="672" y1="112" x2="672" y2="150" stroke="#94a3b8" stroke-width="1.2" stroke-dasharray="4 3" marker-end="url(#t3arr)"/>
  <rect x="24" y="152" width="712" height="52" rx="8" fill="#f1f5f9" stroke="#94a3b8"/>
  <text x="380" y="174" text-anchor="middle" font-size="12" font-weight="700" fill="#334155">BSV ledger</text>
  <text x="380" y="192" text-anchor="middle" font-size="11" fill="#475569">on-chain: blinded commitments · status anchors · nullifier sets — never plaintext PII</text>
</svg>

*Figure 3 — Credential lifecycle (Spec §11). Only blinded commitments and status anchors touch the chain.*

A Tier-1 credential is **self-issued**: the wallet packages the genuine passport data groups with their passive-authentication evidence and commits `s`; its verifiability derives from the document PKI chain, not a third-party signature. A Tier-2/3 credential is signed by an accountable issuer, who may attest over the holder's *existing* commitment so an upgrade adds assurance without forking the identity.

A credential is expressible in any of three interoperable selective-disclosure encodings: **SD-JWT VC** (for EU interop; linkable, so not the sole encoding where unlinkability is required), **ISO/IEC 18013-5 mdoc** (for proximity/mobile-document and remote use), and **BRC-52/53 keyrings** (the BSV-native profile). Where §10 unlinkability is needed, the credential is additionally issuable in an anonymous-credential form (BBS+) or as a commitment a zero-knowledge circuit can consume.

Presentation runs over two protocols from one identity: **BRC-103** for BSV-native peer-to-peer mutual authentication (which also authenticates the relying party to the holder, defeating phishing), and **OpenID4VP with SIOP** for the W3C/eIDAS world. Disclosure granularity is set by the request and ranges from a bare pseudonymous login, through a predicate-only proof (over-18 with no identity revealed), to full attribute disclosure under explicit per-disclosure consent. Sessions and single-sign-on are supported without becoming a correlation honeypot: the identifier exposed to each relying party is always the pairwise pseudonym, and a hosted bridge, if used, must not retain cross-RP correlation data. (Spec §§11, 14.)

## 9. The zero-knowledge toolbox

What makes this feasible on BSV is a separation of layers: the chain layer (DID operations, key derivation, signing) is fixed to secp256k1, but the **proof layer is not bound to that curve** — a presentation proof may use whatever group its proof system needs. Pairing-based and SNARK-friendly constructions run in the credential layer while identity and control stay anchored on secp256k1. The standard fixes the *capabilities* required and the proof *statement*, not the proving system, which is pluggable. One cost this separation does not erase, and must be named: the same `s` lives in the holder's secp256k1-derived key material *and* in the credential-layer commitment and `pid`, so the proof must show — across two different groups/fields — that these are the *same* `s`. This cross-group (foreign-field) equality is itself part of the binding problem and a non-trivial circuit cost; it is not free, and a conforming construction must specify where `s` natively lives and how the equality is proven.

The capabilities form four layers of increasing power: **(A)** selective disclosure (reveal chosen fields); **(B)** attribute predicates (prove age ≥ 18 without the date of birth, e.g. with Bulletproof range proofs, native to secp256k1, no trusted setup); **(C)** multi-show unlinkable presentation (each presentation uncorrelated even to the same verifier — e.g. BBS+); and **(D)** a single succinct proof of the full statement: a credential is validly attested, predicates hold, and `pid = PRF(s, scope)` for a committed `s`, including — for Tier-1 self-read — verifying the ICAO passive-authentication signature chain in-circuit. The central technical task is the **binding problem**: proving that a hidden attribute is the one an accountable source attested, without showing a reusable signature that would itself be a correlation handle. Three strategies address it — an issuer-side commitment, signature-verification-in-circuit, or a zero-knowledge-native credential signature (BBS+/PS). (Spec §13.)

**Feasibility, stated concretely.** Layers A–C are production-ready and cheap on mobile (milliseconds to low seconds, small proofs). Layer D is the expensive case: the dominant cost is verifying the issuer's signature chain (RSA-2048 or ECDSA) inside the circuit, which runs to millions of constraints. It is nonetheless shippable on commodity phones today — several production systems (ZKPassport, Self, OpenPassport, Rarimo) generate ICAO passport proofs on-device — but proving takes seconds to tens of seconds. The practical pattern is **amortization**: run the heavy passive-authentication proof *once* at enrolment, binding the passport to a published commitment and a registration entry; subsequent presentations then prove cheap membership against that registration plus the requested predicates, which are Layer-A/B-class costs. A real engineering cost is **heterogeneity** — states sign with different algorithms and key sizes (RSA, ECDSA, DSA, EdDSA; some legacy hashes), so a conforming Tier-1 circuit suite must cover several signature profiles, and issuer coverage, not single-circuit speed, is the gating factor. On-device proving preserves privacy; remote proving is faster but reveals inputs and is unsuitable for the privacy-critical Tier-1 self-read.

## 10. eIDAS interoperability

The eIDAS profile is a three-stage maturity path, each stage independently useful with an explicit exit gate.

<svg viewBox="0 0 760 270" width="760" height="270" style="max-width:100%;height:auto" xmlns="http://www.w3.org/2000/svg" font-family="ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif">
  <defs><marker id="t5arr" viewBox="0 0 10 10" refX="5" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 z" fill="#64748b"/></marker></defs>
  <rect x="0" y="0" width="760" height="270" rx="10" fill="#ffffff"/>
  <text x="24" y="26" font-size="15" font-weight="700" fill="#0f172a">Figure 5 · eIDAS maturity path</text>
  <rect x="24" y="96" width="216" height="108" rx="8" fill="#e0f2fe" stroke="#0284c7"/>
  <text x="132" y="120" text-anchor="middle" font-size="13" font-weight="700" fill="#075985">Stage 1 · interop bridge</text>
  <text x="132" y="142" text-anchor="middle" font-size="11" fill="#0c4a6e">Tiers 0–1 · non-qualified EAA</text>
  <text x="132" y="158" text-anchor="middle" font-size="11" fill="#0c4a6e">accept EUDI presentations</text>
  <text x="132" y="188" text-anchor="middle" font-size="10.5" fill="#64748b">gate: boundary interop tests</text>
  <line x1="240" y1="150" x2="264" y2="150" stroke="#64748b" stroke-width="1.5" marker-end="url(#t5arr)"/>
  <rect x="266" y="74" width="216" height="130" rx="8" fill="#dbeafe" stroke="#2563eb"/>
  <text x="374" y="98" text-anchor="middle" font-size="13" font-weight="700" fill="#1e3a8a">Stage 2 · qualified (QEAA)</text>
  <text x="374" y="120" text-anchor="middle" font-size="11" fill="#1e40af">Tier 2 · via a qTSP</text>
  <text x="374" y="136" text-anchor="middle" font-size="11" fill="#1e40af">Trusted List mapping</text>
  <text x="374" y="152" text-anchor="middle" font-size="11" fill="#1e40af">HAIP conformance</text>
  <text x="374" y="188" text-anchor="middle" font-size="10.5" fill="#64748b">gate: qTSP partnership</text>
  <line x1="482" y1="139" x2="506" y2="139" stroke="#64748b" stroke-width="1.5" marker-end="url(#t5arr)"/>
  <rect x="508" y="52" width="228" height="152" rx="8" fill="#c7d2fe" stroke="#4338ca"/>
  <text x="622" y="76" text-anchor="middle" font-size="13" font-weight="700" fill="#312e81">Stage 3 · notified eID</text>
  <text x="622" y="98" text-anchor="middle" font-size="11" fill="#3730a3">Tier 3 · LoA High</text>
  <text x="622" y="114" text-anchor="middle" font-size="11" fill="#3730a3">PID, Member State authority</text>
  <text x="622" y="130" text-anchor="middle" font-size="11" fill="#3730a3">EUDI Wallet certification</text>
  <text x="622" y="166" text-anchor="middle" font-size="10.5" fill="#64748b">gate: certification +</text>
  <text x="622" y="180" text-anchor="middle" font-size="10.5" fill="#64748b">Member State sponsorship</text>
  <text x="380" y="238" text-anchor="middle" font-size="12" fill="#475569">Most adoption begins at Stage 1; Stage 3 is the destination, not the entry point.</text>
</svg>

*Figure 5 — The eIDAS maturity path (Spec Part IV).*

**Stage 1 (interop bridge)** lets a BSV service accept EU wallet presentations and issue attributes consumable as non-qualified attestations, registering with a member-state registrar for an access certificate. **Stage 2 (qualified)** issues qualified attestations through a qualified trust service provider, mapped onto EU Trusted Lists. **Stage 3 (notified eID)** is the wallet acting as the technical vehicle of a member-state-sponsored scheme at the highest assurance — a long-horizon, politically-gated destination.

Three reconciliations make the stages work. *Format:* the canonical internal model is the W3C VC, exported to SD-JWT VC or mdoc at the EU boundary. *Trust:* a verifier can resolve trust either through EU Trusted Lists or through the on-chain accredited-issuer registry. *Unlinkability:* the EU mandates unlinkability in principle (Recital 14 calls for zero-knowledge integration) and the ARF's own "full unlinkability" definition coincides with this design's goal, but the ARF baseline formats are linkable and reach verifier-unlinkability only by batch issuance; anonymous-credential schemes (BBS+, and the pairing-free, ECDSA-compatible BBS#) are compatible but not yet in the ARF spec. So this profile emits ARF-compatible formats on the baseline path and offers the zero-knowledge path as the privacy-preserving option — honestly, the layer is ahead of the EU baseline only where the zero-knowledge path is actually used; baseline-format presentations inherit the same linkability until the ARF's zero-knowledge track matures. (Spec §§16–19.)

## 11. Security and privacy

The adversaries of concern are colluding relying parties, an issuer colluding with relying parties, a network observer, a key/device thief, a holder presenting a stolen or copied credential, and a compromised trust anchor. Cross-RP correlation is defeated by scoped pseudonyms and the zero-knowledge presentation; issuer–RP collusion is mitigated because the issuer observes neither presentations nor status checks and a presentation can prove issuer-set membership without naming the issuer. Replay is defeated by binding every proof to a fresh verifier challenge, and a copied credential is unusable because presentation requires proof of holder-key control and knowledge of `s`. **Trust-anchor compromise** is the residual class the above does not cover: a compromised national CSCA undermines every Tier-1 self-read rooted in it, a compromised issuer or qTSP undermines the credentials it signed, and — for Layer-D SNARKs that need a per-circuit setup — a compromised trusted-setup ceremony could forge proofs. These are contained, not eliminated: by accreditation and registry revocation for issuers and CSCAs, by preferring transparent-setup systems (Bulletproofs, STARKs) where possible, and by requiring a multi-party ceremony wherever a trusted setup is unavoidable.

Several limits are stated plainly rather than hidden. **Network-level correlation** (IP, timing, device fingerprint) is where most practical deanonymization happens, and the unlinkability guarantee is *cryptographic* — it does not extend to the network layer. Real deployments need transport-level measures (oblivious HTTP or a mixnet/Tor-style relay, plus timing padding and batched submission), and the design is explicit that cryptographic unlinkability must not be marketed as network anonymity. **On-chain confidentiality** depends on every commitment being blinded with high-entropy salt; this matters most for `n`, which is low-entropy by construction and must never appear except as a salted, one-way value. The one unavoidable exception is the *global* uniqueness nullifier, which must be deterministic in `n` to detect duplicates and therefore cannot be per-holder salted; it is linkable and recomputable within the de-duplication domain by anyone who has read the chip (§4), and global de-duplication's privacy holds only against parties who have not. **Tier-1 binding is self-asserted**, so a lost or stolen passport could be self-read by another party. And **secp256k1 signatures are not post-quantum**; migration is possible through DID key rotation as post-quantum schemes mature, and is a tracked long-term item. (Spec §20.)

On data protection, the architecture keeps personal data off-chain and writes only blinded, non-identifying commitments to the ledger, which is designed to support the argument that the chain's immutability does not conflict with the right to erasure. Whether such commitments are "personal data" is a contested legal question that must be confirmed with data-protection counsel — this is design rationale, not legal advice.

## 12. How it compares

| System | Verifiable KYC | Private (selective disclosure) | Unlinkable across services |
|---|---|---|---|
| Traditional KYC | Yes | No | No |
| EU Digital Identity Wallet (baseline SD-JWT / mdoc) | Yes | Partial | Partial — batch issuance only |
| Microsoft Entra Verified ID | Yes | Partial | No |
| SpruceID (mDL / state wallets) | Yes | Partial | No |
| Dock / Truvera | Yes | Yes | Partial (BBS+) |
| World ID | Personhood only | Partial | Yes (nullifiers) |
| Privado ID / Billions (ex-Polygon ID) | Yes | Yes | Yes |
| **This proposal** | Yes (Tiers 1–3) | Yes | Yes (zero-knowledge path) |

Honestly read: **World ID** delivers unlinkable proof-of-unique-personhood but no attribute KYC, and depends on dedicated iris-scanning hardware with the attendant privacy and governance controversy. The **EU wallet** has decisive regulatory backing but ships linkable baseline formats. The closest peer is **Privado ID / Billions** (the former Polygon ID team), which also does passport-based zero-knowledge identity — on an EVM ecosystem, without a defined eIDAS-notification path. The distinctive combination here is verifiable government-attribute KYC, proof-of-unique-personhood, unlinkability, and a concrete eIDAS path, anchored on a high-throughput public UTXO ledger and entered through a free self-serve passport scan. The unlinkability advantage holds on the zero-knowledge path. (Spec §22.)

## 13. Roadmap and status

Delivery is phase-gated. **Phase 0** builds the substrate: `did:bsv` resolution, key management and recovery, BRC-103 and OpenID4VP presentation, the W3C VC model with SD-JWT export, Tiers 0–1 including free self-read onboarding, and Layer-A selective disclosure — corresponding to the Stage-1 bridge. **Phase 1** adds the zero-knowledge layers B–D and is the privacy differentiator. **Phase 2** adds qualified interoperability (a qTSP partnership, Trusted List mapping, mdoc, full HAIP conformance). **Phase 3** is national scale (notified eID at the highest assurance). Beyond that, legal-person and organisational identity is future work, anchored on the Legal Entity Identifier (LEI) and its verifiable form (vLEI) and bridged through the delegation model.

Two risks bound the ambition. The heaviest zero-knowledge proofs are real engineering, mitigated by amortizing passive authentication into a one-time enrolment. And Stage 3 carries a prior strategic risk — whether EU regulators will anchor a notified scheme on a public, permissionless ledger at all — which Stages 1–2 are deliberately structured not to depend on.

The strongest near-term wedge is the **free, private, unique-per-person passport tier**: useful on day one for age-gating, Sybil-resistant accounts, and bot resistance, with a clean upgrade path to regulated KYC and, eventually, government identity.

*For normative requirements, data schemas, the `did:bsv` profile, and conformance, see the companion standards proposal.*
