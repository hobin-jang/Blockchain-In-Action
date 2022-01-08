pragma solidity ^0.6.0;

contract get_keccak {
    
    bytes32 public result;

    bytes32 public hash_password = 0;

    modifier InputPassword(){
        require(hash_password != 0);
        _;
    }

    function GetHashOfPassword(string memory str) public {
        hash_password = keccak256(abi.encodePacked(str));
    }

    function GetKeccak(uint value) public InputPassword {
        result = keccak256(abi.encodePacked(value, hash_password));
        hash_password = 0;
    }
}