// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address ScarlettMarketPlace;
    event NFTMinted(uint);

    constructor(address _ScarlettMarketPlace) ERC721("MyNFT", "MT") {
        ScarlettMarketPlace = _ScarlettMarketPlace;
    }

    function mint(string memory _tokenURI) public {
        _tokenIds.increment();
        uint newTokenId = _tokenIds.current();
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);
        setApprovalForAll(ScarlettMarketPlace, true);
        emit NFTMinted(newTokenId);
    }
}
