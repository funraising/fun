import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./FunToken.sol";
import "./Curves/Linear.sol";

// The representation of the campaign as a bonding curve-based token
contract FunFun is LinearCurve, Ownable {
    FunToken public funToken;
    IERC20 private immutable _raiseToken;
    uint256 public immutable maxSupply;
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
    ) {
        _raiseToken = raiseToken;
        maxSupply = maxSupply;
        maxSupply = raiseTarget;

        LinearCurve(raiseTarget/maxSupply);
    }

    function buyFun(uint256 amount) {

    }

    /// Used to set FunToken, can be called only once
    function setFunToken(FunToken token) onlyOwner {
        funToken = token;
        renounceOwnership();
    }

}
