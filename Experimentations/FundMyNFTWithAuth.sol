// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract FundMyNFTWithAuth is Ownable {
    address public withdrawalAddress;
    bool public withdrawalEnabled;
    mapping(address => bool) public authorizers;
    uint256 public balance;

    event Deposit(address indexed from, uint256 value);
    event Withdrawal(address indexed to, uint256 value);
    event WithdrawalEnabled();
    event WithdrawalDisabled();
    event AuthorizerAdded(address indexed authorizer);
    event AuthorizerRemoved(address indexed authorizer);

    //This contract requires multiple authorizers address when deployed, they will have the power to enable withdrawal so funds can be used
    constructor(address _withdrawalAddress, address[] memory _authorizers) {
        require(_authorizers.length > 0, "At least one authorizer is required");
        withdrawalAddress = _withdrawalAddress;
        authorizers[_withdrawalAddress] = true;
        for (uint256 i = 0; i < _authorizers.length; i++) {
            authorizers[_authorizers[i]] = true;
        }
    }

    function deposit() public payable {
        balance += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdrawAll() external payable {
        require(withdrawalEnabled, "Withdrawal is not enabled");
        require(msg.sender == withdrawalAddress, "Not authorized");
        balance = address(this).balance;
        require(balance > 0, "There are no funds to withdraw.");
        // Update state before sending funds
        (bool success, ) = payable(msg.sender).call{value: balance}("");
        require(success, "Withdraw failed.");
    }

    function enableWithdrawal() public {
        require(authorizers[msg.sender], "Not authorized");
        require(msg.sender != owner() && msg.sender != withdrawalAddress, "Not authorized");
        withdrawalEnabled = true;
        emit WithdrawalEnabled();
    }

    function disableWithdrawal() public {
        require(authorizers[msg.sender], "Not authorized");
        require(msg.sender != owner() && msg.sender != withdrawalAddress, "Not authorized");
        withdrawalEnabled = false;
        emit WithdrawalDisabled();
    }

    function canWithdraw(address addr) public view returns(bool) {
        return addr == withdrawalAddress && withdrawalEnabled;
    }
}
