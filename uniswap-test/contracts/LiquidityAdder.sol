// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

address constant NON_FUNGIBLE_POSITION_MANAGER = 0x1238536071E1c677A632429e3655c799b22cDA52;
address constant UNISWAP_V3_FACTORY = 0x0227628f3F023bb0B980b67D528571c95c6DaC1c;

interface IERC721Receiver {
  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external returns (bytes4);
}

interface IUniswapV3Factory {
  event OwnerChanged(address indexed oldOwner, address indexed newOwner);
  event PoolCreated(
    address indexed token0,
    address indexed token1,
    uint24 indexed fee,
    int24 tickSpacing,
    address pool
  );
  event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

  function owner() external view returns (address);
  function feeAmountTickSpacing(uint24 fee) external view returns (int24);
  function getPool(
    address tokenA,
    address tokenB,
    uint24 fee
  ) external view returns (address pool);
  function createPool(
    address tokenA,
    address tokenB,
    uint24 fee
  ) external returns (address pool);
  function setOwner(address owner) external;
  function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
}

interface IUniswapV3Pool {
  function initialize(uint160 sqrtPriceX96) external;

  function mint(
    address sender,
    address recipient,
    int24 tickLower,
    int24 tickUpper,
    uint128 amount,
    bytes calldata data
  ) external returns (uint256 amount0, uint256 amount1);

  function increaseLiquidity(
    uint256 tokenId,
    uint128 amount,
    uint256 amount0Max,
    uint256 amount1Max,
    bytes calldata data
  ) external returns (uint256 amount0, uint256 amount1);

  function decreaseLiquidity(
    uint256 tokenId,
    uint128 amount,
    uint256 amount0Min,
    uint256 amount1Min,
    uint256 deadline
  ) external returns (uint256 amount0, uint256 amount1);

  function collect(
    address recipient,
    uint256 tokenId,
    uint128 amount0Requested,
    uint128 amount1Requested
  ) external returns (uint128 amount0, uint128 amount1);

  function burn(
    uint256 tokenId
  ) external returns (uint128 amount0, uint128 amount1);

  function positions(
    uint256 tokenId
  )
    external
    view
    returns (
      uint96 nonce,
      address operator,
      address token0,
      address token1,
      uint24 fee,
      int24 tickLower,
      int24 tickUpper,
      uint128 liquidity,
      uint256 feeGrowthInside0LastX128,
      uint256 feeGrowthInside1LastX128,
      uint128 tokensOwed0,
      uint128 tokensOwed1
    );
}

