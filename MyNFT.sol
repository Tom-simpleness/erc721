// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface IERC721 is IERC165 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

contract MyNFT is IERC721Metadata {
    // Events
    event Transfer(address indexed from, address indexed to, uint256 indexed id);
    event Approval(address indexed owner, address indexed spender, uint256 indexed id);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
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
    mapping(uint256 => string) private _tokenURIs;

    // Ownable2Step state variables
    address public owner;
    address public pendingOwner;

    // Commit-Reveal state variables
    bytes32 public commitment;
    bool public revealed;
    string public hiddenBaseURI;

    // Crowdsale state variables
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public totalSupply;
    uint256 public mintPrice = 0.1 ether;
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
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    // Metadata implementation
    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(_ownerOf[tokenId] != address(0), "Token doesn't exist");
        
        if (!revealed) {
            return hiddenBaseURI;
        }
        
        return _tokenURIs[tokenId];
    }

    // ERC721 core functions
    function ownerOf(uint256 id) external view returns (address owner) {
        owner = _ownerOf[id];
        require(owner != address(0), "Token doesn't exist");
    }

    function balanceOf(address owner) external view returns (uint256) {
        require(owner != address(0), "Owner = zero address");
        return _balanceOf[owner];
    }

    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function approve(address spender, uint256 id) external {
        address owner = _ownerOf[id];
        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "Not authorized");

        _approvals[id] = spender;
        emit Approval(owner, spender, id);
    }

    function getApproved(uint256 id) external view returns (address) {
        require(_ownerOf[id] != address(0), "Token doesn't exist");
        return _approvals[id];
    }

    function _isApprovedOrOwner(address owner, address spender, uint256 id) internal view returns (bool) {
        return (spender == owner || isApprovedForAll[owner][spender] || spender == _approvals[id]);
    }

    function transferFrom(address from, address to, uint256 id) public {
        require(from == _ownerOf[id], "From != owner");
        require(to != address(0), "Transfer to zero address");
        require(_isApprovedOrOwner(from, msg.sender, id), "Not authorized");

        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[id] = to;

        delete _approvals[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(address from, address to, uint256 id) external {
        transferFrom(from, to, id);
        require(
            to.code.length == 0 || 
            IERC721Receiver(to).onERC721Received(msg.sender, from, id, "") == IERC721Receiver.onERC721Received.selector,
            "Unsafe recipient"
        );
    }

    function safeTransferFrom(address from, address to, uint256 id, bytes calldata data) external {
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

    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        require(_ownerOf[tokenId] != address(0), "Token doesn't exist");
        _tokenURIs[tokenId] = uri;
    }

    function _burn(uint256 id) internal {
        address owner = _ownerOf[id];
        require(owner != address(0), "Not minted");

        _balanceOf[owner] -= 1;
        totalSupply--;

        delete _ownerOf[id];
        delete _approvals[id];
        delete _tokenURIs[id];

        emit Transfer(owner, address(0), id);
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

    // Commit-Reveal functions
    function setHiddenBaseURI(string memory uri) external onlyOwner {
        hiddenBaseURI = uri;
    }

    function commitMetadata(bytes32 _commitment) external onlyOwner {
        require(!revealed, "Already revealed");
        commitment = _commitment;
    }

    function revealMetadata(string memory secret) external onlyOwner {
        require(!revealed, "Already revealed");
        require(commitment != bytes32(0), "No commitment");
        require(keccak256(abi.encodePacked(secret)) == commitment, "Invalid secret");
        
        revealed = true;
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
        require(msg.value >= mintPrice, "Insufficient payment");
        require(totalSupply < MAX_SUPPLY, "Max supply reached");

        uint256 tokenId = totalSupply + 1;
        _mint(msg.sender, tokenId);

        // Refund excess payment
        if (msg.value > mintPrice) {
            payable(msg.sender).transfer(msg.value - mintPrice);
        }
    }

    function mintWithURI(address to, uint256 tokenId, string memory uri) external onlyOwner {
        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);
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
