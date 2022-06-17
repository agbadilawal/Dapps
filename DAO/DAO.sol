// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract DAO {
  mapping (address=>bool) public investors;
  mapping (address=>uint) public shares;
  uint public totalShares;
  uint public availableFunds;
  uint public contributionEnd;

  constructor(uint contributionTime){
    contributionEnd = block.timestamp + contributionTime;
  }

  function contribute() payable external{
    require(block.timestamp < contributionEnd,"cant contribute after contribution time elapse");
    investors[msg.sender] += true;
    shares[msg.sender] += msg.value;
    totalShares += msg.value;
    availableFunds += msg.value;
  }

  function redeemShares(uint amount) {
    require(shares[msg.sender] >= amount, "insufficient balance");
    require(investors[msg.sender]);
  }
} 