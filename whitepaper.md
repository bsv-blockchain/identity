# BSV Unified Identity: Private, Verifiable, Unlinkable KYC — from BRC-100 Wallets to eIDAS

**Status:** Draft v0.2 (working) — v0.2 prohibits presentation-time `n`-derived nullifiers and moves global uniqueness to the anchored enrolment registry (§8.4, §10.7); replaces the DG2 facial-image hash with the SOD hash in the `n` derivation (§8.4, §15.3); specifies Tier-1 enrolment, trust-root governance, and contested-registration eviction (§12); mandates transcript-bound presentation challenges (§14.4); adds multi-device and recovery-boundary requirements (§8.6, §8.9); adds the AML scope carve-out (§10.9) and the EU pseudonym reconciliation (§19.7); and refreshes references (BRC-100/104 certificate interface, ARF v2.9.0, W3C DID registry framing).
**Editors:** Siggi (BSV Association); additional editors TBD
**Type:** Standards proposal — a unified identity BRC plus an eIDAS interoperability profile

> Working draft. Section numbering is fixed; prose is filled top-down. Conformance keywords (MUST, MUST NOT, SHOULD, SHOULD NOT, MAY) are interpreted per RFC 2119 / RFC 8174 and apply only to sections marked *Normative*.

---

## Part I — Framing

### 1. Executive summary

Digital identity today rests on trusted third parties acting as gatekeepers. That makes identity data a breach honeypot, makes document forgery a standing risk, and turns every login into a tracking event because the same identifiers are reused everywhere. KYC compounds the problem: regulated services need a verified person, but the prevailing options either destroy privacy (hand over documents, then get correlated across services) or are not verifiable (self-asserted claims a relying party cannot check).

This document proposes a unified identity layer for the BSV blockchain that makes KYC **private but verifiable**. A holder proves they are a real, current, uniquely-identified person who satisfies stated predicates — over-18, EU-resident, assurance at or above some level — without revealing who they are, and presents a *different* identifier to every relying party so that activity cannot be correlated across services, even when those services collude. One boundary is stated up front: this pattern legally serves age verification, Sybil resistance, and access gating. Where anti-money-laundering law requires customer due diligence, the obliged entity must identify the customer and retain identity data, and no predicate proof substitutes for that; there the layer offers verifiable, minimized, consented disclosure — not unlinkability (§10.9).

The layer binds existing primitives rather than inventing new ones: `did:bsv` (a UTXO-friendly DID method listed in the W3C DID extensions registry, §5.2) as the resolvable identifier; W3C Verifiable Credentials as the canonical credential and attestation format; BRC-42/43 key derivation and BRC-103 mutual authentication for keys and presentation; BRC-52/53 keyrings as an optional BSV-native selective-disclosure profile; and a zero-knowledge toolbox for predicate proofs, unlinkable pseudonyms, and proof-of-unique-personhood. Onboarding is tiered, beginning with a free, self-sovereign tier in which the holder reads their own passport chip with no issuer involved, and rising through issuer-verified and in-person tiers. The aim is to consolidate BSV's identity primitives into a single standard and raise them to national-scale, regulated use.

Two deliverables follow: (1) a new BRC specifying the binding layer normatively, and (2) an eIDAS interoperability profile defining a three-stage maturity path — interop bridge, Qualified attestation via a qualified trust service provider, and a notified eID scheme — aligned to the EU Digital Identity Wallet timeline.

### 2. Motivation and the eIDAS window

Centralised identity fails in three predictable ways. Aggregated identity stores are honeypots whose breach is catastrophic and irreversible. Paper and PDF credentials are forgeable and slow to verify. And because the same identifiers are presented to every service, ordinary use produces pervasive cross-service correlation and surveillance as a side effect.

KYC sharpens all three. A regulated service must establish who it is dealing with, yet the act of establishing it typically requires the user to surrender a full identity document to each counterparty, where it is stored, re-used, and exposed. The user pays in privacy; the service pays in liability. The result is a paradox: the more thoroughly identity is verified, the more widely it is leaked.

A UTXO blockchain is well suited to breaking this paradox. Transaction chains give an immutable, timestamped, double-spend-protected sequence of events — exactly what is needed to record credential issuance, key rotation, and revocation — and they verify under SPV without trusting a central index. BSV adds low-fee, high-throughput anchoring and instant verification, and `did:bsv` is already registered and resolvable, so the identifier layer need not be invented.

The regulatory window is open and dated. eIDAS 2.0 (Regulation (EU) 2024/1183) requires every EU member state to make at least one government-backed EU Digital Identity Wallet available: the first implementing regulations were published on 4 December 2024, and the regulation's 24-month clock places national wallet availability at late December 2026, with mandatory acceptance by specified private-sector relying parties (regulated sectors requiring strong authentication, and very large online platforms on user request) following roughly a year later. In practice readiness is lagging — fewer than a third of member states currently meet the readiness benchmark and several national wallets are slipping into 2027 — which, if anything, widens rather than narrows the window for a standards-aligned entrant. The Architecture and Reference Framework is now maintained on a structured, iterative release cycle (v2.9.0, May 2026, at the time of writing) and continues to evolve through 2026. A BSV identity layer that is standards-aligned can interoperate with this infrastructure rather than compete with it.

The specific gap this work targets is unlinkability. The EUDI mainstream selective-disclosure formats (SD-JWT VC, mdoc) are linkable across colluding verifiers. The ARF has now taken up zero-knowledge proof as a first-class topic — high-level requirements for ZKP and for pseudonyms sit in its Annex 2, referencing ETSI TR 119 476 — but support is explicitly expected only *after* the December 2026 launch, over credentials already issued in the linkable baseline formats. So the launch ecosystem is linkable, and the live differentiator is no longer "the ARF lacks zero-knowledge" but **unlinkable-by-default, from day one, with offline (non-interactive) presentation** — the pattern in §10, delivered by the toolbox in §13. The advantage is realised on the BSV-native and zero-knowledge path; presentations made in the EU-baseline formats inherit those formats' linkability, exactly as the EU baseline does until its own ZKP track is deployed (§19.4).

### 3. Scope, terminology, and conformance

**In scope.** The binding layer (identifier, keys, credentials, presentation); the private-verifiable-unlinkable KYC pattern; the KYC tier and level-of-assurance model; the zero-knowledge toolbox; and the eIDAS interoperability profile.

