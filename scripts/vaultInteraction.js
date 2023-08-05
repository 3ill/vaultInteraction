const { ethers } = require('hardhat');
require('dotenv').config();
const {
  GOERLI_URL,
  PRIVATE_KEY,
  PRIVATE_KEY2,
  ACCOUNT1,
  OWNER,
  CONTRACT_ADDRESS,
} = process.env;

// CONTRACT_ADDRESS = "0x049Ced198d9Aa24fA940477917e4E868115Aa198"
const provider = new ethers.JsonRpcProvider(GOERLI_URL);

//! Make sure it's a goerli account address
//? This creates a new instance of a wallet capable of interacting with a contract on the goerli testnet
const signer = new ethers.Wallet(PRIVATE_KEY, provider);
const signer2 = new ethers.Wallet(PRIVATE_KEY2, provider);

//? This function calls the createAccount function defined in the smart contract
//? it easily creates an account;
const createNewAccount = async ({
  _balance,
  _name,
  _signer,
  _vaultContract,
}) => {
  try {
    const name = _name.toString();
    if (_signer) {
      const newVault = _vaultContract.connect(_signer);
      await newVault.createAccount(_balance, name);
    } else {
      _vaultContract.createAccount(_balance, name);
    }
    return 'Account successfully created';
  } catch (error) {
    console.error('Error creating account:', error);
    return 'Failed to create account';
  }
};

const getName = async ({ _contract, _address }) => {
  try {
    const accountName = await _contract.getAccountNames(_address);
    return accountName;
  } catch (error) {
    console.error('Failed to get name', error);
  }
};

const viewBalance = async ({ _contract, _address }) => {
  try {
    const accountBalance = await _contract.viewBalance(_address);
    return accountBalance;
  } catch (error) {
    console.error('Failed to get balance', error);
  }
};

const transferToken = async ({ _contract, _to, _amount }) => {
  try {
    await _contract.transfer(_to, _amount);
  } catch (error) {
    console.error('Transfer Failed', error);
  }
};

const main = async () => {
  let vaultContract;
  let newAccountBalance;

  //? This function creates an instance of the contract
  vaultContract = await ethers.getContractAt('Vault', CONTRACT_ADDRESS, signer);

  console.log(await vaultContract.Owner());

  //? This calls the createAccount function
  // await createNewAccount({
  //   _balance: 5000,
  //   _name: 'your name',
  //   _signer: yourSigner,
  //   _vaultContract: vaultContract,
  // });

  //? This checks the account balance of an address
  const accountBalance = await viewBalance({
    _contract: vaultContract,
    _address: ACCOUNT1,
  });
  const accountBalance1 = await viewBalance({
    _contract: vaultContract,
    _address: OWNER,
  });
  console.log(accountBalance);
  console.log(accountBalance1);

  //? This checks the name of an account
  const accountName = await getName({
    _contract: vaultContract,
    _address: ACCOUNT1,
  });
  const ownerName = await getName({
    _contract: vaultContract,
    _address: OWNER,
  });
  console.log(accountName);
  console.log(ownerName);

  // //? Transfers tokens
  // await transferToken({
  //   _contract: vaultContract,
  //   _to: ACCOUNT1,
  //   _amount: 100,
  // });

  newAccountBalance = await viewBalance({
    _contract: vaultContract,
    _address: ACCOUNT1,
  });

  console.log(newAccountBalance);

  //? withdraw some tokens from account1
  await vaultContract.connect(signer2).withdraw(200);
  newAccountBalance = await viewBalance({
    _contract: vaultContract,
    _address: ACCOUNT1,
  });
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
