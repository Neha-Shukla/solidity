pragma solidity ^0.6.0;

contract TronTradeDubai{
    using SafeMath for uint256;
    
    uint256 constant public MIN_INVESTMENT = 500000000;  //500 TRX
    uint256 constant public MIN_WITHDRAW = 20000000;     //20 TRX
    uint256 constant public MAX_WITHDRAWN_PERCENT = 365; //365 TRX 
    uint256 constant public DIVIDER = 100;
    
    uint256 public totalUsers;
    uint256 public totalInvested;
    uint256 public totalWithdrawn;
    address public owner;
    
    uint256 adminWallet;
    uint256 portfolioWallet;
    uint256 reInvestWallet;
    
    struct Deposit{
        uint256 amount;
        uint256 start;
        uint256 withdrawn;
        uint256 refIncome;
        bool active;
    }
    
    struct User{
        uint256 id;
        Deposit[] deposits;
        uint256 levelIncomeEarned;
        uint256 referrals;
        address referrer;
        uint256 totalWithdrawn;
        bool isExist;
    }
    
    mapping(address=>User) public users;
    mapping(uint256=>address) public usersList;
    
    event NewUserRegisterEvent(address _user,address _ref,uint256 _amount);
    event NewDeposit(address _user,uint256 _amount);
    event ReInvest(address _user,uint256 _amount);
    
    constructor() public{
        owner=msg.sender;
    }
    
    function Invest(address _ref) public payable{
        require(msg.value>=MIN_INVESTMENT, "You should pay min amount");
        if(users[msg.sender].deposits.length==0){
            if(_ref == address(0) || users[_ref].isExist==false || _ref==msg.sender){
                _ref = owner;
            }
            if(msg.sender == owner){
                _ref = address(0);
            }
            
            totalUsers = totalUsers.add(1);
            users[msg.sender].id = totalUsers;
            users[msg.sender].referrer = _ref;
            users[_ref].referrals = users[_ref].referrals.add(1);
            usersList[totalUsers] = msg.sender;
            emit NewUserRegisterEvent(msg.sender,_ref,msg.value);
        }
        else{
            emit ReInvest(msg.sender,msg.value);
        }
        totalInvested = totalInvested.add(msg.value);
        
        users[msg.sender].deposits.push(Deposit(msg.value,block.timestamp,0,0,true));
        DistributeLevelFund(_ref,msg.value);
    }
    
    function DistributeLevelFund(address _ref,uint256 _amount) internal{
        for(uint256 i=0;i<10;i++){
            uint256 percent=0;
            if(_ref == address(0)){
               break; 
            }
            if(i==0){
                percent = 5;
            }
            if(i==1){
                percent = 3;
            }
            if(i==2){
                percent = 2;
            }
            else{
                percent = 1;
            }
            if(ifEligibleToGetLevelIncome(_ref,i+1)){
              
                if(users[_ref].deposits[getTotalDepositsCount(_ref)-1].refIncome.
                add(percent.mul(_amount).div(DIVIDER)).
                add(users[_ref].deposits[getTotalDepositsCount(_ref)-1].withdrawn)
                <= users[_ref].deposits[getTotalDepositsCount(_ref)-1].amount.mul(365).div(DIVIDER))
                {
                    users[_ref].deposits[getTotalDepositsCount(_ref)-1].refIncome = users[_ref].deposits[getTotalDepositsCount(_ref)-1].refIncome.
                    add(percent.mul(_amount).div(DIVIDER));
                    users[_ref].levelIncomeEarned = users[_ref].levelIncomeEarned.add(percent.mul(_amount).div(DIVIDER));
                }
            }
                
            }
        _ref = users[_ref].referrer;
    }
    
    function WithdrawFunds() public{
        
    }
    
    
    
    function DepositAmountInContract() external payable{
        require(msg.sender == owner, "You are not the owner");
        
    }
    
    function ifEligibleToGetLevelIncome(address _user,uint256 _level) public view returns(bool){
        if(users[_user].referrals>=_level)
        return true;
        else 
        return false;
    }
    
    function getTimepassedInSec(address _user,uint256 _index) public view returns(uint256){
        return block.timestamp.sub(users[_user].deposits[_index].start);
    }
    
    function getUserAddressById(uint256 _id) public view returns(address){
        return usersList[_id];
    }
    
    function getTotalDepositsCount(address _user) public view returns(uint256){
        return users[_user].deposits.length;
    }
    
    function getContractBalance() public view returns(uint256){
        return address(this).balance;
    }
    
    function getUserTotalActiveDeposits(address _user) public view returns(uint256){
        uint256 totalAmount=0;
        for(uint256 i=0;i<getTotalDepositsCount(_user);i++){
            if(users[_user].deposits[i].active){
                totalAmount = totalAmount.add(users[_user].deposits[i].amount);
            }
        }
        return totalAmount;
    }
}


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

}