**Out of scope.** Defining a new blockchain or a new DID method — this adopts `did:bsv`. Specifying a consumer wallet product. Mandating a single zero-knowledge proving system — the toolbox is pluggable (§13). Legal-person and organisational identity is deferred to a later profile (mirroring the EU's separate business wallet); delegation (§§9.4, 15.5) is the only organisational touchpoint in this version. When that profile is developed, organisational identity SHOULD anchor on ISO 17442 Legal Entity Identifiers (LEI) in their verifiable form (GLEIF vLEI).

**Conformance.** Normative sections use RFC 2119 / RFC 8174 keywords. The specification is modular: the core (identifier, keys, identity model, the KYC pattern, and presentation — §§7–14) can be adopted independently of the zero-knowledge toolbox (§13) and the eIDAS profile (Part IV), which are separable companion profiles. A conforming implementation declares which parts it implements; partial adoption of the core is valid.

**Terminology (selected).**

- *Holder / Subject* — the person controlling the identity and its keys.
- *Issuer* — a party asserting claims about a subject (Tier 2/3). At Tier 1 there is no third-party issuer: the credential is self-issued by the wallet, with the issuing state's document PKI (via passive authentication) as the verifiability anchor (§11.3).
- *Relying party (RP) / Verifier* — a party requesting proof.
- *qTSP* — qualified trust service provider (eIDAS).
- *Credential* — a W3C Verifiable Credential; an *attestation* is a credential.
- *Presentation secret `s`* — a high-entropy, wallet-generated value, genuinely secret and never disclosed; the source of scoped pseudonyms and holder binding (§8.4, §10).
- *Personhood nullifier `n` (uniKey)* — a deterministic, one-way function of a person's passport identity (Tier 1); the basis for global one-person uniqueness. It is **not** secret — anyone who has read the passport chip can recompute it — so it is used exactly once, at enrolment, to derive the registry uniqueness tag; no `n`-derived value ever appears in a presentation, and pseudonyms are never derivable from it (§8.4, §10.7).
- *Personhood commitment* — the credential's binding commitment to both `s` and `n` (§11.1).
- *Scoped pseudonym* — `pid = PRF(s, RP_scope)`; stable per RP, unlinkable across RPs (§10).
- *Selective disclosure* — revealing chosen fields only.
- *Predicate proof* — proving a statement about an attribute (e.g. age ≥ 18) without revealing the attribute.
- *Tier* — an onboarding assurance level (§12).
- *LoA* — eIDAS level of assurance: Low, Substantial, or High.
- *Passive authentication* — ICAO 9303 verification that a passport chip's data is genuine and unmodified, via the issuing state's signing PKI.

### 4. Design goals and principles

- **P1 — Private by default.** A holder MUST be able to satisfy an RP's requirement without revealing any attribute beyond what that requirement entails.
- **P2 — Verifiable.** Every claim an RP relies on MUST be cryptographically verifiable and anchored to a trust source (issuer signature, document PKI, or DID status).
- **P3 — Unlinkable across contexts.** Distinct RPs MUST receive uncorrelated identifiers; correlation MUST remain infeasible even if RPs collude.
- **P4 — Deliberate uniqueness.** Where one-person-one-account is required, the scope of uniqueness (per-RP vs global) MUST be stated explicitly; global uniqueness is enforced at enrolment — one active registration per personhood nullifier in the anchored enrolment registry — or by an accountable one-credential-per-person guarantee at issuance (§10.7). It is never enforced by revealing person-derived values at presentation.
- **P5 — Free, self-sovereign onboarding.** A usable assurance tier MUST be reachable with no issuer dependency (self-read document, Tier 1); higher assurance adds accountable attestations.
- **P6 — Additive assurance.** Assurance accrues as attestations over a single persistent identity and personhood commitment — not as separate identities per tier.
- **P7 — Non-custodial and recoverable.** Holders control their keys by default; recovery MUST NOT require surrendering custody to a trusted third party.
- **P8 — Current and revocable.** Credential and key status MUST be verifiable, and status checks SHOULD NOT reveal the holder's activity to the issuer.
- **P9 — Standards-aligned.** The layer MUST map to W3C VC/DID, support OpenID4VC/SIOP presentation, and profile cleanly onto eIDAS/ARF, ISO/IEC 18013-5, and SD-JWT.
- **P10 — Reuse over reinvention.** The layer MUST build on existing BSV primitives (`did:bsv`, BRC-42/43/52/53/100/103) rather than introduce a new mechanism wherever an established one already serves.
- **P11 — SPV-verifiable and scalable.** Verification paths MUST be SPV-compatible and MUST NOT require a trusted full-index intermediary as the only option.
- **P12 — Consent and data minimisation.** Disclosures MUST be consented; on-chain data MUST be limited to commitments and hashes, never plaintext PII, to stay compatible with data-protection erasure expectations.

---

## Part II — Landscape and thesis

### 5. Building blocks: the two BSV identity stacks

BSV already carries most of the machinery an identity system needs, but it has grown as two largely separate stacks that were never designed to interlock. Naming them is the first step to binding them.

#### 5.1 The wallet / attestation stack

This stack grew out of the BRC process around a non-custodial wallet.

- **Keys.** BRC-42 (the BSV Key Derivation Scheme, "type-42") derives per-protocol, per-counterparty keys from a root secret; BRC-43 fixes the security levels, protocol IDs, key IDs, and counterparties so derivation paths are well-defined and addressable. Every transaction output and identity proof rides on this.
- **Wallet interface.** BRC-100 is a vendor-neutral wallet-to-application API spanning action (transaction) management, key management, identity and certificate handling, and output management. It is what lets an application talk to any conforming wallet — extension, server, or library.
- **Authentication and presentation.** BRC-103 is a peer-to-peer mutual authentication and certificate-exchange protocol built on Schnorr signatures, nonce challenges, and BRC-42 derivation. It supports selective field disclosure through per-field keyrings, on-chain (UTXO outpoint) revocation, and interchangeable transports — HTTP (specified by BRC-104, which defines the `.well-known/auth` endpoint and `x-bsv-auth` header transport for BRC-103 messages), NFC, or WebSocket.
- **Credentials.** BRC-52 defines privacy-centric identity certificates with selective revelation and UTXO-based revocation: fields are individually encrypted (BRC-2) and signed (BRC-3), and disclosed to a verifier through a keyring that is not itself part of the signature. BRC-53 added the request, creation, and revelation methods over the BRC-1 messaging layer; it is now historical as an application-to-wallet method set — current wallet certificate behaviour is specified by BRC-100 (`acquireCertificate`, `listCertificates`, `proveCertificate`, `relinquishCertificate`) with BRC-52 defining the certificate structure. This document cites BRC-52/53 for the certificate and keyring model and BRC-100 for the live interface.
- **Compliance extension.** BRC-108 binds BRC-52/53 certificates to tokens (extending the BRC-107 Mandala token) to enforce KYC/AML and identity-gated asset rules with SPV-friendly proofs — evidence that the certificate model already reaches into regulated use.

#### 5.2 The VC / DID stack

This stack grew out of W3C self-sovereign-identity practice and was instantiated on BSV by TNG Identity.

- **Identifier.** `did:bsv` is a UTXO-friendly DID method registered in the W3C DID extensions registry — a discovery registry that the W3C explicitly does not operate as an endorsement. Its method specification and reference resolver are currently authored and operated by a single vendor (TNG / Teranode Group), a centralisation dependency deeper than the indexer question and addressed by the multi-vendor resolution requirement in §7.6. The method records DID creation, key rotation, status update, and revocation as immutable, timestamped transaction chains; uses the signatures already present in those transactions for authorisation; and supports multi-party control — for example a 1-of-2 multisig under which either the DID controller or the subject can revoke. A DID manager coordinates subject and controller signatures, and status checks are performed independently of the issuer and manager, so verifying a DID's status does not reveal the verifier's activity to the issuer.
- **Resolution.** A universal resolver validates a DID, loads its transaction history, reconstructs the current DID Document, caches it, and returns a W3C-compliant resolution result. The reference resolver loads history via WhatsOnChain; for a standards proposal this is the centralisation and latency point to address, so a Teranode/overlay-native resolution path is specified as the normative option, with WhatsOnChain as one permissible driver (§7).
- **Credentials and exchange.** W3C Verifiable Credentials and Presentations, served by an Issuer API, a Verifier API (including SIOP), a holder wallet, and an OAuth2/OIDC SSO bridge into Web2 stacks.

#### 5.3 External standards the layer must meet

The W3C VC and DID data models; SD-JWT and ISO/IEC 18013-5 (mdoc) as the selective-disclosure credential encodings used by EUDI; OpenID4VCI and OpenID4VP, with SIOP, as the issuance and presentation protocols; and eIDAS 2.0 with its Architecture and Reference Framework (PID, QEAA, Trusted Lists, and the Low/Substantial/High levels of assurance). For assurance crosswalk and global (non-EU) alignment, the following are reference points mapped where relevant rather than dependencies: NIST SP 800-63-4 (the IAL/AAL/FAL model, §12), ICAO Digital Travel Credentials (the digital form of the eMRTD, §12), ISO/IEC 24760 (identity-management framework and vocabulary), and FIDO2/WebAuthn/CTAP (phishing-resistant authenticators, §8.8). Legal-person identity anchors on ISO 17442 LEI / GLEIF vLEI in future work (§3, §23).

#### 5.4 BAP as prior art

The Bitcoin Attestation Protocol pioneered, on BSV, several ideas this layer carries forward: multiple unlinkable identities per person, attestation chains of trust, signing-key rotation decoupled from the funding source, consent grants and revocation, delegation of a completed KYC between identities, and the uniKey — a deterministic personhood anchor derived from NFC passport attributes (the inspiration for the personhood nullifier `n`, §8.4). BAP is treated purely as inspiration; it informed this model but is not part of the standard, and no backwards compatibility with its on-chain AIP-signed attestation format is provided. The ideas it pioneered are re-expressed natively as W3C Verifiable Credentials bound to `did:bsv`, with no `did:bap` migration path in the normative core.

### 6. The unification thesis and layered architecture

The two stacks of §5 solve adjacent halves of the same problem and do not currently interlock. The wallet/attestation stack has excellent keys, authenticated sessions, and selective-disclosure certificates, but no resolvable, standards-registered identifier and no native bridge to the VC and eIDAS world. The VC/DID stack has a registered identifier (`did:bsv`), W3C credentials, and OIDC/SIOP reach, but treats the wallet as an issuance and holding endpoint rather than exploiting BRC-42 derivation, BRC-103 mutual authentication, or keyring selective disclosure — and it inherits SD-JWT's cross-verifier linkability. Neither stack, on its own, delivers KYC that is at once private, verifiable, and unlinkable.

The proposal is a single binding layer — the new BRC — that sits over both stacks and composes them into one coherent system: `did:bsv` as the resolvable identity; BRC-42/43 keys and BRC-103 sessions beneath it; W3C Verifiable Credentials as the canonical credential, with BRC-52/53 keyrings as an optional BSV-native selective-disclosure profile; and a zero-knowledge toolbox that turns selective disclosure into unlinkable, predicate-bearing, uniqueness-aware presentation. The presentation edge speaks both BRC-103 and OpenID4VP/SIOP, so the same identity serves a BSV-native application and an eIDAS relying party without re-issuance.

The architecture is a stack (Figure 1). At the base, the BSV ledger — UTXO, SPV, and overlay/Teranode services — is the data registry, and type-42 key derivation (BRC-42/43) the cryptographic substrate. Above it sit the two native stacks of §5 as parallel pillars. The binding layer spans both pillars: it is where the personhood commitment, scoped pseudonyms, KYC tiers, and zero-knowledge proofs live (§§9–13). The presentation edge exposes the binding layer over BRC-103 and OpenID4VP/SIOP. At the top, the eIDAS interoperability profile (Part IV) maps the whole system onto PID, QEAA, and Trusted Lists.

![Figure 1 - Layered architecture](diagrams/figure-1-architecture.svg)

*Figure 1 — Layered architecture of the unified BSV identity system: the BSV ledger and type-42 derivation as foundation, the two native stacks of §5 as parallel pillars, the new binding layer spanning both, the dual-protocol presentation edge, and the eIDAS profile on top.*

---

## Part III — Normative core (the proposed BRC)

### 7. Identifier layer — `did:bsv` — *Normative*

This profile adopts `did:bsv` as the canonical identifier and does not redefine it; the method's identifier syntax and on-chain operations follow the registered `did:bsv` method specification. This section pins down how the binding layer uses the method and the additional requirements it places on control, status, and resolution.

**7.1 Adoption.** A subject's root identity MUST be a `did:bsv` DID. Its DID Document verification methods MUST be secp256k1 keys derived under §8. Implementations MUST NOT introduce a competing DID method for the root identity.

**7.2 Operations.** DID creation, key rotation, controller changes, and deactivation MUST be recorded as `did:bsv` transaction-chain operations. Because each operation spends the prior state, the chain is a unique, ordered, double-spend-protected, timestamped history of the identity, from which the current DID Document is deterministically reconstructed.

**7.3 Control model.** Each DID has a controller and a subject. This profile MUST support subject self-revocation via the method's 1-of-2 arrangement, under which either the controller or the subject can deactivate or rotate. Control of the DID is independent of assurance tier: self-control (the subject is its own controller) is the default at every tier, including Tier 3. A deployment MAY name a distinct controller as an operational choice, but the subject MUST retain an independent ability to revoke and to rotate to keys it solely controls (P7).

**7.4 Key rotation and continuity.** Signing keys MUST be rotatable without changing the DID. Superseded keys remain in the on-chain history with their validity window, so signatures made while a key was current stay verifiable after rotation. Rotation MUST preserve identity continuity: credentials bound to the DID remain valid, and — because scoped pseudonyms derive from the presentation secret `s` rather than from any signing key (§8.4, §10) — a holder's relationships with relying parties survive key rotation and recovery unchanged.

**7.5 Status and revocation.** Resolution MUST return the current DID Document together with status (active / deactivated). Revocation is a deactivation operation recorded on-chain. Status determination MUST be performable by a verifier independently, without contacting the issuer or a DID manager, so that checking a DID's status does not disclose the verifier's activity (P8).

**7.6 Resolution.** A resolver MUST reconstruct the DID Document from the on-chain operation chain and MUST verify that chain under SPV. The normative resolution path MUST be available over BSV-native infrastructure (overlay services / Teranode), so that resolution does not depend on a single third-party indexer. A public indexer such as WhatsOnChain MAY be used as a resolution driver but MUST NOT be the sole trust or availability dependency. Resolution results SHOULD be cacheable, with resolution metadata expressing freshness and the block height at which status was determined.

**7.7 The root DID is not a presentation identifier.** The root `did:bsv` is the control and recovery anchor. It MUST NOT be presented to relying parties for routine interactions; relying parties receive per-RP pairwise identifiers (§9) instead. This rule — that the KYC'd root identity is never used directly in an application — is load-bearing for unlinkability (§10).

### 8. Key management and signing — *Normative*

**8.1 Primitives.** All keys are secp256k1. Bitcoin transaction signatures (DID operations, on-chain anchors) use ECDSA; the BRC-103 authentication handshake uses Schnorr. Implementations MUST pass the conformance test vectors (§21) for both.

**8.2 Type-42 derivation.** Keys MUST be derived under BRC-42/43: each key is determined by a (security level, protocol ID, key ID, counterparty) tuple over a root secret. Using the relying party as the counterparty yields a distinct signing key per relationship, so signing keys — like pseudonyms — do not correlate across relying parties.

**8.3 Hierarchy.** A holder controls a single root secret, held non-custodially (P7) in a wallet or secure element. From it derive the identity root key (the `did:bsv` controller key, §7), per-counterparty presentation keys, and credential field-encryption keys (BRC-52 keyrings, §11). The root secret MUST NOT leave the holder's control and MUST NOT be escrowed with any single third party.

**8.4 The personhood commitment — two values, not one.** Personhood rests on two distinct values, both domain-separated from signing keys and both committed in the holder's credential (§11.1):
- the *presentation secret* `s` — a high-entropy value derived from the holder's root secret under a dedicated domain separator (§8.3), so it is reproduced by the same root-secret backup that protects the signing keys (§8.6) and need not be escrowed separately; it is never disclosed, and serves as the PRF input for scoped pseudonyms (§10) and holder binding (§11.6). It is recovered through the §8.6 backup, never by re-reading a document, and because it is independent of any individual signing key, pseudonyms are stable across key rotation and recovery (§7.4).
- the *personhood nullifier* `n` (the uniKey) — a deterministic, one-way function of the holder's passport identity attributes at Tier 1: the document number, the MRZ fields, and the hash of the chip's Document Security Object (SOD). The SOD hash is included because it is high-entropy and readable only from the chip — so computing `n` requires having *read* the chip, not merely photographed the photo page — while contributing no biometric input: the DG2 facial-image hash used in earlier drafts is deliberately excluded, because deriving a uniqueness identifier from a facial image is special-category biometric processing (GDPR Art. 9) and adds no uniqueness beyond the document fields (§15.3). `n` anchors global one-person uniqueness (§10.7): the same passport always yields the same `n`, even from a fresh wallet. Crucially, `n` is **not** a secret — anyone who has read the passport chip can recompute it — so `n`-derived values MUST NOT appear in any presentation: `n` is used exactly once, at enrolment, to derive the registry uniqueness tag (§10.7), and scoped pseudonyms MUST NOT be derivable from `n`.

Conflating the two — using a passport-derived value as the presentation secret — would let anyone who has read the holder's passport recompute their pseudonyms and forge holder binding; the separation is therefore mandatory.

**8.5 Custody.** The default custody model is non-custodial. Custodial deployments MAY exist for specific markets but MUST be declared to the relying party as a property of the credential, since they change the trust model, and MUST NOT be the only option offered for a given assurance tier. Declaration is a weak control on its own: convenience pressure drives real deployments toward custody, and a custodial wallet can correlate a holder across relying parties internally, defeating the §10 unlinkability guarantee even when the on-the-wire identifiers remain pairwise. A custodial deployment MUST therefore additionally disclose that the custodian can correlate the holder's pseudonyms, and the non-custodial option MUST remain the default and stay available at every tier.

**8.6 Recovery.** Implementations MUST support at least one recovery mechanism that does not surrender custody: M-of-N social recovery, threshold/MPC key shares, or hardware-backed backup. Higher tiers MAY additionally offer issuer-assisted re-binding, in which an accountable issuer re-attests the holder's existing personhood commitment to a fresh key set. Any recovery mechanism MUST be expressible as a controller-authorised `did:bsv` key rotation (§7.4) and MUST NOT allow a single external party to unilaterally assume control of the identity. Where recovery reconstructs the root secret from shares (M-of-N social recovery, threshold/MPC), reconstruction MUST occur inside the new device's secure boundary; shares MUST NOT be combined at a coordinator or any other single external point, since whoever momentarily holds the reconstructed root secret holds every pseudonym the holder has (§8.4).

**8.7 Signing in use.** Presentation signatures MUST use the per-RP derived key (BRC-42 with the relying party as counterparty); on-chain DID operations use the controller key. Where a secure element or hardware signer is available, signing keys SHOULD be generated and held there.

**8.8 Authenticator binding (optional).** A wallet MAY bind access to its signing keys to a FIDO2/WebAuthn authenticator — a platform secure element or roaming passkey — for phishing-resistant, hardware-backed custody, corresponding to NIST SP 800-63-4 AAL2/AAL3. Because FIDO authenticators commonly operate on P-256 rather than secp256k1, the authenticator generally gates access to the secure element that holds the secp256k1 identity keys rather than acting as the secp256k1 signer itself; where a platform authenticator does expose secp256k1, it MAY hold the signing key directly. Authenticator strength is a custody axis independent of the assurance tier (§12): it raises AAL, not the proofing level, and complements — never replaces — BRC-103/OID4VP presentation.

**8.9 Multi-device.** Scoped pseudonyms are deterministic in `s`, and `s` derives from the root secret (§8.4); a holder using two devices therefore keeps their relying-party relationships only if both devices derive the same `s`. Independent per-device secrets are non-conformant — they fork the holder's pseudonyms. A multi-device implementation MUST provision the same root secret to each device by secure-boundary-to-secure-boundary transfer (a wrapped transfer between secure elements, or the §8.6 threshold mechanism executed inside the new device's boundary), MUST NOT expose the root secret to any intermediary, sync service, or cloud reconstruction point, and MUST treat de-authorising a device as a key rotation (§7.4), which preserves pseudonyms by design. Where secure-element policy makes the root secret non-exportable, the conforming alternative is a designated proving device: other devices request presentations from it and never hold `s`.

