pragma solidity >=0.6.0 <0.7.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) public {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  uint256 public constant threshold = 1 ether;

  mapping (address => uint256) public balances;

  event Stake(address _address, uint256 _amount);

  function stake() external payable {
    balances[msg.sender] = balances[msg.sender] + msg.value;
    emit Stake(msg.sender, msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value



  // if the `threshold` was not met, allow everyone to call a `withdraw()` function



  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend


}
