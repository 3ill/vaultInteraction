const { ethers } = require('hardhat');

const main = async () => {
  const Vault = await ethers.getContractFactory('Vault');
  const vault = await Vault.deploy();

  const vaultAddress = await vault.getAddress();

  console.log(`Contract deployed at ${vaultAddress} `);
};

main().catch((error) => {
  console.error('You encountered an error', error);
  process.exitCode = 1;
});
