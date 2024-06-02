// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "./interfaces/core/IUniswapV3Factory.sol";
import "./interfaces/core/IUniswapV3Pool.sol";
import "./interfaces/periphery/INonfungiblePositionManager.sol";

address constant NON_FUNGIBLE_POSITION_MANAGER = 0x1238536071E1c677A632429e3655c799b22cDA52;
address constant UNISWAP_V3_FACTORY = 0x0227628f3F023bb0B980b67D528571c95c6DaC1c;

int24 constant MIN_TICK = -887272;
int24 constant MAX_TICK = -MIN_TICK;

contract UniswapV3Liquidity is IERC721Receiver {
  address public token0;
  address public token1;
  uint24 public fee;

  IUniswapV3Pool public pool;

  constructor(address _token0, address _token1, uint24 _fee) {
    token0 = _token0;
    token1 = _token1;
    fee = _fee;

    // Create the pool if it doesn't exist yet
    pool = IUniswapV3Pool(
      IUniswapV3Factory(UNISWAP_V3_FACTORY).getPool(token0, token1, fee)
    );
    if (address(pool) == address(0)) {
      pool = IUniswapV3Pool(
        IUniswapV3Factory(UNISWAP_V3_FACTORY).createPool(token0, token1, fee)
      );
    }
  }

  function addLiquidity(
    uint256 amount0Desired,
    uint256 amount1Desired
  ) external {
    // Approve the position manager to spend the tokens
    IERC20(token0).approve(NON_FUNGIBLE_POSITION_MANAGER, amount0Desired);
    IERC20(token1).approve(NON_FUNGIBLE_POSITION_MANAGER, amount1Desired);

    INonfungiblePositionManager.MintParams
      memory params = INonfungiblePositionManager.MintParams({
        token0: token0,
        token1: token1,
        fee: fee,
        tickLower: MIN_TICK,
        tickUpper: MAX_TICK,
        amount0Desired: amount0Desired,
        amount1Desired: amount1Desired,
        amount0Min: 0,
        amount1Min: 0,
        recipient: address(this),
        deadline: block.timestamp
      });
    (
      uint256 tokenId,
      uint128 liquidity,
      uint256 amount0,
      uint256 amount1
    ) = INonfungiblePositionManager(NON_FUNGIBLE_POSITION_MANAGER).mint(params);

    // // Refund any leftover tokens
    // if (amount0 < amount0Desired) {
    //   IERC20(token0).transfer(msg.sender, amount0Desired - amount0);
    // }
    // if (amount1 < amount1Desired) {
    //   IERC20(token1).transfer(msg.sender, amount1Desired - amount1);
    // }
  }

  // Implement the onERC721Received function
  function onERC721Received(
    address /* operator */,
    address /* from */,
    uint256 /* tokenId */,
    bytes calldata /* data */
  ) external pure override returns (bytes4) {
    return this.onERC721Received.selector;
  }
}
