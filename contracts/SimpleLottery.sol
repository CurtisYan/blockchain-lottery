// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 引入 OpenZeppelin 的 Ownable，方便管理合约所有者权限
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SimpleLottery
 * @dev 基础版的抽奖实例合约，每个抽奖场次一个实例。
 * 包含参与、开奖、领奖等核心功能。
 */
// 将合约名称从 OnChainLottery 改为 SimpleLottery
contract SimpleLottery is Ownable {

    // --- 状态变量 ---
    string public lotteryId;         // 抽奖的唯一 ID
    string public lotteryName;       // 抽奖名称
    uint256 public entryFee;         // 参与费用
    address[] public participants;   // 参与者列表
    address public winner;           // 中奖者地址 (开奖后)
    uint256 public prizePool;        // 奖池总金额 (由参与费用累积)
    uint256 public openingTime;      // 抽奖开放时间 (可选，基础版简化为部署后即开放)
    uint256 public closingTime;      // 参与截止时间 (可选，基础版简化为开奖前)
    uint256 public drawTime;         // 预设的开奖时间戳

    // 抽奖状态
    enum LotteryState {
        Open,        // 开放参与
        Drawing,     // 正在开奖
        Claimable,   // 可领奖
        Closed       // 已结束 (奖金已领取或已重置)
    }

    LotteryState public currentLotteryState; // 当前状态

    // --- 事件 ---
    event LotteryCreated(string indexed id, address indexed owner, string name, uint256 entryFee, uint256 drawTime);
    event EnteredLottery(string indexed lotteryId, address indexed participant);
    event WinnerDrawn(string indexed lotteryId, address indexed winner, uint256 prizeAmount);
    event PrizeClaimed(string indexed lotteryId, address indexed winner, uint256 prizeAmount);
    event LotteryStateChanged(string indexed lotteryId, LotteryState newState);

    /**
     * @dev 构造函数，创建抽奖实例时调用。
     * 由 LotteryFactory 调用，并传入初始化参数。
     * @param _lotteryId 用户自定义的唯一 ID。
     * @param _lotteryName 抽奖名称。
     * @param _entryFee 参与费用。
     * @param _drawTime 预设的开奖时间戳。
     * @param _owner 该抽奖实例的发起人地址。
     */
    constructor(
        string memory _lotteryId,
        string memory _lotteryName,
        uint256 _entryFee,
        uint256 _drawTime,
        address _owner
    ) payable Ownable(_owner) {
        lotteryId = _lotteryId;
        lotteryName = _lotteryName;
        entryFee = _entryFee;
        drawTime = _drawTime;
        // openingTime = block.timestamp; // 基础版简化，部署即开放
        currentLotteryState = LotteryState.Open;
        prizePool = msg.value; // 构造函数接收到的 ETH 作为初始奖池 (如果发起人转入)

        emit LotteryCreated(_lotteryId, _owner, _lotteryName, _entryFee, _drawTime);
        emit LotteryStateChanged(_lotteryId, LotteryState.Open);
    }

    /**
     * @dev 用户支付费用参与抽奖。
     * 必须在抽奖处于 Open 状态且未到开奖时间时调用。
     */
    function enter() public payable {
        // 检查状态是否开放
        require(currentLotteryState == LotteryState.Open, unicode"当前抽奖未开放参与");
        // 检查是否已到开奖时间
        require(block.timestamp < drawTime, unicode"已到开奖时间，无法参与");
        // 检查费用是否正确
        require(msg.value == entryFee, unicode"支付的入场费不正确");

        participants.push(msg.sender); // 添加参与者
        prizePool += msg.value; // 累加奖池

        emit EnteredLottery(lotteryId, msg.sender); // 注意这里 emit 事件需要 lotteryId
    }

    /**
     * @dev 该抽奖场次的发起人调用，用于开奖。
     * 必须在抽奖处于 Open 状态且已到或超过开奖时间，并且有参与者时调用。
     * 注意：这里的随机数方法在生产环境中不安全！
     */
    function drawWinner() public onlyOwner {
        // 检查状态是否开放且已到开奖时间
        require(currentLotteryState == LotteryState.Open, unicode"抽奖未开放或未到开奖时间");
        require(block.timestamp >= drawTime, unicode"未到开奖时间，无法开奖");
        // 检查是否有参与者
        require(participants.length > 0, unicode"没有参与者，无法开奖");

        currentLotteryState = LotteryState.Drawing; // 改为 Drawing 状态
        emit LotteryStateChanged(lotteryId, LotteryState.Drawing);

        // --- 伪随机数生成 (示例，不安全！) ---
        // 依赖区块数据，容易被预测。生产环境需用 VRF 等服务。
        uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, participants.length, msg.sender))) % participants.length;
        // --- 伪随机数结束 ---

        winner = participants[randomIndex]; // 选出中奖者

        emit WinnerDrawn(lotteryId, winner, prizePool); // 注意这里 emit 事件需要 lotteryId

        currentLotteryState = LotteryState.Claimable; // 改为可领奖状态
        emit LotteryStateChanged(lotteryId, LotteryState.Claimable);
    }

    /**
     * @dev 中奖者调用此函数领取奖金。
     * 必须在抽奖处于 Claimable 状态时调用。
     */
    function claimPrize() public {
        // 检查是否是中奖者且状态可领奖
        require(msg.sender == winner, unicode"只有中奖者才能领取奖金");
        require(currentLotteryState == LotteryState.Claimable, unicode"奖金当前不可领取");

        uint256 amountToTransfer = address(this).balance; // 奖金总额 (使用合约余额更准确)

        // 将全部余额发送给中奖者
        // 使用 call 方法更安全，能处理更多 gas 转发
        (bool success, ) = payable(winner).call{value: amountToTransfer}("");
        require(success, unicode"奖金转账失败"); // 确保转账成功

        // 奖池金额在转账后合约余额会变为0，无需手动清零 prizePool 状态变量

        emit PrizeClaimed(lotteryId, winner, amountToTransfer); // 注意这里 emit 事件需要 lotteryId

        currentLotteryState = LotteryState.Closed; // 改为 Closed 状态
        emit LotteryStateChanged(lotteryId, LotteryState.Closed);
    }

    /**
     * @dev 重置抽奖状态和列表，开始新一轮 (基础版通常在领奖后结束本轮)。
     * 只有该抽奖场次的发起人 (Owner) 可调用。
     * 注意：基础版中，重置意味着本场次彻底结束。
     */
    function resetLottery() public onlyOwner {
         // 检查抽奖是否已结束 (例如，奖金已领取)
         require(currentLotteryState == LotteryState.Closed, unicode"抽奖未结束，无法重置");

         // 在基础版中，重置主要是为了清理状态，表示本场次彻底结束。
         // 清空参与者列表
         delete participants;
         // 重置中奖者地址
         winner = address(0);
         // 奖池已在领奖时清零

         // 状态保持 Closed
         // currentLotteryState = LotteryState.Closed; // 保持 Closed
         // emit LotteryStateChanged(lotteryId, LotteryState.Closed);
         // 也可以考虑一个 Self-destruct，但通常不推荐
    }

    // --- 查询函数 (免费调用) ---

    function getParticipants() public view returns (address[] memory) {
        return participants;
    }

    function getLotteryState() public view returns (LotteryState) {
        return currentLotteryState;
    }

    function getWinner() public view returns (address) {
        return winner;
    }

    function getPrizePool() public view returns (uint256) {
        return address(this).balance; // 奖池就是合约余额
    }

    /**
     * @dev 获取抽奖的所有详细信息。
     * @return lotteryName 抽奖名称
     * @return ownerAddress 所有者地址
     * @return fee 参与费用
     * @return time 开奖时间
     * @return pool 奖池金额
     * @return state 当前状态
     * @return winnerAddress 获胜者地址
     */
    function getLotteryDetails() public view returns (
        string memory lotteryName,
        address ownerAddress,
        uint256 fee,
        uint256 time,
        uint256 pool,
        LotteryState state,
        address winnerAddress
    ) {
        return (
            lotteryName,
            Ownable.owner(),
            entryFee,
            drawTime,
            address(this).balance,
            currentLotteryState,
            winner
        );
    }

    // Fallback 函数：接收直接发送给合约的 Ether (不推荐，应通过 enter 参与)
    receive() external payable {
        // 可以选择拒绝直接接收，强制通过 enter
        // revert(unicode"请通过 enter 函数参与抽奖");
    }
}