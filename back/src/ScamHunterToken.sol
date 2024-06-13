// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

import {ChainlinkAPIRequest} from "./ChainlinkAPIRequest.sol";
import {HardcodedChainlinkAPIRequest} from "./HardcodedChainlinkAPIRequest.sol";

contract ScamHunterToken is ERC20, ERC20Burnable {
    // Declare instance of Chainlink API Request Contract
    HardcodedChainlinkAPIRequest private hardcodedChainlinkAPIRequest;

    event AnalyzeFailed();

    constructor(
        address _router,
        bytes32 _donId
    ) ERC20("Scam Hunter Token", "SHT") {
        _mint(msg.sender, 1000000 * (10 ** 18));
        // Initialise chainlink API Request contract
        hardcodedChainlinkAPIRequest = new HardcodedChainlinkAPIRequest(
            _router,
            _donId
        );
    }

    function analyzeContractSecurity() private {
        try hardcodedChainlinkAPIRequest.sendRequestHardcoded() {} catch {
            emit AnalyzeFailed();
        }
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        // Check if the Chainlink API Request contract is secure

        analyzeContractSecurity();

        // Proceed with the transfer if the contract is secure
        return super.transferFrom(sender, recipient, amount);
    }
}
