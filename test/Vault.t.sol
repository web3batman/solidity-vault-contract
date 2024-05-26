// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Vault.sol";
import "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract VaultTest is Test {
    Vault public vault;
    ERC20Mock public token;

    // Events
    event Deposit(address indexed user, address indexed token, uint256 amount);
    event Withdraw(address indexed user, address indexed token, uint256 amount);

    function setUp() public {
        vault = new Vault();
        token = new ERC20Mock();
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
        vault.whitelistToken(address(token));
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

    function testFail_UnauthorizedPause() public {
        vm.prank(address(0x123));
        vault.pause();
    }

    function testFail_UnauthorizedUnpause() public {
        vm.prank(address(0x123));
        vault.unpause();
    }

    function testFail_UnauthorizedWhitelistToken() public {
        vm.prank(address(0x123));
        vault.whitelistToken(address(0x456));
    }

    // Test with multiple users
    function test_MultipleUsersDepositWithdraw() public {
        // Setup additional user accounts
        address user2 = address(0x2);
        vm.deal(user2, 1 ether);
        ERC20Mock token2 = new ERC20Mock();

        vault.whitelistToken(address(token));
        vault.whitelistToken(address(token2));

        token2.mint(user2, 500 ether);
        vm.prank(user2);
        token2.approve(address(vault), type(uint256).max);

        // User1 Deposit
        uint256 user1Deposit = 100 ether;
        vault.deposit(address(token), user1Deposit);

        // User2 Deposit
        vm.prank(user2);
        uint256 user2Deposit = 200 ether;
        vault.deposit(address(token2), user2Deposit);

        // Check balances
        assertEq(vault.deposits(address(this), address(token)), user1Deposit);
        assertEq(vault.deposits(user2, address(token2)), user2Deposit);

        // User1 and User2 Withdraw
        vault.withdraw(address(token), user1Deposit);
        vm.prank(user2);
        vault.withdraw(address(token2), user2Deposit);

        // Check final balances
        assertEq(token.balanceOf(address(this)), 1000 ether);
        assertEq(token2.balanceOf(user2), 500 ether);
    }

    // Test deposit revert when paused
    function testFail_DepositWhenPaused() public {
        vault.whitelistToken(address(token));
        vault.pause();

        vault.deposit(address(token), 50 ether);
        vm.expectRevert("Vault is paused");
    }

    // Test deposit revert when paused
    function testFail_WithdrawWhenPaused() public {
        vault.whitelistToken(address(token));
        vault.deposit(address(token), 50 ether);
        vault.pause();

        vault.withdraw(address(token), 50 ether);
        vm.expectRevert("Vault is paused");
    }

    function test_DepositWithdrawWithWhitelistedToken() public {
        // Whitelist the token and deposit
        vault.whitelistToken(address(token));
        vault.deposit(address(token), 50 ether);

        // Check balances and then withdraw
        assertEq(vault.deposits(address(this), address(token)), 50 ether);
        vault.withdraw(address(token), 50 ether);
    }

    function testFail_DepositWithNonWhitelistedToken() public {
        ERC20Mock nonWhitelistedToken = new ERC20Mock();
        nonWhitelistedToken.mint(address(this), 100 ether);

        // Attempt to deposit a non-whitelisted token
        vault.deposit(address(nonWhitelistedToken), 50 ether);
        vm.expectRevert();
    }

    function testFail_WithdrawWithNonWhitelistedToken() public {
        ERC20Mock nonWhitelistedToken = new ERC20Mock();
        nonWhitelistedToken.mint(address(this), 100 ether);
        vault.deposit(address(token), 100 ether); // Deposit a whitelisted token first

        // Attempt to withdraw a non-whitelisted token
        vault.withdraw(address(nonWhitelistedToken), 50 ether);
        vm.expectRevert();
    }

    // Testing event emission
    function test_DepositEvent() public {
        uint256 amount = 100 ether;
        vault.whitelistToken(address(token));
        vm.expectEmit(true, true, false, true);
        emit Deposit(address(this), address(token), amount);
        vault.deposit(address(token), amount);
    }

    function test_WithdrawEvent() public {
        uint256 amount = 100 ether;
        vault.whitelistToken(address(token));
        vault.deposit(address(token), amount);
        vm.expectEmit(true, true, false, true);
        emit Withdraw(address(this), address(token), amount);
        vault.withdraw(address(token), amount);
    }
}
