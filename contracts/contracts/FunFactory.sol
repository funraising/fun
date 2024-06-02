// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./FunFun.sol";

contract FunFactory {
    IERC20 private _raisinToken;
    mapping(address => FunFun[]) private _funByMan;

    constructor (
        IERC20 raisinToken
    ) {
        _raisinToken = raisinToken;
    }

    function createFun(
        string memory name,
        string memory symbol,
        string memory imageURI,
        uint256 endsAt,
        uint256 maxSupply,
        uint256 raisinTarget
    ) public returns (FunFun) {
        FunFun fun = makeFun(
            endsAt,
            maxSupply,
            raisinTarget
            );
        FunToken funToken = deployFunToken(name, symbol, imageURI, maxSupply, fun);

        fun.setFunToken(funToken);

        return fun;
    }

    function deployFunToken(
        string memory name,
        string memory symbol,
        string memory imageURI,
        uint256 maxSupply,
        FunFun campaign
    ) private returns (FunToken) {
        FunToken funToken = new FunToken(name, symbol, imageURI, maxSupply, campaign);
        require(address(funToken) != address(0), "Failed to deploy FunToken");

        return funToken;
    }

    function makeFun(
        uint256 endsAt,
        uint256 maxSupply,
        uint256 raisinTarget
    ) private returns (FunFun) {
        FunFun fun = new FunFun(
            _raisinToken,
            endsAt,
            maxSupply,
            raisinTarget
        );
        require(address(fun) != address(0), "Failed to deploy FunFun");
        _funByMan[msg.sender].push(fun);

        return fun;
    }

    function getFunByMan(address funder) public view returns (FunFun[] memory) {
        return _funByMan[funder];
    }
}
