// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// Chainlink
import {FunctionsClient} from "../node_modules/@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "../node_modules/@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "../node_modules/@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

/**
 * @title GettingStartedFunctionsConsumer
 * @notice This is an example contract to show how to make HTTP requests using Chainlink
 * @dev This contract uses hardcoded values and should not be used in production.
 */
contract HardcodedChainlinkAPIRequest is FunctionsClient, ConfirmedOwner {
    using FunctionsRequest for FunctionsRequest.Request;

    // DON ID for the Functions DON to which the requests are sent
    bytes32 public donId;

    //////////////////////////// [D] ////////////////////////////

    // reports: latest AI Analysis response.
    string public latestAiAnalysis;

    // emits: price Analysis event.
    event AiAnalysis(string latestAiAnalysis);

    // emits: OCRResponse event.
    event OCRResponse(bytes32 indexed requestId, bytes result, bytes err);

    //////////////////////////// [D] ////////////////////////////

    bytes32 public latestRequestId;
    bytes public latestResponse;
    bytes public latestError;

    constructor(
        address router,
        bytes32 _donId
    ) FunctionsClient(router) ConfirmedOwner(msg.sender) {
        donId = _donId;
    }

    /**
     * @notice Set the DON ID
     * @param newDonId New DON ID
     */
    function setDonId(bytes32 newDonId) external onlyOwner {
        donId = newDonId;
    }

    function sendRequestHardcoded() external onlyOwner {
        // Hardcoding les paramètres ici
        string memory hardcodedSource = "../request-config.js"; // Chemin vers votre fichier de configuration de requête
        FunctionsRequest.Location hardcodedSecretsLocation = FunctionsRequest
            .Location
            .DONHosted; // Emplacement des secrets
        bytes memory hardcodedEncryptedSecretsReference = ""; // Référence aux secrets cryptés, si nécessaire
        string[] memory hardcodedArgs = new string[](1); // Arguments passés à la requête
        hardcodedArgs[0] = "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48"; // Adresse d'un pool Uniswap, exemple d'argument

        // Pas besoin de bytesArgs ici, donc ils sont omis

        // Utilisez un ID de souscription fictif (remplacez-le par un ID valide dans votre environnement)
        uint64 hardcodedSubscriptionId = 2701;

        // Limite de gaz pour la réponse, ajustez selon vos besoins
        uint32 hardcodedCallbackGasLimit = 50000;

        // Création de la requête avec les paramètres hardcodés
        FunctionsRequest.Request memory req;
        req.initializeRequest(
            hardcodedSecretsLocation,
            FunctionsRequest.CodeLanguage.JavaScript,
            hardcodedSource
        );
        req.secretsLocation = hardcodedSecretsLocation;
        req.encryptedSecretsReference = hardcodedEncryptedSecretsReference;
        if (hardcodedArgs.length > 0) {
            req.setArgs(hardcodedArgs);
        }
        // Note: Si vous aviez besoin d'utiliser bytesArgs, vous les ajouteriez ici de manière similaire

        // Envoi de la requête avec les paramètres hardcodés
        latestRequestId = _sendRequest(
            req.encodeCBOR(),
            hardcodedSubscriptionId,
            hardcodedCallbackGasLimit,
            donId // Assurez-vous que donId est correctement défini dans votre contrat
        );
    }

    /**
     * @notice Store latest result/error
     * @param requestId The request ID, returned by sendRequest()
     * @param response Aggregated response from the user code
     * @param err Aggregated error from the user code or from the execution pipeline
     * Either response or error parameter will be set, but never both
     */

    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        latestResponse = response;
        latestError = err;

        //////////////////////////// [D] ////////////////////////////

        // updates: latest request id.
        latestRequestId = requestId;

        // emits: OCRResponse event.
        emit OCRResponse(requestId, response, err);

        // converts: latest response to a (human-readable) string.
        latestAiAnalysis = string(abi.encodePacked(response));
        emit AiAnalysis(latestAiAnalysis);

        //////////////////////////// [D] ////////////////////////////
    }
}
