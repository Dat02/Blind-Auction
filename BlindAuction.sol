pragma solidity 0.8.7;

/* 
- Bid: 
+ trong khoảng thời gian bid
+ giá >= highestBid
+ bid >0

- withdraw: 
+ amount >0
+ update so tien sau withdraw

- endAution:
+ thơi gian > sau khi ket thuc
+ chuyển tiền
*/

contract BlindAuction{


    uint public startAuctionTime;
    uint public EndAuctionTime;

    address public highestBidder;
    uint private highestBid;
    address payable beneficiary;

    mapping (address => uint) refund;
    mapping (address => Bid[]) bids;

    event highestBidIncrease(address bidder, uint amount);
    event EndedAuction(address winner, uint benifit);

   struct Bid{
       string data;
       uint deposit;
    }

    constructor(address payable _beneficiary, uint _timeBinding){
        beneficiary = _beneficiary;
        EndAuctionTime = startAuctionTime + _timeBinding;
    } 

    modifier inBiddingTime(uint timestamp){
        require(timestamp < EndAuctionTime,"auction has ended");
        _;
    }

    modifier afterBidingTime(uint timestamp){
        require(timestamp >= startAuctionTime,"auction has not ended");
        _;
    }


    function SubmitBid(string memory _data) external payable inBiddingTime(block.timestamp){
        require(msg.value >= highestBid,"Not enough money");
        bids[msg.sender].push(Bid(_data,msg.value));

        if (highestBid!=0) {
            // khi co 1 highestBider khac, nguoi truoc do se duoc refund
            refund[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit highestBidIncrease(highestBidder, highestBid);
    }

    function Withdraw() external returns (bool){

        uint256 amount = refund[msg.sender];
        if(amount > 0){
            refund[msg.sender] = 0;
            if(!payable(msg.sender).send(amount)){
                refund[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function EndAution() external afterBidingTime(block.timestamp){
        emit EndedAuction(highestBidder, highestBid);
        selfdestruct(beneficiary);// transfer and destructContract
    }



}
