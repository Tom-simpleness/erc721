import { ethers } from "hardhat";

async function main() {
  const CONTRACT_ADDRESS = "0x7953d8B572b2e0Dd5D3E29495f20f10120752A5D";

  const MyNFTSecure = await ethers.getContractFactory("MyNFTSecure");
  const myNFT = MyNFTSecure.attach(CONTRACT_ADDRESS);
  const [owner] = await ethers.getSigners();

  console.log("🔍 Checking your NFTs...");
  console.log("Contract:", CONTRACT_ADDRESS);
  console.log("Your address:", owner.address);

  try {
    const totalSupply = await myNFT.totalSupply();
    const yourBalance = await myNFT.balanceOf(owner.address);

    console.log("\n📊 Summary:");
    console.log("Total Supply:", totalSupply.toString());
    console.log("Your Balance:", yourBalance.toString());
    console.log("Revealed:", await myNFT.revealed());

    console.log("\n🎨 Your NFTs Details:");

    for (let tokenId = 1; tokenId <= Number(totalSupply); tokenId++) {
      try {
        const tokenOwner = await myNFT.ownerOf(tokenId);
        const tokenURI = await myNFT.tokenURI(tokenId);

        if (tokenOwner.toLowerCase() === owner.address.toLowerCase()) {
          console.log(`\n🎯 NFT #${tokenId}:`);
          console.log(`  Owner: ${tokenOwner}`);
          console.log(`  Metadata URL: ${tokenURI}`);
          console.log(
            `  OpenSea: https://testnets.opensea.io/assets/sepolia/${CONTRACT_ADDRESS}/${tokenId}`
          );
          console.log(
            `  Etherscan: https://sepolia.etherscan.io/token/${CONTRACT_ADDRESS}?a=${tokenId}`
          );
        }
      } catch (error) {
        console.log(`❌ Error checking token ${tokenId}:`, error.message);
      }
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
