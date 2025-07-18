import { ethers } from "hardhat";

async function main() {
  const CONTRACT_ADDRESS = "0x7953d8B572b2e0Dd5D3E29495f20f10120752A5D";

  // Get contract instance
  const MyNFTSecure = await ethers.getContractFactory("MyNFTSecure");
  const myNFT = MyNFTSecure.attach(CONTRACT_ADDRESS);
  const [minter] = await ethers.getSigners();

  console.log("🎯 Minting NFTs...");
  console.log("Contract:", CONTRACT_ADDRESS);
  console.log("Minter:", minter.address);

  try {
    // Check mint price
    const mintPrice = await myNFT.mintPrice();
    console.log("Mint Price:", ethers.formatEther(mintPrice), "ETH");

    // Check if sale is active
    const saleActive = await myNFT.saleActive();
    console.log("Sale Active:", saleActive);

    if (!saleActive) {
      console.log("❌ Sale is not active!");
      return;
    }

    // Mint 2 NFTs
    for (let i = 1; i <= 2; i++) {
      console.log(`\n🔨 Minting NFT #${i}...`);

      const tx = await myNFT.mintNFT({
        value: mintPrice,
        gasLimit: 300000, // Set gas limit to avoid estimation issues
      });

      console.log("Transaction hash:", tx.hash);
      await tx.wait();
      console.log(`✅ NFT #${i} minted successfully!`);
    }

    // Check final status
    console.log("\n📊 Final Status:");
    const totalSupply = await myNFT.totalSupply();
    const balance = await myNFT.balanceOf(minter.address);

    console.log("Total Supply:", totalSupply.toString());
    console.log("Your Balance:", balance.toString());

    // Check token URIs
    for (let i = 1; i <= Number(totalSupply); i++) {
      const tokenURI = await myNFT.tokenURI(i);
      console.log(`Token #${i} URI:`, tokenURI);
    }
  } catch (error) {
    console.error("❌ Error:", error);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
