// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Swapper.sol
/// @author Prajwal More
/// @notice This allows users to swap NFT for other NFT from one collection.
/// @dev Contains functions for swapping NFTs and other required functions.

contract Swapper is Ownable {
    /// @dev Stores the stores the addresses of other token owners to which first owner is agreed to for swaping NFT.
    mapping(address => mapping(uint256 => address)) public agreementMap;

    IERC721 public nft;

    /// @dev Sets address of NFT collection. (for now collction would be static once set for any address)
    /// @param _collection address of NFT collection.
    function setAddress(address _collection) external {
        nft = IERC721(_collection);
    }

    /// @dev unction to swap two NFTs.
    /// @param _collection is address of NFT collections.
    /// @param owner1Token as ID of a
    /// @param owner2Token as ID of token.
    /// @param owner1 as address of first.
    /// @param owner2 as ID of seconds owner.
    /// @return boolean value true or false.
    function swap(
        uint256 owner1Token,
        uint256 owner2Token,
        address owner1,
        address owner2,
        address _collection
    ) external returns (bool) {
        require(
            msg.sender == owner1 || msg.sender == owner2,
            "You are not authorized to swap other's tokens"
        );
        address owner1TokenAllowedTo = agreementMap[_collection][owner1Token];
        address owner2TokenAllowedTo = agreementMap[_collection][owner2Token];

        require(owner1TokenAllowedTo == owner2, "BOTH_NEEDS_TO_AGREE");
        require(owner2TokenAllowedTo == owner1, "BOTH_NEEDS_TO_AGREE");

        nft.safeTransferFrom(owner1, owner2, owner1Token);
        nft.safeTransferFrom(owner2, owner1, owner2Token);
        return true;
    }
    /// @dev emits when addAgreement is called.
    /// @param collection as a NFT collection,
    /// @param TokenId as a ID of NFT,
    /// @param to as a address.
    event evt(address collection, uint256 TokenId, address to);

    /// @dev Explain to a developer any extra details
    /// @param _tokenId as id of token
    /// @param _collection is address of NFT collections.
    /// @param _to is address of other token owners to which first owner is agreed to for swaping NFT.
    function addAgreement(
        uint256 _tokenId,
        address _collection,
        address _to
    ) public payable {
        address ownerAddr = IERC721(_collection).ownerOf(_tokenId);
        require(ownerAddr == msg.sender, "NOT_TOKEN_OWNER");
        agreementMap[_collection][_tokenId] = _to;
        emit evt(_collection, _tokenId, _to);
    }
}
