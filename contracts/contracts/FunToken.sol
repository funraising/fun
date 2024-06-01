// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// Tokens that are bought in the funraising campains.
contract FunToken is ERC20 {
    // solhint-disable-next-line no-empty-blocks
    constructor() ERC20("FunToken", "FUN") {} //TODO: Have the naming configurable based on input

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        // TODO: If campain is unsuscesfull than transfer can be only back to the bonding contract
        //  If succesfull then any transfer
        // If still in progress no transfer allowed

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
}
