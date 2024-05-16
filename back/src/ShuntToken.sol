// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract ShuntToken is ERC20, Ownable {
    constructor() Ownable(msg.sender) ERC20("Scam Hunter", "Shunt") {
        _mint(msg.sender, 1000000 * 10 ** 18);
    }
}
