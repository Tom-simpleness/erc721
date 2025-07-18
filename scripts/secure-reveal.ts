import { ethers } from "hardhat";

async function main() {
  const CONTRACT_ADDRESS = "0x7953d8B572b2e0Dd5D3E29495f20f10120752A5D";

  // IMPORTANT: Ces valeurs doivent correspondre à celles utilisées dans deploy-final.ts
  const SECRET = "my_secret_reveal_phrase_123";
  const BASE_URI =
    "https://gateway.pinata.cloud/ipfs/bafybeifvf25np2ee45l6n5vnssnqaaokb3olsxc2i6fwn6wvv6kcwl66vu/";

  const MyNFTSecure = await ethers.getContractFactory("MyNFTSecure");
  const myNFT = MyNFTSecure.attach(CONTRACT_ADDRESS);
  const [owner] = await ethers.getSigners();

  console.log("🎭 SECURE NFT REVEAL PROCESS");
  console.log("Contract:", CONTRACT_ADDRESS);
  console.log("Owner:", owner.address);

  try {
    // Check current state BEFORE reveal
    console.log("\n📊 BEFORE REVEAL:");
    const revealedBefore = await myNFT.revealed();
    const totalSupply = await myNFT.totalSupply();
    console.log("Revealed:", revealedBefore);
    console.log("Total Supply:", totalSupply.toString());

    if (totalSupply == 0) {
      console.log("⚠️  No NFTs minted yet! Run mint script first.");
      return;
    }

    console.log("\n🎨 Current NFT URIs (should be Mystery Box):");
    for (let i = 1; i <= Number(totalSupply); i++) {
      try {
        const tokenURI = await myNFT.tokenURI(i);
        console.log(`NFT #${i}: ${tokenURI}`);
      } catch (error) {
        console.log(`NFT #${i}: Error reading URI`);
      }
    }

    // Perform the secure reveal
    console.log("\n🚀 PERFORMING SECURE REVEAL...");
    console.log("Secret:", SECRET);
    console.log("Base URI:", BASE_URI);

    // Verify the commitment matches
    const expectedCommitment = ethers.keccak256(
      ethers.toUtf8Bytes(SECRET + BASE_URI)
    );
    const actualCommitment = await myNFT.commitment();
    console.log("Expected commitment:", expectedCommitment);
    console.log("Actual commitment:", actualCommitment);

    if (expectedCommitment !== actualCommitment) {
      console.log(
        "❌ COMMITMENT MISMATCH! Check your secret and baseURI values."
      );
      return;
    }

    console.log("✅ Commitment verified! Proceeding with reveal...");

    const tx = await myNFT.revealMetadata(SECRET, BASE_URI, {
      gasLimit: 150000,
    });

    console.log("Transaction hash:", tx.hash);
    console.log("⏳ Waiting for confirmation...");
    await tx.wait();
    console.log("✅ REVEAL SUCCESSFUL!");

    // Check state AFTER reveal
    console.log("\n📊 AFTER REVEAL:");
    const revealedAfter = await myNFT.revealed();
    console.log("Revealed:", revealedAfter);

    console.log("\n🎉 REVEALED NFT URIs:");
    for (let i = 1; i <= Number(totalSupply); i++) {
      try {
        const tokenURI = await myNFT.tokenURI(i);
        console.log(`NFT #${i}: ${tokenURI}`);
      } catch (error) {
        console.log(`NFT #${i}: Error reading URI`);
      }
    }

    console.log("\n🎊 SECURE REVEAL COMPLETE!");
    console.log("Your NFTs now show their true metadata!");
    console.log("Expected pattern: baseURI + tokenId + '.json'");
    console.log(
      "Example: https://gateway.pinata.cloud/ipfs/QmYourCollectionHash/1.json"
    );
    console.log("\nCheck them on OpenSea testnet!");

    // Show OpenSea links
    console.log("\n🔗 OpenSea Links:");
    for (let i = 1; i <= Number(totalSupply); i++) {
      console.log(
        `NFT #${i}: https://testnets.opensea.io/assets/sepolia/${CONTRACT_ADDRESS}/${i}`
      );
    }
  } catch (error) {
    console.error("❌ Error during reveal:", error);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
