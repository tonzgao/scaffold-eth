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

    mapping(address => uint256) public balances;

    event Stake(address _address, uint256 _amount);

    function stake() external payable {
        balances[msg.sender] = balances[msg.sender] + msg.value;
        emit Stake(msg.sender, msg.value);
    }

    // After some `deadline` allow anyone to call an `execute()` function
    //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
    function execute() external {
        require(now >= deadline);
        if (balances[msg.sender] >= threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
        } else {
            openForWithdraw = true;
        }
    }

    // if the `threshold` was not met, allow everyone to call a `withdraw()` function
    function withdraw() external {
        require(openForWithdraw);
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
