# Agent ID Hub — Hackathon Submission Draft

Status: DRAFT. Do not submit until the contract is deployed, verified on
BscScan, and Yovmi confirms. Submission period ends 2026-12-09 08:00 UTC
(15:00 WIB).

## Project name
Agent ID Hub

## Website
https://yovmiar19.github.io/agent-id-hub/
(Source: frontend/index.html in the repo https://github.com/yovmiar19/agent-id-hub)

## Contract address(es)
- AgentIdHub: **0x41b97784E1916FDe43bd3a7bD105a94A8f565f69** (BSC chain 56)
- Deploy tx: 0xcb1a6e8aa8ed333417a181ef5037a6e3b09d67307c934ec5b4dce5b289256577, block 134335646
- BscScan: https://bscscan.com/address/0x41b97784E1916FDe43bd3a7bD105a94A8f565f69

## Agent ID usage description
Agent ID Hub is built around the Binance Agent ID (.ai) as the identity and
access layer. Every state-changing function on the contract requires the
caller to hold an Agent ID: the contract reads
`balanceOf(msg.sender)` on the SPACE ID Agent ID registry
(0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F, ERC-721, non-transferable) and
reverts otherwise. Three features use it:
1. Profile — an Agent ID holder registers a short bio bound to their Agent ID.
2. Daily check-in — an Agent ID holder checks in once per UTC day and builds
   a streak. This is the repeatable, low-cost interaction that grows the
   number of interacting Agent ID addresses.
3. Tip by name — an Agent ID holder sends BNB to another holder by their .ai
   name (resolved to an address in the frontend via namehash + ownerOf on
   the registry). The contract re-checks that the recipient holds an Agent ID
   before accepting the tip. This is Agent ID as identity and payments.

No fee, no token, no owner privilege that can move user funds. The contract
is open-source (MIT) and the source is verified on BscScan.

## Safety red lines — compliance notes
- No web-based QR code login for Agentic Wallet. The frontend uses a normal
  injected wallet connection only; it never asks for a QR or pairing code.
- No bypass of user transaction confirmation. Every action is a transaction
  the user reviews and confirms in their own wallet.
- No unauthorized asset transfers. Tips only move the exact amount the sender
  specifies in their own transaction; there are no scheduled, bundled or
  automatic transfers and no unlimited approvals.
- Contracts open-source with disclosed owner permissions. The contract has no
  owner-only function that can move funds; this is stated in the code comments.
- No Binance/BNB brand impersonation. The project is named "Agent ID Hub" and
  states it is an independent community project, not affiliated with Binance
  or SPACE ID.
- No collection of sensitive credentials. The dApp never asks for seed phrases,
  private keys, API secrets or pairing codes.
- No promise of returns. Nothing in the product promises income or rewards.
- Trading: the product does not involve trading, so no trading risk warning
  applies. Tipping is a voluntary transfer and the UI says so.

## Community Promotion Award — draft X post (for Yovmi to post)
Hashtags required: #BinanceWalletHackathon and #AgenticWallet. Submit the X
link via the official campaign survey.

Draft:
"Built something for the Agent ID Hackathon: Agent ID Hub — a home for .ai
holders on BNB Chain. Set your profile, check in daily to build a streak,
and tip other Agent ID holders by name. Only .ai holders can use it, checked
on-chain. #BinanceWalletHackathon #AgenticWallet"

Note: post only after the project is live and the website/contract links can
be included. Do not post from Muse; Yovmi posts from his own X (@iremen29).
