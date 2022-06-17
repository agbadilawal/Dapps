
/** 
 *  SourceUnit: c:\Users\memunat\Documents\GitHub\Dapps\Voting Dapp\contracts\voting.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

/// @title A Voting contract
/// @notice Explain to an end user what this does
contract Voting{
  mapping (address => bool ) public voters;//is true if an address is a registered voter

  struct Choice {
    uint id;
    string name;
    uint votes;
  }
  struct Ballot {
    uint id;
    string name;
    Choice[] choices;
    uint end;
  }
  mapping (uint => Ballot) Ballots;
  uint nextBallotId;
  address public admin;

  mapping (address => mapping (uint => bool)) public votes;
  constructor() {
    admin = msg.sender;
  }

  function addVoters(address[] calldata _voters) external onlyAdmin{
    for(uint i = 0; i < _voters.length; i++){
      voters[_voters[i]] = true;//sets addresses passed into this function to true..even if addresses are added twice it doesnt matter because they have already been set to true
    }
  }

  function createBallot(
      string memory name,
      string[] memory choices,
      uint offset
      ) public onlyAdmin{
        Ballots[nextBallotId].id = nextBallotId;
        Ballots[nextBallotId].name = name;
        Ballots[nextBallotId].end = block.timestamp + offset;//expiry of ballot
        for (uint i = 0; i < choices.length; i++) {
          Ballots[nextBallotId].choices.push(Choice(i, choices[i] ,0));
        }
      }
  
  function vote(uint ballotId, uint choiceId) external {
    require(voters[msg.sender] = true, "not aproved to vote");
    require(votes[msg.sender][ballotId] = false, "cant vote twice for a ballot");
    require(block.timestamp < Ballots[ballotId].end, "can only vote till end date");
    votes[msg.sender][ballotId] = true;
    Ballots[ballotId].choices[choiceId].votes++;
  }

  function results(uint ballotId)
      view
      external
      returns(Choice[] memory){
          require(block.timestamp >= Ballots[ballotId].end, "cant see result before ballots end");
          return Ballots[ballotId].choices;
      }


  modifier onlyAdmin() {
    require(msg.sender == admin, "only admin can call");
    _;
  }
}
