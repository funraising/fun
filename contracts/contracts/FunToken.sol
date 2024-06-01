// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/// Tokens that are bought in the funraising campains.
contract FunToken is ERC20, Ownable {
    bool private _locked;
    uint256 private _maxSupply;

    constructor(string memory name, string memory symbol, uint256 maxSupply) ERC20(name, symbol) Ownable() {
        _locked = true;
        _maxSupply = maxSupply;
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        require(!_locked, "FunToken: token is locked");

        _transfer(_msgSender(), to, amount);

        return true;
    }

    function mint(address to, uint256 amount) public onlyOwner returns (bool){
        require(totalSupply() + amount <= _maxSupply, "FunToken: max supply exceeded");

        _mint(to, amount);

        return true;
    }

    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);

        return true;
    }

    function lock() public onlyOwner {
        _locked = true;
    }

    function unlock() public onlyOwner {
        _locked = false;
    }
}
