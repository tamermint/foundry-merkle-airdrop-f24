// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {WoofieToken} from "../src/WoofieToken.sol";
import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    MerkleAirdrop public merkleAirdrop;
    WoofieToken public woofieToken;
    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 public AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;
    bytes32 public proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 public proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proofOne, proofTwo];

    address gasPayer;
    address user;
    uint256 userPrivKey;

    function setUp() public {
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (merkleAirdrop, woofieToken) = deployer.deployMerkleAirdrop();
        } else {
            woofieToken = new WoofieToken();
            merkleAirdrop = new MerkleAirdrop(ROOT, woofieToken);
            woofieToken.mint(woofieToken.owner(), AMOUNT_TO_SEND);
            woofieToken.transfer(address(merkleAirdrop), AMOUNT_TO_SEND);
        }
        (user, userPrivKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function signMessage(uint256 privKey, address account) public view returns (uint8 v, bytes32 r, bytes32 s) {
        bytes32 hashedMessaged = merkleAirdrop.getMessageHash(account, AMOUNT_TO_CLAIM);
        (v, r, s) = vm.sign(privKey, hashedMessaged);
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = woofieToken.balanceOf(user);
        console.log("Starting balance:", startingBalance);

        //get the user to sign the message
        vm.startPrank(user);
        (uint8 v, bytes32 r, bytes32 s) = signMessage(userPrivKey, user);
        vm.stopPrank();

        //gasPayer calls the claim on behalf on the user using the signed message
        vm.prank(gasPayer);
        merkleAirdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);

        uint256 endingBalance = woofieToken.balanceOf(user);
        console.log("Ending balance:", endingBalance);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
}
