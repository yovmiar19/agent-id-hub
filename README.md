# Agent ID Hub

A home for Binance Agent ID (.ai) holders on BNB Chain. Built for the
Binance Agent ID Hackathon (60,000 USDC prize pool).

## What it does

- **Profile** — an Agent ID holder sets a short bio bound to their Agent ID.
- **Daily check-in** — check in once per UTC day and build a streak.
- **Tip by name** — send BNB to another Agent ID holder using their .ai name.

Every state-changing function requires the caller to hold an Agent ID. The
contract reads `balanceOf(msg.sender)` on the SPACE ID Agent ID registry
(`0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F`, ERC-721, non-transferable)
and reverts otherwise. The tip recipient must also hold an Agent ID.

No fee, no token, no owner privilege that can move user funds. The contract
is open-source (MIT).

## Deployed contract

- Network: BNB Smart Chain (chain 56)
- Address: `0x41b97784E1916FDe43bd3a7bD105a94A8f565f69`
- BscScan: https://bscscan.com/address/0x41b97784E1916FDe43bd3a7bD105a94A8f565f69
- Deploy tx: `0xcb1a6e8aa8ed333417a181ef5037a6e3b09d67307c934ec5b4dce5b289256577`

## Frontend

`frontend/index.html` is a static page (ethers.js via CDN). Open it in a
browser with an injected wallet on BNB Smart Chain. No backend, no server
sessions. The frontend resolves a `.ai` name to an address via namehash +
`ownerOf` on the Agent ID registry.

## Contract

`contracts/AgentIdHub.sol` — Solidity 0.8.20, optimizer enabled (200 runs).

## License

MIT
