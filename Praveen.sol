pragma solidity >=0.8.0;

contract TronGalaxyPower{
    using SafeMath for uint256;
    
    uint256 constant DAYS = 1;
    
    uint256 public totalUsers;
    uint256 public dollars = 19000000;   // 1 dollar = 19 trx
    uint256[] public poolsPrice;
    uint256[] public referralIncomePercent;
    
    address owner;
    
    struct User{
        uint256 id;
        bool isExist;
        address referrer;
        uint256 holdAmount;
        uint256 cycles;
        uint256 currPool;
        uint256 currPoolStartTime;
        uint256 currPoolEndTime;
        uint256 prevPoolStartTime;
        uint256 prevPoolEndTime;
        uint256 totalReferrals;
        uint256 referralIncome;
        uint256 extraEarned;
    }
    
    mapping(address => User) public users;
    mapping(uint256 => address) public id2Address;
    
    
    event NewEntry(address _user,address _ref, uint256 _trx);
    event LevelUpgraded(address _user, uint256 _level, uint256 _trx);
    
    constructor(address _owner) public{
        owner = _owner;
        poolsPrice.push(dollars.mul(30));
        poolsPrice.push(dollars.mul(60));
        poolsPrice.push(dollars.mul(90));
        poolsPrice.push(dollars.mul(120));
        poolsPrice.push(dollars.mul(150));
        poolsPrice.push(dollars.mul(180));
        poolsPrice.push(dollars.mul(210));
        poolsPrice.push(dollars.mul(240));
        poolsPrice.push(dollars.mul(270));
        poolsPrice.push(dollars.mul(300));
        poolsPrice.push(dollars.mul(330));
        poolsPrice.push(dollars.mul(360));
        poolsPrice.push(dollars.mul(390));
        poolsPrice.push(dollars.mul(420));
        poolsPrice.push(dollars.mul(450));
        poolsPrice.push(dollars.mul(480));
        poolsPrice.push(dollars.mul(510));
        poolsPrice.push(dollars.mul(540));
        poolsPrice.push(dollars.mul(570));
        poolsPrice.push(dollars.mul(600));
        
        referralIncomePercent.push(30);
        referralIncomePercent.push(20);
        referralIncomePercent.push(10);
        referralIncomePercent.push(5);
        referralIncomePercent.push(5);
    }
    
    function enterSystem(address _ref) external payable{
        enterSystem(msg.sender,_ref,msg.value);
    }
    
    function buyPool() external payable{
        require(getHoldAmount(msg.sender).add(msg.value)>=poolsPrice[users[msg.sender].currPool], "must pay correct amount");
        
        buyPool(msg.sender,users[msg.sender].currPool.add(1),msg.value.add(users[msg.sender].holdAmount));
        if(users[msg.sender].holdAmount>poolsPrice[users[msg.sender].currPool]){
            payable(msg.sender).transfer(users[msg.sender].holdAmount.sub(poolsPrice[users[msg.sender].currPool]));
            users[msg.sender].extraEarned = users[msg.sender].extraEarned.add(users[msg.sender].holdAmount.sub(poolsPrice[users[msg.sender].currPool]));
        }
    }
    
    function enterSystem(address _user, address _ref, uint256 _amount) public{
        require(users[_user].isExist == false, "user already exist");
        require(_amount == poolsPrice[0],"Must pay exact 30 dollars");
        
        if(_ref == address(0) || users[_ref].isExist == false)
        {
            _ref = owner;
        }
        if(msg.sender == owner){
            _ref = address(0);
        }
        totalUsers = totalUsers.add(1);
        users[_user].id = totalUsers;
        users[_user].isExist = true;
        users[_user].referrer = _ref;
        users[_user].cycles = 1;
        users[_user].currPool = 1;
        users[_user].currPoolStartTime = block.timestamp;
        users[_user].currPoolEndTime = block.timestamp.add(DAYS.mul(7));
        
        id2Address[totalUsers] = _user;
        
        users[_ref].totalReferrals = users[_ref].totalReferrals.add(1);
        
        emit NewEntry(_user,_ref,poolsPrice[0]);
        emit LevelUpgraded(_user,1,poolsPrice[0]);
        
        giveReferralIncome(_ref);
    }
    
    function buyPool(address _user,uint256 _poolNumber,uint256 _amount) public{
        require(checkIfNextLevelCanBeUpgraded(_user), "you can't buy next level");
        require(_amount>=poolsPrice[_poolNumber-1],"You have to pay more");
        if(_poolNumber==1)
        require(users[_user].currPool == 20, "you need to buy previous pool first" );
        
        if(users[_user].currPool == 20){
            users[_user].cycles = users[_user].cycles.add(1);
        }
        users[_user].holdAmount = getHoldAmount(_user);
        users[_user].currPool = _poolNumber;
        users[_user].currPoolStartTime = block.timestamp;
        users[_user].currPoolEndTime = block.timestamp.add(DAYS.mul(7));
        users[_user].prevPoolStartTime = block.timestamp;
        users[_user].prevPoolEndTime = block.timestamp.add(DAYS.mul(2));
    }
    
    function giveReferralIncome(address _ref) internal{
        if(users[_ref].totalReferrals>=5){
            for(uint256 i=0;i<5;i++){
                if(_ref == address(0)){
                    break;
                }
                users[_ref].referralIncome = users[_ref].referralIncome.add(dollars.mul(poolsPrice[0].mul(referralIncomePercent[i]).div(1000)));
                _ref = users[_ref].referrer;
            }
        }
    }
    
    function checkIfNextLevelCanBeUpgraded(address _user) public view returns(bool){
        
        if(block.timestamp>=users[_user].currPoolStartTime.add(DAYS.mul(7))){
            return true;
        }
        return false;
    }
    
    function getTimePassed(address _user) public view returns(uint256){
        uint256 timePassed = (block.timestamp.sub(users[_user].currPoolStartTime)).div(DAYS);
        return timePassed;
    }
    
    function getHoldAmount(address _user) public view returns(uint256 amount){
        uint256 timePassed = (block.timestamp.sub(users[_user].currPoolStartTime)).div(DAYS);
        uint256 _amount = timePassed.mul(poolsPrice[users[_user].currPool-1].div(6));
        if(_amount>=(poolsPrice[users[_user].currPool-1].mul(7).div(6))){
            _amount = (poolsPrice[users[_user].currPool-1].mul(7).div(6));
        }
        return _amount;
    }
    
    function releaseHoldAmount(address _user) public{
        // 7th and 8th day amount
        require(msg.sender==owner, "you are not owner");
        
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}
