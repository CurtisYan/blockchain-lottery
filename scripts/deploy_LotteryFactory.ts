import { ethers } from "hardhat";

async function main() {
  // 准备部署账户
  const [deployer] = await ethers.getSigners();

  console.log("用这个账户部署合约:", deployer.address);

  // 看看账户里有多少钱 (测试网代币)
  const accountBalance = await deployer.provider.getBalance(deployer.address);
  console.log("账户余额:", ethers.formatEther(accountBalance), "ETH"); // 这里的 ETH 记得换成你链的代币符号

  // 拿到 LotteryFactory 合约工厂，准备创建合约实例
  const LotteryFactory = await ethers.getContractFactory("LotteryFactory");

  // 开始部署 LotteryFactory 合约
  console.log("正在把 LotteryFactory 合约发到链上...");
  // 部署 LotteryFactory 不需要构造函数参数
  const lotteryFactory = await LotteryFactory.deploy();

  // 等待合约部署完成，拿到最终地址
  await lotteryFactory.waitForDeployment();

  console.log("LotteryFactory 合约部署完成, 地址是:", await lotteryFactory.getAddress());

  // 部署完成后，你可以通过这个 Factory 合约地址来创建新的抽奖实例
  console.log("现在你可以使用这个地址来创建新的抽奖场次了。");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
