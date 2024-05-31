// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FunFactory {
    constructor(
        IERC20 fundingToken,
        IERC20 funToken
    ) {
        // TODO: Save things
    }

    // TODO: Deploys bonding contract
    // TODO: Deploys FunToken with the parameters
    // TODO: Last transaction setup Uniswap liquid pool
}
