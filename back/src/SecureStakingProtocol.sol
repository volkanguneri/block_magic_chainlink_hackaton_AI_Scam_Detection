// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Ownable} from "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Secure Staking Protocol
 * @dev A secure staking protocol that allows users to stake tokens and receive rewards based on a fixed APR
 */
contract SecureStakingProtocol is Ownable {
    IERC20 public token; // The ERC20 token contract

    mapping(address => uint256) public stakes; // Mapping to keep track of user stakes
    uint256 public totalStaked; // Total amount of tokens staked
    uint256 public lastRewardDistribution; // Timestamp of the last reward distribution

    uint256 public constant APR = 10; // 10% APR
    uint256 public constant SECONDS_IN_YEAR = 31536000; // 365 days

    event Staked(address indexed user, uint256 amount); // Event emitted when tokens are staked
    event Withdrawn(address indexed user, uint256 amount); // Event emitted when tokens are withdrawn

    /**
     * @dev Constructor function
     * @param _tokenAddress The address of the ERC20 token
     */
    constructor(address _tokenAddress) Ownable(msg.sender) {
        token = IERC20(_tokenAddress);
    }

    /**
     * @dev Function to allow users to stake tokens
     * @param amount The amount of tokens to stake
     */
    function stakeTokens(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

        distributeRewards(); // Distribute rewards before stake update
        stakes[msg.sender] += amount;
        totalStaked += amount;

        emit Staked(msg.sender, amount);
    }

    /**
     * @dev Function to allow users to withdraw their staked tokens
     * @param amount The amount of tokens to withdraw
     */
    function withdrawTokens(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(stakes[msg.sender] >= amount, "Insufficient staked amount");

        distributeRewards(); // Distribute rewards before stake update
        stakes[msg.sender] -= amount;
        totalStaked -= amount;

        require(token.transfer(msg.sender, amount), "Transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @dev Internal function to distribute rewards to stakers
     */
    function distributeRewards() internal {
        uint256 timeSinceLastDistribution = block.timestamp -
            lastRewardDistribution;
        uint256 reward = (totalStaked * APR * timeSinceLastDistribution) /
            SECONDS_IN_YEAR;
        token.transferFrom(owner(), address(this), reward);
        lastRewardDistribution = block.timestamp;
    }

    /**
     * @dev Function to check the amount of staked tokens by a user
     * @param user The address of the user
     * @return The amount of staked tokens
     */
    function checkStake(address user) external view returns (uint256) {
        return stakes[user];
    }
}
