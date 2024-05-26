// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vault.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract VaultTest is Test {
    Vault public vault;
    ERC20 public token;

    function setUp() public {
        vault = new Vault();
        token = new ERC20("TestToken", "TT");
        token.mint(address(this), 1000 ether); // Minting some test tokens
        token.approve(address(vault), type(uint256).max); // Approving Vault to spend tokens
    }

    function test_DepositAndWithdraw() public {
        uint256 depositAmount = 100 ether;
        vault.whitelistToken(address(token));
        vault.deposit(address(token), depositAmount);

        assertEq(token.balanceOf(address(vault)), depositAmount);
        assertEq(vault.deposits(address(this), address(token)), depositAmount);

        vault.withdraw(address(token), depositAmount);
        assertEq(token.balanceOf(address(this)), 1000 ether);
    }

    function test_PauseAndUnpause() public {
        vault.pause();
        try vault.deposit(address(token), 10 ether) {
            fail("Deposit should fail when paused");
        } catch {}

        vault.unpause();
        vault.deposit(address(token), 10 ether); // This should pass
    }

    function testFuzz_WithdrawMoreThanDeposit(uint256 amount) public {
        vault.whitelistToken(address(token));
        vault.deposit(address(token), 100 ether);
        if (amount > 100 ether) {
            try vault.withdraw(address(token), amount) {
                fail("Should not be able to withdraw more than deposited");
            } catch {}
        }
    }
}
