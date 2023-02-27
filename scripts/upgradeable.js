const { ethers, upgrades } = require("hardhat");
const { deployProxy } = require('@openzeppelin/hardhat-upgrades');
async function main() {
    const [Deployer]=await ethers.getSigners();
    console.log("Deployer Contract Address:",Deployer.address);
    const Upgradeable = await ethers.getContractFactory("StakingContractupgrade");
    const Token = await upgrades.deployProxy(Upgradeable,['QTKN','Q',20],{ initializer: 'initialize' });
    await Token.deployed();
    console.log("NFT StakingContractupgrade Token deployed to:", Token.address);
    saveFrontendFiles(Token,"StakingContractupgrade");
  }
  function saveFrontendFiles(contract, name) {
    const fs = require("fs");
    const contractsDir = `${__dirname}/../contractsData`;
  
    if (!fs.existsSync(contractsDir)) {
      fs.mkdirSync(contractsDir);
    }
  
    const addressFilePath = `${contractsDir}/${name}-address.json`;
    const artifactFilePath = `${contractsDir}/${name}.json`;
  
    fs.writeFileSync(
      addressFilePath,
      JSON.stringify({ address: contract.address }, null, 2)
    );
  
    const contractArtifact = artifacts.readArtifactSync(name);
  
    fs.writeFileSync(
      artifactFilePath,
      JSON.stringify(contractArtifact, null, 2)
    );
  }
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error)
        process.exit(1)
    })
