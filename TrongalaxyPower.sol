pragma solidity >=0.6.0;
// pragma experimental ABIEncoderV2;
contract TronGalaxyPower{
    using SafeMath for uint256;
    
    uint256 constant DAYS = 1;
    
    uint256 public totalUsers;
    uint256 public dollars = 1000000;   // 1 dollar = 19 trx
    uint256[] public poolsPrice;
    uint256[] public referralIncomePercent;
    
    address owner;
    address admin1;
    address admin2;
    
    uint256 public admin1Wallet;
    uint256 public admin2Wallet;
    
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
        uint256 prevHold;
    }
    
    struct History{
        uint256 time;
        uint256 price;
        uint256 pool;
        uint256 amount;
        uint256 earned;
    }
    
    
    mapping(address => User) public users;
    mapping(uint256 => address) public id2Address;
    mapping(address => uint256) public totalMembers;
    mapping(address => bool) public adminRights;
    mapping(address => uint256) public releasedAmount;
    mapping(address => History[]) public history;
    mapping(address => uint256) public historyLength;
    mapping(address => uint256) public cycleRefs;
    
    event NewEntry(address _user,address _ref, uint256 _trx);
    event LevelUpgraded(address _user, uint256 _level, uint256 _trx);
    
    constructor(address _owner,address _admin1,address _admin2) public{
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
        
        adminRights[owner] = true;
        adminRights[_admin1] = true;
        adminRights[_admin2] = true;
        admin1 = _admin1;
        admin2 = _admin2;
    }
    
    /* HELPER FUNCTIONS */
    
    function changePoolPrice() internal{
        poolsPrice[0]=(dollars.mul(30));
        poolsPrice[1]=(dollars.mul(60));
        poolsPrice[2]=(dollars.mul(90));
        poolsPrice[3]=(dollars.mul(120));
        poolsPrice[4]=(dollars.mul(150));
        poolsPrice[5]=(dollars.mul(180));
        poolsPrice[6]=(dollars.mul(210));
        poolsPrice[7]=(dollars.mul(240));
        poolsPrice[8]=(dollars.mul(270));
        poolsPrice[9]=(dollars.mul(300));
        poolsPrice[10]=(dollars.mul(330));
        poolsPrice[11]=(dollars.mul(360));
        poolsPrice[12]=(dollars.mul(390));
        poolsPrice[13]=(dollars.mul(420));
        poolsPrice[14]=(dollars.mul(450));
        poolsPrice[15]=(dollars.mul(480));
        poolsPrice[16]=(dollars.mul(510));
        poolsPrice[17]=(dollars.mul(540));
        poolsPrice[18]=(dollars.mul(570));
        poolsPrice[19]=(dollars.mul(600));
        
    }
    
    function enterSystem(address _user, address _ref, uint256 _amount) internal{
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
        
        cycleRefs[_ref] = cycleRefs[_ref].add(1);
        
        id2Address[totalUsers] = _user;
        
        users[_ref].totalReferrals = users[_ref].totalReferrals.add(1);
        
        admin1Wallet = admin1Wallet.add(_amount.mul(14).div(100));
        admin2Wallet = admin2Wallet.add(_amount.mul(6).div(100));
        
        emit NewEntry(_user,_ref,poolsPrice[0]);
        emit LevelUpgraded(_user,1,poolsPrice[0]);
        history[_user].push(History(block.timestamp,dollars,1,_amount,0));
        historyLength[_user] = historyLength[_user].add(1);
        
        users[_ref].referralIncome = users[_ref].referralIncome.add(poolsPrice[0].mul(referralIncomePercent[0]).div(1000));
        payable(_ref).transfer(poolsPrice[0].mul(referralIncomePercent[0]).div(1000));
                 
            _ref = users[_ref].referrer;
           
            for(uint256 i=1;i<5;i++){
                  if(_ref == address(0)){
                        break;
                    }
                  if(cycleRefs[_ref]>=5){
                    users[_ref].referralIncome = users[_ref].referralIncome.add(poolsPrice[0].mul(referralIncomePercent[i]).div(1000));
                    payable(_ref).transfer(poolsPrice[0].mul(referralIncomePercent[i]).div(1000));
                  }
                 totalMembers[_ref] = totalMembers[_ref].add(1);
             _ref = users[_ref].referrer;
            
        }
    }
    
    function buyPool(address _user,uint256 _poolNumber,uint256 _amount) internal{
        require(checkIfNextLevelCanBeUpgraded(_user), "you can't buy next level");
        require(_amount>=poolsPrice[_poolNumber-1],"You have to pay more");
        
        if(_poolNumber == 7){
            require(users[_user].totalReferrals>=1,"you must have 1 direct to buy 7th pool");
        }
        if(_poolNumber == 10){
            require(users[_user].totalReferrals>=2,"you must have 2 direct to buy 10th pool");
        }
        if(_poolNumber == 13){
            require(users[_user].totalReferrals>=3,"you must have 3 direct to buy 13th pool");
        }
        if(_poolNumber == 16){
            require(users[_user].totalReferrals>=4,"you must have 4 direct to buy 16th pool");
        }
        if(_poolNumber == 19){
            require(users[_user].totalReferrals>=5,"you must have 5 direct to buy 19th pool");
        }
        
        if(users[_user].currPool == 20){
            users[_user].cycles = users[_user].cycles.add(1);
            cycleRefs[_user] = 0;
        }
        
        admin1Wallet = admin1Wallet.add(_amount.mul(14).div(100));
        admin2Wallet = admin2Wallet.add(_amount.mul(6).div(100));
        
        users[_user].currPool = _poolNumber;
        users[_user].currPoolStartTime = block.timestamp;
        users[_user].currPoolEndTime = block.timestamp.add(DAYS.mul(7));
        users[_user].prevPoolStartTime = block.timestamp;
        users[_user].prevPoolEndTime = block.timestamp.add(DAYS.mul(2));
        history[_user].push(History(block.timestamp,dollars,_poolNumber,poolsPrice[_poolNumber-1], _amount.sub(poolsPrice[_poolNumber-1])));
        historyLength[_user] = historyLength[_user].add(1);
    }
    
    function giveReferralIncome(address _reff,uint256 _poolNumber) internal{
        address _ref = _reff;
       
            for(uint256 i=0;i<5;i++){
                  if(_ref == address(0)){
                        break;
                    }
                  if(cycleRefs[_ref]>=5){
                    users[_ref].referralIncome = users[_ref].referralIncome.add(poolsPrice[_poolNumber-1].mul(referralIncomePercent[i]).div(1000));
                    payable(_ref).transfer(poolsPrice[_poolNumber-1].mul(referralIncomePercent[i]).div(1000));
                  }
                 
             _ref = users[_ref].referrer;
            
        
        }
        
    }
    
    function getTimePassed(address _user) internal view returns(uint256){
        uint256 timePassed = (block.timestamp.sub(users[_user].currPoolStartTime)).div(DAYS);
        return timePassed;
    }
    
    function getPrevHold(address _user) public view returns(uint256){
        uint256 timePassed = (block.timestamp.sub(users[_user].prevPoolStartTime)).div(DAYS);
         uint256 amount = 0;
         uint256 pool;
            pool = users[_user].currPool;
            amount = timePassed.mul(poolsPrice[pool-1]).div(6);
        if(amount>=(poolsPrice[pool-1]).mul(2).div(6)){
            amount = (poolsPrice[pool-1]).mul(2).div(6);
        }
        
        else if(users[_user].currPool == 1 && users[_user].cycles!=1){
            pool = 20;
            amount = timePassed.mul(poolsPrice[pool-1]).div(6);
        if(amount>=(poolsPrice[pool-1]).mul(2).div(6)){
            amount = (poolsPrice[pool-1]).mul(2).div(6);
        }
        }
        
        return amount;
    }
    
    function getUserReleaseAmountInRange(uint256 _start,uint256 _end) public view returns(uint256[] memory){
        uint256[] memory amount=new uint256[](10);
        for(uint256 i=_start;i<=_end;i++){
            amount[i-_start]=(users[id2Address[i]].prevHold);
        }
        return amount;
    }
    
    function releaseFundInRange(uint256 _start,uint256 _end) public{
        uint256[] memory amount = getUserReleaseAmountInRange(_start,_end);
        for(uint256 i=_start;i<=_end;i++){
            if(users[id2Address[i]].prevHold>0){
                payable(id2Address[i]).transfer(users[id2Address[i]].prevHold);
            releasedAmount[id2Address[i]] = releasedAmount[id2Address[i]].add(users[id2Address[i]].prevHold);
            users[id2Address[i]].prevHold = 0;
            }
            
        }
    }
    
    /* PUBLIC FUNCTIONS */
    

    function checkIfNextLevelCanBeUpgraded(address _user) public view returns(bool){
        
        if(block.timestamp>=users[_user].currPoolStartTime.add(DAYS.mul(7))){
            return true;
        }
        return false;
    }

    function getHoldAmount(address _user) public view returns(uint256 amount){
        if(users[_user].isExist == false){
            return 0;
        }
        uint256 timePassed = (block.timestamp.sub(users[_user].currPoolStartTime)).div(DAYS);
        uint256 _amount = timePassed.mul(poolsPrice[users[_user].currPool-1].div(6));
        if(_amount>=(poolsPrice[users[_user].currPool-1].mul(7).div(6))){
            _amount = (poolsPrice[users[_user].currPool-1].mul(7).div(6));
        }
        return _amount;
    }
    
    function getContractBalance() public view returns(uint256){
        return address(this).balance;
    }

    function getHistory(address _user,uint256 _index) public view returns(uint256 timestamp,uint256 pool,uint256 price,uint256 amount){
        return (history[_user][_index].time,history[_user][_index].pool,history[_user][_index].price,history[_user][_index].amount);
    }
    
    /* ADMIN FUNCTIONS */
    
    function addAdmins(address _admin) public{
        require(adminRights[msg.sender]==true, "You don't have permissions");
        adminRights[_admin] = true;
    }
    
    function releaseHoldAmount(address _user,uint256 _amount) public{
        // 7th and 8th day amount
        
        require(adminRights[msg.sender]==true, "you are not admin");
        require(users[_user].prevHold>=_amount,"invalid user amount");
        payable(_user).transfer(_amount);
        users[_user].prevHold = users[_user].prevHold.sub(_amount);
        releasedAmount[_user] = releasedAmount[_user].add(_amount);
        
    }
    
    function changePrice(uint256 _price) public{
        require(adminRights[msg.sender] == true, "You are not the admin");
        dollars = _price;
        changePoolPrice();
    }
    
    function jump(address _user, address _ref, uint256 _poolNumber) public payable{
        require(adminRights[msg.sender]==true,"You are not admin");
        require(msg.value>=poolsPrice[_poolNumber-1],"You need to pay correct amount");
        require(users[_user].isExist==false,"User already exists");
    
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
        users[_user].currPool = _poolNumber;
        users[_user].currPoolStartTime = block.timestamp;
        users[_user].currPoolEndTime = block.timestamp.add(DAYS.mul(7));
        
        id2Address[totalUsers] = _user;
        
        users[_ref].totalReferrals = users[_ref].totalReferrals.add(1);
        
        emit NewEntry(_user,_ref,poolsPrice[_poolNumber-1]);
        emit LevelUpgraded(_user,_poolNumber,poolsPrice[_poolNumber-1]);
        
        giveReferralIncome(_ref,_poolNumber);
        
    }
    
    function withdrawAdminAmount() public{
        require(msg.sender==admin1 || msg.sender==admin2,"you are not admin");
        if(msg.sender==admin1){
            msg.sender.transfer(admin1Wallet);
            admin1Wallet = 0;
        }
        else if(msg.sender==admin2){
            msg.sender.transfer(admin2Wallet);
            admin2Wallet = 0;
        }
    }
    
    
    /* EXTERNAL SETTER FUNCTIONS */
    
    function sendMoneyToContract() external payable{
        
    }
    
    function enterSystem(address _ref) external payable{
        enterSystem(msg.sender,_ref,msg.value);
        
    }
    
    function buyPool() external payable{
        if(users[msg.sender].currPool == 20){
            require(getHoldAmount(msg.sender).add(msg.value)>=poolsPrice[0], "must pay correct amount");
            
        }
        else{
            require(getHoldAmount(msg.sender).add(msg.value)>=poolsPrice[users[msg.sender].currPool], "must pay correct amount");
           
        }
        users[msg.sender].holdAmount = getHoldAmount(msg.sender);
         users[msg.sender].prevHold =users[msg.sender].prevHold.add(getPrevHold(msg.sender));
        if(users[msg.sender].currPool==20){
            buyPool(msg.sender,1,msg.value.add(users[msg.sender].holdAmount));
        }
        else
        buyPool(msg.sender,users[msg.sender].currPool.add(1),msg.value.add(users[msg.sender].holdAmount));
        if(users[msg.sender].holdAmount>poolsPrice[users[msg.sender].currPool-1]){
            payable(msg.sender).transfer(users[msg.sender].holdAmount.sub(poolsPrice[users[msg.sender].currPool-1]));
            users[msg.sender].extraEarned = users[msg.sender].extraEarned.add(users[msg.sender].holdAmount.sub(poolsPrice[users[msg.sender].currPool-1]));
        }
        users[msg.sender].holdAmount = 0;
       
        giveReferralIncome(users[msg.sender].referrer,users[msg.sender].currPool);
        
    }
    
    function getAdminWithdrawableAmount(address _admin) public view returns(uint256){
        // require(msg.sender == admin1 || msg.sender==admin2, "You are not admin");
        if(_admin == admin1){
            return admin1Wallet;
        }
        else if(_admin==admin2){
            return admin2Wallet;
        }
        return 0;
    }
    
    function withdrawTronBalance() public{
        msg.sender.transfer(address(this).balance);
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
