pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Storage is ERC20,Ownable(msg.sender) {
    struct WhitelistEntry{ 
        uint256 allowedAmount ;
        uint256 purchasedAmount ;
        uint256 price ;
    }
    mapping (address => WhitelistEntry) public whitelist ;
    bool public saleActive= false ;
    event whitelistUpdated (address indexed account , uint256 allowedAmount , uint256 price ) ;
    event tokenPurchased (address indexed buyer, uint256 mount , uint cost);

    constructor() ERC20("DARKK" , "DAX"){
        _mint(msg.sender, 10000*10**18 ) ;
    }

    modifier onlyWhitelisted(){
        require(whitelist[msg.sender].allowedAmount>0 , "Dont token for account") ;
        _;
    }

    function setWhitelist(address account , uint256 allowedAmount , uint256 price ) external onlyOwner{
        whitelist[account] = WhitelistEntry({
            allowedAmount : allowedAmount ,
            purchasedAmount : 0  ,
            price : price 
        }) ;
        emit whitelistUpdated(account, allowedAmount, price);
    }  

    function removeAccount (address account ) external onlyOwner {
        delete whitelist[account] ;
        emit whitelistUpdated(account, 0, 0);
    }
    function setSaleActive(bool active) external onlyOwner{
        saleActive = active ;
    }
    function buyTokens (uint256 amount) external payable onlyWhitelisted(){
        require(saleActive , "sale is not active" ) ;
        WhitelistEntry storage entry = whitelist[msg.sender] ;
        require(entry.purchasedAmount + amount <= entry.allowedAmount , "qua gioi han co the mua") ;
        uint256 cost = amount*entry.price ;
        require(msg.value>= cost ,"khong du ether");
        entry.purchasedAmount +=amount ;
        _transfer(owner() , msg.sender , amount*10**18);
        if (msg.value >cost ){
            payable(msg.sender).transfer(msg.value-cost);
        }
        emit tokenPurchased(msg.sender, amount, cost);

    }
    function withDraw() external onlyOwner{
        payable(owner()).transfer(address(this).balance) ;
    }

}