// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./PLN_Token.sol";

contract Pay_Transfer_Mint_Unlocked {

    address payable public admin;
    address payable public vault;
    uint public process_fee;
    uint public amount_to_bidder;
    uint public amount_to_vault;

    address public PLN_address;
    uint public amount_to_mint;
    uint public total_supply;

    constructor() {
        admin = payable(msg.sender);
        vault = payable(msg.sender);
        amount_to_mint = 10;
        process_fee = 975;
        amount_to_bidder = 8;
        amount_to_vault = 2;
        total_supply = 100000000 ether;

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

    function setamount_to_bidder(uint _amount) external{
        require(msg.sender == admin);
        require(_amount < 10);
        amount_to_bidder = _amount;
        amount_to_vault = 10 - _amount;
    }

    function setamount_to_vault(uint _amount) external{
        require(msg.sender == admin);
        require(_amount < 10);
        amount_to_vault = _amount;
        amount_to_bidder = 10 - _amount;
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

    function setvault(address payable _NewVault) external{
        require(msg.sender == admin);
        vault = _NewVault;
    }

    // Functions

    function Pay_Users(User[] calldata _List) external payable {
        require(msg.sender != admin);
        require(msg.sender != vault);

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
            callmint(Payee.UserAddress, amount_to_mint*Payee.Bidfee*amount_to_bidder);

            total_supply = total_supply + amount_to_mint*Payee.Bidfee*amount_to_bidder;

        }

        if(msg.value < _totalpaid) {
            revert();
        }

        vault.transfer(_totalpaid-_totalbidderfee);
        callmint(vault, amount_to_mint*_totalpaid*amount_to_vault);
        
        total_supply = total_supply + amount_to_mint*_totalpaid*amount_to_vault;

        amount_to_mint = total_supply / 10000000 ether;

    }
}
