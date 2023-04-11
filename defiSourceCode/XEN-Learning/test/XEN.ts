import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("XENCrypto", function () {

  async function deployXENFixture() {
    const [owner, otherAccount] = await ethers.getSigners();

    const Math = await ethers.getContractFactory("Math");
    const math = await Math.deploy();

    const XEN = await ethers.getContractFactory("XENCrypto", {
      libraries:{
        Math: math.address
      }
    });
    
    const xen = await XEN.deploy();
    return { XEN, xen, owner, otherAccount };
  }


  /**
   * 这个项目核心的就是 数学方面的测试  溢出  精度丢失之类的  用了一个库 abdk-libraries-solidity
   * 
   * Math_New.test.js    log2  对数  用库的log2 和 传统的 log2 做对比  
   * 
   * Math.test.js    测试 Math 库  一些常见的  Max  Min 方法是否输出正确 
   * 
   * XENCrypto-BaseParams.test.js          
   *  以 XENCrypto.sol 为基准 
   *      XENCrypto5001.sol     改了起始的  GENESIS_RANK = 5_001 
   *      XENCrypto100001.sol              GENESIS_RANK = 100_001
   *      XENCrypto25mm1.sol               GENESIS_RANK = 25_000_001
   *  测试 TOKEN 的 name symbol   起始的 global rank   - 针对 三个不同的合约 XENCrypto5001 XENCrypto100001 XENCrypto25mm1
   *  测试 初始的 AMP = 3_000    EEAR = 100  APY = 20  - 针对 三个不同的合约 XENCrypto5001 XENCrypto100001 XENCrypto25mm1
   *  测试 一年后的 AMP APY
   *  测试 42个月+后的 AMP APY
   *  测试 100个月+后的 AMP APY
   *  测试 应该mint的token数量   - 针对 三个不同的合约 XENCrypto5001 XENCrypto100001 XENCrypto25mm1
   * 
   * XENCrypto-Bum.test.js 
   *  测试 token 为0 时不能 burn 
   *       burn的参数不能非法
   *       没有批准的不能burn
   *       burn后  其他人的余额应该对的上
   * 
   * XENCrypto-MintAndStake.test.js
   *  测试 没有参与挖矿 不能获取奖励并stake 
   *       获取奖励后 stake 的百分比不能超过 100% 
   *       挖矿天数不能为0  也不能大于1000  在此期间 可随意 mint + stake 
   *       当一个钱包地址应该挖矿时  不能再用这个地址再次进行挖矿操作了 
   *       等待期过了后  允许获取奖励
   *       返回正确的质押奖励
   * 
   * XENCrypto-Rank.test.js
   *  测试  global rank 应该从1 开始
   *        同一个地址不能多次stake 
   *        还没过等待期拒绝获取奖励   过了后就不应该拒绝
   *        拒绝 0x0000000... 地址
   *        mintRewardShard 的 share不能小于1  也不能大于100
   *        返回正确的 MintInfo 
   *        随着衰减天数增加 奖励应该逐步减少 
   */
  describe("Deployment", function () {

    it("Should set the right genesisTs", async function () {
      const { XEN, xen } = await loadFixture(deployXENFixture);
      const t = await xen.genesisTs();
      console.log("genesisTime " + t);
      expect(await xen.globalRank()).to.equal(1);

      
      await xen.claimRank(100);


    });
    
    /* it("Should set the right owner", async function () {
      const { lock, owner } = await loadFixture(deployXENFixture);

      expect(await lock.owner()).to.equal(owner.address);
    });

    it("Should receive and store the funds to lock", async function () {
      const { lock, lockedAmount } = await loadFixture(
        deployXENFixture
      );

      expect(await ethers.provider.getBalance(lock.address)).to.equal(
        lockedAmount
      );
    });

    it("Should fail if the unlockTime is not in the future", async function () {
      // We don't use the fixture here because we want a different deployment
      const latestTime = await time.latest();
      const Lock = await ethers.getContractFactory("Lock");
      await expect(Lock.deploy(latestTime, { value: 1 })).to.be.revertedWith(
        "Unlock time should be in the future"
      );
    }); */

  });

  /* describe("Withdrawals", function () {
    describe("Validations", function () {
      it("Should revert with the right error if called too soon", async function () {
        const { lock } = await loadFixture(deployOneYearLockFixture);

        await expect(lock.withdraw()).to.be.revertedWith(
          "You can't withdraw yet"
        );
      });

      it("Should revert with the right error if called from another account", async function () {
        const { lock, unlockTime, otherAccount } = await loadFixture(
          deployOneYearLockFixture
        );

        // We can increase the time in Hardhat Network
        await time.increaseTo(unlockTime);

        // We use lock.connect() to send a transaction from another account
        await expect(lock.connect(otherAccount).withdraw()).to.be.revertedWith(
          "You aren't the owner"
        );
      });

      it("Shouldn't fail if the unlockTime has arrived and the owner calls it", async function () {
        const { lock, unlockTime } = await loadFixture(
          deployOneYearLockFixture
        );

        // Transactions are sent using the first signer by default
        await time.increaseTo(unlockTime);

        await expect(lock.withdraw()).not.to.be.reverted;
      });
    }); */

   /*  describe("Events", function () {
      it("Should emit an event on withdrawals", async function () {
        const { lock, unlockTime, lockedAmount } = await loadFixture(
          deployOneYearLockFixture
        );

        await time.increaseTo(unlockTime);

        await expect(lock.withdraw())
          .to.emit(lock, "Withdrawal")
          .withArgs(lockedAmount, anyValue); // We accept any value as `when` arg
      });
    });

    describe("Transfers", function () {
      it("Should transfer the funds to the owner", async function () {
        const { lock, unlockTime, lockedAmount, owner } = await loadFixture(
          deployOneYearLockFixture
        );

        await time.increaseTo(unlockTime);

        await expect(lock.withdraw()).to.changeEtherBalances(
          [owner, lock],
          [lockedAmount, -lockedAmount]
        );
      });
    });
  });
    */

});