### 9. Identity model — *Normative*

**9.1 Three levels.** The model has three levels:

1. *Root personhood identity* — one `did:bsv` per person, the control and recovery anchor, carrying the personhood commitment (the secret `s` and nullifier `n`, §8.4). It is never presented directly to relying parties (§7.7).
2. *Per-RP pairwise identifiers* — for each relying party, a derived, unlinkable identifier: the scoped pseudonym `pid = PRF(s, scope_RP)` together with a per-RP presentation key (§8.2). These are what relying parties see and store.
3. *Personas (optional)* — a holder MAY maintain multiple context identities (for example professional vs personal), each its own `did:bsv` able to hold its own credentials, optionally provable as sharing the same personhood commitment when uniqueness is required.

**9.2 Unlinkability.** Distinct relying parties MUST receive uncorrelated identifiers (P3). Pseudonym derivation MUST be one-way: from a `pid` it MUST be infeasible to recover `s`, the root DID, or any other relying party's `pid`. Cross-RP correlation MUST remain infeasible even if relying parties pool their data (§10, §13).

**9.3 Uniqueness alongside unlinkability.** All of a holder's pseudonyms derive from the one presentation secret `s`, while uniqueness rests on the one personhood nullifier `n` (§8.4); together they allow proof-of-unique-personhood (§10, §13) while keeping the pseudonyms themselves unlinkable. The scope of any uniqueness guarantee — per-RP or global — is a deliberate choice (P4) specified in §10; the identity model only requires that both be expressible.

**9.4 Delegation.** The model MUST allow a holder to delegate presentation rights or a completed KYC to another identity — for example an organisation acting for a person, or reusing one KYC across a holder's own personas. A delegation is a signed, revocable Verifiable Credential; its governance, scope, and revocation are specified in §15.

### 10. Private, verifiable, unlinkable KYC — *Normative*

**10.1 Goal.** A holder MUST be able to satisfy a relying party that they are a real, current, appropriately-assured person who meets stated conditions, while disclosing nothing beyond those conditions and presenting an identifier that cannot be correlated with the identifier they present to any other relying party. *Private* and *verifiable* are joint requirements here, not a trade-off.

**10.2 The pattern.** Three elements compose it:
- a *personhood commitment* — the credential's commitment to the presentation secret `s` and the personhood nullifier `n` (§8.4); `s` is generated in the wallet and never disclosed;
- a *scoped pseudonym* — `pid = PRF(s, scope_RP)`, computed per relying party (§9.1);
- a *presentation proof* — a zero-knowledge proof (§13) tying the pseudonym to a valid credential and to the disclosed conditions, without revealing `s`, the credential, or any undisclosed attribute.

![Figure 4 - Scoped pseudonyms](diagrams/figure-4-scoped-pseudonyms.svg)

*Figure 4 — The core pattern. A single personhood commitment yields a different, stable pseudonym at each relying party; every presentation is verifiable, yet no set of relying parties can correlate them.*

**10.3 What the proof establishes.** For a relying party with scope `r`, required predicate set `P`, and minimum tier `t`, a conforming presentation proves, in zero knowledge, that the holder knows a secret `s` and a credential `C` such that:
(a) `C` commits to `s` (and, where a uniqueness guarantee applies, to the personhood nullifier `n`, §10.7);
(b) `C` is validly attested by a source trusted at tier ≥ `t` (§10.5);
(c) `C` is current — not revoked or expired (§10.6);
(d) every predicate in `P` holds over the attributes in `C`;
(e) `pid = PRF(s, r)`;
(f) where a uniqueness guarantee applies, `C` is an active member of the anchored enrolment registry (§10.7) — proven without revealing which member;
revealing to the relying party only `pid`, the truth of `P`, and the satisfied tier — and nothing else. In particular no value derived from the personhood nullifier `n` is revealed (§8.4), and `C` itself is never shown: a commitment repeated verbatim at every presentation would be a cross-scope correlation handle as damaging as a reused identifier.

**10.4 What the relying party does and does not get.** It gets an identifier that is *stable for it* — the same person returns the same `pid` at the same scope, so one-account-per-person is enforceable locally — and *unlinkable across scopes*: another relying party's `pid` for the same person is uncorrelated, and correlation MUST remain infeasible even under collusion (§9.2). It does not learn `s`, the root DID, the credential, the holder's other pseudonyms, or any attribute value beyond the disclosed predicates.

**10.5 Attestation source and tier.** The source that attests `C` MAY be a Tier-1 self-read passport — in which case (b) is satisfied by an ICAO 9303 passive-authentication signature chaining to the issuing state's CSCA (§12), and `C` is self-issued — or a Tier-2/3 issuer or qTSP. The tier MUST be a provable attribute of the proof, so a relying party can require a minimum (for example "tier ≥ 1 AND over-18") without learning anything further. Where revealing the specific attesting source would itself correlate the holder, the proof SHOULD instead prove that the source belongs to an accepted trust set (e.g. an EU Trusted List, §17) without revealing which member (§13.4).

**10.6 Currency and revocation.** The proof MUST bind to credential and DID status (§7.5) such that a revoked or expired credential cannot produce an accepted presentation. Status MUST be checkable by the relying party without contacting the issuer (P8); §13.5 specifies privacy-preserving revocation via non-membership in a published accumulator.

**10.7 Uniqueness scope — the deliberate choice (P4).** Per-RP uniqueness — the scoped pseudonym `pid = PRF(s, r)` — gives Sybil resistance at each relying party with full cross-RP privacy and needs no shared infrastructure, because `pid` is stable for that RP yet uncorrelated across RPs. Global one-person-one-account rests on the personhood nullifier `n` (§8.4), which is deterministic from the passport and so survives re-enrolment with a fresh `s` — and it is enforced **at enrolment, never at presentation**. Two admissible mechanisms:

- *(i) Registry-enforced (Tier 1).* Enrolment publishes a registration record to the anchored enrolment registry, keyed by the deterministic uniqueness tag `tag = PRF_n(uniqueness_dst)` (Appendix C.4). The registry admits at most **one active registration per tag** — re-enrolling the same passport with a fresh wallet collides on the tag and is rejected — and every uniqueness-bearing presentation proves registry membership (§10.3(f)) without revealing which entry. One person then holds one active credential committing to one `s`, so per-scope one-account-per-person follows from the stability of `pid` alone; nothing `n`-derived need ever be revealed to a relying party. The tag is recomputable by anyone holding the chip data, so a passport reader can test *whether a document has enrolled* — a bounded, documented residual (§15.3, §20.4). Earlier drafts instead revealed a per-presentation nullifier `PRF(n, scope)`; because `n` is chip-recomputable and `scope` public, any passport reader could compute every relying party's nullifier for the holder and join dedup records back to the real passport identity. Presentation-time `n`-derived values are therefore prohibited outright (§8.4).
- *(ii) Issuance-enforced (Tiers 2–3).* An accountable provider guarantees one credential per person at issuance.

A deployment MUST state which guarantee it offers. A registration record MUST contain only the blinded commitment, the one-way tag, and the enrolment evidence — never identifying data (P12). Tier 1 alone provides only a self-asserted cryptographic anchor (`n` from the document), so a Tier-1 global-uniqueness guarantee resists casual Sybil attacks but not determined impersonation with a borrowed or stolen passport; contested registrations are resolved by accountable eviction (§12), and the accountable guarantee comes from Tiers 2–3.

**10.8 Requirements summary.** A conforming implementation MUST: derive pseudonyms with a one-way PRF (§9.2); keep cross-scope correlation infeasible under collusion; disclose no attribute beyond the requested predicates; carry the tier as a provable attribute; bind every presentation to credential/DID status; never expose the root DID (§7.7); never reveal an `n`-derived value or the commitment `C` at presentation (§8.4, §10.3); and limit any on-chain footprint to blinded commitments, revocation handles, and enrolment-registry records (§10.7).

**10.9 Regulatory scope of the pattern (informative).** The §10 pattern — predicate proof plus unlinkable pseudonym — legally serves age verification, Sybil resistance, and access gating. It does not, by itself, satisfy anti-money-laundering customer due diligence: under the EU AML framework (the 2024 AML Regulation package and its predecessors), an obliged entity must *identify* the customer and *retain* identity data — name, date of birth, and more — not merely receive a predicate, however sound the cryptography behind it. For AML-regulated onboarding, the layer's contribution is the full-disclosure mode (§14.3): verifiable, minimized, consented disclosure with strong provenance. The honest claim there is *minimized and verifiable*, not *unlinkable*. Deployments MUST NOT represent a predicate-only presentation as fulfilling customer-due-diligence obligations.

### 11. Credential and attestation layer — *Normative*

![Figure 3 - Credential lifecycle](diagrams/figure-3-credential-lifecycle.svg)

*Figure 3 — Credential lifecycle. Enrolment binds the personhood commitment; issuance produces a W3C VC (exportable to SD-JWT / mdoc / keyring); presentation is a zero-knowledge proof revealing only a pseudonym and predicates; status is checked privately. Only blinded commitments and status anchors touch the chain.*

**11.1 Canonical format.** The canonical credential and attestation type is the W3C Verifiable Credential; an *attestation* is a VC. A credential MUST commit to the holder's presentation secret `s` and personhood nullifier `n` (§8.4) and MUST be cryptographically bound to a holder key derived from the root identity (§8.2), so that only the holder can present it; this key/control binding — not embedding the DID string — is what "bound to `did:bsv`" means throughout this document. The credential MUST NOT require the resolvable root `did:bsv` to be exposed at presentation (§7.7); a verifier identifies the subject only through a scoped pseudonym derived at presentation (§10), never through the root identifier.

**11.2 Data model.** Claims SHOULD use established vocabularies (W3C / schema.org). Each attribute MUST be individually addressable so it can be selectively disclosed, or proven by predicate, without revealing its neighbours. Every credential carries, as verifiable metadata: its tier / level of assurance (§12), its attesting source, a validity period, a status/revocation pointer (11.5), and the single blinded commitment to `s` and `n` (C.4).

**11.3 Self-issued and issuer-issued credentials.** Two issuance modes correspond to the tiers (§12):
- *Self-issued (Tier 1).* The wallet packages the genuine passport data groups together with their ICAO 9303 passive-authentication evidence into a self-issued VC and commits `s`. The credential's verifiability derives from the document PKI chain — re-provable directly or in zero knowledge (§13 Layer D) — not from any third-party signature. Its limitations are those of Tier 1: authentic document, self-asserted holder binding, no issuer revocation.
- *Issuer-issued (Tier 2/3).* An accountable issuer or qTSP issues a signed VC (for example over OpenID4VCI). An issuer MAY attest over the holder's *existing* commitment `s` rather than mint a fresh identity, so an upgrade adds assurance without forking the holder's identity (P6).

**11.4 Selective-disclosure encodings.** A credential MUST be expressible in at least one selective-disclosure encoding. The layer defines three interoperable profiles: SD-JWT (EUDI interop; linkable, §13 Layer A); ISO/IEC 18013-5 mdoc (mDL-style and proximity use); and BRC-52/53 keyrings (the BSV-native profile — per-field encryption with keyring revelation and UTXO-outpoint revocation). Where a use requires §10 unlinkability, the credential MUST additionally be issuable in a form compatible with §13 Layer C/D (e.g. a BBS+ credential, or a commitment a SNARK can consume); SD-JWT alone MUST NOT be relied on where unlinkability is required.

**11.5 Status, revocation, and source trust.** A credential's status MUST be checkable by a verifier privately, without contacting the issuer (§10.6), via a `did:bsv` status operation (§7.5) and/or non-membership in a published revocation accumulator (§13.5). For issuer-issued credentials the attesting source is itself identified by a `did:bsv` and trusted through accreditation (Trusted Lists, §17); a presentation SHOULD be able to prove the source belongs to an accepted set without naming it (§13.4). Self-issued Tier 1 credentials have no issuer revocation; reliance is limited to document validity, expiry, and any published lost/stolen signals, consistent with the Tier 1 assurance ceiling (§12).

**11.6 Holder binding and non-transferability.** A credential MUST be non-transferable: presentation MUST require proof of control of the holder key and/or knowledge of `s`, so that a copied credential cannot be presented by another party.

