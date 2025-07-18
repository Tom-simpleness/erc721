import { ethers } from "hardhat";

async function main() {
  const CONTRACT_ADDRESS = "0x7953d8B572b2e0Dd5D3E29495f20f10120752A5D";

  // Get contract instance
  const MyNFTSecure = await ethers.getContractFactory("MyNFTSecure");
  const myNFT = MyNFTSecure.attach(CONTRACT_ADDRESS);
  const [owner] = await ethers.getSigners();

  console.log("🔧 SETTING UP SECURE NFT CONTRACT");
  console.log("Contract:", CONTRACT_ADDRESS);
  console.log("Owner:", owner.address);

  try {
    // 1. Set hidden base URI (mystery box)
    console.log("\n1. Setting hidden metadata...");
    const hiddenURI =
      "https://gateway.pinata.cloud/ipfs/bafybeiffeobw3sxee742xr33acjbrfyes5456dnzo6hvyivbvd2npiyysq";
    await myNFT.setHiddenBaseURI(hiddenURI);
    console.log("Hidden URI set to:", hiddenURI);

    // 2. Prepare secure commitment (secret + baseURI)
    console.log("\n2. Creating secure commitment...");
    const secret = "my_secret_reveal_phrase_123";
    const baseURI = "https://gateway.pinata.cloud/ipfs/QmYourCollectionHash/";

    // IMPORTANT: Le commitment inclut MAINTENANT le secret ET la baseURI
    const commitment = ethers.keccak256(ethers.toUtf8Bytes(secret + baseURI));
    await myNFT.commitMetadata(commitment);
    console.log("Secret:", secret);
    console.log("Base URI (hidden until reveal):", baseURI);
    console.log("Commitment created:", commitment);

    // 3. Start sale
    console.log("\n3. Starting sale...");
    await myNFT.startSale();
    console.log("Sale is now active!");

    // 4. Check status
    console.log("\n📊 Contract Status:");
    console.log("Sale Active:", await myNFT.saleActive());
    console.log("Revealed:", await myNFT.revealed());
    console.log("Total Supply:", (await myNFT.totalSupply()).toString());
    console.log(
      "Mint Price:",
      ethers.formatEther(await myNFT.mintPrice()),
      "ETH"
    );
    console.log(
      "Contract Balance:",
      ethers.formatEther(await ethers.provider.getBalance(CONTRACT_ADDRESS)),
      "ETH"
    );

    console.log("\n✅ CONTRACT SETUP COMPLETE!");
    console.log("\n🎯 Next steps:");
    console.log(
      "1. Run 'npx hardhat run scripts/mint.ts --network sepolia' to mint NFTs"
    );
    console.log(
      "2. Run 'npx hardhat run scripts/secure-reveal.ts --network sepolia' to reveal later"
    );
    console.log("3. Check your NFTs on OpenSea testnet");
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
