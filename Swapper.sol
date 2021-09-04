pragma solidity 0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



contract Swapper is Ownable {
    // This will collect collection address.
    mapping(string => address) public addressCollector;

    //collection > tokenId > to
    // collection {{tokenId : to},{tokenId : to},{tokenId : to}}
    mapping(address => uint256) public collectionToTokenId;

    mapping(address => mapping(uint256 => address)) public agreementMap;

    ERC721 public nft1;
    ERC721 public nft2;

    /* addCollection() will record all collection added for future swappings */
    function addCollections(string memory _collectionName, address _collection)
        external
        onlyOwner
        returns (bool)
    {
        addressCollector[_collectionName] = _collection;
        return true;
    }

    // it can be managed in UI to save the gas fees.
    function setAddress(address _collection1, address _collection2) external {
        nft1 = ERC721(_collection1);
        nft2 = ERC721(_collection2);
    }

    //add bothaAgree records in addressCollector.

    function isAgree(
        address _owner,
        uint256 _tokenId,
        address _collection
    ) public returns (bool) {
        //isAgree for swap.
        address to = agreementMap[_collection][_tokenId];
        require(to == _owner, "ERR_AUTORIZED_TO_YOU");
        if (to == _owner) {
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
        require(
            isAgree(owner1, owner1Token, _collection),
            "BOTH_NEEDS_TO_AGREE"
        );
        require(
            isAgree(owner2, owner2Token, _collection),
            "BOTH_NEEDS_TO_AGREE"
        );

        require(
            msg.sender == owner1 || msg.sender == owner2,
            "You are not authorized to swap other's tokens"
        );
        require(
            msg.sender == owner2,
            "You are not authorized to swap other's tokens"
        );
        // Do with UI.
        nft1.safeTransferFrom(owner1, owner2, owner1Token);
        nft1.safeTransferFrom(owner2, owner1, owner2Token);
        return true;
    }

    event evt(address collection, uint256 TokenId, address to);

    function addAgreement(
        uint256 _tokenId,
        address _collection,
        address _to
    ) public payable {
        // check if tokenId is token from that collection collection
        // string memory nm=nft.name();
        // require(keccak256(abi.encodePacked(nm))== keccak256(abi.encodePacked(addressCollector[_collection])), "ERR_COLLECTION_IS_DIFFERENT");
        //require(condition, "Collection not present");
        // if caller is owner of `tokenId`.
        address ownerAddr = ERC721(_collection).ownerOf(_tokenId);
        require(ownerAddr == msg.sender, "NOT_TOKEN_OWNER");
        agreementMap[_collection][_tokenId] = _to; // this would be updating previous state instead of adding one more record //need to change to array of mappings.

        emit evt(_collection, _tokenId, _to);
    }


    //UI-> NFTContract >
}
