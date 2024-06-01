export function polynomial(supply: number, amountToRaise: number, totalSupply: number, degree: number) {
    const a = amountToRaise / (Math.pow(totalSupply, degree) / degree)
    const price = Math.pow(supply, degree-1) * a
    return price
}