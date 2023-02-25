// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StakingContract is ERC20, Ownable {
    mapping(address => uint256) public amountStaked;
    mapping(address=>bool) public staked;
    uint256 public stakeStartTime;
    uint256 public duration;
    uint256 public price = 1 wei;

    constructor(string memory name, string memory symbol, uint256 _duration) ERC20(name, symbol) {
        duration = _duration;
    }

   function buyTokens(uint256 numTokens) public payable {
        require(numTokens > 0, "Invalid input");
        uint256 totalPrice = numTokens * price;
        require(msg.value >= totalPrice, "Insufficient payment");
        _mint(msg.sender, numTokens);
        if (msg.value > totalPrice) {
            uint256 refundAmount = msg.value - totalPrice;
            (bool success, ) = msg.sender.call{value: refundAmount}("");
            require(success, "Failed to return unused ether to sender");
        }
    }

    function stake(uint256 _amount) public {
        require(_amount > 0, "Cannot stake 0 tokens");
        require(balanceOf(msg.sender) >= _amount, "Not enough tokens");
        require(amountStaked[msg.sender] == 0, "Tokens already staked");
        transfer(address(this), _amount);
        amountStaked[msg.sender] = _amount;
        staked[msg.sender]=true;
        stakeStartTime = block.timestamp;
    }


function unstake() public {
    require(amountStaked[msg.sender] > 0, "No tokens staked");
    uint256 reward = calculateReward(msg.sender);
    uint256 totalAmount = amountStaked[msg.sender] + reward;
    amountStaked[msg.sender] = 0;  
    staked[msg.sender] = false;
    _mint(address(this), reward); // add reward amount to contract balance
    _transfer(address(this), msg.sender, totalAmount);
}


    function calculateReward(address _staker) public view returns (uint256) {
        uint256 stakedTokens = amountStaked[_staker];
        uint256 reward = stakedTokens / 100;
        uint256 timeElapsed = block.timestamp - stakeStartTime;
        uint256 rewardMultiplier = timeElapsed / duration;
        reward *= rewardMultiplier;
        return reward;
    }

    function checkBalance(address _user) public view returns (uint256) {
        return balanceOf(_user);
    }
    function withdrawEther() public onlyOwner {
    uint256 balance = address(this).balance;
    require(balance > 0, "No Ether available to withdraw");
    (bool success, ) = payable(owner()).call{value: balance}("");
    require(success, "Failed to transfer Ether to owner");
}
}
