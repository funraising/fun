import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./FunToken.sol";
import "./Curves/Linear.sol";

// The representation of the campaign as a bonding curve-based token
contract FunFun is LinearCurve, Ownable {
    FunToken public funToken;
    IERC20 private immutable _raiseToken;
    uint256 public immutable maxSupply;
    uint256 public immutable endsAt;
    uint256 public immutable raiseTarget;

    /// @param funToken FunToken of the fundraiser
    /// @param raiseToken Token of the fundraising
    /// @param endsAt Timestamp at which the fundraiser ends
    /// @param maxSupply How much of Fun Token will be minted with reaching the end of the campaign
    /// @param raiseTarget How much we are raising of the raise token in the campaign
    constructor(
        IERC20 raiseToken,
        uint256 endsAt,
        uint256 maxSupply,
        uint256 raiseTarget
    ) LinearCurve(raiseTarget / maxSupply) {
        _raiseToken = raiseToken;
        maxSupply = maxSupply;
        maxSupply = raiseTarget;
        endsAt = endsAt;
    }

    /// Investors buy the fundraiser's FunToken
    function buyFun(uint256 amount) public {
        require(funToken != 0, "FunToken not set");
        require(amount != 0, "Require non-zero amount");

        uint256 raiseTokenAmount = priceForSupply(funToken.totalSupply() + amount) - priceForSupply(funToken.totalSupply());
        raiseTarget.transferFrom(msg.sender, address(this), raiseTokenAmount);
        funToken.mint(msg.sender, amount);

        if (funToken.totalSupply() == maxSupply) {
            finishCampaign();
        }
    }

    /// Sell all the fun tokens in case the campaign fail to meet the criteria
    function sellFun() public {
        require(funToken != 0, "FunToken not set");
        require(block.timestamp >= endsAt, "Campaign not finished");

        uint256 addressAmount = funToken.balanceOf(msg.sender);

    }

    function finishCampaign() private {
        require(funToken.totalSupply() == maxSupply, "Campaign not finished");
        funToken.unlock();

        // TODO: Setup Uniswap pool
    }

    /// Used to set FunToken, can be called only once
    function setFunToken(FunToken token) public onlyOwner {
        funToken = token;
        renounceOwnership();
    }

}
