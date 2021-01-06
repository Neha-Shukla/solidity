// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract LenderAndBorrower{
    using SafeMath for uint256;
    uint256 totalLenders;
    uint256 totalBorrowers;
    uint256 totalProperties;
    
    struct Lender{
        uint256 lid;
        string name;
        string email;
        string username;
        bool isExist;
        bytes32 passKey;
        address[] borrowersId;
        uint256[] propertyId;
        uint256 totalAmount;
        bool loggedIn;
    }
    
    struct Borrower{
        uint256 bid;
        string name;
        string email;
        uint256 phone;
        uint256 pId;
        uint256 startDate;
        uint256 endDate;
        bool isExist;
    }
    
    struct Property{
        string propertyAddr;
        uint256 pid;
        address lender;
        string propertyType;
        uint256 price;
        uint256 interest;
        uint256 tenure;1
        bool sold;
        uint256 balance;
        address borrower;
    }
    
    mapping(address=>Lender) public lenders;
    mapping(address=>Borrower) public borrowers;
    mapping(uint256=>Property) public properties;
    mapping(address=>uint256) public borrower2Property;
    mapping(string=>uint256) public propertiesId2Address;
    mapping(uint256=>address) public borrowersId2Address;
    mapping(uint256=>address) public lendersId2Address;
    
    event registerlenderEvent(address _user,string _passKey, bytes32 _hashed);
    event loginlenderEvent(address _user,string _passKey,bytes32 _hashed);
    
    function RegisterAsLender(string memory _name,string memory _email, string memory _username,string memory _passKey) public{
        require(lenders[msg.sender].isExist == false, "lender already exists");
        lenders[msg.sender].passKey=keccak256(bytes(_passKey));
        lenders[msg.sender].isExist = true;
        totalLenders=totalLenders.add(1);
        lenders[msg.sender].lid = totalLenders;
        lenders[msg.sender].name = _name;
        lenders[msg.sender].email = _email;
        lenders[msg.sender].username = _username;
        lendersId2Address[totalLenders]=msg.sender;
        
        emit registerlenderEvent(msg.sender,_passKey,keccak256(bytes(_passKey)));
    }
    
    function LoginForLender(string memory _passKey) public{
        require(lenders[msg.sender].isExist, "lender needs to register first");
        require(lenders[msg.sender].passKey == keccak256(bytes(_passKey)),"wrong passKey");
        lenders[msg.sender].loggedIn = true;
        emit loginlenderEvent(msg.sender,_passKey,keccak256(bytes(_passKey)));
    }
    
    function LoggedOut() public{
        require(lenders[msg.sender].loggedIn==true,"you are not logged in");
        lenders[msg.sender].loggedIn=false;
    }
    
    function AddBorrowers(address _bAddr,string memory _name,string memory _email, uint256 _phone, uint256 _startDate,uint256 _endDate, string memory _propertyAddr, string memory _propType,uint256 _price,uint256 _tenure,uint256 _interest) public{
        uint256 _pId = totalProperties.add(1);
        require(lenders[msg.sender].isExist, "You are not the lender");
        require(propertiesId2Address[_propertyAddr]==0,"already existing Property");
        Addproperty(_propertyAddr,  _propType, _price, _tenure, _interest);
        totalBorrowers = totalBorrowers.add(1);
        borrowersId2Address[totalBorrowers]=_bAddr;
        borrower2Property[_bAddr] = _pId;
        lenders[msg.sender].borrowersId.push(_bAddr);
        lenders[msg.sender].totalAmount = lenders[msg.sender].totalAmount.add(properties[_pId].price);
        properties[_pId].sold = true;
        borrowers[_bAddr] = Borrower(totalBorrowers,_name,_email,_phone,_pId,_startDate,_endDate,true);
        properties[_pId].borrower = _bAddr;
    }
    
    function Addproperty(string memory _propertyAddr, string memory _propType,uint256 _price,uint256 _tenure,uint256 _interest) public{
        require(lenders[msg.sender].isExist, "You are not the lender");
        totalProperties = totalProperties.add(1);
        lenders[msg.sender].propertyId.push(totalProperties);
        properties[totalProperties] = Property(_propertyAddr,totalProperties,msg.sender,_propType,_price,_interest,_tenure,false,_price,address(0));
        propertiesId2Address[_propertyAddr]=totalProperties;
    }
    
    function GetBorrowers() public view returns(address[] memory){
        address[] memory res = new address[](lenders[msg.sender].borrowersId.length);
        for(uint256 i=0;i<lenders[msg.sender].borrowersId.length;i++){
            res[i] = lenders[msg.sender].borrowersId[i];
        }
        return res;
    }
    
    function GetProperties() public view returns(uint256[] memory res){
        return lenders[msg.sender].propertyId;
    }
    
    function GetTotalBorrowers(address _user) public view returns(uint256){
        return lenders[_user].borrowersId.length;
    }
    
    function GetTotalAmount(address _user) public view returns(uint256){
        return lenders[_user].totalAmount;
    }
    
    function GetBorrowerInfo(address _user) public view returns(string memory _name,string memory _propType,uint256 _date,uint256 _amount){
        return (borrowers[_user].name,properties[borrowers[_user].pId].propertyType,borrowers[_user].startDate,properties[borrowers[_user].pId].price);
    }
    
    function IsLoggedIn() public view returns(bool){
        return lenders[msg.sender].loggedIn;
    }
    
    function GetPropertyDetails(address _user) public view returns(uint256 _pId,string memory _propertyAddr,address _lender, uint256 _price, string memory _propType){
        return (
            properties[borrower2Property[_user]].pid,
            properties[borrower2Property[_user]].propertyAddr,
            properties[borrower2Property[_user]].lender,
            properties[borrower2Property[_user]].price,
            properties[borrower2Property[_user]].propertyType
            );
    }
    
    function IsLenderOrBorrower(address _user) public view returns(uint256){
        if(lenders[_user].isExist){
            return 1;
        }
        else if (borrowers[_user].isExist){
            return 2;
        }
        return 0;
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
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
