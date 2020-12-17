pragma solidity ^0.5.11;

contract MyTron{
    using SafeMath for uint256;
    
    uint256 constant MIN_AMOUNT =1000;
    uint256 constant BASE_PERCENT = 120;
    uint256 constant public MILLION = 1000;
    uint256 constant public TIME_STAMP = 30;
    uint256 constant public TRX = 1;
    
    uint256 public totalUsers;
	uint256 public totalInvested;
	uint256 public totalWithdrawn;
	uint256 public totalDeposits;
	uint256 public maxBalance;
	uint256 public adminWallet;
	
	address payable internal marketingAddress;
	address payable internal projectAddress;
	address payable internal developmentAddress;
	address payable internal owner;

    struct Deposit {
		uint256 amount;
		uint256 withdrawn;
		uint256 start;
	}

	struct User{
	    uint256 referrals;
	    Deposit[] deposits;
	    address referrer;
	    uint256 checkpoint;
	    uint256 weeklyLastWithdraw;
	    uint256 total_structure;
	    uint256 totalDownlineBalance;
	    uint256 level;
	    bool isExist;
	    uint256 totalWithdrawn;
	    uint256 levelIncome;
	    uint256 binaryCommissionEarned;
	    uint256 dailyProfitEarned;
	}
	
	struct UserLevels{
	    uint256 level1;
	    uint256 level2;
	    uint256 level3;
	    uint256 level4;
	    uint256 level5;
	    uint256 level6;
	    uint256 level7;
	    uint256 level8;
	    uint256 level9;
	    uint256 level10;
	}
	
	mapping(address => User) public users;
	mapping(address => UserLevels) public usersLevels;
	
	event Newbie(address indexed user);
	event NewDeposit(address indexed user, uint256 amount);
    event Withdrawn(uint256 amount, uint256 prev, uint256 curr, uint256 diff);
    event binaryEvent(uint256 amount, uint256 prev, uint256 curr, uint256 diff);

    constructor(address payable marketingAddr, address payable projectAddr, address payable developmentAddr, address payable _owner) public {
		require(!isContract(marketingAddr) && !isContract(projectAddr) && !isContract(developmentAddr));
		marketingAddress = marketingAddr;
		projectAddress = projectAddr;
		developmentAddress = developmentAddr;
		owner = _owner;
	}

    function invest(address _referrer) public payable{
        require(msg.value>=MIN_AMOUNT , "It should be greater than min value");
        
	    User storage user = users[msg.sender];
	    _referrer = setReferrer(_referrer);
	    
	    if (user.deposits.length == 0) {
    		user.checkpoint = block.timestamp;
    		user.weeklyLastWithdraw = block.timestamp;
    		user.level = 3;
    		user.isExist=true;
    		totalUsers = totalUsers.add(1);
    		emit Newbie(msg.sender);
    	}
    	
	    users[_referrer].referrals =  users[_referrer].referrals.add(1);
	    users[msg.sender].referrer = _referrer;
	    
	    user.deposits.push(Deposit(msg.value, 0, block.timestamp));
	    emit NewDeposit(msg.sender, msg.value);
	    
	    if (address(this).balance > maxBalance) {
    			maxBalance = address(this).balance;
    	}
    
    	totalInvested = totalInvested.add(msg.value);
    	totalDeposits = totalDeposits.add(1);
    	
    	setDownlineVolume(msg.value);
    	
    	//give 70% to admin
        adminWallet = adminWallet.add(msg.value.mul(7).div(10));
        setUplines(msg.sender);
        giveCommission(msg.sender,msg.value);
    }
    
    function setReferrer(address _referrer) internal view returns(address){
        User storage user = users[msg.sender];
	    if(user.referrer==address(0)){
    	    if((_referrer == msg.sender || _referrer==address(0) || users[_referrer].isExist==false) && msg.sender!=owner ){
    	        _referrer=owner;
    	    }
    	    
    	    else if(msg.sender==owner){
    	        _referrer=address(0);
    	    }
	    }
	    else{
	        _referrer = user.referrer;
	    }
	    return _referrer;
    }
    
    function setDownlineVolume(uint256 _amount) internal{
        address upline = users[msg.sender].referrer;
        for(uint256 i=0;i<10;i++){
            if(upline==address(0)){
                break;
            }
            users[upline].totalDownlineBalance = users[upline].totalDownlineBalance.add(_amount);
            setLevel(msg.sender);
            upline = users[upline].referrer;
        }
    }
    
    function getBinaryBalance() public view returns(uint256){
        uint256 vol=getDownlineBalance(msg.sender);
        if(vol>=MILLION.mul(500)){
            return vol.mul(2).div(100);
        }
         if(vol>=MILLION.mul(100)){
            return vol.mul(15).div(1000);
        }
        
        if(vol>=MILLION.mul(50)){
            return vol.mul(1).div(100);
        }
       
        if(vol>=MILLION.mul(10)){
            return (vol.mul(5).div(1000));
        }
        return 0;
    }
    
    function setLevel(address _user) internal{
         uint256 vol=getDownlineBalance(_user);
   
        if(vol>=MILLION.mul(500)){
            if(users[_user].level!=10){
            users[_user].level = 10;
            users[_user].weeklyLastWithdraw = block.timestamp;
            }
        }

        if(vol>=MILLION.mul(100)){
            if(users[_user].level!=9){
            users[_user].level = 9;
            users[_user].weeklyLastWithdraw = block.timestamp;
            }
        }
        
        if(vol>=MILLION.mul(50)){
            if(users[_user].level!=8){
            users[_user].level = 8;
            users[_user].weeklyLastWithdraw = block.timestamp;
            }
        }
    
        if(vol>=MILLION.mul(10)){
            if(users[_user].level!=7){
            users[_user].level = 7;
            users[_user].weeklyLastWithdraw = block.timestamp;
            }
        }

        if(vol>=MILLION.mul(5)){
            users[_user].level = 6;
        }
                    
        if(vol>=MILLION){
            users[_user].level = 5;
        }

        if(vol>=100000000000){
            users[_user].level = 4;
        }
        
    }
    
    function setUplines(address _user) internal{
	    address _upline=users[_user].referrer;
	   
	    for(uint8 i = 0; i < 10; i++) {
                if(_upline == address(0)) break;
                users[_upline].total_structure = users[_upline].total_structure.add(1);
                if(i==0){
                    usersLevels[_upline].level1 =  usersLevels[_upline].level1.add(1);
                }
                if(i==1){
                    usersLevels[_upline].level2 =  usersLevels[_upline].level2.add(1);
                }
                if(i==2){
                    usersLevels[_upline].level3 =  usersLevels[_upline].level3.add(1);
                }
                if(i==3){
                    usersLevels[_upline].level4 =  usersLevels[_upline].level4.add(1);
                }
                if(i==4){
                    usersLevels[_upline].level5 =  usersLevels[_upline].level5.add(1);
                }
                if(i==5){
                    usersLevels[_upline].level6 =  usersLevels[_upline].level6.add(1);
                }
                if(i==6){
                    usersLevels[_upline].level7 =  usersLevels[_upline].level7.add(1);
                }
                if(i==7){
                    usersLevels[_upline].level8 =  usersLevels[_upline].level8.add(1);
                }
                if(i==8){
                    usersLevels[_upline].level9 =  usersLevels[_upline].level9.add(1);
                }
                if(i==9){
                    usersLevels[_upline].level10 =  usersLevels[_upline].level10.add(1);
                }
                _upline = users[_upline].referrer;
            }
	}
	
	function getExtraProfit(address _user) internal view returns(uint256){
	    uint256 percent = 0;
	    if(getUserTotalDeposits(_user)>=TRX.mul(100000)){
	        percent = (getUserTotalDeposits(_user).div(TRX.mul(100000))).mul(5);
	    }
	    if(percent>=50)
	    percent = 50;
	    
	    return percent;
	}

    function totalDailyPercent(address _user) public view returns(uint256){
        return 120+getExtraProfit(_user);
    }
    
    function giveCommission(address _user,uint256 _amount) internal{
        address _upline = users[_user].referrer;
        for(uint256 i=1;i<=10;i++){
            if(_upline==address(0))
            break;
            
            if(i==1){
                if(users[_upline].level>=i){
                    users[_upline].levelIncome = users[_upline].levelIncome.add(_amount.mul(4).div(100));
                }
            }
             if(i==2){
                if(users[_upline].level>=i){
                    users[_upline].levelIncome = users[_upline].levelIncome.add(_amount.mul(3).div(100));
                }
            }
             if(i==3){
                if(users[_upline].level>=i){
                    users[_upline].levelIncome = users[_upline].levelIncome.add(_amount.mul(2).div(100));
                }
            }
             if(i==4){
                if(users[_upline].level>=i){
                    users[_upline].levelIncome = users[_upline].levelIncome.add(_amount.mul(1).div(100));
                }
            }
             if(i==5){
                if(users[_upline].level>=i){
                    users[_upline].levelIncome = users[_upline].levelIncome.add(_amount.mul(1).div(100));
                }
            }
             if(i==6){
                if(users[_upline].level>=i){
                    users[_upline].levelIncome = users[_upline].levelIncome.add(_amount.mul(1).div(100));
                }
            }
             if(i==7){
                if(users[_upline].level>=i){
                    users[_upline].levelIncome = users[_upline].levelIncome.add(_amount.mul(5).div(1000));
                }
            }
             if(i==8){
                if(users[_upline].level>=i){
                    users[_upline].levelIncome = users[_upline].levelIncome.add(_amount.mul(5).div(1000));
                }
            }
             if(i==9){
                if(users[_upline].level>=i){
                    users[_upline].levelIncome = users[_upline].levelIncome.add(_amount.mul(5).div(1000));
                }
            }
             if(i==10){
                if(users[_upline].level>=i){
                    users[_upline].levelIncome = users[_upline].levelIncome.add(_amount.mul(5).div(1000));
                }
            }
            _upline = users[_upline].referrer;
        }
    }
    
    function getDownlineBalance(address _user) public view returns(uint256){
	    return users[_user].totalDownlineBalance;
	}
	
	function withdraw() public{
	    User storage user = users[msg.sender];

        require(isActive(msg.sender),"User is not an active user");
		uint256 totalAmount;
		uint256 dividends;

    // amount for all deposits which can be maximum 200%
		for (uint256 i = 0; i < user.deposits.length; i++) {

			if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(2)) {

				if (user.deposits[i].start > user.checkpoint) {

					dividends = (user.deposits[i].amount.mul(totalDailyPercent(msg.sender)))
						.mul(block.timestamp.sub(user.deposits[i].start))
						.div(TIME_STAMP.mul(10000));

				} else {

				dividends = (user.deposits[i].amount.mul(totalDailyPercent(msg.sender)))
						.mul(block.timestamp.sub(user.checkpoint))
						.div(TIME_STAMP.mul(10000));
				}

				if (user.deposits[i].withdrawn.add(dividends) > user.deposits[i].amount.mul(2)) {
					dividends = (user.deposits[i].amount.mul(2)).sub(user.deposits[i].withdrawn);
				}
                
                emit Withdrawn(dividends,user.checkpoint,block.timestamp,block.timestamp.sub(user.checkpoint));
				user.deposits[i].withdrawn = user.deposits[i].withdrawn.add(dividends); /// changing of storage data
				totalAmount = totalAmount.add(dividends);

			}
			
			user.dailyProfitEarned = user.dailyProfitEarned.add(totalAmount);
		}
		if(totalAmount>0){
		    user.checkpoint = block.timestamp;
		}
		
		uint256 binaryBalance;
		if(getBinaryBalance()>0 && block.timestamp.sub(users[msg.sender].weeklyLastWithdraw)>TIME_STAMP.mul(7)){
		   binaryBalance = getBinaryBalance().mul(block.timestamp.sub(users[msg.sender].weeklyLastWithdraw)).div(TIME_STAMP.mul(7));
	        emit binaryEvent(binaryBalance,user.weeklyLastWithdraw,block.timestamp,block.timestamp.sub(user.weeklyLastWithdraw));
	        user.weeklyLastWithdraw = block.timestamp;
		    user.binaryCommissionEarned = user.binaryCommissionEarned.add(binaryBalance);
		    
		}
        
        totalAmount = totalAmount.add(binaryBalance);
		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

	

		msg.sender.transfer(totalAmount);

		totalWithdrawn = totalWithdrawn.add(totalAmount);
	    users[msg.sender].totalWithdrawn = users[msg.sender].totalWithdrawn.add(totalAmount);
	}
	
