// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./PLN_Token.sol";

contract Pay_Transfer_Mint {

    address payable public admin;
    uint public process_fee;

    address public PLN_address;
    uint public amount_to_mint;

    uint public constant duration = 365 days;
    uint public InflationInterval;

    constructor() {
        admin = payable(msg.sender);
        amount_to_mint = 10 ether;
        process_fee = 975;
        InflationInterval = block.timestamp + duration;
    }

    // Token Settings

    function setPLNaddress(address _address_PLN) external{
        require(msg.sender == admin);
        PLN_address = _address_PLN;
    }

    function callmint(address _toAddress, uint amount) private {
        Plnning Token = Plnning(PLN_address);
        Token.mint(_toAddress, amount);
    }

    function set_amount_to_mint() external{
            require(block.timestamp > InflationInterval); 
            amount_to_mint = amount_to_mint * 110/100;
            InflationInterval = InflationInterval + 365 days;
    }

    // Pay_User Settings

    struct User{
        address payable UserAddress;
        uint Bidfee; 
    }    

    function setProcessFee(uint _NewProcessFee) external{
        require(msg.sender == admin);
        require(_NewProcessFee < 1000);
        process_fee = _NewProcessFee;
    }

    function setAdmin(address payable _NewAdmin) external{
        require(msg.sender == admin);
        admin = _NewAdmin;
    }

    // Functions

    function Pay_Users(User[] calldata _List) external payable {

        uint _Bidderfee;
        uint _totalbidderfee = 0;
        uint _totalpaid = 0;

        User memory Payee;
        
        for(uint i = 0; i < _List.length; i++) {
            Payee = _List[i];

            _totalpaid = _totalpaid + Payee.Bidfee;            
            _Bidderfee = Payee.Bidfee * process_fee / 1000;
            _totalbidderfee = _totalbidderfee + _Bidderfee; 

            Payee.UserAddress.transfer(_Bidderfee);
            callmint(Payee.UserAddress, amount_to_mint*_Bidderfee*10);
        }

        if(msg.value < _totalpaid) {
            revert();
        }

        admin.transfer(_totalpaid-_totalbidderfee);
        callmint(admin, amount_to_mint*_totalpaid);
    }
}
