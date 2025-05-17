Author:Curtisyan江南易
前言：目前该项目只是做了个基础版的功能，完整版是作者的完整构思。以后该代码还会维护，联系方式在末尾。首次使用可以看看说明文件目录下单完整版功能说明，该项目还有很大潜力

测试网领水：https://faucet.moonbeam.network/

# 区块链去中心化抽奖平台

基于区块链技术的公平、透明的抽奖系统，所有过程均在链上进行，无法篡改。本项目包含智能合约和前端应用两部分。（前端在 lottery-dapp 目录里）

![抽奖平台截图](说明文件/img1.png)

## 功能特点

- 🔗 基于区块链，公开透明，无法篡改
- 🎮 任何人都可以创建和参与抽奖
- 💰 自动化奖池管理和奖金分配
- 🔒 去中心化设计，无需信任第三方
- 🌐 支持多种网络（Moonbase Alpha测试网等）

## 技术栈

### 智能合约
- Solidity ^0.8.0
- Hardhat
- OpenZeppelin合约库

### 前端
- Next.js
- TypeScript
- ethers.js
- TailwindCSS
- shadcn/ui组件库

## 目录结构

```
/
├── contracts/                 # 智能合约代码
├── scripts/                   # 部署脚本
├── lottery-dapp/              # 前端应用
├── test/                      # 合约测试
├── hardhat.config.ts          # Hardhat配置
└── README.md                  # 项目说明
```

## 快速开始

### 前提条件

- Node.js v16+
- npm 或 yarn
- MetaMask钱包（或其他Web3钱包）
- 测试网络ETH（如Moonbase Alpha测试网的DEV代币）

### 1. 克隆仓库

```bash
git clone https://github.com/curtisyan/blockchain-lottery.git
cd blockchain-lottery
```

### 2. 安装依赖

```bash
# 安装根目录依赖（合约相关）
npm install

# 安装前端依赖
cd lottery-dapp
npm install
cd ..
```

## 智能合约部署

### 1. 设置环境变量

创建`.env`文件:

```bash
cp .env.example .env
```

编辑`.env`文件，填写以下内容:

```
MOONBASE_URL=https://rpc.testnet.moonbeam.network
PRIVATE_KEY=你的部署钱包私钥
```

注意：**请勿在公共仓库中提交包含私钥的文件！**

### 2. 编译合约

```bash
npx hardhat compile
```

### 3. 部署合约

```bash
# 部署到Moonbase Alpha测试网
npx hardhat run scripts/deploy_LotteryFactory.ts --network moonbase
```

部署脚本会自动:
- 部署LotteryFactory合约
- 将ABI文件复制到前端目录
- 更新前端环境变量

### 4. 验证合约（可选）

```bash
npx hardhat verify --network moonbase 部署的合约地址
```

## 前端应用运行

### 1. 设置环境变量

如果部署脚本没有自动创建，则手动创建`lottery-dapp/.env.local`文件:

```
NEXT_PUBLIC_LOTTERY_FACTORY_ADDRESS=你的合约地址
```

### 2. 启动开发服务器

```bash
cd lottery-dapp
npm run dev
```

访问 http://localhost:3000 打开应用。

### 3. 构建生产版本

```bash
cd lottery-dapp
npm run build
npm run start
```

## 使用指南

### 连接钱包

1. 安装MetaMask（或其他兼容钱包）
2. 切换到Moonbase Alpha测试网
3. 在应用中点击"连接钱包"按钮

### 创建抽奖

1. 点击"创建新的抽奖"按钮
2. 填写抽奖信息：
   - 抽奖ID（唯一标识）
   - 抽奖名称
   - 参与费用（DEV代币）
   - 开奖时间
3. 提交，确认交易

### 参与抽奖

1. 浏览抽奖列表或通过ID直接访问
2. 点击"参与"按钮
3. 支付参与费用
4. 确认交易

### 开奖与领奖

1. 抽奖创建者可在开奖时间后点击"开奖"按钮
2. 中奖者可点击"领取奖金"按钮领取奖池金额

## 部署到线上环境

### 1. 前端部署

可以将前端部署到Vercel、Netlify等平台：

```bash
# 使用Vercel部署
cd lottery-dapp
npm i -g vercel
vercel
```

### 2. 合约部署到主网

```bash
# 编辑hardhat.config.ts, 添加主网配置
# 然后执行
npx hardhat run scripts/deploy_LotteryFactory.ts --network mainnet
```

## 常见问题

### 合约交互失败

- 检查钱包是否连接到正确网络
- 确认账户有足够的DEV代币（用于支付gas费）
- 查看浏览器控制台错误信息

### 钱包连接问题

- 刷新页面
- 重启钱包应用
- 确认浏览器允许钱包扩展访问

### 合约不存在错误

- 确认环境变量中的合约地址正确
- 验证合约已在当前网络上部署
- 检查ABI文件是否正确

## 贡献指南

欢迎提交Pull Request或Issue！

1. Fork项目
2. 创建你的特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交你的修改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 打开Pull Request

## 许可证

MIT

## 联系方式

realthat@foxmail.com
