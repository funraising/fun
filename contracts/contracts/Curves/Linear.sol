contract LinearCurve {
    uint256 private _steepnes;

    constructor(uint256 steepnes){
    _steepnes = steepnes;
    }

    function currentPrice(uint256 currentSupply) public pure {
        return currentSupply * _steepnes;
    }

}
