// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;
/*

*     * * *      *   *       *      *      * *   * * * * *
* *   *        *     * *   * *    *   *    *  *      *
*  *  * *     *      *   *   *   * * * *   * *       *
* *   *        *     *       *  *       *  *  *      *
*     * * *      *   *       * *         * *   *     *

*/

contract DecMark{
    using SafeMath for uint256;
    
    uint256 SECURITY_DEPOSIT = 0.01 ether;
    uint256 TAX_RATE = 2;    // 2%
    uint256 JUDGE_FEE = 0.1 ether;
    address judge;
    uint256 savingWallet;
    uint256 totalSellers;
    uint256 totalBuyers;
    uint256 totalItems;
    
    /*
    1 -> adhaar
    2 -> pancard
    3 -> voterId
    4 -> passport
    */
    struct Product{
        uint256 pid;
        string name;
        uint256 price;
        address owner;
        bool isExist;
        bool isPurchased;
    }
    
    struct Seller{
        uint256 sid;
        uint256 identityNumber;
        uint256 identityType;
        uint256 totalItemsSelled;
        uint256 rating;
        bool isExist;
    }
    
    struct Buyer{
        uint256 bid;
        uint256[] totalItemsPurchased;
        bool isExist;
    }
    
    mapping(address=>Seller) public sellers;
    mapping(address=>Buyer) public buyers;
    mapping(uint256=>Product) public products;
    
    constructor(){
        judge = msg.sender;
    }
    
    modifier onlySeller{
        require(sellers[msg.sender].isExist);
        _;
    }
    modifier onlyBuyer{
        require(buyers[msg.sender].bid>0);
        _;
    }
    modifier onlyJudge{
        require(msg.sender==judge);
        _;
    }
    
    function RegisterAsSeller(uint256 _identityNumber, uint256 _identityType) public payable{
        require(msg.value>=SECURITY_DEPOSIT,"You must pay security amount");
        require(!sellers[msg.sender].isExist,"Seller already exist");
        sellers[msg.sender] = Seller({
            sid:totalSellers.add(1),
            identityNumber:_identityNumber,
            identityType:_identityType,
            totalItemsSelled:0,
            rating:0,
            isExist:true
        });
        totalSellers = totalSellers.add(1);
    }
    
    function RegisterAsBuyer() public{
        require(!buyers[msg.sender].isExist==true, "Buyer already exist");
        buyers[msg.sender]=Buyer({
            bid:totalBuyers.add(1),
            totalItemsPurchased:buyers[msg.sender].totalItemsPurchased,
            isExist:true
        });
        totalBuyers = totalBuyers.add(1);
    }
    
    function AddItem(string memory _name, uint256 _price) public onlySeller(){
        totalItems = totalItems.add(1);
        products[totalItems] = Product({
           pid:totalItems,
           name:_name,
           price:_price,
           owner:msg.sender,
           isExist:true,
           isPurchased:false
        });
    }
    
    function UpdateItem(uint256 _itemId,uint256 _price, string calldata _name, address _owner) public onlySeller(){
        require(products[_itemId].isExist,"Item not exist");
        require(products[_itemId].owner == msg.sender);
        products[_itemId].price = _price;
        products[_itemId].owner = _owner;
        products[_itemId].name = _name;
    }
    
    function DeleteItem(uint256 _itemId) public onlySeller(){
        require(products[_itemId].isExist,"Item not exist");
        require(products[_itemId].owner == msg.sender);
        delete(products[_itemId]);
        totalItems = totalItems.sub(1);
    }
    
    function PurchaseItem(uint256 _itemId) public onlyBuyer(){
        
    }
    
    function RaiseDispute() public payable onlyBuyer(){
        
    }
    
    function WithdrawAmountBySeller() public onlySeller(){
        
    }
    
    function WithdrawAmountByBuyer() public onlyBuyer(){
        
    }
    
    function WithdrawAmountByJudge() public onlyJudge(){
        
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
