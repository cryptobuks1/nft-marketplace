// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract ArtSeaMarket {
    using Counters for Counters.Counter;
    struct Auction {
        address payable ownerAddress;
        address tokenAddress;
        uint tokenId;
        uint minBidAmount;
        uint highestBidAmount;
        address payable highestBidder;
        bool ended;
        bool sold;
    }

    Counters.Counter auctionIds;
    Auction[] auctions;

    function submitAuction(
        address tokenAddress,
        uint tokenId,
        uint minBidAmount
    ) public returns (uint) {
        IERC721 token = IERC721(tokenAddress);
        address tokenOwner = token.ownerOf(tokenId);
        require(tokenOwner == msg.sender, "You do not own the NFT");

        Auction memory newAuction = Auction({
            ownerAddress: payable(msg.sender),
            tokenAddress: tokenAddress,
            tokenId: tokenId,
            minBidAmount: minBidAmount,
            highestBidAmount: 0,
            highestBidder: payable(0),
            ended: false,
            sold: false
        });
        uint newAuctionId = auctionIds.current();
        auctions.push(newAuction);
        return newAuctionId;
    }

    function submitBid(uint auctionId) public payable {
        Auction memory auction = auctions[auctionId];
        if (msg.value > auction.highestBidAmount) {
            auction.highestBidder.transfer(auction.highestBidAmount);
            auction.highestBidAmount = msg.value;
            auction.highestBidder = payable(msg.sender);
        }
    }

    function finalizeAuction(uint auctionId, bool accept) public {
        Auction memory auction = auctions[auctionId];

        if (accept) {
            IERC721 token = IERC721(auction.tokenAddress);
            token.safeTransferFrom(
                auction.ownerAddress,
                auction.highestBidder,
                auction.tokenId
            );
            auction.ownerAddress.transfer(auction.highestBidAmount);
            auction.sold = true;
        } else {
            auction.highestBidder.transfer(auction.highestBidAmount);
            auction.sold = false;
        }
        auction.ended = true;
    }
}
