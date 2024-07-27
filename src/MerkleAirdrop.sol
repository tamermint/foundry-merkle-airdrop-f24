// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title Airdrop contract
 * @author Vivek Mitra
 * @notice Simple contract to demo airdrops
 * @dev The contract utilizes Merkle proofs for verification and OpenZeppelin's ERC20 contract
 */
contract MerkleAirdrop {
    using SafeERC20 for IERC20;

    //////////////////////
    ///// Errors ////////
    ////////////////////

    error MerkleAirdrop__InvalidMerkleProof();
    error MerkleAirdrop__AlreadyClaimed();

    //////////////////////
    ///State variables///
    /////////////////////

    address[] public s_claimers; //list of claiming addresses
    mapping(address user => bool claimed) public s_hasClaimed; //mapping of claimed addresses
    bytes32 private immutable i_merkleRoot; //to store the root of the address array
    IERC20 private immutable i_airdropToken; //to initialize our woofie token

    //////////////////////
    ///Type Declaration///
    /////////////////////

    //////////////////////
    ///// Events ////////
    ////////////////////
    event AirdropClaimed(address account, uint256 amount);

    //////////////////////
    ///// Functions /////
    ////////////////////
    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    /**
     * @notice function to let an address claim the airdrop token
     * @param account address trying to claim the airdrop
     * @param amount amount of tokens to claim
     * @param merkleProof proof array to store the address and compare against the i_merkleRoot
     */
    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
        //check if address has already lcaimed or not (Checks)
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        //calculate hash using account and amount -> leaf node (Effects)
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encodePacked(account, amount)))); //hashing done twice to avoice collisions
        //verify the proof
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidMerkleProof();
        }
        //Interaction
        //add to mapping
        s_hasClaimed[account] = true;

        //emit event
        emit AirdropClaimed(account, amount);

        //send tokens
        i_airdropToken.safeTransfer(account, amount);
    }

    //////////////////////////////
    /////View & Pure Functions //
    /////////////////////////////

    function getProof() public view returns (bytes32) {
        return i_merkleRoot;
    }

    function getClaimers() public view returns (address[] memory) {
        return s_claimers;
    }

    function getAirdropToken() public view returns (address) {
        return address(i_airdropToken);
    }
}
