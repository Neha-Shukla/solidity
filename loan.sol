// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract LenderAndBorrower{
    using SafeMath for uint256;
    uint256 totalLenders;
    uint256 totalBorrowers;
    uint256 totalProperties;
    
    struct Lender{
        uint256 lid;
        bool isExist;
        bytes32 passKey;
        address[] borrowersAddress;
        address[] propertyAddress;
    }
    
    struct Borrower{
        uint256 bid;
        string email;
        uint256 phone;
        address propertyAddr;
    }
    
    struct Property{
        uint256 pid;
        address lender;
        address borrower;
        uint256 propertyType;
    }
    
    mapping(address=>Lender) public lenders;
    mapping(address=>Borrower) public borrowers;
    mapping(address=>Property) properties;
    
    event registerlenderEvent(address _user,string _passKey, bytes32 _hashed);
    event loginlenderEvent(address _user,string _passKey,bytes32 _hashed);
    
    function RegisterAsLender(string memory _passKey) public{
        require(lenders[msg.sender].isExist == false, "lender already exists");
        lenders[msg.sender].passKey=keccak256(bytes(_passKey));
        lenders[msg.sender].isExist = true;
        totalLenders=totalLenders.add(1);
        lenders[msg.sender].lid = totalLenders;
        emit registerlenderEvent(msg.sender,_passKey,keccak256(bytes(_passKey)));
    }
    
    function LoginForLender(string memory _passKey) public{
        require(lenders[msg.sender].isExist, "lender needs to register first");
        require(lenders[msg.sender].passKey == keccak256(bytes(_passKey)),"wrong passKey");
        emit loginlenderEvent(msg.sender,_passKey,keccak256(bytes(_passKey)));
    }
    
    function AddBorrowers(address _bAddr,string memory _email, uint256 _phone, address _propertyAddr, uint256 _propType) public{
        totalBorrowers = totalBorrowers.add(1);
        lenders[msg.sender].borrowersAddress.push(_bAddr);
        lenders[msg.sender].propertyAddress.push(_propertyAddr);
        borrowers[_bAddr] = Borrower(totalBorrowers,_email,_phone,_propertyAddr);
        totalProperties = totalProperties.add(1);
        properties[_propertyAddr] = Property(totalProperties,msg.sender,_bAddr,_propType);
    }
    
    function GetBorrowers() public view returns(address[] memory){
        return lenders[msg.sender].borrowersAddress;
    }
    
    function GetProperties() public view returns(address[] memory){
        return lenders[msg.sender].propertyAddress;
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
