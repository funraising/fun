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
    mapping (address => uint256) private ledger;

    /// @param raiseToken_ Token of the fundraising
    /// @param endsAt_ Timestamp at which the fundraiser ends
    /// @param maxSupply_ How much of Fun Token will be minted with reaching the end of the campaign
    /// @param raiseTarget_ How much we are raising of the raise token in the campaign
    constructor(
        IERC20 raiseToken_,
        uint256 endsAt_,
        uint256 maxSupply_,
        uint256 raiseTarget_
    ) LinearCurve(raiseTarget / maxSupply) {
        _raiseToken = raiseToken_;
        maxSupply = maxSupply_;
        maxSupply = raiseTarget_;
        endsAt = endsAt_;
    }

    /// Investors buy the fundraiser's FunToken
    function buyFun(uint256 amount) public {
        require((address(funToken) == address(0)), "FunToken not set");
        require(amount != 0, "Require non-zero amount");

        uint256 raiseTokenAmount = priceForSupply(funToken.totalSupply() + amount) - priceForSupply(funToken.totalSupply());
        ledger[msg.sender] += raiseTokenAmount;
        _raiseToken.transferFrom(msg.sender, address(this), raiseTokenAmount);
        funToken.mint(msg.sender, amount);

        if (funToken.totalSupply() == maxSupply) {
            finishCampaign();
        }
    }

    /// Sell all the fun tokens in case the campaign fail to meet the criteria
    function sellFun() public {
        require(address(funToken) != address(0), "FunToken not set");
        require(block.timestamp >= endsAt, "Campaign not finished");

        uint256 addressAmount = funToken.balanceOf(msg.sender);
        require(addressAmount != 0, "No FunToken balance");
        _raiseToken.transfer(msg.sender, ledger[msg.sender]);
        funToken.burnFrom(msg.sender, addressAmount);
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
