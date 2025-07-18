import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const MyNFTModule = buildModule("MyNFTModule", (m) => {
  const name = m.getParameter("name", "My Cool NFT Collection");
  const symbol = m.getParameter("symbol", "MCN");

  const myNFT = m.contract("MyNFT", [name, symbol]);

  return { myNFT };
});

export default MyNFTModule;
