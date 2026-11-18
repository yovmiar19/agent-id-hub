# Agent ID Hub — Design (Binance Agent ID Hackathon)

## Goal
Build a dApp on BNB Chain that actively uses Agent ID, for the Agent ID Hackathon
(60,000 USDC pool, submission 2026-11-18 08:00 UTC to 2026-12-09 08:00 UTC).
Two project award categories (top 10 each, 29,000 USDC each): metrics-based
(interacting Agent ID addresses, volume, tx count) and Innovation Award (judged;
needs live product + min 30 Agent ID addresses interacting during submission).

## Concept: Agent ID Hub
One dApp, three features, all gated to Agent ID holders:
1. **Profile** — an Agent ID holder registers a short bio linked to their Agent ID.
2. **Daily check-in** — an Agent ID holder checks in once per day, building a streak.
   Cheap (gas only) and repeatable, so it drives the most interactions.
3. **Tip by name** — send BNB to another Agent ID holder by their .ai name
   (e.g. yovmi.ai), without needing their wallet address. Real payments use case.

## How Agent ID is used on-chain (the gate)
- Agent ID registry (SPACE ID, ERC-721, non-transferable):
  `0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F` on BNB Chain (chain 56).
- Every state-changing function requires the caller to hold an Agent ID:
  `IERC721(AGENT_ID).balanceOf(msg.sender) > 0`, else revert.
  This is the proven pattern used by Coracle Agents and Horror Protocol.
- Name resolution (.ai name to wallet address) is done in the frontend via
  SPACE ID (SID Registry + Public Resolver, namehash). The contract accepts the
  resolved address and re-checks that the recipient holds an Agent ID before
  accepting a tip. Verify the exact tokenId derivation from the registry
  contract before finalising the resolver.

## Contract (single contract, Solidity, BNB Chain)
- `AgentIdHub.sol`, SPDX MIT, Solidity ^0.8.20, OpenZeppelin ERC721-holder check
  via the registry interface (no OZ dependency needed beyond IERC721).
- State:
  - `mapping(address => string) profileBio` + `mapping(address => uint256) profileUpdatedAt`
  - `mapping(address => uint256) lastCheckInDay` + `mapping(address => uint256) streak`
  - `mapping(address => uint256) tipsReceived` + `mapping(address => uint256) tipsSent`
  - `uint256 totalCheckIns`, `uint256 totalTips`, `uint256 totalTippedWei`
- Functions (all gated to Agent ID holders unless noted):
  - `setProfile(string calldata bio)` — bio max 280 chars.
  - `checkIn()` — once per UTC day; increments streak if yesterday, else resets to 1.
  - `tip(address payable recipient, string calldata message)` payable — recipient
    must hold an Agent ID; forwards msg.value minus nothing (no fee); emits event.
  - `tipByName` is a frontend convenience: resolve name to address off-chain,
    then call `tip()`. Do not put name parsing on-chain.
- Events: `ProfileSet`, `CheckedIn`, `Tipped` (all indexed by address).
- No owner-only mint, no pause, no fee, no token. Owner is only used for nothing
  privileged; keep the contract ownerless where possible and document that no
  owner permission can move user funds.
- Safety red lines (from the hackathon rules): no QR login, no bypassing user
  transaction confirmation, no unauthorized transfers, no collecting credentials,
  no promising returns, no Binance/BNB brand impersonation, open-source with
  disclosed permissions.

## Frontend
- Static web app (no backend, no server-stored sessions). Connect wallet via
  WalletConnect / injected wallet; read Agent ID holding from the registry;
  show check-in, profile and tip UI. Display risk note that tipping is a
  voluntary transfer.
- Host as a static page; link it in the submission with the contract address.

## Deployment and submission
- Deploy to BNB Smart Chain (chain 56) with the deployer wallet Yovmi names.
  Verify source on BscScan and open-source the repo.
- Submission needs: project name, website, contract address(es), Agent ID usage
  description, and other required materials. No registration needed.
- Gas: deployment needs BNB. Yovmi's BSC wallet holds ~0.000149 BNB (2026-11-18),
  likely not enough; confirm the exact deployment cost from the estimate and ask
  Yovmi to fund the deployer before broadcasting.
- Preview every deployment transaction and wait for Yovmi's confirmation before
  broadcasting (on-chain safety rails).

## Distribution (to reach 30+ interacting Agent ID addresses)
- The check-in is the growth loop: free, daily, streak-based. Share the dApp in
  Agent ID communities and on X. The Community Promotion Award (X posts with
  #BinanceWalletHackathon and #AgenticWallet, 20 winners share 2,000 USDC) is a
  separate, easier prize to pursue in parallel.
- Track interacting Agent ID addresses on-chain (events + balanceOf checks).

## Open questions to resolve during build
- Exact tokenId derivation for an .ai name on the Agent ID registry (for the
  frontend resolver; confirm against the registry contract / SPACE ID docs).
- Exact deployment gas cost (estimate before asking Yovmi to fund).
- Whether to use a single contract or split profile/check-in/tip (single is
  simpler and cheaper to deploy; keep single unless a reason appears).
