// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Vault is Ownable {
    // State variables
    mapping(address => bool) private whitelistedTokens;
    mapping(address => mapping(address => uint256)) public deposits; // User -> Token -> Amount
    bool private paused;

    // Events
    event Deposit(address indexed user, address indexed token, uint256 amount);
    event Withdraw(address indexed user, address indexed token, uint256 amount);

    // Modifiers
    modifier whenNotPaused() {
        require(!paused, "Vault is paused");
        _;
    }

    modifier onlyWhitelisted(address _token) {
        require(whitelistedTokens[_token], "Token not whitelisted");
        _;
    }

    // Constructor
    constructor() Ownable(msg.sender) {
        paused = false;
    }

    // Admin functions
    function pause() public onlyOwner {
        paused = true;
    }

    function unpause() public onlyOwner {
        paused = false;
    }

    function whitelistToken(address _token) public onlyOwner {
        whitelistedTokens[_token] = true;
    }

    // User functions
    function deposit(address _token, uint256 _amount) public whenNotPaused onlyWhitelisted(_token) {
        // Assuming approval
        require(IERC20(_token).transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        deposits[msg.sender][_token] += _amount;
        emit Deposit(msg.sender, _token, _amount);
    }

    function withdraw(address _token, uint256 _amount) public whenNotPaused onlyWhitelisted(_token) {
        require(deposits[msg.sender][_token] >= _amount, "Insufficient balance");
        deposits[msg.sender][_token] -= _amount;
        require(IERC20(_token).transfer(msg.sender, _amount), "Transfer failed");
        emit Withdraw(msg.sender, _token, _amount);
    }
}
