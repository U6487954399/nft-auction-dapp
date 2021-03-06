pragma solidity 0.5.11;

//import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol';
//import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol';
//import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/ownership/Ownable.sol';


import './openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';
import './openzeppelin-solidity/contracts/math/SafeMath.sol';
import './openzeppelin-solidity/contracts/ownership/Ownable.sol';

import './NFT.sol';

contract NFTAuction is Ownable, NFT{
    
    using SafeMath for uint;
    
    string  public name;
    string  public ItemDescription;
    address public NFTContractAddress;
    uint256 public NFTID;
    address payable public auction_owner;
    address public highest_bidder;
    uint public highest_bid;
    uint public end_time;
    uint private totalbids;

    

    
    mapping(address => uint) bidovi;
    bool Finalized;

    


    function GetAuctions() public view returns(string memory, string memory, address, uint256, uint256 time) { return (
        
        name,
        ItemDescription, 
        NFTContractAddress,
        NFTID,
        time =end_time - now
        );
    }
    
    
  
    function CreateAuction(string memory _name, string memory _description, uint _time, address  _contractAddress, uint256 _tokenID) public {
        
        NFT NFTInstance = NFT(_contractAddress);
        require (msg.sender == NFTInstance.ownerOf(_tokenID));
        NFTInstance.transferFrom(msg.sender, address(this), _tokenID);


        name = _name;
        ItemDescription = _description;
        NFTID =_tokenID;
        NFTContractAddress = _contractAddress;
        
        auction_owner = msg.sender;
        end_time = now + _time;
    }

    
    modifier IsNotOwner(){
        require(msg.sender != auction_owner);
        _;
        
    }
    
    modifier AuctionEnded(){
        require(now > end_time);
        _;
        
    }

    modifier AuctionActive(){
        require(now < end_time);
        _;
        
    }

    modifier IsNotHighestBidder(){
        require (msg.sender != highest_bidder);
        _;        
    }
    
    function Bid() IsNotOwner AuctionActive public payable {
       
        require (msg.value > 0);

        uint256 newbid = bidovi[msg.sender].add (msg.value);
        require( newbid > highest_bid);

        if (highest_bid != 0) {
            
            bidovi[highest_bidder] += highest_bid;
        }
       
       
        highest_bid = newbid;
        highest_bidder = msg.sender;
	totalbids++;        

    }

    
    function Withdraw() AuctionEnded public returns (bool) {
        
        uint amount = bidovi[msg.sender];
        if (amount != 0) {
            
            bidovi[msg.sender] = 0;
         
            if (!msg.sender.send(amount)) {
               
                bidovi[msg.sender] = amount;
                return false;
            }
        }
        
        return true;
    }

    
    function EndAuction() public {
       
        require (msg.sender == auction_owner || msg.sender == highest_bidder);
        require(now > end_time);
        require(!Finalized);
     
        if(totalbids != 0){
        NFT NFTInstance = NFT(NFTContractAddress);
        NFTInstance.transferFrom(address(this), highest_bidder, NFTID);
        auction_owner.transfer(highest_bid);
        }
        else if (totalbids == 0){
        NFT NFTInstance = NFT(NFTContractAddress);
        NFTInstance.transferFrom(address(this),auction_owner, NFTID);
        }
        
        
        
        
        Finalized = true;
        
       
    }}
