// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "./interfaces/core/IUniswapV3Factory.sol";
import "./interfaces/core/IUniswapV3Pool.sol";
import "./interfaces/periphery/INonfungiblePositionManager.sol";

int24 constant MIN_TICK = -887272;
int24 constant MAX_TICK = -MIN_TICK;

contract UniswapV3Liquidity is IERC721Receiver {
  address public token0;
  address public token1;
  uint24 public fee;

  IUniswapV3Pool public pool;
  IUniswapV3Factory public factory;

  address public positionManagerAddress;

  event LiquidityAdded(uint256 amount0, uint256 amount1);
  event MintResult(
    uint256 tokenId,
    uint128 liquidity,
    uint256 amount0,
    uint256 amount1
  );
  event ApprovalCheck(uint256 allowance0, uint256 allowance1);
  event PoolCreated(address pool);

  constructor(
    address _token0,
    address _token1,
    uint24 _fee,
    address _factoryAddress,
    address _positionManagerAddress
  ) {
    token0 = _token0;
    token1 = _token1;
    fee = _fee;
    factory = IUniswapV3Factory(_factoryAddress);
    positionManagerAddress = _positionManagerAddress;

    // Create the pool if it doesn't exist yet
    pool = IUniswapV3Pool(factory.getPool(token0, token1, fee));
    if (address(pool) == address(0)) {
      pool = IUniswapV3Pool(factory.createPool(token0, token1, fee));
      emit PoolCreated(address(pool));

      require(address(pool) != address(0), "Pool creation failed");
    }
    require(address(pool) != address(0), "Pool not found or created");
  }

  function addLiquidity(
    uint256 amount0Desired,
    uint256 amount1Desired
  ) external {
    // Approve the position manager to spend the tokens
    IERC20(token0).approve(positionManagerAddress, amount0Desired);
    IERC20(token1).approve(positionManagerAddress, amount1Desired);

    uint256 allowance0 = IERC20(token0).allowance(
      address(this),
      positionManagerAddress
    );
    uint256 allowance1 = IERC20(token1).allowance(
      address(this),
      positionManagerAddress
    );
    emit ApprovalCheck(allowance0, allowance1);

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
    ) = INonfungiblePositionManager(positionManagerAddress).mint(params);

    emit LiquidityAdded(amount0, amount1);
    emit MintResult(tokenId, liquidity, amount0, amount1);

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
