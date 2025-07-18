import { ethers } from "hardhat";

async function main() {
  console.log("🚀 Deploying FINAL NFT with correct Pinata URLs...");

  // Get the ContractFactory and Signers here.
  const MyNFTSecure = await ethers.getContractFactory("MyNFTSecure");
  const [deployer] = await ethers.getSigners();

  console.log("Deploying with account:", deployer.address);
  console.log(
    "Account balance:",
    (await deployer.provider.getBalance(deployer.address)).toString()
  );

  // Deploy the contract
  const myNFT = await MyNFTSecure.deploy(
    "My Cool NFT Collection Final",
    "MCNF"
  );
  await myNFT.waitForDeployment();

  const contractAddress = await myNFT.getAddress();
  console.log("MyNFTSecure FINAL deployed to:", contractAddress);
  console.log("Owner:", await myNFT.owner());
  console.log("Max Supply:", await myNFT.MAX_SUPPLY());
  console.log(
    "Mint Price:",
    ethers.formatEther(await myNFT.mintPrice()),
    "ETH"
  );

  // IMMEDIATE SETUP with correct URLs
  console.log("\n🔧 SETTING UP CONTRACT...");

  // 1. Set hidden URI (mystery box)
  const hiddenURI =
    "https://gateway.pinata.cloud/ipfs/bafybeifvf25np2ee45l6n5vnssnqaaokb3olsxc2i6fwn6wvv6kcwl66vu/hidden.json";
  await myNFT.setHiddenBaseURI(hiddenURI);
  console.log("✅ Hidden URI set:", hiddenURI);

  // 2. Create commitment with your real folder
  const secret = "my_secret_reveal_phrase_123";
  const baseURI =
    "https://gateway.pinata.cloud/ipfs/bafybeifvf25np2ee45l6n5vnssnqaaokb3olsxc2i6fwn6wvv6kcwl66vu/";

  const commitment = ethers.keccak256(ethers.toUtf8Bytes(secret + baseURI));
  await myNFT.commitMetadata(commitment);
  console.log("✅ Commitment created:", commitment);

  // 3. Start sale
  await myNFT.startSale();
  console.log("✅ Sale started!");

  console.log("\n🎯 CONTRACT READY!");
  console.log("Contract Address:", contractAddress);
  console.log("Hidden URI:", hiddenURI);
  console.log("Secret:", secret);
  console.log("Base URI:", baseURI);

  console.log("\n📋 Individual NFT URLs after reveal:");
  console.log(
    "NFT #1:",
    "https://gateway.pinata.cloud/ipfs/bafybeifvf25np2ee45l6n5vnssnqaaokb3olsxc2i6fwn6wvv6kcwl66vu/1.json"
  );
  console.log(
    "NFT #2:",
    "https://gateway.pinata.cloud/ipfs/bafybeifvf25np2ee45l6n5vnssnqaaokb3olsxc2i6fwn6wvv6kcwl66vu/2.json"
  );
  console.log(
    "NFT #3:",
    "https://gateway.pinata.cloud/ipfs/bafybeifvf25np2ee45l6n5vnssnqaaokb3olsxc2i6fwn6wvv6kcwl66vu/3.json"
  );

  console.log("\n🚀 Next: Mint NFTs, then reveal!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
