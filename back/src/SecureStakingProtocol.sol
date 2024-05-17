// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SecureStakingProtocol is Ownable {
    IERC20 public token;

    mapping(address => uint256) public stakes;
    uint256 public totalStaked;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    constructor(address _tokenAddress) Ownable(msg.sender) {
        token = IERC20(_tokenAddress);
    }

    function stakeTokens(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

        stakes[msg.sender] += amount;
        totalStaked += amount;

        emit Staked(msg.sender, amount);
    }

    function withdrawTokens(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(stakes[msg.sender] >= amount, "Insufficient staked amount");

        stakes[msg.sender] -= amount;
        totalStaked -= amount;

        require(token.transfer(msg.sender, amount), "Transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    function checkStake(address user) external view returns (uint256) {
        return stakes[user];
    }
}
