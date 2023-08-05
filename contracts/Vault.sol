// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

/**
 * @title Vault contract
 * @author 3illBaby
 * @notice A simple banking solution
 */

contract Vault {
    //! Contract events
    event accountCreated(address indexed _client);
    event coinDeposited(address indexed _client);
    event coinTransferred(
        address indexed _from,
        address indexed _to,
        uint256 indexed _amount
    );
    event accountFrozen(address indexed _client);
    event accountActivated(address indexed _client);
    event coinWithdrawn(address indexed _client, uint256 indexed _amount);

    //! Enums & Structs
    enum AccountStatus {
        Active,
        Frozen
    }

    struct Account {
        string name;
        uint256 balance;
        AccountStatus status;
    }

    //! Contract States

    mapping(address => Account) public accounts;

    address[] public accountOwners;
    address public immutable Owner;

    //? Constructor accepts an address on deployment
    constructor() {
        Owner = msg.sender;
    }

    //! Contract Modifiers
    modifier onlyOwner() {
        require(
            msg.sender == Owner,
            "Only contract owner can call this function"
        );
        _;
    }

    modifier notFrozern(address _address) {
        require(
            accounts[_address].status == AccountStatus.Active,
            "Account is frozen!"
        );
        _;
    }

    modifier creationCompliance(uint256 _amount, string memory _name) {
        require(
            _amount > 0 && bytes(_name).length > 0,
            "invalid name or amount"
        );
        _;
    }

    modifier addressCompliance(address _address) {
        require(_address != address(0), "invalid address");
        _;
    }

    /**
     *  ! This function implements a modifier
     * ? This function creates a new user account
     * @param _initialBalance this gets set as the users account balance
     * @param _name this get set as the users account name
     */
    function createAccount(
        uint256 _initialBalance,
        string memory _name
    ) external creationCompliance(_initialBalance, _name) {
        address client = msg.sender;
        require(accounts[client].balance == 0, "Account already exsits");
        Account memory clientAccount = Account({
            name: _name,
            balance: _initialBalance,
            status: AccountStatus.Active
        });
        accounts[client] = clientAccount;
        accountOwners.push(client);

        emit accountCreated(client);
    }

    /**
     * ! This function implements a modifier
     * ? This function deposits some tokens to the specified address
     * @param _amount This is the amount to be added to the account balance
     * @param _address This is the address to be deposited to
     */
    function deposit(
        uint256 _amount,
        address _address
    ) external payable notFrozern(msg.sender) addressCompliance(_address) {
        require(_amount > 0, "invalid amount");
        require(_address != address(0), "invalid address");
        require(
            accounts[_address].status == AccountStatus.Active,
            "This account doesnt exsist"
        );

        address client = msg.sender;
        accounts[client].balance += _amount;

        emit coinDeposited(client);
    }

    /**
     * ! This function implements a modifier
     * ? this function transfers some tokens to the specified address
     * @param _address This is the address that the amount will be transfered to
     * @param _amount this is the amount to be transfered
     */

    function transfer(
        address _address,
        uint256 _amount
    ) external notFrozern(msg.sender) addressCompliance(_address) {
        address client = msg.sender;
        require(_amount > 0, "invalid amount");
        require(accounts[client].balance >= _amount, "Insufficient Balance");

        accounts[client].balance -= _amount;
        accounts[_address].balance += _amount;

        emit coinTransferred(client, _address, _amount);
    }

    /**
     * ! This function implements a modifier
     * ? This function gets the balance of a particular address
     * @param _address The address on which the function is called on
     */

    function viewBalance(
        address _address
    ) public view addressCompliance(_address) returns (uint256 _balance) {
        _balance = accounts[_address].balance;

        return _balance;
    }

    /**
     * ! This function implements a modifier
     * ? This function can only be called by the owner of this contract
     * @param _address The address of the account you want to freeze
     */

    function freezeAccount(
        address _address
    ) external onlyOwner addressCompliance(_address) {
        require(
            accounts[_address].status == AccountStatus.Active,
            "Account is already frozen"
        );
        accounts[_address].status = AccountStatus.Frozen;
        emit accountFrozen(_address);
    }

    function unFreezeAccount(
        address _address
    ) external onlyOwner addressCompliance(_address) {
        require(
            accounts[_address].status == AccountStatus.Frozen,
            "Account is not frozen"
        );

        accounts[_address].status = AccountStatus.Active;
        emit accountActivated(_address);
    }

    //? This function returns an array of all accounts created
    function getAllAccounts() public view returns (address[] memory) {
        address[] memory clients = new address[](accountOwners.length);

        for (uint256 i = 0; i < accountOwners.length; i++) {
            clients[i] = accountOwners[i];
        }

        return clients;
    }

    //? this function gets the account name of a specific address
    function getAccountNames(
        address _address
    ) public view addressCompliance(_address) returns (string memory _name) {
        _name = accounts[_address].name;
        return _name;
    }

    //? this function gets the total number of accounts created
    function getNumAccountOwners() external view returns (uint256) {
        return accountOwners.length;
    }

    /**
     * ! This function implements a modifier
     * ? This function withdraws a specified amount from an account
     * @param _amount the amount to be withdrawn from an account
     */
    function withdraw(uint256 _amount) public payable notFrozern(msg.sender) {
        address client = msg.sender;
        require(_amount > 0, "invalid amount");
        require(accounts[client].balance >= _amount, "Insufficient balance");

        accounts[client].balance -= _amount;

        emit coinWithdrawn(client, _amount);
    }
}