**11.7 On-chain footprint.** Only commitments, status anchors, and revocation accumulators are written on-chain; credential contents and any PII remain off-chain in the holder's custody (P11, P12).

### 12. KYC tiers and levels of assurance — *Normative*

Identity in this system is anchored to a single persistent `did:bsv` (§7). From Tier 1 upward it also carries a persistent **personhood commitment** — to the wallet-held presentation secret `s` and the passport-derived personhood nullifier `n` (§8.4) — over which assurance then accrues as additive attestations. A holder MAY begin at any tier and upgrade; the `did:bsv` and, once established, the commitment persist across upgrades, so scoped pseudonyms and existing relationships remain stable when assurance increases. A credential's tier MUST be expressible as a verifiable attribute, so that a relying party can require a minimum tier (§13) without learning anything further.

![Figure 2 - Tier progression](diagrams/figure-2-tiers.svg)

*Figure 2 — Tiers are additive over a single persistent identity. A holder may start anywhere and upgrade; the rising boxes denote increasing assurance, while the base bar denotes the one identity and commitment that persist throughout.*

A central principle separates two ideas that are routinely conflated: **cryptographic authenticity is not identity assurance level.** A self-read passport can yield data that is provably genuine and provably from an un-cloned chip, yet still sit at the lowest assurance level, because no accountable party has verified that the person presenting it is its rightful holder.

**Tier 0 — Bare identity key.** A self-generated BRC identity key — a `did:bsv` controlled by a BRC-42-derived key (§§7–8) — with no document check and no personhood commitment. It proves only control of the key, i.e. continuity of the same pseudonymous actor, not who that actor is. Optional control proofs over an email address or phone number MAY be recorded, but these are not identity proofing and do not raise the tier.
*Assurance:* below eIDAS Low (no identity proofing). Use: pseudonymous and key-based login, throwaway sessions.

**Tier 1 — Self-read document (free).** The holder scans the passport Machine Readable Zone (MRZ) to derive the chip access key (PACE, with BAC fallback), reads the NFC chip, and the wallet performs ICAO 9303 **passive authentication** — verifying the Document Security Object signature and the data-group hashes against the issuing state's Country Signing CA via the ICAO Public Key Directory. The wallet MUST perform active or chip authentication wherever a Tier-1 uniqueness or personhood guarantee is relied upon — passive authentication alone does not detect a cloned chip, and cloning would defeat the uniqueness anchor `n` (§§8.4, 10.7); it SHOULD perform it in all cases, and MAY perform an on-device liveness and face match against the chip's facial image (DG2), which never leaves the device (§15.2). Because a substantial share of circulating passports — notably including US passports — implement neither active nor chip authentication, a deployment MUST publish a per-document-type capability matrix and define its behaviour where AA/CA is unavailable: register the document *without* a uniqueness guarantee (marked in the credential's assurance metadata), or decline Tier-1 uniqueness for that document class. Silently downgrading is prohibited. From the genuine attributes the wallet derives the personhood nullifier `n` (the uniKey) — deterministic over the document number, MRZ fields, and SOD hash; no biometric input (§8.4) — which anchors uniqueness, and separately generates a fresh, high-entropy presentation secret `s` held only in the wallet (§8.4). The trust anchor is the issuing state's document PKI; there is no third-party issuer, which is what makes the tier free.
*Proves:* the document data is authentic and the chip is genuine.
*Does not prove:* that the presenter is the rightful holder (self-liveness, if performed, remains self-asserted), nor that the document has not been revoked or reported lost/stolen.
*Assurance:* comparable to eIDAS **Low** in document-authenticity terms, but not a formal eIDAS level absent an accountable provider. Use: commerce, age-gating, and unique-account / Sybil resistance.

| Tier-1 property | Holds? |
|---|---|
| Genuine passport document | Yes |
| Genuine, un-cloned chip (with active / chip authentication) | Yes |
| Unique per document | Yes |
| Verified that the presenter is the rightful holder | No |
| Accountable issuer / regulatory KYC | No |

Tier 1 establishes *what the document is*, never *who is holding it*.

**Tier-1 enrolment, normatively.** Tier 1 has no issuer, so enrolment MUST be *publicly verifiable*: the wallet publishes a registration record — the blinded commitment (§11.1), the uniqueness tag (§10.7), and the Layer-D enrolment proof (§13.2), or a commitment to that proof with a retrieval pointer — to the anchored enrolment registry, where **anyone** can verify the proof against the published document-PKI trust root. No trusted enrolment service is introduced: the overlay that maintains the registry enforces the one-active-registration-per-tag rule mechanically, and its enforcement is checkable by any observer. Three obligations follow.
- *Trust-root governance.* In-circuit passive authentication verifies against an accepted DSC/CSCA certificate set, expressed as a published root (in practice a Merkle root over accepted certificates). A deployment MUST specify who curates that root, its update cadence, and its on-chain anchoring — noting that ICAO PKD access is paid-membership and CSCA master-list coverage is incomplete, so accepted-set coverage, not circuit performance, gates real-world availability. The curator SHOULD be a multi-party overlay function, not a single vendor.
- *Contested registrations.* A stolen or pre-read passport can be enrolled by the wrong party before the rightful holder, and Tier 1 cannot adjudicate rightful holding (§20.8). A Tier-2/3 accountable proofing event over the same document MUST therefore be able to **evict** a Tier-1 registration for the same tag and install the verified holder's commitment; the evicted party's relying-party relationships (keyed to its own `s`) do not transfer.
- *Registration-time correlation.* The registration transaction's timing and funding are a linkage surface between the holder's wallet and their enrolment; deployments SHOULD mitigate with batched anchoring windows, randomized submission delay, and third-party broadcast.

**Tier 2 — Issuer-verified.** A trusted Issuer or qTSP performs identity proofing — typically a supervised or remote document read with liveness binding carried out by an accountable party — and issues a signed credential, and/or attests to the holder's existing personhood commitment. This adds an accountable issuer and a verified holder-to-document binding, and supports issuer-side revocation and freshness.
*Assurance:* targets eIDAS **Substantial**.

**Tier 3 — In-person verified.** Identity proofing is performed in physical presence (or a supervised equivalent) by an accountable, ideally qualified, party. This gives the strongest holder binding and is the route toward a notified eID scheme and Qualified attestations.
*Assurance:* targets eIDAS **High**.

| Tier | Who vouches | Holder binding | ≈ eIDAS LoA (indic.) | Typical use |
|---|---|---|---|---|
| 0 — Bare identity key | self (key only) | none | — | pseudonymous / key-based login |
| 1 — Self-read document | issuing state's document PKI | self-asserted | Low | commerce, age-gating, Sybil resistance |
| 2 — Issuer-verified | accountable issuer / qTSP | verified remotely | Substantial | regulated services, finance onboarding |
| 3 — In-person | accountable / qualified party | verified in person | High | high-value, notified eID, Qualified attestations |

Two consequences. First, a relying party requires a **minimum** tier as a predicate (for example, "tier ≥ 1 AND over-18"), proven in zero knowledge (§13) without disclosing surplus attributes. Second, on uniqueness: Tier 1 can bootstrap **global** proof-of-unique-personhood through the personhood nullifier `n` (§8.4), since the passport document number is unique per person per document — but its holder binding is self-asserted, so a Tier-1 guarantee resists casual Sybil attacks rather than determined impersonation with a borrowed or stolen passport. Tiers 2 and 3 add accountable binding and so harden it.

**Assurance crosswalk.** The tier is a *proofing* level; mapped across frameworks:

| This spec | eIDAS LoA | NIST 800-63-4 IAL (proofing) | ICAO DTC analogue |
|---|---|---|---|
| Tier 0 | below Low | IAL1 (no proofing) | — |
| Tier 1 — self-read | ≈ Low (informal) | ≈ IAL1 — document-authentic, self-asserted binding | DTC Type 1 (eMRTD-bound, holder-generated) |
| Tier 2 — issuer-verified | Substantial | IAL2 (remote, accountable) | DTC Type 2 (issuer-generated) |
| Tier 3 — in-person | High | IAL3 (in-person / supervised) | DTC Type 2/3 |

NIST SP 800-63-4 deliberately separates proofing (IAL) from authenticator strength (AAL, §8.8) and federation (FAL, §14.6); only IAL maps to the tier, which is why custody and presentation mode are independent axes — a Tier-1 holder on a FIDO secure element is IAL1/AAL2. ISO/IEC 24760 supplies the identity-management vocabulary: its *partial identity* is this spec's persona / scoped pseudonym (§9). ISO/IEC 29115 is the older single-ordinal assurance model that both eIDAS LoA and NIST xAL supersede, and which the authenticity-vs-assurance split above deliberately moves beyond; it is a background reference only. eIDAS remains the regulatory target (Part IV).

**ICAO DTC alignment.** The passport tiers map onto ICAO's Digital Travel Credential framework. A Tier-1 self-read is a **DTC Type 1**: the virtual credential (DTC-VC) is generated by the holder from the eMRTD chip, with the passport booklet as the physical component, and — because it derives from the eMRTD — ICAO treats it as issued by the passport authority. Tier-2/3 issuer generation corresponds to **DTC Type 2** (issuer-built, device-bound) and, where no physical book is carried, **Type 3**. This gives the passport path a sanctioned international standard and a migration route into government-issued DTCs and border use (§16).

**Passport lifecycle — what `n` anchors.** The nullifier `n` is derived from chip data, and eMRTDs carry no reliable cross-document person identifier, so `n` is *per-document, not per-person*: renewing or replacing a passport yields a new document number and therefore a new `n`, and a lawful second document (dual citizenship, or a replacement issued before expiry) yields a second valid `n`. Tier-1 global uniqueness is therefore one-account-per-passport-document, not strictly one-per-person — the precise sense in which it resists casual but not determined Sybil behaviour (§10.7). Crucially this does not disturb a holder's relationships: per-RP pseudonyms derive from the wallet-held secret `s` (§8.4), so renewing a passport leaves every existing `pid` intact and only the global-uniqueness anchor `n` resets. On renewal the holder re-enrols under the new document's tag (§10.7); the superseded registration SHOULD be retired at its document's expiry, bounding the window in which one person lawfully holds two active Tier-1 registrations. Collapsing multiple documents to one person is exactly the accountable binding that Tiers 2–3 add.

### 13. Zero-knowledge toolbox — *Normative (capabilities); Informative (instantiations)*

**13.1 The separation that makes this feasible on BSV.** The chain layer — DID operations, key derivation, signing (§§7–8) — is fixed to secp256k1 by BSV. The credential and proof layer is *not* bound to that curve: a presentation proof may use whatever group its proof system requires. Pairing-based schemes (BBS+ on BLS12-381) and SNARK-friendly constructions therefore run in the credential layer while identity and control stay anchored on secp256k1. Conformance requires the *capabilities* in 13.2; named instantiations are illustrative and the toolbox is deliberately pluggable (§3).

**13.2 Capability layers (the full menu, ordered by maturity).**

- *Layer A — Selective disclosure (available now, secp256k1-native).* Reveal chosen fields, hide the rest. Instantiations: BRC-52/53 keyrings (BSV-native) and SD-JWT (EUDI interop). It hides unselected fields but reveals selected values in clear and shows a reusable issuer signature, so it is linkable across presentations — sufficient where linkability is acceptable, insufficient for §10.
- *Layer B — Attribute predicates (near-term, secp256k1-native).* Prove statements about hidden attributes — age ≥ 18, residency ∈ set — without revealing the value. Instantiation: Pedersen commitments with Bulletproof range / set-membership proofs, which need no trusted setup and run natively on secp256k1. The open problem it must solve — binding the committed attribute to the attestation without a linkable signature — is addressed in 13.3.
- *Layer C — Unlinkable presentation (medium-term).* Multi-show unlinkable selective disclosure: each presentation is uncorrelated even to the same verifier. Instantiation: BBS+ credentials on a pairing-friendly curve (BLS12-381), aligning with the EUDI/ARF direction; or a fresh per-presentation SNARK proving possession of a valid credential. This is the layer that delivers §10 unlinkability for disclosed attributes.
- *Layer D — Predicate + unlinkability + personhood (medium-term, SNARK-based).* A single succinct proof of the full §10 statement: a credential is validly attested, predicates hold, and `pid = PRF(s, scope)` for a committed `s`. Instantiation: a zk-SNARK/STARK with a SNARK-friendly PRF (e.g. Poseidon) for the nullifier and, for Tier-1 self-read credentials, a circuit that verifies the ICAO 9303 passive-authentication signature chain in-circuit — yielding a private "genuine passport, predicates hold, nullifier `pid`" proof. This is the cryptographic engine of free, private, verifiable KYC, following the emerging class of zero-knowledge passport circuits.

**13.3 The binding problem.** The central task is proving that a hidden attribute is the one an accountable source attested, without showing a reusable signature (which would be a linkage handle). Three admissible strategies:
(a) *Issuer-side commitment* — the source signs a Pedersen/Poseidon commitment to the attribute; the holder proves predicates over the commitment and, with Layer C/D, never shows the signature.
(b) *Signature-in-circuit* — verify the source's ECDSA/Schnorr (or, for Tier 1, the passport's) signature inside the proof. Schnorr over secp256k1 is materially cheaper in-circuit than ECDSA and SHOULD be preferred where the source signature scheme is a free choice.
(c) *ZK-native credential signature* — issue under a scheme built for unlinkable proof of possession (BBS+ / PS signatures); the credential-layer curve then differs from secp256k1 by design (13.1).

