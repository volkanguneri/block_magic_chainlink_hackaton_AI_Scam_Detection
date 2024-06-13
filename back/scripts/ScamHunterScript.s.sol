// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "../lib/forge-std/src/Script.sol";
import "../src/ScamHunterToken.sol";

contract ScamHunterScript is Script {
    function run() external {
        uint deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // REFER TO DOCS FOR UP-TO-DATE ADDRESSES
        // https://docs.chain.link/chainlink-functions/supported-networks
        address ROUTER_ADDRESS = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0; // ETH SEPOLIA
        bytes32 DON_ID = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000; // ETH SEPOLIA

        ScamHunterToken scamHunterToken = new ScamHunterToken(
            ROUTER_ADDRESS,
            DON_ID
        );

        // silences warning.
        scamHunterToken;

        vm.stopBroadcast();
    }
}
