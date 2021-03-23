pragma solidity ^0.8.0;

import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/token/ERC721/IERC721Receiver.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/token/ERC721/ERC721.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/utils/math/SafeMath.sol";

contract PhotosNFT is ERC721URIStorage, IERC721Receiver {
    using SafeMath for uint256;
    
    mapping (address => bool) internal ownerList;
    mapping (uint256 => string) internal tokenURIList;
    
    uint256 tokenIDCounter;
    
    event SafeTransferEvent(address indexed _initiatedBy, address indexed _from, uint256 _tokenID, bytes indexed _data);
    
    constructor() ERC721("Phalanx Game Tiles","PHALANX"){
        ownerList[msg.sender] = true;
        tokenIDCounter = 0;
        tokenURIList[0] = "https://ipfs.io/ipfs/QmcLXhCNjqztfZPUAj3qqtYFFq8o72RN6PcMWjV4JQsQhq?filename=FootSoldiers.json";
        tokenURIList[1] = "https://ipfs.io/ipfs/QmVarrDpNfEKonf2vo6Ne4XfDPDvWEGxw76EuaPFQXMhcs?filename=Forest.json";
        tokenURIList[2] = "https://ipfs.io/ipfs/QmdK15WDZQPih442vXULsTi9vtJMDVRPu5rm6h7psegChx?filename=HeavyScout.json";
        tokenURIList[3] = "https://ipfs.io/ipfs/QmXaGnYJove25Ed4iPYie6wPGfMF6xvqdSpVz5Qo55SQSQ?filename=LightScout.json";
        tokenURIList[4] = "https://ipfs.io/ipfs/QmYXhKKucttMU4c1inVbEzuNQDnWfhbfWTuatjkZq3cCps?filename=SeigeShip.json";
        tokenURIList[5] = "https://ipfs.io/ipfs/QmTR88ctugka4eZpjnwAwb5rbJGK9d82yjRLSrwXoQyzT3?filename=Archers.json";
    }
    
    modifier onlyOwner {
        require(ownerList[msg.sender], "Error: Not a contract owner");
        _;
    }
    
    modifier contractOwnsNFT (uint256 _tokenID) {
        require(this.ownerOf(_tokenID) == address(this), "Error: Contract does not own NFT");
        _;
    }
    
    function addOwner(address _newOwner) public onlyOwner {
        ownerList[_newOwner] = true;
    }
    
    function removeOwner(address _removedOwner) public onlyOwner {
        if  (_removedOwner == msg.sender){
            revert("Error: Cannot remove yourself as an owner");
        } else {
            ownerList[_removedOwner] = false;
        }
    }
    
    function getNextTokenID() internal returns (uint256) {
        tokenIDCounter++;
        
        return tokenIDCounter;
    }
    
    function generateNFT(uint256 _NFTTokenIndex) public onlyOwner returns (uint256) {
        uint256 _tokenID = getNextTokenID();
        
        _mint(address(this), _tokenID);
        _setTokenURI(_tokenID, tokenURIList[_NFTTokenIndex]);
        
        return _tokenID;
    }
    
    function sendNFTToAddress(address _NFTRecipient, uint256 _tokenID) public onlyOwner contractOwnsNFT(_tokenID) {
        this.safeTransferFrom(address(this), _NFTRecipient, _tokenID);
    }
    
    function setNFTIndex(uint256 _NFTIndex, string memory _NFTURI) public onlyOwner {
        tokenURIList[_NFTIndex] = _NFTURI;
    }
    
    function removeNFTIndex(uint256 _NFTIndex) public onlyOwner {
        delete tokenURIList[_NFTIndex];
    }
    
    function getNFTURI(uint256 _NFTIndex) public view returns (string memory) {
        return tokenURIList[_NFTIndex];
    }
    
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external virtual override returns (bytes4) {
        emit SafeTransferEvent(operator, from, tokenId, data);
        
        return this.onERC721Received.selector;
    }
}