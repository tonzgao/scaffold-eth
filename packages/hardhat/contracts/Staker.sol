pragma solidity >=0.6.0 <0.7.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    constructor(address exampleExternalContractAddress) public {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    uint256 public constant threshold = 1 ether;
    uint256 public deadline = now + 30 seconds;

    bool public openForWithdraw = false;
    bool public executed = false;

    mapping(address => uint256) public balances;

    event Stake(address _address, uint256 _amount);

    modifier notCompleted() {
        require(executed == false, "Contract has already been executed");
        _;
    }

    modifier deadlineReached(bool _requirement) {
        if (_requirement) {
            require(now >= deadline, "Deadline has not been reached");
        } else {
            require(now < deadline, "Deadline has already been reached");
        }
        _;
    }

    function stake() external payable notCompleted deadlineReached(false) {
        balances[msg.sender] = balances[msg.sender] + msg.value;
        emit Stake(msg.sender, msg.value);
    }

    // After some `deadline` allow anyone to call an `execute()` function
    //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
    function execute() external notCompleted deadlineReached(true) {
        if (balances[msg.sender] >= threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
            executed = true;
        } else {
            openForWithdraw = true;
        }
    }

    // if the `threshold` was not met, allow everyone to call a `withdraw()` function
    function withdraw() external notCompleted {
        require(openForWithdraw, "Withdrawals are not enabled yet");
        (bool sent, bytes memory data) = msg.sender.call{
            value: balances[msg.sender]
        }("");
        require(sent, "Failed to send Ether");
        balances[msg.sender] = 0;
    }

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256) {
        if (now >= deadline) {
            return 0;
        }
        return deadline - now;
    }
}
