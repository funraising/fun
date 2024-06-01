// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./FunFun.sol";


/// Tokens that are bought in the funraising campains.
contract FunToken is ERC20, Ownable {
    bool private _locked;
    uint256 private _maxSupply;
    string private _imageURI;

    constructor(
        string memory name,
        string memory symbol,
        string memory imageURI,
        uint256 maxSupply,
        FunFun campaign
        ) ERC20(name, symbol) {
        _locked = true;
        _maxSupply = maxSupply;
        _imageURI = imageURI;

        transferOwnership(address(campaign));
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

    function burnFrom(address account, uint256 amount) public {
        _burn(account, amount);
    }

    function locked() public view returns (bool) {
        return _locked;
    }

    function unlock() public onlyOwner {
        _locked = false;
    }

    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }
}
