pragma solidity 0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTContract1 is ERC721 {
    constructor() ERC721("NFT type 1", "NFT1") {
        _mint(0x633B398ad7909D53264806708817de7855A2D12E, 0);
    }
}
