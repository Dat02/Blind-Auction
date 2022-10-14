pragma solidity 0.8.10 ;
// import "./ierc.sol";
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol';
contract Auction {

    IERC20 public immutable token;
    uint public startBiddingTime;
    uint public endBiddingTime;

    uint public startRevealTime;
    uint public endRevealTime;

    uint public highestBid;
    address public highestBidder;

    mapping(address => bytes32) bidInfo;
    mapping (address => bool) bidded;


    address payable beneficiary;
    mapping (address => uint) refund;

    
    constructor(address _token ,address payable _beneficiary, uint _timeBinding, uint _timeBreak, uint _timeReveal){
        
        token = IERC20(_token);
        beneficiary = _beneficiary;
        startBiddingTime = block.timestamp;
        endBiddingTime = startBiddingTime + _timeBinding;
        startRevealTime = endBiddingTime + _timeBreak;
        endRevealTime = startRevealTime + _timeReveal;

    } 

    
    modifier inBiddingTime(uint timestamp){
        require(timestamp < endBiddingTime,"time for bidding has ended");
        _;
    }

    modifier inRevealTime(uint timestamp){
        require(timestamp > startRevealTime && timestamp < endRevealTime,"not valid time");
        _;
    }

    modifier afterRevealTime (uint timestamp){
        require(timestamp > endRevealTime, "cannot end auction");
        _;
    }



    function bid(uint _amount) external inBiddingTime (block.timestamp){
        bytes32 byteCode = getBytesInfo(msg.sender, _amount);
        bidInfo[msg.sender]  = byteCode;
        bidded[msg.sender] = true;
    }

    function getBytesInfo(address _bidder, uint _amount) private pure returns (bytes32) {
        return keccak256(abi.encode(_bidder, _amount));
    }

   
    // function Reveal(uint _amount) external inRevealTime (block.timestamp) {
    //    require (getBytesInfo(msg.sender, _amount) == bidInfo[msg.sender], "bidder's info is invalid");
    //     require (_amount > highestBid, "you bidded not enough money");
    //     highestBid = _amount;
    //     highestBidder = msg.sender;
    //     if (highestBid != 0) refund[highestBidder] = highestBid;
    //     token.transferFrom(msg.sender, address(this), _amount);
    // }
     function Reveal(uint _amount) external inRevealTime (block.timestamp) {
        require (getBytesInfo(msg.sender, _amount) == bidInfo[msg.sender], "bidder's info is invalid");
        // require (_amount > highestBid, "you bidded not enough money");
        if(_amount>=highestBid){
            refund[highestBidder] = highestBid;
            token.transfer(highestBidder, highestBid);
            highestBid = _amount;
            highestBidder = msg.sender;
            
        }
        else {
            refund[msg.sender] = _amount;
            token.transfer(msg.sender, _amount);
        }
    }

    function withdraw() external { 
         uint256 amount = refund[msg.sender];
            if(amount > 0){
            refund[msg.sender] = 0;
            token.transfer(msg.sender, amount);   
            }
    }

    function EndAuction() public afterRevealTime(block.timestamp){
        token.transfer(beneficiary,highestBid);
        highestBid = 0;
        highestBidder = address(0);
    }    

}
