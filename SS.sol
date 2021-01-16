pragma solidity ^0.7.4;

// invest
contract SS{
    
    using SafeMath for uint256;
    uint256 constant public MIN_AMOUNT = 100000000;   //100 TRX
    uint256 constant public DAILY_ROI = 2;   //2%
    uint256 constant public MAX_WITHDRAW_PERCENT = 400; //400% i.e. 4 times
    uint256 constant TRX = 1000000;
    address public owner;
    uint256 totalUsers;
    uint256[] LevelIncome;
    uint256[] PoolPrice;
    
      uint public currUserID = 0;
      uint public pool1currUserID = 0;
      uint public pool2currUserID = 0;
      uint public pool3currUserID = 0;
      uint public pool4currUserID = 0;
      uint public pool5currUserID = 0;
      uint public pool6currUserID = 0;
      uint public pool7currUserID = 0;
      uint public pool8currUserID = 0;
      uint public pool9currUserID = 0;
      uint public pool10currUserID = 0;
      
      uint public pool1activeUserID = 0;
      uint public pool2activeUserID = 0;
      uint public pool3activeUserID = 0;
      uint public pool4activeUserID = 0;
      uint public pool5activeUserID = 0;
      uint public pool6activeUserID = 0;
      uint public pool7activeUserID = 0;
      uint public pool8activeUserID = 0;
      uint public pool9activeUserID = 0;
      uint public pool10activeUserID = 0;
      
      
    struct User{
        uint256 id;
        uint256 poolWallet;
        uint256 withdrawWallet;
        uint256 totalWithdrawn;
        uint256 investedAmount;
        uint256 checkPoint;
        address referrer;
        bool isExist;
        uint256 levelIncome;
    }
    
     struct PoolUserStruct {
        bool isExist;
        uint id;
       uint payment_received; 
       uint cycle;
    }
    
    mapping(address=>User) public users;
    mapping(uint256=>address) public userAddressById;
    
     mapping (address => PoolUserStruct) public pool1users;
     mapping (uint => address) public pool1userList;
     
     mapping (address => PoolUserStruct) public pool2users;
     mapping (uint => address) public pool2userList;
     
     mapping (address => PoolUserStruct) public pool3users;
     mapping (uint => address) public pool3userList;
     
     mapping (address => PoolUserStruct) public pool4users;
     mapping (uint => address) public pool4userList;
     
     mapping (address => PoolUserStruct) public pool5users;
     mapping (uint => address) public pool5userList;
     
     mapping (address => PoolUserStruct) public pool6users;
     mapping (uint => address) public pool6userList;
     
     mapping (address => PoolUserStruct) public pool7users;
     mapping (uint => address) public pool7userList;
     
     mapping (address => PoolUserStruct) public pool8users;
     mapping (uint => address) public pool8userList;
     
     mapping (address => PoolUserStruct) public pool9users;
     mapping (uint => address) public pool9userList;
     
     mapping (address => PoolUserStruct) public pool10users;
     mapping (uint => address) public pool10userList;
     
     
    event investedSuccessfullyEvent(address _user,address _ref,uint256 _amount);
    event levelIncomeDistributedSuccessfully(address _ref,uint256 _level,uint256 _amountPercent,uint256 _amount);
    
    constructor(address _owner) public{
        owner = _owner;
        LevelIncome.push(10);
        LevelIncome.push(9);
        LevelIncome.push(8);
        LevelIncome.push(7);
        LevelIncome.push(6);
        LevelIncome.push(5);
        LevelIncome.push(4);
        LevelIncome.push(3);
        LevelIncome.push(2);
        LevelIncome.push(1);
        
        PoolPrice.push(TRX.mul(1000));
        PoolPrice.push(TRX.mul(2000));
        PoolPrice.push(TRX.mul(5000));
        PoolPrice.push(TRX.mul(10000));
        PoolPrice.push(TRX.mul(25000));
        PoolPrice.push(TRX.mul(50000));
        PoolPrice.push(TRX.mul(100000));
        PoolPrice.push(TRX.mul(250000));
        PoolPrice.push(TRX.mul(500000));
        PoolPrice.push(TRX.mul(1000000));
    }
    
    function invest(address _ref) external payable{
        require(users[msg.sender].isExist==false,"user already invested");
        require(msg.value>=MIN_AMOUNT, "must have sufficient amount");
        _invest(msg.sender,_ref,msg.value);
    }
    
    function _invest(address _user,address _ref,uint256 _amount) internal{
        if(!users[_ref].isExist){
            _ref = owner;
        }
        
        if(_user == owner){
            _ref = address(0);
        }
        
        totalUsers = totalUsers.add(1);
        
        users[_user].id = totalUsers;
        users[_user].referrer = _ref;
        users[_user].investedAmount = _amount;
        users[_user].checkPoint = block.timestamp;
        users[_user].isExist = true;
        userAddressById[totalUsers] = _user;
        
        //giveLevelIncome
        giveLevelIncome(_ref,_amount);
        
        emit investedSuccessfullyEvent(_user,_ref,_amount);
    }
    
    function giveLevelIncome(address _ref,uint256 _amount) public{
    
        for(uint256 i=0;i<15;i++){
            if(_ref==address(0)){
                break;
            }
            users[_ref].levelIncome = users[_ref].levelIncome .add(LevelIncome[i].mul(_amount).div(100));
            emit levelIncomeDistributedSuccessfully(_ref,i+1,LevelIncome[i],LevelIncome[i].mul(_amount).div(100));
             _ref = users[_ref].referrer;
        }
       
    }
    
    function buyPool(uint256 _poolNumber) public payable{
        require(msg.value>=PoolPrice[_poolNumber-1],"amount must be greater or equal to pool price");
       if(_poolNumber==1){
            require(!pool1users[msg.sender].isExist, "you have purchased the pool before");
            pool1currUserID = pool1currUserID+1;
            pool1users[msg.sender] = PoolUserStruct(true,pool1currUserID,0,0);
            pool1userList[pool1currUserID]=msg.sender;
        }
        if(_poolNumber==2){
            require(!pool2users[msg.sender].isExist, "you have purchased the pool before");
            pool2currUserID = pool2currUserID+1;
            pool2users[msg.sender] = PoolUserStruct(true,pool2currUserID,0,0);
            pool2userList[pool2currUserID]=msg.sender;
        }
        if(_poolNumber==3){
            require(!pool3users[msg.sender].isExist, "you have purchased the pool before");
            pool3currUserID = pool3currUserID+1;
            pool3users[msg.sender] = PoolUserStruct(true,pool3currUserID,0,0);
            pool3userList[pool3currUserID]=msg.sender;
        }
        if(_poolNumber==4){
            require(!pool4users[msg.sender].isExist, "you haven't purchased the pool before");
            pool4currUserID = pool4currUserID+1;
            pool4users[msg.sender] = PoolUserStruct(true,pool4currUserID,0,0);
            pool4userList[pool4currUserID]=msg.sender;
        }
        if(_poolNumber==5){
            require(!pool5users[msg.sender].isExist, "you haven't purchased the pool before");
            pool5currUserID = pool5currUserID+1;
            pool5users[msg.sender] = PoolUserStruct(true,pool5currUserID,0,0);
            pool5userList[pool5currUserID]=msg.sender;
        }
        if(_poolNumber==6){
            require(!pool6users[msg.sender].isExist, "you have purchased the pool before");
            pool6currUserID = pool6currUserID+1;
            pool6users[msg.sender] = PoolUserStruct(true,pool6currUserID,0,0);
            pool6userList[pool6currUserID]=msg.sender;
        }
        if(_poolNumber==7){
            require(!pool7users[msg.sender].isExist, "you have purchased the pool before");
            pool7currUserID = pool7currUserID+1;
            pool7users[msg.sender] = PoolUserStruct(true,pool7currUserID,0,0);
            pool7userList[pool7currUserID]=msg.sender;
        }
        if(_poolNumber==8){
            require(!pool8users[msg.sender].isExist, "you have purchased the pool before");
            pool8currUserID = pool8currUserID+1;
            pool8users[msg.sender] = PoolUserStruct(true,pool8currUserID,0,0);
            pool8userList[pool8currUserID]=msg.sender;
        }
        if(_poolNumber==9){
            require(!pool9users[msg.sender].isExist, "you have purchased the pool before");
            pool9currUserID = pool9currUserID+1;
            pool9users[msg.sender] = PoolUserStruct(true,pool9currUserID,0,0);
            pool9userList[pool9currUserID]=msg.sender;
        }
        if(_poolNumber==10){
            require(!pool10users[msg.sender].isExist, "you have purchased the pool before");
            pool10currUserID = pool10currUserID+1;
            pool10users[msg.sender] = PoolUserStruct(true,pool10currUserID,0,0);
            pool10userList[pool10currUserID]=msg.sender;
        }
    }
    
    function reBuyPool(uint256 _poolNumber) public payable{
        require(msg.value>=PoolPrice[_poolNumber-1],"amount must be greater or equal to pool price");
        if(_poolNumber==1){
            require(pool1users[msg.sender].isExist, "you haven't purchased the pool before");
            pool1currUserID = pool1currUserID+1;
            pool1users[msg.sender] = PoolUserStruct(true,pool1currUserID,0,0);
            pool1userList[pool1currUserID]=msg.sender;
        }
        if(_poolNumber==2){
            require(pool2users[msg.sender].isExist, "you haven't purchased the pool before");
            pool2currUserID = pool2currUserID+1;
            pool2users[msg.sender] = PoolUserStruct(true,pool2currUserID,0,0);
            pool2userList[pool2currUserID]=msg.sender;
        }
        if(_poolNumber==3){
            require(pool3users[msg.sender].isExist, "you haven't purchased the pool before");
            pool3currUserID = pool3currUserID+1;
            pool3users[msg.sender] = PoolUserStruct(true,pool3currUserID,0,0);
            pool3userList[pool3currUserID]=msg.sender;
        }
        if(_poolNumber==4){
            require(pool4users[msg.sender].isExist, "you haven't purchased the pool before");
            pool4currUserID = pool4currUserID+1;
            pool4users[msg.sender] = PoolUserStruct(true,pool4currUserID,0,0);
            pool4userList[pool4currUserID]=msg.sender;
        }
        if(_poolNumber==5){
            require(pool5users[msg.sender].isExist, "you haven't purchased the pool before");
            pool5currUserID = pool5currUserID+1;
            pool5users[msg.sender] = PoolUserStruct(true,pool5currUserID,0,0);
            pool5userList[pool5currUserID]=msg.sender;
        }
        if(_poolNumber==6){
            require(pool6users[msg.sender].isExist, "you haven't purchased the pool before");
            pool6currUserID = pool6currUserID+1;
            pool6users[msg.sender] = PoolUserStruct(true,pool6currUserID,0,0);
            pool6userList[pool6currUserID]=msg.sender;
        }
        if(_poolNumber==7){
            require(pool7users[msg.sender].isExist, "you haven't purchased the pool before");
            pool7currUserID = pool7currUserID+1;
            pool7users[msg.sender] = PoolUserStruct(true,pool7currUserID,0,0);
            pool7userList[pool7currUserID]=msg.sender;
        }
        if(_poolNumber==8){
            require(pool8users[msg.sender].isExist, "you haven't purchased the pool before");
            pool8currUserID = pool8currUserID+1;
            pool8users[msg.sender] = PoolUserStruct(true,pool8currUserID,0,0);
            pool8userList[pool8currUserID]=msg.sender;
        }
        if(_poolNumber==9){
            require(pool9users[msg.sender].isExist, "you haven't purchased the pool before");
            pool9currUserID = pool9currUserID+1;
            pool9users[msg.sender] = PoolUserStruct(true,pool9currUserID,0,0);
            pool9userList[pool9currUserID]=msg.sender;
        }
        if(_poolNumber==10){
            require(pool10users[msg.sender].isExist, "you haven't purchased the pool before");
            pool10currUserID = pool10currUserID+1;
            pool10users[msg.sender] = PoolUserStruct(true,pool10currUserID,0,0);
            pool10userList[pool10currUserID]=msg.sender;
        }
    }
    
    function withdrawAmount() public{
        
    }
}


library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
