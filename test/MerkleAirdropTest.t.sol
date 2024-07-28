// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {WoofieToken} from "../src/WoofieToken.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdrop public merkleAirdrop;
    WoofieToken public woofieToken;
    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 public AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;
    bytes32 public proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 public proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proofOne, proofTwo];

    address user;
    uint256 userPrivKey;

    function setUp() public {
        woofieToken = new WoofieToken();
        merkleAirdrop = new MerkleAirdrop(ROOT, woofieToken);
        woofieToken.mint(woofieToken.owner(), AMOUNT_TO_SEND);
        woofieToken.transfer(address(merkleAirdrop), AMOUNT_TO_SEND);
        (user, userPrivKey) = makeAddrAndKey("user");
    }

    function testUsersCanClaim() public {
        console.log(user);
        uint256 startingBalance = woofieToken.balanceOf(user);
        console.log("Starting balance:", startingBalance);

        vm.prank(user);
        merkleAirdrop.claim(user, AMOUNT_TO_CLAIM, PROOF);

        uint256 endingBalance = woofieToken.balanceOf(user);
        console.log("Ending balance:", endingBalance);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
}