**13.4 Issuer-set privacy.** Where naming the attesting source would itself correlate the holder, a proof SHOULD support proving the source's membership in an accepted trust set (e.g. an EU Trusted List, §17) without revealing which member.

**13.5 Revocation, privately.** Status (§7.5, §10.6) MUST be checkable without the issuer learning of the check. Instantiation: maintain credential/nullifier revocation as a published accumulator (on-chain or overlay) and prove non-membership in zero knowledge. The published set MUST contain only opaque revocation handles or nullifiers, never identifying data (P12).

**13.6 Proving-system trade-offs (informative).** Bulletproofs — no trusted setup, good for ranges, no native multi-show unlinkability. Groth16 — tiny proofs, fast verification, per-circuit trusted setup. PLONK / Halo2 — universal or no setup, larger proofs. STARKs — transparent and post-quantum, largest proofs. BBS+ — native unlinkable multi-show, requires pairings, predicates only via extensions. A deployment selects per use case; the binding layer fixes the interfaces and statements (10.3), not the proving system.

**13.7 Where proofs are verified.** Presentation proofs are verified off-chain by the relying party. BSV anchors commitments, credential status/revocation, and — for global uniqueness — the enrolment registry and its root history (§10.7). On-chain data MUST remain limited to blinded commitments, hashes, and one-way registry tags (P11, P12); no proof or attribute is required to be verified in Bitcoin script.

**13.8 Feasibility and performance (informative).** The layers differ sharply in cost, and a deployment MUST NOT treat them as uniformly available.
- *Layers A–B (selective disclosure, predicates)* are production-ready and cheap on mobile: keyring / SD-JWT disclosure and Bulletproof range / set-membership proofs run in milliseconds to low seconds with sub-kilobyte to low-kilobyte proofs and no trusted setup.
- *Layer C (multi-show unlinkable)* via BBS+ is available in current libraries with millisecond proving.
- *Layer D (full passive-auth-in-circuit)* is the expensive case. The dominant cost is verifying the issuer's signature chain — the Document Security Object signature (RSA-2048 or ECDSA) and its link to the CSCA — inside the circuit; naive RSA-2048 verification runs to millions of constraints. It is nonetheless shippable on commodity phones today — production systems (e.g. ZKPassport, Self, OpenPassport, Rarimo) generate ICAO proofs on-device — but proving takes seconds to tens of seconds, not interactive-instant, and demands real engineering.
- *Amortisation is mandatory in practice.* The heavy passive-auth proof SHOULD be run **once at enrolment**, binding the passport to the published personhood commitment (§8.4) and a registration entry; subsequent presentations then prove cheap membership against that registration plus the requested predicates and the scoped-pseudonym PRF — Layer-A/B-class costs. Re-proving the passport on every presentation SHOULD be avoided.
- *Heterogeneity is a real cost.* States sign with different algorithms and key sizes (RSA, ECDSA, DSA, EdDSA; some legacy SHA-1), so a conforming Tier-1 circuit suite must cover several signature profiles; issuer coverage, not single-circuit speed, is the practical gating factor.
- *Proving location.* On-device proving preserves privacy; remote/server proving is faster but reveals inputs to the prover and MUST NOT be used for Tier-1 self-read, whose privacy depends on local generation.
Concrete circuit sizes, proof/verify times per device class, and the registration-versus-presentation split are conformance-suite deliverables (§21), not assumed here.

### 14. Authentication and presentation — *Normative*

**14.1 Two protocols, one identity.** A conforming wallet MUST support both presentation protocols: BRC-103 for BSV-native peer-to-peer mutual authentication and certificate exchange (Schnorr handshake over HTTP, NFC, or WebSocket), and OpenID4VP with SIOP for the W3C/eIDAS world. The same identity and credentials serve both; only the presentation envelope differs, and no re-issuance is required to move between them.

**14.2 Presentation request.** A relying party states what it needs — the required predicate set `P`, the minimum tier `t`, the presentation scope `r`, and whether unlinkability is required — as a presentation request (DIF Presentation Exchange / OpenID4VP query, or a BRC-103 certificate request). The wallet computes the scoped pseudonym and the zero-knowledge presentation proof (§10, §13) that satisfies the request with the minimum disclosure consistent with it (P1).

**14.3 Varying detail.** Disclosure granularity is set by the request and ranges over: a bare pseudonymous login (Tier 0 key control only, §12); a predicate-only proof (e.g. over-18, no identity revealed); and full attribute disclosure where the holder consents (e.g. regulated onboarding revealing name and date of birth). The wallet MUST default to the least disclosure that satisfies the request and MUST obtain holder consent for each disclosure (§15).

**14.4 Channels and replay protection.** Presentations run over web (same-device redirect or cross-device QR / deep link), WebSocket or HTTP (BRC-103 over BRC-104), and NFC for in-person/proximity use (mdoc proximity or BRC-103 over NFC). Every presentation proof MUST be bound to a fresh verifier-supplied challenge (nonce), and the transport MUST be mutually authenticated. The challenge MUST be single-use, time-boxed, and **derived from a transcript that pins the presentation scope, the verifier's identity key, and the holder's per-RP presentation key** (for BRC-103, the session identity keys; for OpenID4VP, the client identifier plus TLS channel binding). A bare random nonce prevents replay to the same verifier but not relay: without transcript binding, a malicious application holding a victim's valid proof can present it over its own authenticated session, so the party proving must be cryptographically the party authenticated.

**14.5 Mutual authentication and anti-phishing.** BRC-103 authenticates the relying party to the holder as well as the holder to the relying party. Before any disclosure, the wallet MUST show the holder the verifier's identity and accreditation and the exact attributes or predicates requested, so the holder can refuse an over-broad or unaccredited request (§15.1).

**14.6 Sessions and SSO — without a correlation honeypot.** After a successful presentation a relying party MAY open a session keyed to the scoped pseudonym. SSO is supported through the SIOP / OIDC bridge, but it MUST NOT become a central correlation point: the identifier exposed to each relying party MUST be the pairwise scoped pseudonym (§9.1), and the design MUST prevent any intermediary from correlating a holder across relying parties beyond what the holder explicitly consents to. Self-issued (SIOP) presentation or direct relying-party verification SHOULD be preferred over a hosted identity provider that observes every login; where a hosted bridge is used, it MUST NOT retain cross-RP correlation data.

### 15. Consent, data rights, and governance — *Normative*

**15.1 Consent.** Every disclosure requires explicit, informed, per-disclosure consent. Before disclosing, the wallet MUST present the verifier's identity, the attributes or predicates requested, the stated purpose, and any retention period; the holder MUST be able to decline. The wallet MUST keep a consent record (a consent receipt) of what was shared, with whom, and when; this receipt MAY be hash-anchored on-chain for non-repudiation without recording its contents (P12).

**15.2 Data minimisation and purpose limitation.** Requests MUST be satisfiable with the minimum disclosure; relying parties SHOULD request predicates rather than attribute values wherever a predicate suffices (e.g. over-18 rather than date of birth). A wallet MAY warn the holder of, or refuse, a request broader than its stated purpose. Biometric matching (the Tier-1 liveness check, §12) MUST be performed on-device only, and biometric data MUST NOT leave the holder's device, addressing its special-category status under data-protection law.

**15.3 Erasure versus immutability.** On-chain data MUST be limited to commitments, hashes, status anchors, and nullifiers — never plaintext PII (P12). Personal data lives off-chain: in the holder's wallet, and in a relying party's store only after a consented disclosure. This is designed to support the argument that the chain's immutability does not conflict with the right to erasure: erasure operates on the off-chain copies, while the on-chain commitments are salted, one-way, and openable only with the holder's secret. Whether such commitments are "personal data" is a contested legal question — the EDPB and national authorities have argued that a hash of personal data can remain personal data where it is re-linkable — so this position MUST be confirmed with data-protection counsel and rests on the high-entropy blinding required in §20.4. One on-chain value is deliberately *not* salted and needs its own analysis: the enrolment-registry uniqueness tag (§10.7) is deterministic in `n` by construction — that determinism is what enforces one-registration-per-person. It is recomputable only from chip data (§8.4), reveals nothing beyond enrolment existence, and is retired on eviction or document expiry; but it *is* re-linkable by a party holding chip data and is therefore likely personal data under the EDPB's reasoning. A deployment MUST carry this specific value in its data-protection impact assessment rather than subsuming it under the salted-commitment argument. (Design rationale, not legal advice.) Withdrawal of consent MUST be supported: when a holder revokes a consent grant, the relying party MUST delete the disclosed data, and the corresponding credential or grant status MUST be updatable so the withdrawal is verifiable (§13.5).

**15.4 Data-protection roles.** In self-sovereign use the holder is the controller of the data in their own wallet; a relying party becomes the controller of data it receives upon disclosure; an issuer is controller or processor for issuance data only. The architecture minimises issuer exposure: an issuer does not observe presentations or status checks (§7.5), so it cannot build a profile of where the holder uses their credentials.

**15.5 Delegation and power of attorney.** A delegation or power of attorney (§9.4) is expressed as a signed, scope-limited, revocable Verifiable Credential — for example granting a named party authority over a defined domain (finance, real-estate, business, family, or general) for a bounded period. Delegated authority MUST be presentable with the same privacy properties as any other credential, and its revocation MUST be effective and verifiable (§13.5).

**15.6 Governance of the trust framework.** Accreditation of issuers and certifiers — who may attest at which tier, and how that accreditation is published, audited, and revoked — MUST be governed by a defined trust framework. For the regulated path this maps onto eIDAS Trusted Lists and qTSP supervision (§17). For the BSV-native path, the accredited-issuer registry SHOULD be maintained as an overlay-discoverable, on-chain-anchored list whose entries are themselves `did:bsv` identities, so that accreditation status is resolvable and revocable by the same mechanisms as any other credential.

---

## Part IV — eIDAS interoperability profile (the maturity path)

![Figure 5 - eIDAS maturity path](diagrams/figure-5-eidas-roadmap.svg)

*Figure 5 — The three-stage eIDAS maturity path. Each stage is independently useful and has an explicit exit gate; ambition and political dependency rise left to right.*

### 16. Stage 1 — interop bridge — *Normative*

The least-ambitious, fastest stage: the BSV identity layer interoperates with the EUDI ecosystem without claiming qualified status. For travel and border use, Tier-1 credentials are additionally expressible as ICAO DTC Type 1 (§12), so one identity serves both eIDAS relying parties and DTC verifiers.

**16.1 Two bridge roles.** A deployment MAY act as either or both:
- *Relying party.* A BSV-native service accepts EUDI Wallet presentations (PID, QEAA, or EAA) over OID4VP and verifies them against EU trust anchors. To do so it MUST register with a Member State Registrar and obtain an access certificate that EUDI Wallet Units use to authenticate it.
- *Non-qualified attribute provider.* The layer issues attributes consumable by EUDI wallets as non-qualified EAAs. It MUST register as a non-qualified EAA Provider and SHOULD publish an attestation rulebook in the EU catalogue so relying parties can interpret its attributes.

**16.2 Format and protocol at the boundary.** At the EU boundary, issuance MUST use OID4VCI and presentation MUST use OID4VP, both under the HAIP profile, and credentials MUST be encoded as SD-JWT VC or mdoc; the optional W3C VC encoding MAY be used only for non-qualified EAAs and only where the counterparty accepts it (§19). The BSV-native BRC-103 and keyring path (§14) is used only inside the BSV ecosystem.

**16.3 Trust direction.** At Stage 1 the layer trusts EU anchors in order to consume EU credentials, and asks EU relying parties to trust it only at the non-qualified level. It issues no PID and makes no qualified claim.

**16.4 What it buys and what it does not.** Immediate two-way interoperability with the EUDI ecosystem; but BSV-issued attributes carry only non-qualified weight in the EU, and unlinkability at the boundary is bounded by the EUDI formats (§19.4).

### 17. Stage 2 — QEAA via a qTSP — *Normative*

Mid stage: BSV-anchored attestations gain EU-wide qualified status by being issued through a Qualified Trust Service Provider.

**17.1 The qualified route.** A Qualified Electronic Attestation of Attributes (QEAA) is issued by a qTSP under eIDAS supervision and listed on a national Trusted List aggregated into the EU List of Trusted Lists. For a BSV-anchored attestation to be qualified, the issuing entity MUST be, or operate under, a supervised qTSP, and the attestation MUST carry the `attestation_legal_category` value `QEAA`.

**17.2 Mapping BSV certifiers to Trusted Lists.** The BSV-native accredited-issuer registry (§15.6) maps onto eIDAS Trusted Lists: an issuer that is also a qTSP appears on both, and its on-chain registry entry SHOULD reference its Trusted List entry, so a verifier can resolve qualified status by either path — the EU Trusted List or the on-chain anchor.

