// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.25;

// // OpenZeppelin
// import {ERC20} from "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import {Ownable} from "../node_modules/@openzeppelin/contracts/access/Ownable.sol";


// contract ShuntToken is ERC20, Ownable, FunctionsClient, ConfirmedOwner {
//     using FunctionsRequest for FunctionsRequest.Request;

//     // DON ID for the Functions DON to which the requests are sent
//     bytes32 public donID;

//     // State variables to store the last request ID, response, and error
//     bytes32 public s_lastRequestId;
//     bytes public s_lastResponse;
//     bytes public s_lastError;

//     // Custom error type
//     error UnexpectedRequestID(bytes32 requestId);

//     // Event to log responses
//     event Response(
//         bytes32 indexed requestId,
//         string result,
//         bytes response,
//         bytes err
//     );

//     // JavaScript source code
//     // Fetch data from the Etherscan
//     // Documentation: https://docs.etherscan.io/
//     string sourceEtherscan =
//         string(
//             abi.encodePacked(
//                 "const axios = require('axios');",
//                 "const etherscanApiKey = 'YOUR_ETHERSCAN_API_KEY';",
//                 "const contractAddress = args[0];",
//                 "const url = `https://api.etherscan.io/api?module=account&action=txlist&address=${contractAddress}&startblock=0&endblock=99999999&sort=asc&apikey=${etherscanApiKey}`;",
//                 "const response = await axios.get(url);",
//                 "if (response.data.status === '1') {",
//                 "  const txCount = response.data.result.length;",
//                 "  return Functions.encodeString(txCount.toString());",
//                 "} else {",
//                 "  throw Error('Request failed');",
//                 "}"
//             )
//         );

//     // JavaScript source code
//     // Fetch data from the OpenAI
//     // Documentation:https://platform.openai.com/docs/introduction
//     string sourceOpenAI =
//         string(
//             abi.encodePacked(
//                 "const axios = require('axios');",
//                 "const openaiApiKey = 'YOUR_OPENAI_API_KEY';",
//                 "const contractToAnalyze = args[0];",
//                 "const response = await axios.post('https://api.openai.com/v1/completions', {",
//                 "  model: 'text-davinci-002',",
//                 "  prompt: `Analyze this smart contract for potential threats: ${contractToAnalyze}`,",
//                 "  max_tokens: 1000",
//                 "}, {",
//                 "  headers: {",
//                 "    'Authorization': `Bearer ${openaiApiKey}`",
//                 "  }",
//                 "});",
//                 "if (response.error) {",
//                 "  throw Error('Request failed');",
//                 "}",
//                 "const analysis = response.data.choices[0].text;",
//                 "return Functions.encodeString(analysis);"
//             )
//         );

//     constructor(
//         address _chainlinkAPIRequestRouter,
//         uint32 _donID
//     )
//         Ownable(msg.sender)
//         ERC20("Scam Hunter", "Shunt")
//         FunctionsClient(_chainlinkAPIRequestRouter)
//         ConfirmedOwner(msg.sender)
//     {
//         _mint(msg.sender, 1000000 * 10 ** 18);
//         donID = _donID;
//     }

//     /**
//      * @notice Set the DON ID
//      * @param newDonId New DON ID
//      */
//     function setDonId(bytes32 newDonId) external onlyOwner {
//         donID = newDonId;
//     }

//     /**
//      * @notice Sends an HTTP request using any API with javascript source code defined in ShuntToken.sol
//      * @param subscriptionId The ID for the Chainlink subscription
//      * @param args The arguments to pass to the HTTP request
//      * @return requestId The ID of the request
//      */
//     function sendRequest(
//         string calldata source,
//         uint64 subscriptionId,
//         string[] calldata args,
//         uint32 callbackGasLimit
//     ) external onlyOwner returns (bytes32 requestId) {
//         FunctionsRequest.Request memory req;
//         req.initializeRequestForInlineJavaScript(source); // Initialize the request with JS code
//         if (args.length > 0) req.setArgs(args); // Set the arguments for the request

//         // Send the request and store the request ID
//         s_lastRequestId = _sendRequest(
//             req.encodeCBOR(),
//             subscriptionId,
//             callbackGasLimit,
//             donID
//         );

//         return s_lastRequestId;
//     }

//     /**
//      * @notice Callback function for fulfilling a request
//      * @param requestId The ID of the request to fulfill
//      * @param response The HTTP response data
//      * @param err Any errors from the Functions request
//      */
//     function fulfillRequest(
//         bytes32 requestId,
//         bytes memory response,
//         bytes memory err
//     ) internal override {
//         if (s_lastRequestId != requestId) {
//             revert UnexpectedRequestID(requestId); // Check if request IDs match
//         }
//         // Update the contract's state variables with the response and any errors
//         s_lastResponse = response;
//         string calldata result = string(response);
//         s_lastError = err;

//         // Emit an event to log the response
//         emit Response(requestId, result, s_lastResponse, s_lastError);
//     }

//     // // Chainlink send request for ethrscan api to get the contract verified or not
//     // function getContract() private returns (string calldata) {
//     //     sendRequest(sourceEtherscan, 2701, "", 300000);
//     // }

//     // // Chainlink send request for OpenAI API to get the contract security analysis
//     // function getAnalysis() private returns (string calldata) {
//     //     sendRequest(sourceOpenAI, 2701, "", 300000);
//     // }

//     // /**
//     //  * @dev Overrides the transferFrom function to include contract analysis logic
//     //  * @param sender The sender address
//     //  * @param recipient The recipient address
//     //  * @param amount The amount to transfer
//     //  * @return A boolean indicating success or failure of the transfer
//     //  */
//     // function transferFrom(
//     //     address sender,
//     //     address recipient,
//     //     uint256 amount
//     // ) public override returns (bool) {
//     //     //send request ETherscan
//     //     sendRequest(sourceEtherscan, 2701, "", 300000);

//     //     // if verified, send request open ai
//     //     sendRequest(sourceOpenAI, 2701, "", 300000);

//     //     // and approve if the user decides to

//     //     return true;
//     // }
// }
