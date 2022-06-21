// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//! import and use OZ safemath, ERC20 to represent shares & reentrancy guard libraries on functions

contract DAO {
    struct Proposal {
        uint256 id;
        string name;
        uint256 amount;
        address payable recipient;
        uint256 votes;
        uint256 end;
        bool executed;
    }
    mapping(address => bool) public investors;
    mapping(address => uint256) public shares; //* make the shares ERC20 tokens so it can use the erc20 functions like transferFrom
    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping (uint=>bool)) public votes;
    uint256 public totalShares;
    uint256 public availableFunds;
    uint256 public contributionEnd;//time in seconds
    uint public nextProposalId;
    uint public voteTime;
    uint public quorum;
    address public admin;

    constructor(
      uint256 contributionTime,
      uint256 _voteTime,
      uint256 _quorum 
      ) {
        require(_quorum < 0 && _quorum < 100);
        contributionEnd = block.timestamp + contributionTime;
        voteTime = _voteTime;
        quorum = _quorum;
        admin = msg.sender;
    }

    function contribute() payable external {
        require(
            block.timestamp < contributionEnd,
            "cant contribute after contribution time elapse"
        );
        investors[msg.sender] = true;
        shares[msg.sender] += msg.value;
        totalShares += msg.value;
        availableFunds += msg.value;
    }

    function redeemShares(uint256 amount) public onlyInvestors() {
        require(shares[msg.sender] >= amount, "insufficient shares");
        require(availableFunds >= amount, "insufficient funds in the pool");
        shares[msg.sender] -= amount;
        availableFunds -= amount;
        payable(msg.sender).transfer(amount);// this sends the balance to the investors wallet 
    }

    //! set if investors share balance is empty from either redeeming or transferring, remove it from investor mapping

    function transferShares(uint256 amount, address payable recipient) external onlyInvestors {
        require(shares[msg.sender] >= amount, "insufficient shares");
        shares[msg.sender] -= amount;
        investors[recipient] = true;
        shares[recipient] += amount;
    }

    function createProposal (
      string memory name,
      uint amount,
      address payable reciepient
    ) public onlyInvestors {
        require(availableFunds >= amount, "amount too big");
        proposals[nextProposalId] = Proposal(
            nextProposalId,
            name,
            amount,
            reciepient,
            0,
            block.timestamp + voteTime,
            false
        );
        availableFunds -= amount;
        nextProposalId++;
      }

    function vote(uint proposalId)external onlyInvestors {
      Proposal storage proposal = proposals[proposalId];
      require(votes[msg.sender][proposalId] = false, "investor can only vote for a proposal once");
      require(block.timestamp < proposal.end, "can only vote till proposal expiry");
      votes[msg.sender][proposalId] = true;
      proposal.votes += shares[msg.sender];
    }

    function executeProposal(uint proposalId) external onlyAdmin {
      Proposal storage proposal = proposals[proposalId];
      require(block.timestamp >= proposal.end, "cannot execute before end date");
      require(votes[msg.sender][proposalId] == false, "the proposal has been executed already");
      require((proposal.votes / totalShares) * 100 >= quorum, "cannot execute proposal with votes below quorum");//this to express the votes on a proposal as an multiple of 100(to express a fraction as a percent) in order to compare it to the quorum
      _transferEther(proposal.amount, proposal.recipient);
    }

    function withdrawEther(uint amount, address payable to) public onlyAdmin{
      _transferEther(amount, to);//!chore: set function-owner to admin
    }

    function _transferEther(uint amount, address payable to) internal  {
      require(amount <= availableFunds, "insufficient funds");
      availableFunds -= amount;
      to.transfer(amount);
    }

    
    // recieve() external payable {
    //     availableFunds += msg.value;
    // }

    modifier onlyInvestors() {
        require(investors[msg.sender], "you have to be an investor");
      _;
    }
    modifier onlyAdmin() {
        require(msg.sender == admin, "forbidden: only admin can call");
      _;
    }
}
