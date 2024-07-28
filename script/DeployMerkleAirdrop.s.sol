// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {WoofieToken} from "../src/WoofieToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    MerkleAirdrop public airdrop;
    WoofieToken public token;
    bytes32 public constant ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public constant AMOUNT = 4 * (25 * 1e18);

    function deployMerkleAirdrop() public returns (MerkleAirdrop, WoofieToken) {
        vm.startBroadcast();
        token = new WoofieToken();
        airdrop = new MerkleAirdrop(ROOT, IERC20(token));
        token.mint(token.owner(), AMOUNT);
        token.transfer(address(airdrop), AMOUNT);
        vm.stopBroadcast();
        return (airdrop, token);
    }

    function run() external {
        deployMerkleAirdrop();
    }
}
