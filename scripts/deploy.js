const { ethers } = require('hardhat');

const main = async () => {
  try {
    const Vault = await ethers.getContractFactory('Vault');
    const vault = await Vault.deploy();

    const contractAddress = await vault.getAddress();
    console.log(contractAddress);
  } catch (error) {
    console.error('you encountered an error', error);
  }
};

main().catch((error) => {
  console.error('You encountered an error', error);
  process.exitCode = 1;
});
