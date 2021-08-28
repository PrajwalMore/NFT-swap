pragma solidity 0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Swapper is Ownable {
    // This will collect collection address.
    mapping( string => address) public addressCollector;

    struct NFT {
        uint256 tokenId;
        uint256 expectedPrice;
        address to;
        //ipfs uri
    }
    mapping(address => NFT) public addNFT;

    struct DS {
        uint256 tokenId;
        address allowedTo;
    }
    mapping(uint256 => DS) public agreementMap;

    ERC721 public nft;

    /* addCollection() will record all collection added for future swappings */
    function addCollections(string memory _collectionName, address _collection)
        external
        onlyOwner
        returns (bool)
    {
        addressCollector[_collectionName] = _collection;
        return true;
    }

    function setAddress(address _collection1,address _collection2) external {
        nft1 = ERC721(_collection1);
        nft2 = ERC721(_collection2);
    }

    //add bothaAgree records in addressCollector.

    function bothAgree(
        address owner1,
        address owner2,
        uint256 _tokenId1,
        address _collection
    ) public returns (bool) {
        //isAgree for swap.
        address to = addNFT[_collection].to;
        //require(to== msg.sender,"ERR_AUTORIZED_TO_YOU");
        if (to != msg.sender) {
            return true;
        } else {
            return false;
        }
    }

    /*
     * function to swap two NFTs.
     * take `_tokenId1` , `_tokenId2` as IDs of collection.
     * `_collection` is address of NFT collections.
     */
    function swap(
        uint256 owner1Token,
        uint256 owner2Token,
        address owner1,
        address owner2,
        address _collection
    ) external returns (bool) {
        //transfer from caller to other accounts , if both are agree on deal.
        // this contract make available method on collection address to NFT seller/buyer.
        require(
            bothAgree(owner1, owner2, owner1Token, _collection),
            "BOTH_NEEDS_TO_AGREE"
        );
        require(
            bothAgree(owner2, owner1, owner2Token, _collection),
            "BOTH_NEEDS_TO_AGREE"
        );

        // Do with UI.
        nft.safeTransferFrom(owner1, owner2, owner1Token);
        nft.safeTransferFrom(owner2, owner1, owner2Token);
        return true;
    }

    event evt(address ownerAddr);

function addAgreement(
        uint256 _tokenId,
        address _collection,
        uint256 _expectedPrice,
        address _to
    ) payable public returns(bool success){
        //check for caller should be someone from user1 or user2.

        // check if tokenId is token from that collection collection
        // string memory nm=nft.name();
        // require(keccak256(abi.encodePacked(nm))== keccak256(abi.encodePacked(addressCollector[_collection])), "ERR_COLLECTION_IS_DIFFERENT");
        //require(condition, "Collection not present");
        // if caller is owner of `tokenId`.
        address ownerAddr = ERC721(_collection).ownerOf(_tokenId);
        require(ownerAddr == msg.sender, "NOT_TOKEN_OWNER");
        addNFT[_collection].tokenId = _tokenId; // this would be updating previous state instead of adding one more record //need to change to array of mappings.
        addNFT[_collection].expectedPrice = _expectedPrice;
        addNFT[_collection].to = _to;
        //ERC721(_collection).approve(address(this), _tokenId);
        (bool success, ) = address(_collection).call(
            abi.encodeWithSignature("approv(address,uint256)", address(this),_tokenId)
        );
        return success;
        //emit evt(ownerAddr);
    }


}
