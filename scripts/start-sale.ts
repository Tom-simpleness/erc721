import { ethers } from "hardhat";

async function main() {
  const CONTRACT_ADDRESS = "0x7953d8B572b2e0Dd5D3E29495f20f10120752A5D";

  const MyNFTSecure = await ethers.getContractFactory("MyNFTSecure");
  const myNFT = MyNFTSecure.attach(CONTRACT_ADDRESS);
  const [owner] = await ethers.getSigners();

  console.log("🚀 STARTING SALE...");
  console.log("Contract:", CONTRACT_ADDRESS);
  console.log("Owner:", owner.address);

  try {
    // Check current state
    console.log("\n📊 BEFORE:");
    console.log("Sale Active:", await myNFT.saleActive());

    // Start sale
    console.log("\n🔧 Starting sale...");
    const tx = await myNFT.startSale();
    console.log("Transaction hash:", tx.hash);
    await tx.wait();
    console.log("✅ Transaction confirmed!");

    // Check final state
    console.log("\n📊 AFTER:");
    console.log("Sale Active:", await myNFT.saleActive());
    console.log("Revealed:", await myNFT.revealed());
    console.log("Total Supply:", (await myNFT.totalSupply()).toString());
    console.log(
      "Mint Price:",
      ethers.formatEther(await myNFT.mintPrice()),
      "ETH"
    );

    if (await myNFT.saleActive()) {
      console.log("\n🎉 SALE IS NOW ACTIVE!");
      console.log("You can now mint NFTs with:");
      console.log("npx hardhat run scripts/mint.ts --network sepolia");
    } else {
      console.log("\n❌ Sale is still not active. Check for errors.");
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
