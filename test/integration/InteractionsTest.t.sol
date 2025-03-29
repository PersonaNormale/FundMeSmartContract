// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract FundMeTestIntegration is Test {
    FundMe fundMe;

    address immutable i_user = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(i_user, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        vm.startPrank(i_user);
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe{value: SEND_VALUE}(address(fundMe));
        vm.stopPrank();

        // vm.prank(i_user);
        // fundMe.fund{value: SEND_VALUE}();

        assertEq(address(fundMe).balance, SEND_VALUE);
    }

    function testOwnerCanWithdrawInteractions() public {
        uint256 preOwnerBalance = address(fundMe.getOwner()).balance;

        vm.prank(i_user);
        fundMe.fund{value: SEND_VALUE}();

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 afterOwnerBalance = address(fundMe.getOwner()).balance;

        assertEq(preOwnerBalance + SEND_VALUE, afterOwnerBalance);
    }
}
