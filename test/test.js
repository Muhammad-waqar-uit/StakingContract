const {expect} = require('chai');
const { ethers } = require('hardhat');

describe("StakingContract", function () {
  let owner;
  let user1;
  let user2;
  let stakingContract;

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();
    const StakingContract = await ethers.getContractFactory("StakingContract");
    stakingContract = await StakingContract.deploy("TestToken", "TT", 20);
    await stakingContract.deployed();
  });

  describe("buyTokens", function () {
    it("should mint tokens for the sender", async function () {
        const balanceBefore = await stakingContract.balanceOf(user1.address);
        console.log("Balance before:", balanceBefore.toString());
        await stakingContract.connect(user1).buyTokens(10, { value: ethers.utils.parseEther("0.1") });
        const balanceAfter = await stakingContract.balanceOf(user1.address);
        console.log("Balance after:", balanceAfter.toString());
        expect(balanceAfter.toNumber()).to.equal(10);
      });
      

    it("should revert if numTokens is 0", async function () {
      await expect(stakingContract.connect(user1).buyTokens(0, { value: ethers.utils.parseEther("0.1") }))
    });
    it("should revert if payment is insufficient", async function () {
      await expect(stakingContract.connect(user1).buyTokens(10, { value: ethers.utils.parseEther("0.09") }))});
      it("should stake tokens", async function () {
        await stakingContract.connect(user1).buyTokens(100, { value: ethers.utils.parseEther("0.1") });
        await stakingContract.connect(user1).stake(100); // 5 * 10**18
        const amountStaked = await stakingContract.amountStaked(user1.address);
        const balance = await stakingContract.balanceOf(stakingContract.address);
        expect(amountStaked.toNumber()).to.equal(100);
        expect(balance.toNumber()).to.equal(100);
      });
  
      it("should revert if amount is 0", async function () {
        await expect(stakingContract.connect(user1).stake(0));
      });
  });});