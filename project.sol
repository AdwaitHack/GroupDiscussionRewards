// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract GroupDiscussionRewards {
    struct Discussion {
        string topic;
        address creator;
        uint rewardPool;
        uint participants;
        bool isActive;
    }

    mapping(uint => Discussion) public discussions;
    mapping(uint => mapping(address => bool)) public hasParticipated;

    uint public discussionCount;
    address public owner;

    event DiscussionCreated(uint discussionId, string topic, uint rewardPool);
    event RewardClaimed(uint discussionId, address participant);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createDiscussion(string memory topic, uint rewardPool) public payable onlyOwner {
        require(msg.value == rewardPool, "Insufficient funds for reward pool");

        discussionCount++;
        discussions[discussionCount] = Discussion({
            topic: topic,
            creator: msg.sender,
            rewardPool: rewardPool,
            participants: 0,
            isActive: true
        });

        emit DiscussionCreated(discussionCount, topic, rewardPool);
    }

    function participateInDiscussion(uint discussionId) public {
        Discussion storage discussion = discussions[discussionId];
        require(discussion.isActive, "Discussion is not active");
        require(!hasParticipated[discussionId][msg.sender], "You have already participated");

        hasParticipated[discussionId][msg.sender] = true;
        discussion.participants++;
    }

    function claimReward(uint discussionId) public {
        Discussion storage discussion = discussions[discussionId];
        require(hasParticipated[discussionId][msg.sender], "You did not participate in this discussion");
        require(discussion.isActive, "Discussion is no longer active");
        require(discussion.participants > 0, "No participants to distribute rewards");

        uint reward = discussion.rewardPool / discussion.participants;
        discussion.rewardPool -= reward;
        payable(msg.sender).transfer(reward);

        emit RewardClaimed(discussionId, msg.sender);
    }

    function endDiscussion(uint discussionId) public onlyOwner {
        Discussion storage discussion = discussions[discussionId];
        require(discussion.isActive, "Discussion is already ended");

        discussion.isActive = false;
    }
}
