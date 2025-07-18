# ERC721 NFT Collection with Advanced Patterns

A comprehensive ERC721 NFT smart contract implementation featuring multiple design patterns and security mechanisms, deployed on Sepolia testnet.

## 🚀 Project Overview

This project implements a complete NFT collection with the following advanced patterns:

- **ERC721 + Metadata Extension**: Full NFT functionality with metadata support
- **Ownable2Step**: Secure ownership transfer requiring acceptance
- **Commit-Reveal Pattern**: Secure metadata reveal mechanism
- **Crowdsale**: Public minting with configurable pricing
- **Timelock**: Delayed withdraw functionality for community safety

## 📋 Features

### Core ERC721 Functionality

- ✅ Standard NFT minting, transfer, and approval functions
- ✅ Metadata support with `tokenURI()` implementation
- ✅ Safe transfer checks with `IERC721Receiver` support
- ✅ ERC165 interface detection

### Advanced Security Patterns

- ✅ **Ownable2Step**: Two-step ownership transfer for enhanced security
- ✅ **Commit-Reveal**: Cryptographic commitment to prevent front-running
- ✅ **Timelock**: 1-week grace period before fund withdrawal
- ✅ **Access Control**: Owner-only functions with proper modifiers

### Crowdsale Features

- ✅ Public minting with ETH payment (0.01 ETH per NFT)
- ✅ Maximum supply cap (10,000 NFTs)
- ✅ Sale activation/deactivation controls
- ✅ Automatic refund for excess payments

### Metadata Management

- ✅ IPFS integration with Pinata for decentralized storage
- ✅ Hidden metadata during pre-reveal phase
- ✅ Secure reveal mechanism with cryptographic verification
- ✅ Individual metadata files for each NFT

## 🔧 Technical Details

### Contract Information

- **Contract Name**: MyNFTSecure
- **Symbol**: MCNF
- **Network**: Sepolia Testnet
- **Contract Address**: `0x7953d8B572b2e0Dd5D3E29495f20f10120752A5D`
- **Max Supply**: 10,000 NFTs
- **Mint Price**: 0.01 ETH

### IPFS Metadata Structure

```
Hidden Metadata (Pre-reveal):
https://gateway.pinata.cloud/ipfs/bafybeifvf25np2ee45l6n5vnssnqaaokb3olsxc2i6fwn6wvv6kcwl66vu/hidden.json

Revealed Metadata:
https://gateway.pinata.cloud/ipfs/bafybeifvf25np2ee45l6n5vnssnqaaokb3olsxc2i6fwn6wvv6kcwl66vu/1.json
https://gateway.pinata.cloud/ipfs/bafybeifvf25np2ee45l6n5vnssnqaaokb3olsxc2i6fwn6wvv6kcwl66vu/2.json
...
```

## 🛠 Installation & Setup

### Prerequisites

- Node.js v18+
- npm or yarn
- MetaMask or similar Web3 wallet

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd erc721

# Install dependencies
npm install

# Create environment file
cp .env.example .env
# Add your private key and Infura/Alchemy API key
```

### Environment Variables

```env
PRIVATE_KEY=your_private_key_here
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/your_api_key
ETHERSCAN_API_KEY=your_etherscan_api_key
```

## 📜 Available Scripts

### Deployment

```bash
# Deploy the contract with full setup
npx hardhat run scripts/deploy-final.ts --network sepolia
```

### Interaction Scripts

```bash
# Check current sale status
npx hardhat run scripts/check-sale-status.ts --network sepolia

# Mint NFTs (requires active sale)
npx hardhat run scripts/mint.ts --network sepolia

# Check your NFTs
npx hardhat run scripts/check-nfts.ts --network sepolia

# Start/stop sale (owner only)
npx hardhat run scripts/start-sale.ts --network sepolia

# Perform secure reveal (owner only)
npx hardhat run scripts/secure-reveal.ts --network sepolia
```

### Testing & Development

```bash
# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test

# Run local blockchain
npx hardhat node
```

## 🔐 Security Features

### Commit-Reveal Pattern

The contract uses a secure commit-reveal mechanism:

1. **Commit Phase**: Owner commits to a hash of `secret + baseURI`
2. **Reveal Phase**: Owner provides both secret and baseURI to unlock metadata
3. **Verification**: Contract verifies the commitment matches the provided values

### Timelock Mechanism

- Withdrawal requires a 1-week grace period after revelation
- Community has time to react to any malicious behavior
- Owner must explicitly request withdrawal before the timelock begins

### Ownable2Step

- Ownership transfer requires acceptance from the new owner
- Prevents accidental ownership loss to invalid addresses
- Two-step process ensures intentional ownership changes

## 📊 Contract State

### Current Status (Live Contract)

- ✅ **Deployed**: Contract successfully deployed on Sepolia
- ✅ **Sale Active**: Public minting is currently enabled
- ✅ **Revealed**: Metadata has been revealed
- ✅ **NFTs Minted**: 2 NFTs currently minted
- 💰 **Available for Mint**: 9,998 NFTs remaining

## 🤝 Contributing

1. Follow the established code style
2. Add tests for new features
3. Update documentation
4. Ensure all tests pass
5. Submit pull requests for review

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Disclaimer

This is an educational project. While security best practices are implemented, always conduct thorough audits before using in production environments.

---

**Built with ❤️ using Hardhat, TypeScript, and Solidity**
