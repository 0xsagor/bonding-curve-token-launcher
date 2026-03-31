const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  const CurveToken = await hre.ethers.getContractFactory("BondingCurveToken");
  
  // slope = 0.0001 ETH, initialPrice = 0.01 ETH
  const slope = hre.ethers.parseEther("0.0001");
  const initialPrice = hre.ethers.parseEther("0.01");

  const token = await CurveToken.deploy("CurveAsset", "CRV", slope, initialPrice);
  await token.waitForDeployment();

  console.log("Bonding Curve Token deployed to:", await token.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
