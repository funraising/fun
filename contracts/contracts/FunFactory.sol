// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./FunFun.sol";

contract FunFactory {
    mapping(address => FunFun[]) private _funByFunder;

    function makeFun(
    ) public returns (FunFun) {
        FunFun fun = FunFun(address(0)); // TODO: Deploy FunFun and save the address
        _funByFunder[msg.sender].push(fun);

        return fun;
    }

    function makeFun(
        uint256 amount
    ) public returns (address) {
        address fun = address(0); // TODO: Deploy FunFun and save the address
        funByFunder[msg.sender].push(fun);

        return fun;
    }

    // TODO: Deploys bonding contract
    // TODO: Deploys FunToken with the parameters
    // TODO: Last transaction setup Uniswap liquid pool


    function getFunByFunder(address funder) public view returns (FunFun[] memory) {
        return _funByFunder[funder];
    }
}
