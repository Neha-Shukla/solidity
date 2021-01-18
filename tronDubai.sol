pragma solidity ^0.6.0;

contract TronTradeDubai{
    using SafeMath for uint256;
    
    uint256 constant public MIN_INVESTMENT = 500000000;  // 500 TRX
    uint256 constant public MIN_WITHDRAW = 20000000;     // 20 TRX
    uint256 constant public MAX_WITHDRAWN_PERCENT = 365; // 365% 
    uint256 constant public DIVIDER = 100;
    uint256 constant public DAILY_ROI = 1;               // 1%
    uint256 constant public TIME = 1; 
    
    uint256 internal totalUsers;
    uint256 internal totalInvested;
    uint256 internal totalWithdrawn;
    address internal owner;
    
    uint256 adminWallet;
    uint256 portfolioWallet;
    uint256 reInvestWallet;
    
    address adminAcc;
    address portfolioAcc;
    address reInvestAcc;
    
    struct Deposit{
        uint256 amount;
        uint256 start;
        uint256 withdrawn;
        uint256 refIncome;
        uint256 max;
        bool active;
    }
    
    struct User{
        uint256 id;
        Deposit[] deposits;
        uint256 levelIncomeEarned;
        uint256 referrals;
        address referrer;
        uint256 totalWithdrawn;
        uint256 holdReferralBonus;
        bool isExist;
    }
    
    mapping(address=>User) public users;
    mapping(uint256=>address) public usersList;
    
    event NewUserRegisterEvent(address _user,address _ref,uint256 _amount);
    event NewDeposit(address _user,uint256 _amount);
    event ReInvest(address _user,uint256 _amount);
    event Dividends(address _user,uint256 _amount,uint256 _start,uint256 _end,uint256 _diff);
    event Withdraw(address _user,uint256 _amount);
    
    constructor(address _adminAcc,address _portfolioAcc,address _reInvestAcc) public{
        owner=msg.sender;
        adminAcc = _adminAcc;
        portfolioAcc = _portfolioAcc;
        reInvestAcc = _reInvestAcc;
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
            users[msg.sender].isExist = true;
            emit NewUserRegisterEvent(msg.sender,_ref,msg.value);
        }
        else{
            emit ReInvest(msg.sender,msg.value);
        }
        totalInvested = totalInvested.add(msg.value);
        
        users[msg.sender].deposits.push(Deposit(msg.value,block.timestamp,0,0,
        MAX_WITHDRAWN_PERCENT.mul(msg.value).div(DIVIDER),true));
        
        // give amount to production
        adminWallet = adminWallet.add(msg.value.mul(10).div(DIVIDER));
        portfolioWallet = portfolioWallet.add(msg.value.mul(5).div(DIVIDER));
        reInvestWallet = reInvestWallet.add(msg.value.mul(30).div(DIVIDER));
        
        address(uint256(adminAcc)).transfer(msg.value.mul(10).div(DIVIDER));
        address(uint256(portfolioAcc)).transfer(msg.value.mul(5).div(DIVIDER));
        address(uint256(reInvestAcc)).transfer(msg.value.mul(30).div(DIVIDER));
        
        DistributeLevelFund(users[msg.sender].referrer,msg.value);
    }
    
    function DistributeLevelFund(address _ref,uint256 _amount) internal{
        for(uint256 i=0;i<10;i++){
            uint256 percent=0;
            if(_ref == address(0)){
               break; 
            }
            else if(i==0){
                percent = 5;
            }
            else if(i==1){
                percent = 3;
            }
            else if(i==2){
                percent = 2;
            }
            else{
                percent = 1;
            }
            if(ifEligibleToGetLevelIncome(_ref,i+1)){
              users[_ref].holdReferralBonus = users[_ref].holdReferralBonus.
              add(_amount.mul(percent).div(DIVIDER));
            }
            _ref = users[_ref].referrer;
            }
        
    }
    
    function WithdrawFunds() public{
        require(getWithdrawableAmount()>=MIN_WITHDRAW , "you must withdraw amount > 20 TRX");
        require(getWithdrawableAmount()<=getContractBalance(),"Low contract balance");
        uint256 totalAmount;
        uint256 dividends;
        address _user = msg.sender;
        
        for(uint256 i=0;i<users[_user].deposits.length;i++){
            uint256 ROI = DAILY_ROI.mul(users[_user].deposits[i].amount).
            mul(block.timestamp.sub(users[_user].deposits[i].start)).div(DIVIDER).div(TIME);
            uint256 maxWithdrawn = users[_user].deposits[i].max;
            uint256 alreadyWithdrawn = users[_user].deposits[i].withdrawn;
            uint256 holdReferralBonus = users[_user].holdReferralBonus;
            
            if(alreadyWithdrawn != maxWithdrawn){
                if(holdReferralBonus.add(alreadyWithdrawn)>=maxWithdrawn){
                    dividends = maxWithdrawn.sub(alreadyWithdrawn);
                    holdReferralBonus = holdReferralBonus.sub(maxWithdrawn.sub(alreadyWithdrawn));
                    users[_user].deposits[i].active = false;
                }
                else{
                    
                    if(holdReferralBonus.add(alreadyWithdrawn).add(ROI)>=maxWithdrawn){
                        dividends = maxWithdrawn.sub(alreadyWithdrawn);
                        users[_user].deposits[i].active = false;
                    }
                    else{
                        dividends = holdReferralBonus.add(ROI);
                    }
                    holdReferralBonus = 0;
                }
                users[_user].holdReferralBonus = holdReferralBonus;
            }
            emit Dividends(_user,dividends,users[_user].deposits[i].start,
                block.timestamp,block.timestamp.sub(users[_user].deposits[i].start));
                if(dividends>0)
                users[_user].deposits[i].start = block.timestamp;
                users[_user].deposits[i].withdrawn = users[_user].deposits[i].withdrawn+dividends;
                   totalAmount = totalAmount.add(dividends); 
            }
        require(totalAmount>MIN_WITHDRAW,"Nothing to Withdraw");
        if(totalAmount>getContractBalance()){
            totalAmount = getContractBalance();
        }
        msg.sender.transfer(totalAmount);
        totalWithdrawn = totalWithdrawn.add(totalAmount);
        users[_user].totalWithdrawn = users[_user].totalWithdrawn.add(totalAmount);
        emit Withdraw(_user,totalAmount);
    }
    
    function getWithdrawableAmount() public view returns(uint256){
        uint256 totalAmount;
        uint256 dividends;
        address _user = msg.sender;
        
        for(uint256 i=0;i<users[_user].deposits.length;i++){
            uint256 ROI = DAILY_ROI.mul(users[_user].deposits[i].amount).
            mul(block.timestamp.sub(users[_user].deposits[i].start)).div(DIVIDER).div(TIME);
            uint256 maxWithdrawn = users[_user].deposits[i].max;
            uint256 alreadyWithdrawn = users[_user].deposits[i].withdrawn;
            uint256 holdReferralBonus = users[_user].holdReferralBonus;
            
            if(alreadyWithdrawn != maxWithdrawn){
                if(holdReferralBonus.add(alreadyWithdrawn)>=maxWithdrawn){
                    dividends = maxWithdrawn.sub(alreadyWithdrawn);
                }
                else{
                    if(holdReferralBonus.add(alreadyWithdrawn).add(ROI)>=maxWithdrawn){
                        dividends = maxWithdrawn.sub(alreadyWithdrawn);
                    }
                    else{
                        dividends = holdReferralBonus.add(ROI);
                    }
                 
                }
             
            }
            
            totalAmount = totalAmount.add(dividends); 
        }
        
        return totalAmount;
    }
    function DepositAmountInContract() external payable{
        require(msg.sender == owner, "You are not the owner");
        
    }
    
    function ifEligibleToGetLevelIncome(address _user,uint256 _level) internal view returns(bool){
        if(users[_user].referrals>=_level)
        return true;
        else 
        return false;
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
    
    function getAllDepositInfo(address _user,uint256 _index) public view returns(uint256 amount,
    uint256 start, uint256 withdrawn,uint256 max,bool active){
        return (users[_user].deposits[_index].amount,users[_user].deposits[_index].start,
        users[_user].deposits[_index].withdrawn,users[_user].deposits[_index].max,
        users[_user].deposits[_index].active);
    }
    
    function getTotalUsers() public view returns(uint256){
        return totalUsers;
    }
    
    function getTotalWithdrawn() public view returns(uint256){
        return totalWithdrawn;
    }
    
    function getTotalInvested() public view returns(uint256){
        return totalInvested;
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
