pragma solidity 0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
contract NFTContract2 is ERC721{
constructor() ERC721("NFT type 2","NFT2") {
    _mint(0x2B9C48448CE78a92f993ACe5bEED165b725039fb, 0);
}
}
