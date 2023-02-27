// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StakingContract is ERC20, Ownable {
    //staked amount mapping with address
    mapping(address => uint256) public amountStaked;
    //checking if amount is staked or not
    mapping(address=>bool) public staked;
    //start time after staking
    uint256 public stakeStartTime;
    //duration of time in seconds it is stored
    uint256 public duration;
    //price of one token is 1 wei
    uint256 public price = 1 wei;
/*
     * @dev Constructor to initialize the contract of Staking.
     * @param name_ The name of the contract token.
     * @param symbol_ the symbol of the contract token
     */
    constructor(string memory name, string memory symbol, uint256 _duration) ERC20(name, symbol) {
        duration = _duration;
    }
/*
     * @dev Allows a user to Buy Token.
     * @param numTokens how much token user wants to buy 
     * it will mint it directly to user account
     */
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
/*
     * @dev Allows a stake tokens.
     * @param _amount to stake. 
     * checks if user amount is grater than zero then transfer amount to stake
     */
    function stake(uint256 _amount) public {
        require(_amount > 0, "Cannot stake 0 tokens");
        require(balanceOf(msg.sender) >= _amount, "Not enough tokens");
        require(amountStaked[msg.sender] == 0, "Tokens already staked");
        transfer(address(this), _amount);
        amountStaked[msg.sender] = _amount;
        staked[msg.sender]=true;
        stakeStartTime = block.timestamp;
    }

/*
     * @dev Allow user to unstake amount.
     * it will unstake all the tokens with reward if any to the staker account address
     */
// function unstakeAll() public returns(uint256){
//     require(amountStaked[msg.sender] > 0, "No tokens staked");
//     uint256 reward = calculateReward(msg.sender);
//     uint256 totalAmount = amountStaked[msg.sender] + reward;
//     amountStaked[msg.sender] = 0;  
//     staked[msg.sender] = false;
//     _mint(address(this), reward); // add reward amount to contract balance
//     _transfer(address(this), msg.sender, totalAmount);
//     return totalAmount;
// }
function unstake() public returns (uint256) {
    require(amountStaked[msg.sender] > 0, "No tokens staked");
    uint256 reward = calculateReward(msg.sender);
    uint256 totalAmount = amountStaked[msg.sender] + reward;
    amountStaked[msg.sender] = 0;
    staked[msg.sender] = false;
    _mint(address(this), reward); // add reward amount to contract balance
    _transfer(address(this), msg.sender, totalAmount);
    return totalAmount;
}

/*
     * @dev Allow user to calculate reward.
     * @param takes stakers address
     * it will check if you have any rewards up till calling the function
     */

    function calculateReward(address _staker) public view returns (uint256) {
        uint256 stakedTokens = amountStaked[_staker];
        uint256 reward = stakedTokens / 100;
        uint256 timeElapsed = block.timestamp - stakeStartTime;
        uint256 rewardMultiplier = timeElapsed / duration;
        reward *= rewardMultiplier;
        return reward;
    }
/*
     * @dev Allow check account balance.
     * it will user address then tell tokens works like balanceof use any function
     */
    function checkBalance(address _user) public view returns (uint256) {
        return balanceOf(_user);
    }
    /*
     * @dev Allow owner to withdraw ether from contract.
     * it will get all the amount if any then transfer it to owner since it can be called only by owner.
     */
    function withdrawEther() public onlyOwner {
    uint256 balance = address(this).balance;
    require(balance > 0, "No Ether available to withdraw");
    (bool success, ) = payable(owner()).call{value: balance}("");
    require(success, "Failed to transfer Ether to owner");
}
    // function unstake(uint256 amount)public returns(bool){
    //     require(staked[msg.sender],"No tokens staked");
    //     uint reward=calculateReward(msg.sender);
    //     uint amounts=amount;
    //     if(amounts==amountStaked[msg.sender]+staker_reward[msg.sender]){
    //         amountStaked[msg.sender] = 0;
    //         staked[msg.sender] = false;
    //         _mint(address(this), reward); // add reward amount to contract balance
    //         _transfer(address(this), msg.sender, amounts);
    //     }else{
    //         amountStaked[msg.sender]+=staker_reward[msg.sender];
    //         amountStaked[msg.sender]-=amounts;
    //         _mint(address(this), reward);
    //         _transfer(address(this), msg.sender, amounts);
    //     }
    //     return true;
    // }

    function unstake(uint256 withdraw) public returns(uint256){
        uint256 amount = unstake();
        uint stakingamount= amount-withdraw;
        stake(stakingamount);
        return amount;
    }
}
