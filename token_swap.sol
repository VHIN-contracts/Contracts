// SPDX-License-Identifier: MIT
// fd6a3c4a8e4c91d66f53486171c4528d880d0ad97811263142215914e39becbd

pragma solidity ^0.8.0;


contract VHINSwaper {
	address payable owner;
	uint256 private developer_fee;

	USDCToken public usdc;
	address USDC_add = payable(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);

	VHIN public vhin;
	address payable vhin_add = payable(0x83b3c321cadd68C786e401A60E74E10ba8CA9292);

	uint256 multiplier = 10**18;
	uint256 multiplier_2 = 10**6;
	uint256 division = 10**12;

	bool internal locked;

	uint256 sold = 1;
	uint256 tresure = 1;

	constructor() {
		owner = payable(msg.sender);

		usdc = USDCToken(USDC_add);
		vhin = VHIN(vhin_add);

        vhin.swaper_starter(msg.sender);
	}


	// transfer USDC for custom tokens
	function sell_tokens(uint256 _amount) public prevent_reentrancy {
		require (_amount > 1 * 10**4, "Amount must be greater than 0.01 USDC.");
		require(usdc.balanceOf(msg.sender) >= _amount, "You don't have enough USDC tokens.");

		if (_amount >= vhin.balanceOf(address(this))) {
			vhin.mint_to_swaper();
		}

		uint256 _price = get_price();
		uint256 _new_amount = ((((_amount * division) / 1000) * 995) * _price) / 10000;

		require(recieve_money(_amount));
		require(send_tokens(_new_amount));

		developer_fee += (((_amount * division) - _new_amount) / 5) / division;
		tresure += (_amount - developer_fee) * division;
		sold += _new_amount;
	}

	// for function sell_tokens
	function recieve_money(uint256 _amount) private returns(bool) {
		/*User needs to approve this contract on his amount of USDC tokens*/
		require(usdc.transferFrom(msg.sender, address(this), _amount), "You don't have enough funds.");
		return true;
	}

	function send_tokens(uint256 _amount) private returns(bool) {
		require(vhin.transferFrom(address(this), msg.sender, _amount), "Something went wrong.");
		return true;
	}


	// transfer custom tokens for USDC
	function buy_tokens(uint256 _amount) public prevent_reentrancy {
		require (_amount > 1 * 10**16, "Amount must be greater than 0.01 VHIN.");
		require (vhin.balanceOf(msg.sender) >= _amount, "You don't have enough VHIN tokens.");

		uint256 _price = get_price();
		uint256 _new_amount = ((((_amount / 1000) * 995) / _price) * 10000) / division;

		require(recieve_tokens(_amount));
		require(send_money(_new_amount));

		developer_fee += ((_amount - (_new_amount * division)) / 5) / division;
		tresure -= _amount - (developer_fee * division);
		sold -= _new_amount * division;
	}

	// for funcion buy_tokens
	function recieve_tokens(uint256 _amount) private returns(bool) {
		vhin.user_allowance(_amount, msg.sender);
		require(vhin.transferFrom(msg.sender, address(this), _amount), "You don't have enough funds.");
		return true;
	}

	function send_money(uint256 _amount) private returns(bool) {
		usdc.approve(address(this), _amount + 1);
		require(usdc.transferFrom(address(this), msg.sender, _amount), "Something went wrong.");
		return true;
	}


	// calc price with 4 decimals
	function get_price() public view returns(uint256) {
		return (tresure * 10**4) / sold;
	}

	// change payout wallet
	function change_owner(address _new_owner) public require_owner {
		owner = payable(_new_owner);
	}

	// show acumulated developer fees
	function look_fee() public view require_owner returns(uint256) {
		return developer_fee;
	}

	// deposit acumulated developer fees to owner wallet
	function pay_fee() public require_owner {
		require(developer_fee >= 1 * 10 ** 16, "There is not enough fees.");
		usdc.approve(address(this), developer_fee + 1);
		require(usdc.transferFrom(address(this), owner, developer_fee), "Something went wrong.");
		developer_fee = 0;
	}

	// shows how much VHIN has been sold
	function show_sold() public view returns(uint256) {
		return sold;
	}

	// shows how much USDC is in the contract
	function show_tresure() public view returns(uint256) {
		return tresure;
	}


	modifier require_owner(){ 
		require(msg.sender == owner, "You are not the owner.");
		_; 
	}

	modifier prevent_reentrancy(){ 
		require (!locked, "Preventing reentrancy attack.");
		locked = true;
		_;
		locked = false;
	}
}


interface VHIN {
    function transfer(address dst, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint wad) external returns (bool);
    function balanceOf(address guy) external view returns (uint);

    function swaper_starter(address _owner) external;
    function mint_to_swaper() external;
    function user_allowance(uint256 _amount, address _user) external;
}

interface USDCToken {
    function transfer(address dst, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint wad) external returns (bool);
    function balanceOf(address guy) external view returns (uint);
    function approve(address spender, uint256 amount) external returns (bool);
}