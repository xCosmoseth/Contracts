// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract AInime is ERC721, Ownable  {

    using Strings for uint256;

    uint256 public MAX_TOKENS = 28; // Can go up for next phases
    uint256 public MAX_MINT_PER_TX = 1; // Can be changed, just in case for next phases 
    uint256 public MAX_PER_WALLET = 1; // Can be changed, just in case for next phases 
    uint256 public MINT_PHASE = 1; // Used to handle changing list of whitelisted address
    uint256 private constant TOKENS_RESERVED = 1; // Number of token minted when contract is deployed that will go to a specific address, check the constructor
    
    uint256 public price = 0; //For later, next mint phase will be based on floor price -- IN WEI

    bool public isSaleActive = false; // Turn on/off the sale
    bool public onlyAllowlist = false; //Turn on/off the allowlist requirement

    uint256 public totalSupply;
    mapping(address => uint256) private mintedPerWallet; //Map the address with the amount of token minted
    mapping(uint256 => mapping(address => bool)) private allowlistAddress; //Allowlist management

    string public baseUri; //Metadata
    string public baseExtension = ".json";

    event Withdraw(uint256 amount, address indexed recipient);

    constructor() ERC721("AInime", "AINM") {
        baseUri = "ipfs://bafybeid5ffupq56t7jga52bdcwcajukx22akmiu55q2dovctj3die4j77a/"; //unreavealed metadata, change it with yours
        for(uint256 i = 1; i <= TOKENS_RESERVED; ++i) {
            _mint(0x1682E9378002D0623f0d4eF25C018C73AE098eDb, i); // Transfer the first NFT to an address, only at launch.
            //Important, if you use the contract, change this address!
        }
        totalSupply = TOKENS_RESERVED;
    }

    function mint(uint256 _numTokens) external payable {
        require(isSaleActive, "The sale is paused.");
        if (onlyAllowlist) {        
            require(allowlistAddress[MINT_PHASE][msg.sender], "Only allowlisted addresses can mint.");
        }
        require(_numTokens <= MAX_MINT_PER_TX, "You exceed the total NFT mint per transaction.");
        require(mintedPerWallet[msg.sender] + _numTokens <= MAX_PER_WALLET, "You exceed the limit per wallet.");

        uint256 curTotalSupply = totalSupply;
        require(curTotalSupply + _numTokens <= MAX_TOKENS, "Exceeds actual total supply.");
        require(curTotalSupply + _numTokens <= 1000, "Exceeds the maximum total supply.");
        require(_numTokens * price <= msg.value, "Insufficient funds.");
        
        for(uint256 i = 1; i <= _numTokens; ++i) {
            _mint(msg.sender, curTotalSupply + i);
        }

        mintedPerWallet[msg.sender] += _numTokens;
        totalSupply += _numTokens;
        if (totalSupply == MAX_TOKENS) {
            MINT_PHASE += 1; //Updates the mint phase number, used to clear out the allowlist
        }
    }

    // Owner-only functions
    function flipSaleState() external onlyOwner {
        isSaleActive = !isSaleActive;
    }

    function onlyAllowlistMint() external onlyOwner {
        onlyAllowlist = !onlyAllowlist;
    }

    function setBaseUri(string memory _baseUri) external onlyOwner {
        baseUri = _baseUri;
    }

    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }

    function setMaxToken(uint256 _maxToken) external onlyOwner {
        MAX_TOKENS = _maxToken;
    }

    function setMaxMintPerTX(uint256 _maxMintPerTX) external onlyOwner {
        MAX_MINT_PER_TX = _maxMintPerTX;
    }

    function setMaxMintPerWallet(uint256 _maxMintPerWallet) external onlyOwner {
        MAX_PER_WALLET = _maxMintPerWallet;
    }

    function changeOwnership(address owner) external onlyOwner {
        _transferOwnership(owner);
    }

    //Allowlist Management
    //Improve: Use of merkle trees instead
    //This function allows to change the whitelisted addresses depending on the mint phase
    function addInAllowlist(uint256 _mintPhase, address _address) external onlyOwner {
        allowlistAddress[_mintPhase][_address] = true;
    }

    //This function returns true if the address is in the allowlist for the specified phase
    function getIfAllowlist(uint256 _mintPhase, address _address) public view returns (bool) {
        return  allowlistAddress[_mintPhase][_address];
    }

    //This function allows to remove an address from the allowlist for the specified phase
    function removeFromAllowlist(uint256 _mintPhase, address _address) external onlyOwner {
        delete allowlistAddress[_mintPhase][_address];
    }

    // In case someone sends ETH on the contract, ability to retreive them to send back to the person
    // Or to withdraw in case someone wants to pay for the mint
    // Also for next phases if floor price based price
    function withdrawAll() external payable onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "There are no funds to withdraw.");
        // Update state before sending funds
        (bool success, ) = payable(msg.sender).call{value: balance}("");
        require(success, "Withdraw failed.");
        emit Withdraw(balance, msg.sender);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
 
        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
            : "";
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseUri;
    }
}