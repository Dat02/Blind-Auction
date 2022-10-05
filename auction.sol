pragma solidity >=0.7.11;

/*
    Bid:
    - Thoi gian dau gia con hoat dong
    - Gia ttri dat no phai lon hon GTLN tai thoi diem do
    - Bid !=0
    Withdraw:
    - amount> 0
    - rut amount = bid
    - after send = 0
    auctionEnd
    - Khi nao ket thuc phien dau gia
    - su kien transfer
*/

contract BlindAuction {
    // variables
    address payable public beneficiary;
    uint256 public auctionEndTime;

    uint256 private highestBid;
    address private highestBidder;

    bool ended = false;

    // Allowed withdrawals of previous bids
    mapping(address => uint256) public pendingReturns;

    event highestBidIncrease(address bidder, uint256 amount);
    event auctionEnded(address winner, uint256 amount);

    modifier onlyAfter(uint _time) 
    {require(block.timestamp > _time);
        _;}
    constructor(uint256 _biddingTime, address payable _beneficiary){
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp+_biddingTime;
    }
    //functions
    function bid() public payable{
        if(block.timestamp > auctionEndTime){
            revert("Phien dau gia ket thuc");
        }
        if(msg.value<=highestBid){
            revert("Gia cua ban thap hon gia cao nhat");
        }
        if(highestBid!=0){
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit highestBidIncrease(msg.sender, msg.value);
    }
    function withdraw() public returns(bool) {
        uint256 amount = pendingReturns[msg.sender];
        if(amount > 0){
            pendingReturns[msg.sender] = 0;
            if(!payable(msg.sender).send(amount)){
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }
      function auctionEnd() public{
        if(ended){
            revert("Phien dau gia da co the ket thuc");
        }
        if(block.timestamp < auctionEndTime){
            revert("Phien dau gia chua ket thuc");
        }
        ended = true;
        emit auctionEnded(highestBidder, highestBid);
        // transfer
        beneficiary.transfer(highestBid);
    }
    function reveal()  public view returns (uint256){
            require(ended , "Phien dau gia chua ket thuc");
            require(msg.sender == beneficiary, "Chi co ng to chuc moi xem duoc");
            return highestBid;
    }
}