//     function getUserDividends(address userAddress) public view returns (uint256) {
// 		User storage user = users[userAddress];

// 		uint256 userPercentRate = getUserPercentRate(userAddress);

// 		uint256 totalDividends;
// 		uint256 dividends;

// 		for (uint256 i = 0; i < user.deposits.length; i++) {

// 			if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(5).div(2)) {

// 				if (user.deposits[i].start > user.checkpoint) {

// 					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
// 						.mul(block.timestamp.sub(user.deposits[i].start))
// 						.div(TIME_STEP);

// 				} else {

// 					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
// 						.mul(block.timestamp.sub(user.checkpoint))
// 						.div(TIME_STEP);

// 				}

// 				if (user.deposits[i].withdrawn.add(dividends) > user.deposits[i].amount.mul(5).div(2)) {
// 					dividends = (user.deposits[i].amount.mul(5).div(2)).sub(user.deposits[i].withdrawn);
// 				}

// 				totalDividends = totalDividends.add(dividends);

// 				/// no update of withdrawn because that is view function

// 			}

// 		}

// 		return totalDividends;
// 	}

	function getUserCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].checkpoint;
	}

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}
	
	function isActive(address userAddress) public view returns (bool) {
		User storage user = users[userAddress];

		if (user.deposits.length > 0) {
			if (user.deposits[user.deposits.length-1].withdrawn < user.deposits[user.deposits.length-1].amount.mul(5).div(2)) {
				return true;
			}
		}
	}

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint256, uint256, uint256) {
	    User storage user = users[userAddress];

		return (user.deposits[index].amount, user.deposits[index].withdrawn, user.deposits[index].start);
	}

	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256) {
	    User storage user = users[userAddress];

		uint256 amount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			amount = amount.add(user.deposits[i].amount);
		}

		return amount;
	}

	function getUserTotalWithdrawn(address userAddress) public view returns(uint256) {
	    User storage user = users[userAddress];

		uint256 amount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			amount = amount.add(user.deposits[i].withdrawn);
		}

		return amount;
	}

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
    
    //external
    function getBinaryBalanceLeftForWithdrawl(address _user) public view returns(uint256){
        uint256 binaryBalance = 0;
        if(isActive(_user)){
         binaryBalance = getBinaryBalance().mul(block.timestamp.sub(users[msg.sender].weeklyLastWithdraw)).div(TIME_STAMP.mul(7));
        }
    }
    
    function getUserDailyBalanceLeftForWithdrawl(address _user) public view returns(uint256){
        User storage user = users[_user];
        uint256 totalAmount;
		uint256 dividends;

    // amount for all deposits which can be maximum 200%
		for (uint256 i = 0; i < user.deposits.length; i++) {

			if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(2)) {

				if (user.deposits[i].start > user.checkpoint) {

					dividends = (user.deposits[i].amount.mul(totalDailyPercent(msg.sender)))
						.mul(block.timestamp.sub(user.deposits[i].start))
						.div(TIME_STAMP.mul(10000));

				} else {

				dividends = (user.deposits[i].amount.mul(totalDailyPercent(msg.sender)))
						.mul(block.timestamp.sub(user.checkpoint))
						.div(TIME_STAMP.mul(10000));
				}

				if (user.deposits[i].withdrawn.add(dividends) > user.deposits[i].amount.mul(2)) {
					dividends = (user.deposits[i].amount.mul(2)).sub(user.deposits[i].withdrawn);
				}
                
             	totalAmount = totalAmount.add(dividends);

			}
		}
		return totalAmount;
    }
    
    function getDailyProfitEarnedSoFar(address _user) public view returns(uint256){
        return users[_user].dailyProfitEarned;
    }
    
    function userInfo(address _user) public view returns( 
        uint256 referrals,
	    uint256 total_structure,
	    uint256 level,
	    uint256 _totalWithdrawn,
	    uint256 referralCommission){
	        return (
	            users[_user].referrals,
	            users[_user].total_structure,
	            users[_user].level,
	            users[_user].totalWithdrawn,
	            users[_user].levelIncome
	            );
	    }
	    
	function getLevelWiseCount(address _user,uint256 _level) public view returns(uint256){
	    if(_level==1){
	        return usersLevels[_user].level1;
	    }
	     if(_level==2){
	        return usersLevels[_user].level2;
	    }
	     if(_level==3){
	        return usersLevels[_user].level3;
	    }
	     if(_level==4){
	        return usersLevels[_user].level4;
	    }
	     if(_level==5){
	        return usersLevels[_user].level5;
	    }
	     if(_level==6){
	        return usersLevels[_user].level6;
	    }
	     if(_level==7){
	        return usersLevels[_user].level7;
	    }
	     if(_level==8){
	        return usersLevels[_user].level8;
	    }
	     if(_level==9){
	        return usersLevels[_user].level9;
	    }
	     if(_level==10){
	        return usersLevels[_user].level10;
	    }
	}
	

}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}