**17.3 Lifecycle and revocation.** QEAAs MUST follow the ARF revocation rules: an Attestation Status List or Attestation Revocation List per the Commission technical specifications, or short-lived attestations (validity ≤ 24 hours) such that revocation is unnecessary. The privacy-preserving accumulator of §13.5 MUST be reconciled with these — either serving as or backing the status list, or replaced by short-lived re-issuance — without weakening private status checks (§10.6).

**17.4 Format.** A QEAA MUST be encoded as SD-JWT VC or mdoc, not W3C VC; the canonical W3C VC (§11) is exported to the required encoding (§19).

**17.5 What it buys.** EU-wide qualified recognition of BSV-anchored attributes: the chain provides the tamper-evident, privately-verifiable status substrate, while the qTSP provides the legal accountability eIDAS requires.

### 18. Stage 3 — notified eID scheme at LoA High — *Normative*

The most ambitious stage: a BSV-based wallet is the technical vehicle of a Member State-sponsored eID scheme notified at level of assurance High and recognised for cross-border authentication.

**18.1 What notification requires.** A Member State notifies an eID scheme, which then undergoes peer review. LoA High requires identity proofing at the highest assurance (in-person or an equivalent supervised process — our Tier 3, §12), key protection in a certified secure cryptographic device, and conformity with the EUDI Wallet certification scheme defined by the implementing acts.

**18.2 BSV mapping.** To reach Stage 3 the wallet MUST meet EUDI Wallet certification (a Wallet Secure Cryptographic Device and Wallet Unit Attestation, HAIP conformance, and the rest of the certification scheme); identity proofing MUST be at Tier 3; and the scheme MUST carry a PID issued under Member State authority by a designated PID Provider, alongside the `did:bsv` identity. At this stage the BSV layer operates as part of a notified national scheme rather than as an independent provider.

**18.3 Assurance mapping.** Tier 0 sits below Low; Tier 1 is comparable to Low (informally, see §12); Tier 2 targets Substantial; Tier 3 targets High. A notified scheme carrying PID at LoA High corresponds to Tier 3.

**18.4 Reality check.** Stage 3 is a long-horizon, politically-gated destination requiring Member State sponsorship and formal certification. This profile defines the technical conformance target; it does not assert a timeline. Stage 3 is the destination, not the entry point — most adoption begins at Stage 1.

**18.5 Open strategic risk (informative).** Beyond scheduling and certification, a prior question is unresolved: whether EU regulators and Member States will accept a *public, permissionless* ledger as the anchoring substrate of a notified identity scheme at all. The concerns are real and not purely technical — the data-protection optics of writing any per-identity commitment to a public chain (§15.3), the absence of a single accountable operator, and the governance and brand associations of the wider BSV ecosystem. The architecture mitigates the first (only blinded, non-identifying commitments are written on-chain, §20.4) but cannot mitigate the others by design. This risk is now evidenced, not hypothetical: at least one early Member State wallet pilot was abandoned in part because a stack relying on blockchain and zero-knowledge proofs did not meet baseline security requirements — notably protecting cryptographic material in certified secure hardware — and informed commentary expects advanced cryptography such as ZKP, and a fortiori public-ledger anchoring, to be admitted only at a later, more cautiously certified stage. The architecture's answer is on-device proving with secure-element key custody (§8) and only blinded commitments on-chain, but the burden of proof sits with this profile. This is a first-class strategic risk for Stage 3, distinct from the timeline; Stages 1–2 are deliberately structured to deliver value without depending on its resolution.

### 19. Format and trust interoperability — *Normative*

The cross-cutting mechanics that make Stages 1–3 work.

**19.1 Credential-format mapping.** The canonical internal model is the W3C VC (§11). At the EU boundary it MUST be exported to SD-JWT VC or mdoc, because EUDI mandates those two formats and permits W3C VC only for non-qualified EAAs. A conforming bridge MUST implement SD-JWT VC and SHOULD implement mdoc (for proximity / mDL and, with ISO/IEC 18013-7, remote mdoc verification).

**19.2 Protocols.** Issuance MUST use OID4VCI and presentation MUST use OID4VP, both under the HAIP profile; ISO/IEC 18013-7 applies to remote mdoc flows. These are the EU-boundary mode of the dual-protocol presentation layer (§14); the BRC-103 mode is used only within the BSV ecosystem.

**19.3 Trust anchoring.** EU trust is established through Registrar registration, access certificates, and Trusted Lists; BSV-native trust through the on-chain accredited-issuer registry (§15.6). The profile MUST let a verifier resolve an attestation's trust by either path, and an on-chain registry entry SHOULD reference the corresponding Trusted List entry where one exists.

**19.4 Unlinkability reconciliation.** The Regulation mandates unlinkability in principle — Recital 14 calls for integrating privacy-preserving technologies such as zero-knowledge proof, and the technical framework forbids any party from obtaining data that lets transactions be tracked, linked, or correlated without the user's authorisation. The ARF's own definition of full unlinkability — no party, including a provider colluding with a relying party, can tell that disclosed attributes describe the same user — coincides with the §10 goal. As of 2026 the ARF has acted on this: zero-knowledge proof is now a dedicated discussion topic with high-level requirements consolidated into Annex 2 (alongside a dedicated pseudonyms topic), referencing ETSI TR 119 476 and naming BBS+, the pairing-free ECDSA-compatible BBS#, zk-SNARKs, and ECDSA-based anonymous credentials. Two of those requirements are directly germane: a ZKP scheme is expected to generate proofs over PIDs and attestations *already issued* in ISO/IEC 18013-5 or SD-JWT VC form, and ZKP interactions MUST NOT enable tracking or linkability. Three caveats keep the gap real. First, deployment is deferred: ZKP support is expected only *after* the December 2026 launch, so the live baseline (SD-JWT VC, mdoc) is linkable and reaches verifier-unlinkability only by issuing single-use credentials in batches, at operational cost. Second, the ARF's leading ECDSA-compatible candidate, BBS#, requires per-presentation interaction with the issuer (linear scaling), whereas the §13 path supports offline, non-interactive unlinkable presentation. Third, the recent relaxation of device binding from mandatory to recommended eases anonymous-credential deployment but does not change the launch baseline. This profile therefore: (a) for the EU baseline path, emits ARF-compatible SD-JWT VC / mdoc, accepting their linkability or using batch issuance; and (b) offers the §13 Layer C/D zero-knowledge path as the privacy-preserving option aligned with Recital 14 and the Annex 2 ZKP requirements. Because those requirements describe proving over already-issued SD-JWT/mdoc credentials without linkability, this layer is positioned not merely as *ahead of* the EU baseline but as a candidate **conformant zero-knowledge presentation layer for ARF-issued credentials**, mapping onto the ARF ZKP track (BBS#/BBS+) as it is specified. One caveat scopes that claim: the ARF requirement literally describes proving over PIDs and attestations *already issued* as SD-JWT VC or mdoc — SHA-256 salted-disclosure structures under ECDSA signatures — and proving those formats inside a circuit is a substantially heavier statement than this design's enrolment-commitment circuit (§13.8). The conformance claim is therefore made for the BBS# track as the ARF specifies it, with SD-JWT-VC/mdoc-in-circuit proving named as an explicit work item (§23, Phase 1) rather than an implied capability. The honest summary: the layer's zero-knowledge path delivers unlinkability from day one and offline; its baseline-format path inherits the same linkability as the EU baseline until the ARF zero-knowledge track is actually deployed, so the standing advantage is the day-one, non-interactive property rather than a permanent capability gap (§22).

**19.5 Revocation reconciliation.** The privacy-preserving accumulator (§13.5) MUST map onto the ARF Attestation Status List / Attestation Revocation List, or be replaced by short-lived (≤ 24-hour) attestations; unlinkable revocation under collusion remains an active research area and a candidate contribution.

**19.6 Centralisation contrast (informative).** The ARF relies on centralised trust anchors, government-issued identifiers, and registry-based relying-party lookup; the BSV layer offers a decentralised, on-chain-anchored trust substrate. At Stages 1–2 the layer conforms to the EU's centralised anchors at the boundary while retaining decentralised anchoring internally — a positioning point developed in §22.

**19.7 Pseudonym reconciliation (CIR 2024/2979 / ARF Topic 11) — *Normative*.** The EU gives wallet pseudonyms a specific legal-technical meaning: Commission Implementing Regulation (EU) 2024/2979 Annex V designates W3C WebAuthn (Level 2) as the technical specification for pseudonym generation, and the ARF handles pseudonyms as Annex 2 Topic 11 — which also develops scope-rate-limited pseudonyms whose cryptography is expected to be standardized by a recognised standardisation body. The scoped pseudonym `pid` (§10) is not a WebAuthn pseudonym, so a Stage-1/2 bridge MUST NOT claim that `pid` implements the CIR 2024/2979 pseudonym requirement. A conforming bridge runs dual-stack: WebAuthn-based pseudonyms for the EU legal obligation (aligning naturally with the §8.8 authenticator binding), and `pid` for the zero-knowledge path. Topic 11's scope-rate-limited-pseudonym track is the potential convergence point for `pid` and SHOULD be tracked — noting that its standardisation-body requirement is not satisfied by a BRC alone.

---

## Part V — Closing

### 20. Security and privacy considerations — *Normative (requirements); Informative (analysis)*

**20.1 Threat model.** The adversaries of concern are: colluding relying parties seeking to correlate a user; an issuer or attestation source colluding with relying parties; a network observer; a thief of a holder's keys or device; a holder attempting to present a stolen or copied credential; and a compromised trust anchor (a CSCA, an issuer/qTSP, or a ZK trusted setup).

**20.2 Correlation and linkability.** Cross-RP correlation is defeated by scoped pseudonyms and the zero-knowledge presentation (§§9–10, §13): even pooled relying-party data cannot link a user's pseudonyms. Issuer–RP collusion is mitigated because the issuer observes neither presentations nor status checks (§7.5, §15.4) and because a presentation can prove issuer-set membership without naming the issuer (§13.4). Two residual exposures remain and MUST be addressed at deployment: (i) network-level correlation (IP, timing, device fingerprint): the unlinkability guarantee of §§9–10 is *cryptographic* and does not extend to the network layer, where most practical deanonymisation occurs. It SHOULD be mitigated with transport-level measures — oblivious HTTP (OHTTP) or a mixnet / Tor-style relay to hide network origin, plus timing padding and batched submission — and a deployment MUST NOT represent its cryptographic unlinkability as network-level anonymity; and (ii) the linkability of the EU baseline formats when the SD-JWT/mdoc path is used instead of the ZK path (§19.4).

**20.3 Key and device compromise.** Root keys SHOULD be held in a secure element. Compromise is contained by rotation and non-custodial recovery (§8.6); because pseudonyms derive from the personhood commitment rather than a signing key (§8.4), recovery preserves a holder's relationships (§7.4). Device loss is a recovery event, not an identity loss.

**20.4 Commitment confidentiality.** Any on-chain commitment MUST be blinded with high-entropy salt so it cannot be brute-forced or dictionary-attacked back to its inputs. This matters most for the personhood nullifier `n`, which is recomputable by anyone who has read the passport chip and therefore MUST never be committed or published except as a salted, one-way value — with exactly one deliberate exception, the unsalted enrolment-registry tag of §10.7, whose data-protection analysis is in §15.3. The SOD-hash input to `n` (§8.4) makes it infeasible to dictionary-attack from photo-page data alone, but chip readers recompute it trivially; genuine entropy comes only from the presentation secret `s` (§8.4). Treating `n` as if it were secret is the failure mode to avoid.

**20.5 Replay and transfer.** Presentation proofs MUST bind to a fresh, transcript-derived verifier challenge (§14.4), defeating both replay and relay. Non-transferability (§11.6) prevents a copied credential from being presented by another party. Zero-knowledge proofs in common systems (e.g. Groth16) are re-randomizable — the same statement yields unlimited distinct valid proof encodings — so proof bytes MUST NOT be used as an identifier, deduplication key, or anti-replay handle by verifiers or overlay indexers; freshness comes from the §14.4 challenge, and account identity from the scoped pseudonym only.

**20.6 Revocation freshness.** Status checks have latency bounded by resolver/accumulator synchronisation; a revoked credential could be accepted within that window. Deployments MUST state an acceptable freshness window and SHOULD prefer short-lived attestations where the window must be tight (§17.3, §19.5).

**20.7 Trust-anchor compromise.** A compromised CSCA undermines Tier 1; a compromised issuer/qTSP undermines the credentials it signed; both are contained by accreditation and registry revocation (§15.6). A compromised ZK trusted setup could forge proofs; transparent-setup systems (Bulletproofs, STARKs) avoid this, and where a setup is required it MUST use a multi-party ceremony (§13.6).

**20.8 Residual limits, stated plainly.** Tier-1 binding is self-asserted: a lost or stolen passport could be self-read by another party, so Tier-1 personhood and uniqueness resist casual abuse, not determined impersonation (§§10.7, 12). The enrolment race is the sharp instance: whoever enrols a document first holds its registration, and Tier 1 cannot distinguish the rightful holder from a thief — the normative remedy is accountable eviction by a Tier-2/3 proofing event (§12), not adjudication at Tier 1. A chip reader can also test whether a document has enrolled at all, via the deterministic registry tag (§10.7, §15.3) — bounded, but real. And secp256k1 ECDSA/Schnorr are not post-quantum; migration is possible through DID key rotation (§7.4) as post-quantum signatures and proof systems mature, and is a tracked long-term item.

