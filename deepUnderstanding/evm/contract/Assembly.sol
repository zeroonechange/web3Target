// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Assembly {

    function addAs(uint x, uint y) public pure returns (uint) {
         assembly{
            let result := add(x, y)
            mstore(0x0, result)
            return(0x0, 32)
         }
    }

    function defineT() public {
        assembly{
            let x := 2 
            let y := x 

            
        }
    }

}