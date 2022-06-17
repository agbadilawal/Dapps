// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

//! import and use OZ safemath & reentrancy guard libraries

contract DAO {
    mapping(address => bool) public investors;
    mapping(address => uint256) public shares; //* make the shares ERC20 tokens so it can use the erc20 functions like transfer
    uint256 public totalShares;
    uint256 public availableFunds;
    uint256 public contributionEnd;

    constructor(uint256 contributionTime) {
        contributionEnd = block.timestamp + contributionTime;
    }

    function contribute() external payable {
        require(
            block.timestamp < contributionEnd,
            "cant contribute after contribution time elapse"
        );
        investors[msg.sender] += true;
        shares[msg.sender] += msg.value;
        totalShares += msg.value;
        availableFunds += msg.value;
    }

    function redeemShares(uint256 amount) {
        require(shares[msg.sender] >= amount, "insufficient shares");
        require(investors[msg.sender], "you have to be an investor");
        require(availableFunds >= amount, "insufficient funds in the pool");
        shares[msg.sender] -= amount;
        availableFunds -= amount;
        msg.sender.transfer(amount); // this sends the balance to the investors wallet
    }
    //! set if investors share balance is empty, remove it from investor mapping

    function tranferShares(uint256 amount, address payable recipient) external {
        require(shares[msg.sender] >= amount, "insufficient shares");
        require(investors[msg.sender], "you have to be an investor");

        shares[msg.sender] -= amount;
        investors[recipient] = true;
        shares[recipient] += amount;        
    }
}
