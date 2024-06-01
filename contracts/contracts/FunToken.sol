// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/// Tokens that are bought in the funraising campains.
contract FunToken is ERC20, Ownable { // FIXME: probably not ERC20
    enum CampainState {InProgress, Success, Fail};
    
    // solhint-disable-next-line no-empty-blocks
    constructor() ERC20("FunToken", "FUN") {} //TODO: Have the naming configurable based on input

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        // TODO: If campain is unsuscesfull then transfer can only be sent back to the bonding contract
        //  If succesfull then any transfer
        // If still in progress no transfer allowed

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
}
