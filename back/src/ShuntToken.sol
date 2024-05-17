// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// OpenZeppelin
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

// Importing the Chainlink contract
import {ChainlinkRequestToAI} from "./ChainlinkRequestToAI.sol";

contract ShuntToken is ERC20, Ownable {
    // Declaration of a variable to store the instance of the Chainlink contract
    ChainlinkRequestToAI public chainlinkContract;

    constructor(
        address _chainlinkContractAddr
    ) Ownable(msg.sender) ERC20("Scam Hunter", "Shunt") {
        _mint(msg.sender, 1000000 * 10 ** 18);

        // Creating an instance of the Chainlink contract with the specified address
        chainlinkContract = ChainlinkRequestToAI(_chainlinkContractAddr);
    }

    /**
     * @dev Sends the bytecode to OpenAI via Chainlink for analysis
     * @param bytecode The bytecode of the contract to be analyzed
     */
    function sendBytecodeToOpenAI(string memory bytecode) public {
        // Sends the request to the Chainlink oracle for bytecode analysis
        chainlinkContract.sendRequest(1, [bytecode]); // The first argument is the subscription ID, which is 1 here
    }

    /**
     * @dev Overrides the transferFrom function to include contract analysis logic
     * @param sender The sender address
     * @param recipient The recipient address
     * @param amount The amount to transfer
     * @return A boolean indicating success or failure of the transfer
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        bytes memory senderBytecode = new bytes(extcodesize(sender));
        assembly {
            extcodecopy(
                sender,
                add(senderBytecode, 0x20),
                0,
                extcodesize(sender)
            )
        }

        // Decompose the bytecode and store it in the variable contractToAnalyse
        string memory contractToAnalyse = string(
            abi.encodePacked("Bytecode: ", bytesToString(senderBytecode))
        );

        // Send the bytecode to OpenAI for analysis via Chainlink
        sendBytecodeToOpenAI(contractToAnalyse);

        // Continue with the usual transfer logic
        return true;
    }

    /**
     * @dev Converts a byte array to a string
     * @param data The byte array to convert
     * @return The string representation of the byte array
     */
    function bytesToString(
        bytes memory data
    ) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }
}
