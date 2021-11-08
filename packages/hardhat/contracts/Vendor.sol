pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./YourToken.sol";


contract Vendor is Ownable {
  using SafeMath for uint256;
  YourToken yourToken;

  constructor(address tokenAddress) public {
    yourToken = YourToken(tokenAddress);
  }

  uint256 public constant tokensPerEth = 100;
  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  //ToDo: create a payable buyTokens() function:
  function buyTokens() external payable {
    uint256 amountOfTokens = tokensPerEth.mul(msg.value);
    yourToken.transfer(msg.sender, amountOfTokens);
    emit BuyTokens(msg.sender, msg.value, amountOfTokens);
  }

  //ToDo: create a sellTokens() function:
  function sellTokens(uint256 theAmount) external {
    uint256 payment = theAmount.div(tokensPerEth);
    require(address(this).balance >= payment, "Vendor is too poor to buyback");
    bool success = yourToken.transferFrom(msg.sender, address(this), theAmount);
    require(success, "Could not transfer tokens");
    (bool sent, bytes memory data) = msg.sender.call{
        value: payment
    }("");
    require(sent, "Failed to send Ether");
  }

  //ToDo: create a withdraw() function that lets the owner, you can 
  //use the Ownable.sol import above:
  function withdraw() external onlyOwner {
    (bool sent, bytes memory data) = msg.sender.call{
        value: address(this).balance
    }("");
    require(sent, "Failed to send Ether");
  }
}