### 21. Reference implementation and conformance — *Normative*

**21.1 Reference stack.** A reference implementation SHOULD build on the existing BSV TypeScript stack: the SDK wallet client and BRC-103 authentication, BRC-52/53 certificates, the `did:bsv` resolver (overlay/Teranode-native, with WhatsOnChain as a driver, §7.6), and a pluggable zero-knowledge module exposing the §13 layers (Bulletproofs on secp256k1; BBS+/BBS# on their respective curves; a SNARK toolchain including the ICAO passport circuit).

**21.2 Conformance vectors.** The standard MUST publish test vectors for: ECDSA and Schnorr over secp256k1 (§8.1); type-42 derivation (§8.2); scoped-pseudonym PRF derivation (§10); the §10.3 presentation statement for each ZK layer, including enrolment-registry membership (positive and negative); canonical-range rejection of proof public inputs — a verifier MUST reject any public signal outside the canonical field range, and the suite MUST include a negative (aliased) vector for it; date-of-birth and threshold canonicalization, including MRZ two-digit-year and Feb-29 edge vectors (the PoC document fixes the rules); the fixed domain-separation tag registry, including the permanent retirement of withdrawn tags; revocation-accumulator non-membership (§13.5); and the SD-JWT VC and mdoc export mappings (§19.1). The suite MUST additionally assert the §20.5 prohibition: no conforming component may index or deduplicate by proof bytes.

**21.3 Conformance suite.** A multi-language conformance runner (at minimum TypeScript and Go, mirroring the existing BSV conformance framework) MUST validate an implementation against the vector corpus, and MUST include EU-boundary interoperability tests for OID4VCI/OID4VP under HAIP against the EUDI reference implementation and, where possible, a Large-Scale Pilot.

**21.4 Reference flows.** The implementation SHOULD demonstrate, end to end: Tier-1 self-read passport onboarding; a predicate-only presentation (over-18) with an unlinkable pseudonym; a Tier-2 issuer/QEAA issuance; and a Stage-1 bridge presentation to an EU relying party.

**21.5 Openness.** The specification, vectors, and reference implementation SHOULD be published openly within the BSV open-source ecosystem so that conformance is independently checkable.

### 22. Comparison — *Informative*

This layer is not the first digital-identity system; its contribution is the *combination* of native unlinkability, built-in tiered KYC anchored to a free self-read tier, decentralised on-chain trust, and eIDAS interoperability on one scalable chain.

| Dimension | This proposal | EUDI-native | Sovrin / Indy (AnonCreds) | ION / Sidetree | Centralised IdP |
|---|---|---|---|---|---|
| Identifier anchoring | `did:bsv` on BSV (UTXO, SPV) | none; PKI + registries | permissioned ledger | `did:ion` (Bitcoin + off-chain store, batched) | account at provider |
| Unlinkability (multi-show / collusion) | native, collusion-resistant, day-one | baseline linkable; ZK post-launch / batch issuance | yes | n/a (identifier only) | none; provider sees all |
| Predicate / ZK proofs | yes (§13), offline | in ARF Annex 2; deployed post-launch | yes | no | no |
| Built-in KYC / personhood | yes; tiered, free self-read | yes; PID (government) | no | no | no |
| Trust-anchor decentralisation | on-chain registry | centralised | consortium | decentralised id, off-chain data | centralised |
| eIDAS interop / standing | yes (Part IV) | native | limited | limited | no |
| Scale & cost | high throughput, low fee | PKI-bound; issuer batch cost | consortium-limited | Bitcoin throughput; batched | high (centralised) |

A few points the table compresses. The EUDI Wallet is the regulatory destination, not a competitor: this layer interoperates with it (Part IV); its standing advantage is unlinkability *from day one and offline*, where the ARF mandates the property and has now written high-level ZKP requirements into Annex 2 but defers their deployment to after the December 2026 launch (§19.4) — which also makes this layer a candidate conformant ZK presentation layer for ARF-issued credentials rather than only a competitor (scoped as in §19.4: via the BBS# track, with SD-JWT/mdoc-in-circuit proving a named work item). Hyperledger Indy with AnonCreds pioneered unlinkable selective disclosure and predicate proofs and deserves that credit; the difference here is the ledger model — a permissioned validator consortium versus a public, high-throughput UTXO chain with SPV — and the addition of passport-anchored personhood and eIDAS interop. ION/Sidetree anchors decentralised identifiers on Bitcoin but is an identifier layer only, with DID documents kept in content-addressed storage (an availability dependency) and batched anchoring latency; this layer anchors directly and adds the credential, KYC, and zero-knowledge stack above the identifier. Centralised identity providers are convenient but make the provider a correlation point that sees every login (§14.6), hold the user's data, and carry no verifiable KYC or portability.

### 23. Roadmap and phasing — *Informative*

Delivery is phase-gated and aligned to the eIDAS calendar — national EU Digital Identity Wallets due by late December 2026 and mandatory relying-party acceptance (regulated sectors, very large online platforms) following roughly a year later, with real-world rollout lagging into 2027. Each phase has an explicit exit gate.

**Phase 0 — Foundations.** `did:bsv` resolution (overlay/Teranode-native), key management and recovery, BRC-103 and OID4VP presentation, the W3C VC model with SD-JWT VC export, Tiers 0–1 (including free self-read passport onboarding), and Layer-A selective disclosure. Delivers the substrate, free KYC, and basic login; corresponds to the Stage-1 bridge. *Gate:* conformance vectors pass; security review of key handling and the self-read pipeline.

**Phase 1 — Predicates and unlinkability.** Zero-knowledge Layers B–D: range/predicate proofs, unlinkable presentation, the enrolment registry with membership proofs (§10.7), and the ICAO passport circuit. This is the privacy differentiator. It also carries the SD-JWT-VC/mdoc-in-circuit proving work item (§19.4) toward ARF ZKP conformance. *Gate:* ZK audit (including any setup ceremony); unlinkability tested against pooled-RP collusion.

**Phase 2 — Qualified interoperability.** Stage 2 (QEAA via a qTSP), Trusted List mapping, mdoc and ISO/IEC 18013-7, full OID4VCI/VP HAIP conformance, and Tier-2 issuers. Timed to meet relying-party obligations. *Gate:* EU-boundary interop tests pass; a qTSP partnership in place.

**Phase 3 — National scale.** Stage 3 (notified eID at LoA High, Tier 3, PID under Member State authority) and EUDI Wallet certification. Long-horizon and politically gated. *Gate:* certification and Member State sponsorship.

**Beyond — organisational identity.** Legal-person and organisational identity (out of scope here, §3) is future work, anchored on ISO 17442 LEI / GLEIF vLEI and bridged through the delegation model (§§9.4, 15.5).

### 24. Conclusion and appendices

**Conclusion.** BSV already holds the pieces of a national-grade identity system — type-42 keys, BRC-103 authentication, BRC-52/53 selective-disclosure certificates, and a registered, UTXO-friendly `did:bsv` — but they have stood as two unconnected stacks. This proposal binds them into one standard whose defining property is KYC that is private, verifiable, and unlinkable: a person proves they are a real, current, appropriately-assured human who meets a relying party's conditions, presents a different identifier to every service, and cannot be correlated across services even under collusion. Onboarding begins free, with a self-read passport, and rises through issuer-verified, in-person, and ultimately notified-eID assurance. The layer interoperates with eIDAS at every stage and is unlinkable by default from day one, where the EU has written zero-knowledge requirements into the ARF but defers them to after the December 2026 launch — positioning this layer as a candidate conformant ZK presentation layer for ARF-issued credentials (via the BBS# track, §19.4), not merely a competitor. The next steps are to publish it as a BRC and an eIDAS interoperability profile, build the open reference implementation and conformance suite (§21), and engage a qTSP and a Member State for the qualified and notified stages.

**Appendix A — BRC reference.**

| BRC | Subject | Role here |
|---|---|---|
| 1 | Abstract messaging layer | carried certificate requests (BRC-53, historical) |
| 2 | Encryption | field encryption for keyrings |
| 3 | Digital signatures | certificate field signatures |
| 42 | Key derivation (type-42) | per-counterparty keys (§8) |
| 43 | Security levels, protocol/key IDs, counterparties | derivation addressing (§8) |
| 52 | Identity certificates | selective-disclosure certificates (§11) |
| 53 | Certificate creation and revelation | historical; superseded by the BRC-100 certificate methods (`acquireCertificate`, `listCertificates`, `proveCertificate`, `relinquishCertificate`) — cited for lifecycle concepts (§11) |
| 100 | Wallet-to-application interface | wallet API substrate and the live certificate interface (§5.1, §11) |
| 103 | P2P mutual authentication & certificate exchange | BSV-native presentation (§14) |
| 104 | HTTP transport for BRC-103 | `.well-known/auth` endpoint and `x-bsv-auth` headers; the web transport of §14 |
| 107 | Mandala token protocol | base for identity-linked tokens |
| 108 | Identity-linked tokens | KYC/AML-gated assets (§5.1) |

**Appendix B — `did:bsv` profile — *Normative*.**

This appendix consolidates §7 into a concrete profile over the registered `did:bsv` method [DID-BSV], W3C DID Core [DID-CORE], and W3C DID Resolution [DID-RES]. It adds requirements to the method; it does not redefine it.

**B.1 Identifier syntax.** A DID is `did:bsv:<method-specific-id>`, where the method-specific identifier is the hex-encoded transaction ID of the DID issuance transaction. Resolution decodes it from hex to the binary txid and follows the on-chain operation chain (B.5).

**B.2 DID Document profile.** The default is self-sovereign (subject is its own controller, §7.3); the document lists the holder's secp256k1 keys directly:

```json
{
  "@context": ["https://www.w3.org/ns/did/v1"],
  "id": "did:bsv:<txid-hex>",
  "verificationMethod": [{
    "id": "did:bsv:<txid-hex>#subject-key",
    "type": "JsonWebKey2020",
    "controller": "did:bsv:<txid-hex>",
    "publicKeyJwk": { "kty": "EC", "crv": "secp256k1", "x": "...", "y": "..." }
  }],
  "authentication": ["did:bsv:<txid-hex>#subject-key"],
  "assertionMethod": ["did:bsv:<txid-hex>#subject-key"]
}
```

Requirements:
- Every `verificationMethod` MUST be a secp256k1 key (`JsonWebKey2020` with `publicKeyJwk` `kty:"EC"`, `crv:"secp256k1"`), derived under §8.
- `authentication` MUST be present (BRC-103 handshake and presentation control). `assertionMethod` SHOULD be present where the DID acts as a credential issuer (Tier 2/3). `capabilityInvocation` / `capabilityDelegation` MAY express delegation (§9.4); `keyAgreement` MAY be present for keyring key-wrap.
- The root DID Document MUST NOT carry attributes or services that identify the natural person: it is a control and recovery anchor, never a presentation identifier (§7.7, P12). `service` entries SHOULD be limited to control/recovery endpoints (e.g. `LinkedDomains`).
- In the non-SSI case a `controller` property names the controller's `did:bsv`, and the subject document lists the subject key while the controller is resolved separately, per [DID-BSV].

**B.3 Control and the 1-of-2 arrangement (§7.3).** Subject and controller each hold secp256k1 keys that sign DID transactions. Either party MAY deactivate or rotate (1-of-2). A new DID Document version MUST be signed by **both** subject and controller; the preceding funding transaction MAY be signed by either. In SSI use the holder is both, holding both key pairs.

**B.4 Operations (§7.2, §7.4).**
- *Create* — two transactions: a DID issuance transaction and the first DID Document transaction. The issuance txid becomes the method-specific identifier.
- *Update / rotate* — a funding transaction (either party) followed by a DID Document transaction (both parties). The DID is unchanged; superseded keys remain in history with their validity windows, so prior signatures stay verifiable (§7.4).
- *Deactivate / revoke* — a revocation transaction spending the chain-tip UTXO, by either party.
Each operation spends the prior state's UTXO-0, yielding an ordered, double-spend-protected, timestamped chain from which the current document is deterministically reconstructed.

**B.5 Resolution (§7.6).** Per [DID-BSV]: decode the method-specific id to a txid and make it current; fetch the transaction spending its UTXO-0; if that is a DID Document transaction whose own UTXO-0 is unspent, return it; if spent, make it current and repeat; a funding transaction is skipped (made current, repeat); a revocation transaction returns the last document with metadata `deactivated:true`. A `versionId` query selects a specific DID Document transaction by txid. Profile additions:
- The resolver MUST verify the operation chain under SPV (§7.6, P11).
- The normative resolution path MUST run over BSV-native infrastructure (overlay / Teranode). A public indexer (e.g. WhatsOnChain) MAY be a driver but MUST NOT be the sole trust or availability dependency.
- Resolution metadata MUST express the block height at which status was determined, and SHOULD support caching with a freshness indicator.

**B.6 Status (§7.5).** `active` / `deactivated` is derived from the chain (a revocation transaction sets `deactivated`). A verifier MUST be able to determine status independently, without contacting the issuer or a DID manager (P8). DID status complements credential status (Appendix C.3): a deactivated root DID invalidates any presentation bound to it.

**B.7 Resolution result.** A resolver returns a standard W3C result: `didDocument`; `didResolutionMetadata` (content type, any `error`, and the block height at which the chain was read); `didDocumentMetadata` (`created`, `updated`, `deactivated`, `versionId`, and, where known, `nextUpdate`).

**B.8 §7 conformance map.** 7.1 Adoption → B.1–B.2; 7.2 Operations → B.4; 7.3 Control → B.3; 7.4 Rotation/continuity → B.4; 7.5 Status/revocation → B.6; 7.6 Resolution → B.5, B.7; 7.7 Root-not-a-presentation-identifier → B.2 (no person-identifying data in the document).

*References:* [DID-BSV] the registered `did:bsv` method specification (TNG/Teranode); [DID-CORE] W3C Decentralized Identifiers (DIDs) v1.0; [DID-RES] W3C DID Resolution.

**Appendix C — Data schemas — *Normative (structure); Informative (examples)*.**

These are interoperability profiles over existing standards; exact wire encodings are finalised with the reference implementation (§21). References are listed at the end.

**C.1 Credential / attestation (W3C VCDM 2.0 [VCDM2]).** A credential is a W3C Verifiable Credential:

```json
{
  "@context": [
    "https://www.w3.org/ns/credentials/v2",
    "https://bsvblockchain.org/ns/unified-identity/v1"
  ],
  "type": ["VerifiableCredential", "BsvIdentityCredential"],
  "issuer": "did:bsv:<issuer>",
  "validFrom": "2026-01-01T00:00:00Z",
  "validUntil": "2031-01-01T00:00:00Z",
  "credentialSubject": {
    "personhoodCommitment": {
      "commitment": "<single blinded commitment binding s, n, and the addressable attributes (C.4)>",
      "scheme": "poseidon-commit-v1"
    },
    "assurance": { "tier": 1, "loa": "low-indicative" },
    "claims": { "given_name": "...", "family_name": "...", "birthdate": "...",
                "age_over_18": true, "nationality": "..." }
  },
  "credentialSchema": { "id": "https://bsvblockchain.org/schema/identity/v1", "type": "JsonSchema" },
  "credentialStatus": { "...": "see C.3" },
  "evidence": [ { "...": "Tier-1 passive-auth record or Tier-2/3 proofing record" } ],
  "proof": { "...": "DataIntegrityProof, or carried in an SD encoding (C.2)" }
}
```

Requirements: a credential MUST commit to both `s` and `n` (§8.4, §11.1) in a single blinded commitment (C.4, §20.4); the tier/LoA MUST be a provable, verifiable attribute (§12); each claim MUST be individually addressable for selective disclosure or predicate proof (§11.2); `issuer` is a `did:bsv` for Tier 2/3, while a Tier-1 credential is self-issued and its `evidence` carries the ICAO 9303 passive-authentication record (DSC→CSCA chain, data-group hashes, the Document Security Object) in place of a third-party signature (§11.3); for Tier-1 self-issued credentials `credentialStatus` reduces to document validity, expiry, and any lost/stolen signal (no issuer revocation, §11.5).

**C.2 Selective-disclosure encodings (§11.4).** A credential MUST be expressible in at least one of:
- *SD-JWT VC* [SD-JWT-VC] over SD-JWT [SD-JWT / RFC 9901]: media type `application/dc+sd-jwt` (earlier drafts `vc+sd-jwt`); `vct` carries the type (it is **not** selectively disclosable, so choose a value that leaks nothing, per the spec's data-minimisation note); `cnf` carries the holder key for Key Binding (KB-JWT); `status` points to a Token Status List (C.3); selectively-disclosable claims are salted digests (≥128-bit salt). This profile is linkable across colluding verifiers (§13 Layer A) and MUST NOT be the sole encoding where §10 unlinkability is required.
- *ISO/IEC 18013-5 mdoc* [MDOC]: CBOR, namespaced data elements, a Mobile Security Object; proximity over NFC/BLE and remote over ISO/IEC 18013-7.
- *BRC-52/53 keyrings*: per-field BRC-2 encryption and BRC-3 signatures revealed through a keyring, with UTXO-outpoint revocation (the BSV-native profile).
Where §10 unlinkability is required, the credential MUST additionally be issuable in a Layer C/D form: a BBS+ credential, or a commitment a SNARK can consume (C.4).

**C.3 Status and revocation.** Two complementary layers.
- *Interoperable status pointer.* Either a W3C Bitstring Status List entry [BSL] — `credentialStatus` of type `BitstringStatusListEntry` with `statusPurpose` (`revocation`/`suspension`), `statusListIndex`, and `statusListCredential` — or, for SD-JWT/mdoc, a `status` claim referencing an IETF Token Status List [TSL]: a compressed bit array published as a signed Status List Token (JWT/CWT), giving herd anonymity (a verifier retrieves many statuses, so the issuer does not learn which credential was checked). Both reveal the issuer's aggregate revocations, and if fetched from the issuer they leak the timing of the check.
- *Privacy-preserving accumulator (§13.5),* REQUIRED where the no-issuer-contact property (P8) and unlinkability are both needed:

```json
{
  "accumulator": "did:bsv:<registry>#rev-2026",
  "anchorOutpoint": "<txid>:<vout>",
  "scheme": "merkle-sparse-v1 | rsa-acc-v1 | allosaur-v1",
  "revocationHandle": "<opaque, blinded>",
  "nonMembershipProof": "<zero-knowledge proof — presented, never stored>"
}
```

The published set MUST contain only opaque handles or nullifiers, never identifying data (P12). Anonymous, oblivious revocation checks are achievable with accumulator constructions of the AnonCreds / ALLOSAUR class. The current accumulator value is anchored on-chain or on an overlay.

**C.4 Personhood commitment, uniqueness tag, and pseudonym (§8.4, §10).**
- *Presentation secret* `s` — high-entropy (≥128-bit), wallet-generated, domain-separated; recovered via §8.6, never from a document.
- *Personhood nullifier* `n` (the uniKey) — `n = H_dst("bsv-personhood-n" ‖ canonical(passport_identity))`, a one-way hash over the canonicalised passport identity: document number, MRZ fields, and SOD hash (§8.4 — deliberately no biometric data group). Deterministic, **not** secret, and never used at presentation.
- *Commitment in the credential* — a single blinded commitment `C = Commit(s, attrs, n; salt)` (§20.4): Pedersen on the proof-system group, or Poseidon inside a SNARK circuit. `C` is the enrolment-registry leaf at Tier 1 (§10.7). A tier upgrade re-attests by issuing a fresh `C` (new salt, updated assurance metadata) over the same `s` and `n`; the registry replaces the entry under the unchanged tag, so pseudonyms and uniqueness both persist (P6). Earlier drafts specified two separate commitments (`C_s`, `C_n`); the single-commitment form is normative — it is what the presentation circuit opens and the registry stores — and dual-commitment encodings are non-conformant.
- *Scoped pseudonym* — `pid = PRF_s(scope_RP)`, with a SNARK-friendly PRF (e.g. Poseidon) where proven in zero knowledge, or HMAC-SHA-256 where no proof is needed; `scope_RP` is the verifier's stable scope (§14.2).
- *Enrolment uniqueness tag* (§10.7) — `tag = PRF_n("bsv-uniqueness-tag")`, published once in the registration record. Deterministic and unsalted by construction (§15.3, §20.4); never revealed at presentation. This replaces the withdrawn `gnull` global-set nullifier of earlier drafts, which was recomputable by chip readers and is prohibited (§8.4).
- *Domain-separation registry* — every PRF/hash use MUST take its tag from a single published registry; the PoC document fixes the initial field-constant assignments and permanently retires the withdrawn presentation-nullifier tag. Tags MUST keep `s`-derived pseudonyms and `n`-derived values in disjoint spaces, so pseudonyms are never derivable from `n` (§8.4). A retired tag MUST never be reassigned.

**C.5 Consent receipt (ISO/IEC TS 27560:2023 [27560], building on ISO/IEC 29184 [29184] and Kantara CR v1.1 [KCR]; §15.1).**

```json
{
  "header": { "receiptId": "...", "timestamp": "...",
              "schema": "iso-27560:2023+dpv", "version": "1" },
  "parties": {
    "controller": { "id": "did:bsv:<rp>", "name": "...",
                    "accreditation": "<Trusted List reference>" },
    "principal": { "pseudonym": "<pid>" }
  },
  "consent": {
    "purposes": ["age-verification"],
    "disclosed": ["age_over_18"],
    "legalBasis": "consent",
    "processing": ["use"],
    "retention": "P0D",
    "collectionMethod": "oid4vp | brc-103"
  },
  "status": { "state": "active | withdrawn", "updated": "..." }
}
```

The principal is identified **only** by the scoped pseudonym `pid`, never the root identity (§7.7). The receipt MAY be hash-anchored on-chain for non-repudiation, recording only a salted commitment to the receipt and never its contents (§15.1, P12). Withdrawal sets `status.state` to `withdrawn` and triggers the deletion obligation (§15.3). Field semantics SHOULD use the Data Privacy Vocabulary [DPV] for interoperability.

*References:* [VCDM2] W3C Verifiable Credentials Data Model 2.0 (Recommendation, 2025-05-15); [SD-JWT-VC] IETF SD-JWT VC (draft-ietf-oauth-sd-jwt-vc); [SD-JWT] RFC 9901 (Selective Disclosure for JWTs); [MDOC] ISO/IEC 18013-5 and 18013-7; [BSL] W3C Bitstring Status List v1.0 (Recommendation, 2025-05-15); [TSL] IETF OAuth Token Status List (draft-ietf-oauth-status-list); [27560] ISO/IEC TS 27560:2023; [29184] ISO/IEC 29184:2020; [KCR] Kantara Consent Receipt v1.1; [DPV] Data Privacy Vocabulary. Commitment, PRF, and accumulator constructions follow standard cryptographic literature (Pedersen commitments; Poseidon; AnonCreds; ALLOSAUR).

**Appendix D — Glossary.**

- *Accumulator* — a compact set representation supporting (non-)membership proofs; used for privacy-preserving revocation (§13.5).
- *BBS+ / BBS#* — anonymous-credential signature schemes giving multi-show unlinkable selective disclosure; BBS+ needs pairing-friendly curves, BBS# is pairing-free and ECDSA-compatible.
- *DTC (ICAO Digital Travel Credential)* — the digital form of an eMRTD; Type 1 is holder-generated from the chip (≈ Tier 1), Type 2/3 are issuer-generated (≈ Tier 2/3) (§12).
- *FIDO2 / WebAuthn / CTAP* — phishing-resistant authenticator standards; an optional custody layer that raises NIST AAL independently of the proofing tier (§8.8).
- *HAIP* — High Assurance Interoperability Profile for OID4VCI/OID4VP.
- *IAL / AAL / FAL* — NIST SP 800-63-4 assurance dimensions (identity proofing, authenticator strength, federation), selected independently; only IAL maps to the tier (§12).
- *ICAO 9303 / passive authentication* — the electronic-passport standard, and the verification that chip data is genuine via the issuing state's PKI.
- *LEI / vLEI* — ISO 17442 Legal Entity Identifier and its GLEIF verifiable-credential form; the intended anchor for future organisational identity (§3, §23).
- *LoA* — eIDAS level of assurance: Low, Substantial, High.
- *mdoc* — the ISO/IEC 18013-5 mobile-document credential format (CBOR).
- *Scoped pseudonym* — `pid = PRF(s, scope)`; stable per scope, unlinkable across scopes (§10).
- *Personhood nullifier `n` (uniKey)* — a deterministic, one-way, passport-derived value (document number, MRZ, SOD hash) anchoring global uniqueness at enrolment; not a secret, and never surfaced at presentation (§8.4, §10.7).
- *Enrolment registry / uniqueness tag* — the anchored registry of active personhood commitments, admitting one active registration per deterministic tag `PRF_n(dst)`; presentations prove membership without revealing the entry (§10.7).
- *OID4VCI / OID4VP* — OpenID for Verifiable Credential Issuance / Presentation.
- *PID / QEAA / EAA* — Person Identification Data; Qualified Electronic Attestation of Attributes; Electronic Attestation of Attributes.
- *Personhood commitment* — a credential's single blinded commitment binding two values: the wallet-held presentation secret `s` (source of pseudonyms and holder binding) and the passport-derived nullifier `n` (the uniKey, anchor of uniqueness) (§8.4, §10, C.4).
- *qTSP* — qualified trust service provider.
- *SD-JWT VC* — the selective-disclosure JWT verifiable-credential format.
- *Trusted List* — the eIDAS register of supervised and qualified providers.

**Appendix E — Conformance vectors.** Index of the published test vectors (§21.2). *(To accompany the reference implementation.)*
