// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./interfaces/IERC721.sol";
import "./interfaces/IERC721Metadata.sol";
import "./interfaces/IERC165.sol";
import "./interfaces/IERC721Receiver.sol";
import "./lib/StringUtils.sol";

contract MyNFTSecure is IERC721, IERC721Metadata, IERC165 {
    using StringUtils for uint256;

    // Events are defined in the imported interfaces
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    // ERC721 state variables
    mapping(uint256 => address) internal _ownerOf;
    mapping(address => uint256) internal _balanceOf;
    mapping(uint256 => address) internal _approvals;
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    // Metadata state variables
    string private _name;
    string private _symbol;

    // Ownable2Step state variables
    address public owner;
    address public pendingOwner;

    // Commit-Reveal state variables - VERSION SÉCURISÉE
    bytes32 public commitment;
    bool public revealed;
    string public hiddenBaseURI;
    string private baseURI; // ← PRIVÉ maintenant !

    // Crowdsale state variables
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public totalSupply;
    uint256 public mintPrice = 0.01 ether;
    bool public saleActive;

    // Timelock state variables
    uint256 public constant GRACE_PERIOD = 1 weeks;
    uint256 public withdrawUnlockTime;
    bool public withdrawRequested;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    // ERC165 implementation
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    // Metadata implementation
    function name() public view virtual override(IERC721Metadata) returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override(IERC721Metadata) returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override(IERC721Metadata) returns (string memory) {
        require(_ownerOf[tokenId] != address(0), "Token doesn't exist");
        
        if (!revealed) {
            return hiddenBaseURI; // Mystery box
        }
        
        // Après reveal : baseURI + tokenId + ".json"
        return string(abi.encodePacked(baseURI, tokenId.toString(), ".json"));
    }

    // Utility function to convert uint to string has been moved to StringUtils.sol

    // ERC721 core functions
    function ownerOf(uint256 id) public view virtual override(IERC721) returns (address tokenOwner) {
        tokenOwner = _ownerOf[id];
        require(tokenOwner != address(0), "Token doesn't exist");
    }

    function balanceOf(address tokenOwner) public view virtual override(IERC721) returns (uint256) {
        require(tokenOwner != address(0), "Owner = zero address");
        return _balanceOf[tokenOwner];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override(IERC721) {
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function approve(address spender, uint256 id) public virtual override(IERC721) {
        address tokenOwner = _ownerOf[id];
        require(msg.sender == tokenOwner || isApprovedForAll[tokenOwner][msg.sender], "Not authorized");

        _approvals[id] = spender;
        emit Approval(tokenOwner, spender, id);
    }

    function getApproved(uint256 id) public view virtual override(IERC721) returns (address) {
        require(_ownerOf[id] != address(0), "Token doesn't exist");
        return _approvals[id];
    }

    function _isApprovedOrOwner(address tokenOwner, address spender, uint256 id) internal view returns (bool) {
        return (spender == tokenOwner || isApprovedForAll[tokenOwner][spender] || spender == _approvals[id]);
    }

    function transferFrom(address from, address to, uint256 id) public virtual override(IERC721) {
        require(from == _ownerOf[id], "From != owner");
        require(to != address(0), "Transfer to zero address");
        require(_isApprovedOrOwner(from, msg.sender, id), "Not authorized");

        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[id] = to;

        delete _approvals[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(address from, address to, uint256 id) public virtual override(IERC721) {
        this.safeTransferFrom(from, to, id, "");
    }

    function safeTransferFrom(address from, address to, uint256 id, bytes calldata data) public virtual override(IERC721) {
        transferFrom(from, to, id);
        require(
            to.code.length == 0 ||
            IERC721Receiver(to).onERC721Received(msg.sender, from, id, data) == IERC721Receiver.onERC721Received.selector,
            "Unsafe recipient"
        );
    }

    // Internal functions for minting and burning
    function _mint(address to, uint256 id) internal {
        require(to != address(0), "Mint to zero address");
        require(_ownerOf[id] == address(0), "Already minted");
        require(totalSupply < MAX_SUPPLY, "Max supply reached");

        _balanceOf[to]++;
        _ownerOf[id] = to;
        totalSupply++;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal {
        address tokenOwner = _ownerOf[id];
        require(tokenOwner != address(0), "Not minted");

        _balanceOf[tokenOwner] -= 1;
        totalSupply--;

        delete _ownerOf[id];
        delete _approvals[id];

        emit Transfer(tokenOwner, address(0), id);
    }

    // Ownable2Step functions
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is zero address");
        pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner, newOwner);
    }

    function acceptOwnership() external {
        require(msg.sender == pendingOwner, "Not pending owner");
        address previousOwner = owner;
        owner = msg.sender;
        pendingOwner = address(0);
        emit OwnershipTransferred(previousOwner, msg.sender);
    }

    function renounceOwnership() external onlyOwner {
        owner = address(0);
        pendingOwner = address(0);
        emit OwnershipTransferred(msg.sender, address(0));
    }

    // Commit-Reveal functions - VERSION SÉCURISÉE
    function setHiddenBaseURI(string calldata uri) external onlyOwner {
        hiddenBaseURI = uri;
    }

    function commitMetadata(bytes32 _commitment) external onlyOwner {
        require(!revealed, "Already revealed");
        commitment = _commitment;
    }

    // 🔐 RÉVEAL SÉCURISÉ : baseURI définie SEULEMENT au moment du reveal
    function revealMetadata(string calldata _baseURI) external onlyOwner {
        require(!revealed, "Already revealed");
        require(commitment != bytes32(0), "No commitment");
        require(keccak256(abi.encodePacked(_baseURI)) == commitment, "Invalid baseURI");
        
        revealed = true;
        baseURI = _baseURI; // ← Défini SEULEMENT maintenant !
    }

    // Crowdsale functions
    function startSale() external onlyOwner {
        saleActive = true;
    }

    function stopSale() external onlyOwner {
        saleActive = false;
    }

    function setMintPrice(uint256 newPrice) external onlyOwner {
        mintPrice = newPrice;
    }

    function mintNFT() external payable {
        require(saleActive, "Sale not active");
        require(msg.value == mintPrice, "Payment must be exact mint price");
        require(totalSupply < MAX_SUPPLY, "Max supply reached");

        uint256 tokenId = totalSupply + 1;
        _mint(msg.sender, tokenId);
    }

    // Timelock withdraw functions
    function requestWithdraw() external onlyOwner {
        require(revealed, "Must reveal before withdraw");
        require(!withdrawRequested, "Withdraw already requested");
        
        withdrawRequested = true;
        withdrawUnlockTime = block.timestamp + GRACE_PERIOD;
    }

    function executeWithdraw() external onlyOwner {
        require(withdrawRequested, "No withdraw requested");
        require(block.timestamp >= withdrawUnlockTime, "Grace period not finished");
        
        withdrawRequested = false;
        withdrawUnlockTime = 0;
        
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        
        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Transfer failed");
    }

    function cancelWithdraw() external onlyOwner {
        require(withdrawRequested, "No withdraw requested");
        
        withdrawRequested = false;
        withdrawUnlockTime = 0;
    }

    // View function to check contract balance
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

