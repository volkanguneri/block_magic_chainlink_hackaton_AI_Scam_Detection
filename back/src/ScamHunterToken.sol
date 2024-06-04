// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract ScamHunterToken is ERC20, ERC20Burnable {
    // Chainlink API Request Contract Address
    address private chainlinkAPIRequestAddress;

    constructor(
        address _chainlinkAPIRequestAddress
    ) ERC20("Scam Hunter Token", "SHT") {
        _mint(msg.sender, 1000000 * (10 ** 18));
        // Initialise chainlink API Request contract address address
        chainlinkAPIRequestAddress = _chainlinkAPIRequestAddress;
    }

    function analyzeContractSecurity() private {
        // Call the Chainlink API Request contract
        chainlinkAPIRequestAddress.sendRequest(
            "request-config.js",
            "Location.Inline",
            "Location.DONHosted",
            "",
            "sender",
            2701,
            30000
        );
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        // Check if the Chainlink API Request contract is secure
        require(
            analyzeContractSecurity(),
            "Chainlink API Request contract is not secure"
        );

        // Proceed with the transfer if the contract is secure
        return super.transferFrom(sender, recipient, amount);
    }
}
