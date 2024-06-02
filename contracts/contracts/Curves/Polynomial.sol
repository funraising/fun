contract PolynomialCurve {
  uint256 private _steepness;

  constructor(uint256 steepness) {
    _steepness = steepness;
  }

  function priceForSupply(uint256 currentSupply) public view returns (uint256) {
    return currentSupply ^ (2 * _steepness);
  }
}
