import { ethers } from "hardhat";

async function main() {
  const CONTRACT_ADDRESS = "0x7953d8B572b2e0Dd5D3E29495f20f10120752A5D";

  const MyNFTSecure = await ethers.getContractFactory("MyNFTSecure");
  const myNFT = MyNFTSecure.attach(CONTRACT_ADDRESS) as any;

  console.log("🔍 Checking Sale Status...");
  console.log("Contract:", CONTRACT_ADDRESS);

  try {
    const saleActive = await myNFT.saleActive();
    const revealed = await myNFT.revealed();
    const totalSupply = await myNFT.totalSupply();
    const mintPrice = await myNFT.mintPrice();

    console.log("\n📊 Contract Status:");
    console.log("Sale Active:", saleActive);
    console.log("Revealed:", revealed);
    console.log("Total Supply:", totalSupply.toString());
    console.log("Mint Price:", ethers.formatEther(mintPrice), "ETH");

    if (saleActive) {
      console.log("\n✅ La vente est ACTIVE - vous pouvez minter des NFTs !");
    } else {
      console.log(
        "\n❌ La vente est FERMÉE - il faut l'activer avec startSale()"
      );
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
