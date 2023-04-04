// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ScarlettMarketPlace is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _nftCount;
    Counters.Counter private _nftsSold;
    uint public minFloorPrice = 1 ether;
    address payable private _marketOwner;

    mapping(uint => NFT) private idToNFT;

    struct NFT {
        address nftContract;
        uint tokenId;
        address seller;
        address payable owner;
        uint price;
        bool listed;
    }

    constructor() {
        _marketOwner = payable(msg.sender);
    }

    //List  nft on marketplace
    function listNft(
        address _nftContract,
        uint _tokenId,
        uint _price
    ) public nonReentrant {
        require(_price > 0, "Price cannot be 0");
        require(
            _price > minFloorPrice,
            "price cannot be less tha min floor price"
        );

        IERC721(_nftContract).transferFrom(msg.sender, address(this), _tokenId);
        _nftCount.increment();

        idToNFT[_tokenId] = NFT(
            _nftContract,
            _tokenId,
            msg.sender,
            payable(address(this)),
            _price,
            true
        );
    }

    // Buy nft
    function buyNft(
        address _nftContract,
        uint _tokenId
    ) public payable nonReentrant {
        NFT storage nft = idToNFT[_tokenId];
        require(
            msg.value >= nft.price,
            "buying price cannot be less than selling price"
        );
        address payable buyer = payable(msg.sender);
        payable(nft.seller).transfer(msg.value); //transfer mone to seller
        IERC721(_nftContract).transferFrom(address(this), buyer, nft.tokenId);
        nft.owner = buyer;
        nft.listed = false;

        _nftsSold.increment();
    }

    function getListedNfts() public view returns (NFT[] memory) {
        uint nftCount = _nftCount.current();
        uint unsoldNfts = nftCount - _nftsSold.current();

        NFT[] memory nft = new NFT[](unsoldNfts);
        uint index = 0;
        for (uint i = 0; i < nftCount; i++) {
            if (idToNFT[i + 1].listed) {
                nft[index] = idToNFT[i + 1];
                index++;
            }
        }
        return nft;
    }

    //Resell nft

    function resell(
        address _nftContract,
        uint _tokenId,
        uint _price
    ) public payable nonReentrant {
        require(_price > 0, "selling price cannot be 0");
        require(
            _price > minFloorPrice,
            "price cannot be less tha min floor price"
        );

        IERC721(_nftContract).transferFrom(msg.sender, address(this), _tokenId);
        NFT storage nft = idToNFT[_tokenId];
        nft.seller = msg.sender;
        nft.owner = payable(address(this));
        nft.price = _price;
        nft.listed = true;
    }

    // User functions

    function getMyNfts() public view returns (NFT[] memory) {
        uint nftCount = _nftCount.current();
        uint myNftCount = 0;
        for (uint i = 0; i < nftCount; i++) {
            if (idToNFT[i + 1].owner == msg.sender) {
                myNftCount++;
            }
        }
        NFT[] memory nft = new NFT[](myNftCount);
        uint index = 0;
        for (uint i = 0; i < nftCount; i++) {
            if (idToNFT[i + 1].owner == msg.sender) {
                nft[index] = idToNFT[i + 1];
                index++;
            }
        }
        return nft;
    }

    function getMyListedNfts() public view returns (NFT[] memory) {
        uint nftCount = _nftCount.current();
        uint myListedNfts = 0;
        for (uint i = 0; i < nftCount; i++) {
            if (idToNFT[i + 1].owner == msg.sender && idToNFT[i + 1].listed) {
                myListedNfts++;
            }
        }

        //storing in memory
        NFT[] memory nft = new NFT[](myListedNfts);
        uint index = 0;
        for (uint i = 0; i < nftCount; i++) {
            if (idToNFT[i + 1].owner == msg.sender && idToNFT[i + 1].listed) {
                nft[index] = idToNFT[i + 1];
                index++;
            }
        }
        return nft;
    }
}