contract UniswapV3Liquidity is IERC721Receiver {
  IERC20 private buyToken;
  IERC20 private funToken;
  address BUY_TOKEN;
  address FUN_TOKEN;

  int24 private constant MIN_TICK = -887272;
  int24 private constant MAX_TICK = -MIN_TICK;
  int24 private constant TICK_SPACING = 60;

  INonfungiblePositionManager public nonfungiblePositionManager =
    INonfungiblePositionManager(NON_FUNGIBLE_POSITION_MANAGER);

  constructor(address _buyTokenAddress, address _funTokenAddress) {
    buyToken = IERC20(_buyTokenAddress);
    funToken = IERC20(_funTokenAddress);
    BUY_TOKEN = _buyTokenAddress;
    FUN_TOKEN = _funTokenAddress;
  }

  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata
  ) external returns (bytes4) {
    return IERC721Receiver.onERC721Received.selector;
  }

  function sqrt(uint256 y) internal pure returns (uint256 z) {
    if (y > 3) {
      z = y;
      uint256 x = y / 2 + 1;
      while (x < z) {
        z = x;
        x = (y / x + x) / 2;
      }
    } else if (y != 0) {
      z = 1;
    }
  }

  function getSqrtPriceX96(uint256 price) public pure returns (uint160) {
    uint256 sqrtPrice = sqrt(price);
    return uint160(sqrtPrice * 2 ** 96);
  }

  function createPool() external {
    IUniswapV3Factory poolManager = IUniswapV3Factory(UNISWAP_V3_FACTORY);
    address poolAddress = poolManager.createPool(BUY_TOKEN, FUN_TOKEN, 3000);

    uint160 sqrtPriceX96 = getSqrtPriceX96(1);
    IUniswapV3Pool(poolAddress).initialize(sqrtPriceX96);
  }

  function mintNewPosition(
    uint256 amount0ToAdd,
    uint256 amount1ToAdd
  )
    external
    returns (
      uint256 tokenId,
      uint128 liquidity,
      uint256 amount0,
      uint256 amount1
    )
  {
    buyToken.transferFrom(msg.sender, address(this), amount0ToAdd);
    funToken.transferFrom(msg.sender, address(this), amount1ToAdd);

    buyToken.approve(address(nonfungiblePositionManager), amount0ToAdd);
    funToken.approve(address(nonfungiblePositionManager), amount1ToAdd);

    INonfungiblePositionManager.MintParams
      memory params = INonfungiblePositionManager.MintParams({
        token0: BUY_TOKEN,
        token1: FUN_TOKEN,
        fee: 3000,
        tickLower: MIN_TICK,
        tickUpper: MAX_TICK,
        amount0Desired: amount0ToAdd,
        amount1Desired: amount1ToAdd,
        amount0Min: 0,
        amount1Min: 0,
        recipient: address(this),
        deadline: block.timestamp
      });

    // Note that the pool defined by DAI/USDC and fee tier 0.3% must already be created and initialized in order to mint
    (tokenId, liquidity, amount0, amount1) = nonfungiblePositionManager.mint(
      params
    );

    if (amount0 < amount0ToAdd) {
      buyToken.approve(address(nonfungiblePositionManager), 0);
      uint256 refund0 = amount0ToAdd - amount0;
      buyToken.transfer(msg.sender, refund0);
    }
    if (amount1 < amount1ToAdd) {
      funToken.approve(address(nonfungiblePositionManager), 0);
      uint256 refund1 = amount1ToAdd - amount1;
      funToken.transfer(msg.sender, refund1);
    }
  }

  function collectAllFees(
    uint256 tokenId
  ) external returns (uint256 amount0, uint256 amount1) {
    INonfungiblePositionManager.CollectParams
      memory params = INonfungiblePositionManager.CollectParams({
        tokenId: tokenId,
        recipient: address(this),
        amount0Max: type(uint128).max,
        amount1Max: type(uint128).max
      });

    (amount0, amount1) = nonfungiblePositionManager.collect(params);
  }

  function increaseLiquidityCurrentRange(
    uint256 tokenId,
    uint256 amount0ToAdd,
    uint256 amount1ToAdd
  ) external returns (uint128 liquidity, uint256 amount0, uint256 amount1) {
    buyToken.transferFrom(msg.sender, address(this), amount0ToAdd);
    funToken.transferFrom(msg.sender, address(this), amount1ToAdd);

    buyToken.approve(address(nonfungiblePositionManager), amount0ToAdd);
    funToken.approve(address(nonfungiblePositionManager), amount1ToAdd);

    INonfungiblePositionManager.IncreaseLiquidityParams
      memory params = INonfungiblePositionManager.IncreaseLiquidityParams({
        tokenId: tokenId,
        amount0Desired: amount0ToAdd,
        amount1Desired: amount1ToAdd,
        amount0Min: 0,
        amount1Min: 0,
        deadline: block.timestamp
      });

    (liquidity, amount0, amount1) = nonfungiblePositionManager
      .increaseLiquidity(params);
  }

  function decreaseLiquidityCurrentRange(
    uint256 tokenId,
    uint128 liquidity
  ) external returns (uint256 amount0, uint256 amount1) {
    INonfungiblePositionManager.DecreaseLiquidityParams
      memory params = INonfungiblePositionManager.DecreaseLiquidityParams({
        tokenId: tokenId,
        liquidity: liquidity,
        amount0Min: 0,
        amount1Min: 0,
        deadline: block.timestamp
      });

    (amount0, amount1) = nonfungiblePositionManager.decreaseLiquidity(params);
  }
}

interface INonfungiblePositionManager {
  struct MintParams {
    address token0;
    address token1;
    uint24 fee;
    int24 tickLower;
    int24 tickUpper;
    uint256 amount0Desired;
    uint256 amount1Desired;
    uint256 amount0Min;
    uint256 amount1Min;
    address recipient;
    uint256 deadline;
  }

  function mint(
    MintParams calldata params
  )
    external
    payable
    returns (
      uint256 tokenId,
      uint128 liquidity,
      uint256 amount0,
      uint256 amount1
    );

  struct IncreaseLiquidityParams {
    uint256 tokenId;
    uint256 amount0Desired;
    uint256 amount1Desired;
    uint256 amount0Min;
    uint256 amount1Min;
    uint256 deadline;
  }

  function increaseLiquidity(
    IncreaseLiquidityParams calldata params
  )
    external
    payable
    returns (uint128 liquidity, uint256 amount0, uint256 amount1);

  struct DecreaseLiquidityParams {
    uint256 tokenId;
    uint128 liquidity;
    uint256 amount0Min;
    uint256 amount1Min;
    uint256 deadline;
  }

  function decreaseLiquidity(
    DecreaseLiquidityParams calldata params
  ) external payable returns (uint256 amount0, uint256 amount1);

  struct CollectParams {
    uint256 tokenId;
    address recipient;
    uint128 amount0Max;
    uint128 amount1Max;
  }

  function collect(
    CollectParams calldata params
  ) external payable returns (uint256 amount0, uint256 amount1);
}

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(
    address owner,
    address spender
  ) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);
}
