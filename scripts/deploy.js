const { ethers } = require("hardhat");
const fs = require("fs");

const main = async () => {
  const nftContractFactory = await ethers.getContractFactory("ArtSeaTokens");
  const nftContract = await nftContractFactory.deploy();
  await nftContract.deployed();
  console.log("NFT contract deployed to:", nftContract.address);
  fs.copyFile(
    "../artifacts/contracts/ArtSeaTokens.sol/ArtSeaTokens.json",
    "../src/utils/ArtSeaTokens.json",
    (err) => {
      if (err) throw err;
      console.log("Copied ABI file to React's src directory");
    }
  );
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (err) {
    console.log(err);
    process.exit(1);
  }
};

runMain();
