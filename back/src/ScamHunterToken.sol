// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract ScamHunterToken is ERC20, ERC20Burnable {
    constructor() ERC20("Scam Hunter Token", "SHT") {
        _mint(msg.sender, 1000000 * (10 ** 18));
    }
}
