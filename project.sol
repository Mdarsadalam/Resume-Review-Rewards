// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ResumeReviewRewards {
    IERC20 public rewardToken;  // The ERC20 token used for rewards

    address public owner;
    mapping(address => uint256) public reviews;  // Mapping to track reviews by each user

    // Events to log the review process
    event ResumeReviewed(address indexed reviewer, address indexed submitter, uint256 reward);
    event RewardClaimed(address indexed reviewer, uint256 amount);

    // Modifier to restrict actions to the owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // Constructor to initialize the contract with the reward token
    constructor(address _rewardToken) {
        rewardToken = IERC20(_rewardToken);
        owner = msg.sender;
    }

    // Function to submit a resume for review (only for owners/admins)
    function submitResumeForReview(address submitter) external onlyOwner {
        require(submitter != address(0), "Invalid address");
        reviews[submitter] = 0;  // Initialize review count
    }

    // Function to review a resume and reward the reviewer
    function reviewResume(address reviewer, address submitter, uint256 rewardAmount) external onlyOwner {
        require(reviewer != address(0), "Invalid reviewer address");
        require(submitter != address(0), "Invalid submitter address");
        require(rewardAmount > 0, "Reward amount must be greater than 0");

        // Transfer reward tokens to the reviewer
        rewardToken.transferFrom(owner, reviewer, rewardAmount);

        // Increment the review count for the submitter
        reviews[submitter] += 1;

        // Emit event for the review action
        emit ResumeReviewed(reviewer, submitter, rewardAmount);
    }

    // Function for the reviewer to claim rewards
    function claimReward() external {
        uint256 rewardAmount = reviews[msg.sender] * 10**18;  // Calculate the reward based on the review count
        require(rewardAmount > 0, "No rewards to claim");

        // Transfer the reward to the reviewer
        rewardToken.transfer(msg.sender, rewardAmount);

        // Reset the review count for the reviewer
        reviews[msg.sender] = 0;

        // Emit event for reward claim
        emit RewardClaimed(msg.sender, rewardAmount);
    }

    // Function to withdraw tokens from the contract (only for the owner)
    function withdrawTokens(uint256 amount) external onlyOwner {
        rewardToken.transfer(owner, amount);
    }
}
