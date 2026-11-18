// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title AgentIdHub
/// @notice A hub for Binance Agent ID (.ai) holders on BNB Chain.
/// @dev Every state-changing function requires the caller to hold an Agent ID.
///      The Agent ID registry is the SPACE ID ERC-721 (non-transferable) at
///      0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F. A holder is any address with
///      balanceOf > 0 on that registry. No owner, no fee, no token, no pause:
///      nothing in this contract can move user funds except the explicit tip()
///      call the sender makes themselves.
interface IAgentIdRegistry {
    function balanceOf(address owner) external view returns (uint256);
}

contract AgentIdHub {
    IAgentIdRegistry public constant AGENT_ID =
        IAgentIdRegistry(0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F);

    uint256 public constant MAX_TEXT_LEN = 280;

    // Profile: a short bio bound to the caller's Agent ID address.
    mapping(address => string) public profileBio;
    mapping(address => uint256) public profileUpdatedAt;

    // Check-in: one per UTC day. lastCheckInDay stores block.timestamp / 1 days.
    mapping(address => uint256) public lastCheckInDay;
    mapping(address => uint256) public streak;

    // Tips: counts and totals per address.
    mapping(address => uint256) public tipsReceived;
    mapping(address => uint256) public tipsSent;
    mapping(address => uint256) public tipsReceivedWei;
    mapping(address => uint256) public tipsSentWei;

    uint256 public totalProfiles;
    uint256 public totalCheckIns;
    uint256 public totalTips;
    uint256 public totalTippedWei;

    event ProfileSet(address indexed user, string bio);
    event CheckedIn(address indexed user, uint256 indexed day, uint256 streak);
    event Tipped(
        address indexed from,
        address indexed to,
        uint256 amount,
        string message
    );

    modifier onlyAgentId() {
        require(
            AGENT_ID.balanceOf(msg.sender) > 0,
            "AgentIdHub: caller holds no Agent ID"
        );
        _;
    }

    /// @notice Set or update the caller's profile bio (max 280 chars).
    function setProfile(string calldata bio) external onlyAgentId {
        require(bytes(bio).length <= MAX_TEXT_LEN, "AgentIdHub: bio too long");
        if (
            bytes(profileBio[msg.sender]).length == 0 &&
            bytes(bio).length > 0
        ) {
            totalProfiles += 1;
        }
        profileBio[msg.sender] = bio;
        profileUpdatedAt[msg.sender] = block.timestamp;
        emit ProfileSet(msg.sender, bio);
    }

    /// @notice Check in once per UTC day. Consecutive days grow the streak.
    function checkIn() external onlyAgentId {
        uint256 day = block.timestamp / 1 days;
        require(
            lastCheckInDay[msg.sender] != day,
            "AgentIdHub: already checked in today"
        );
        if (lastCheckInDay[msg.sender] == day - 1) {
            streak[msg.sender] += 1;
        } else {
            streak[msg.sender] = 1;
        }
        lastCheckInDay[msg.sender] = day;
        totalCheckIns += 1;
        emit CheckedIn(msg.sender, day, streak[msg.sender]);
    }

    /// @notice Tip another Agent ID holder. The recipient must hold an Agent ID.
    /// @dev Follows checks-effects-interactions: state is updated before the
    ///      external call so a reentrant recipient cannot double-count.
    function tip(
        address payable recipient,
        string calldata message
    ) external payable onlyAgentId {
        require(msg.value > 0, "AgentIdHub: tip must be > 0");
        require(recipient != address(0), "AgentIdHub: zero recipient");
        require(recipient != msg.sender, "AgentIdHub: cannot tip self");
        require(
            AGENT_ID.balanceOf(recipient) > 0,
            "AgentIdHub: recipient holds no Agent ID"
        );
        require(
            bytes(message).length <= MAX_TEXT_LEN,
            "AgentIdHub: message too long"
        );

        tipsSent[msg.sender] += 1;
        tipsReceived[recipient] += 1;
        tipsSentWei[msg.sender] += msg.value;
        tipsReceivedWei[recipient] += msg.value;
        totalTips += 1;
        totalTippedWei += msg.value;
        emit Tipped(msg.sender, recipient, msg.value, message);

        (bool ok, ) = recipient.call{value: msg.value}("");
        require(ok, "AgentIdHub: transfer failed");
    }
}
