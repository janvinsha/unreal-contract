// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract UnrealMarket is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;
        Counters.Counter private _collectionIds;

    uint256 listingPrice = 0.025 ether;
    address payable owner;

    mapping(uint256 => MarketItem) private idToMarketItem;
   mapping(uint256 => address) private whitelist;
   
    mapping(uint256 => Collection) private collections;

    mapping(address => Profile) private profiles;

struct Profile{
     address profileId;
    string banner;
    string dp;
    string name;
      string bio;
}

    event ProfileEdited (
   address profileId,
    string banner,
    string dp,
    string name,
      string bio
    );

      event ProfileCreated (
   address profileId,
    string banner,
    string dp,
    string name,
      string bio
    );
struct Collection{
      uint256 collectionId;
    string banner;
    string dp;
    address owner;
    string name;
    uint256 totalSupply;
    uint256 noHolders;
    string description;
     string[] tags;
}

event CollectionCreated (
    uint256 indexed collectionId,
    string banner,
    string dp,
    address owner,
    string name,
    uint256 totalSupply,
    uint256 noHolders,
    string description,
     string[] tags
);

    struct MarketItem {
      uint256 tokenId;
      address payable seller;
      address payable owner;
      uint256 price;
      bool sold;
      string collection;
      string name;
      string image;
      string category;
      string description;
      string[] tags;
    }

    event MarketItemCreated (
      uint256 indexed tokenId,
      address seller,
      address owner,
      uint256 price,
      bool sold,
      string collection,
       string name,
       string image,
      string category,
      string description,
      string[] tags
    );

    constructor() ERC721("Unreal Market", "UTT") {
      owner = payable(msg.sender);
    }

    /* Updates the listing price of the contract */
    function updateListingPrice(uint _listingPrice) public payable {
      require(owner == msg.sender, "Only marketplace owner can update listing price.");
      listingPrice = _listingPrice;
    }

    /* Returns the listing price of the contract */
    function getListingPrice() public view returns (uint256) {
      return listingPrice;
    }

function createCollection(string memory banner,
string memory dp,
string memory name,
string memory description,
     string[] memory tags
) public payable{
    require(msg.value == listingPrice, "Price must be equal to listing price");

   _collectionIds.increment();
      uint256 newCollectionId = _collectionIds.current();

     collections[newCollectionId] =  Collection(
        newCollectionId,
        banner,
        dp,
        msg.sender,
        name,
        0,
        0,
       description,tags
    );
      }

    function fetchCollections() public view returns (Collection[] memory) {
      uint collectionCount = _collectionIds.current();
      uint currentIndex = 0;
      Collection[] memory tempCollections = new Collection[](collectionCount);
      for (uint i = 0; i < collectionCount; i++) {
          uint currentId = i + 1;
          Collection memory currentCollection = tempCollections[currentId];
          tempCollections[currentIndex] = currentCollection;
          currentIndex += 1;
      }
      return tempCollections;
    }
     function fetchCollectionsOfAddress() public view returns (Collection[] memory) {
      uint collectionCount = _collectionIds.current();
      uint currentIndex = 0;
      Collection[] memory tempCollections = new Collection[](collectionCount);
      for (uint i = 0; i < collectionCount; i++) {
          if(collections[i + 1].owner == msg.sender){
          uint currentId = i + 1;
          Collection memory currentCollection = tempCollections[currentId];
          tempCollections[currentIndex] = currentCollection;
          currentIndex += 1;
          }
      }
      return tempCollections;
    }

     function fetchCollection(uint256 id) public view returns (Collection memory) {
      return collections[id];
    }


function editProfile(
    string memory banner,
string memory dp,
string memory name,
string memory bio
) public{
   profiles[msg.sender].banner=banner;
   profiles[msg.sender].dp=dp;
   profiles[msg.sender].name=name;
    profiles[msg.sender].bio=bio;
    emit ProfileEdited(
        msg.sender,
        banner,
        dp,
        name,
        bio
    );
}

function createProfile(
    string memory banner,
string memory dp,
string memory name,
string memory bio
) public{
  profiles[msg.sender] =Profile(
        msg.sender,
        banner,
        dp,
        name,
        bio
    );
    emit ProfileCreated(
        msg.sender,
        banner,
        dp,
        name,
        bio
    );
}


function getProfile(address id) public view returns(Profile memory){
    return profiles[id];
}


    /* Mints a token and lists it in the marketplace */
    function createToken(string memory tokenURI, uint256 price,string memory collection,
     string memory name,
     string memory image,
      string memory category,
      string memory description,
      string[] memory tags
    ) public payable returns (uint) {
      _tokenIds.increment();
      uint256 newTokenId = _tokenIds.current();

      _mint(msg.sender, newTokenId);
      _setTokenURI(newTokenId, tokenURI);
      createMarketItem(newTokenId, price,collection,  name,image,
      category,
      description,
      tags);
      return newTokenId;
    }

    function createMarketItem(
      uint256 tokenId,
      uint256 price,
      string memory collection,
       string memory name,
       string memory image,
      string memory category,
      string memory description,
      string[] memory tags
    
    ) private {
      require(price > 0, "Price must be at least 1 wei");
      require(msg.value == listingPrice, "Price must be equal to listing price");

      idToMarketItem[tokenId] =  MarketItem(
        tokenId,
        payable(msg.sender),
        payable(address(this)),
        price,
        false,
     collection,
        name,
        image,
      category,
      description,
      tags
      );

      _transfer(msg.sender, address(this), tokenId);
      emit MarketItemCreated(
        tokenId,
        msg.sender,
        address(this),
        price,
        false,
       collection,
         name,
         image,
      category,
      description,
      tags
      );
    }

    /* allows someone to resell a token they have purchased */
    function resellToken(uint256 tokenId, uint256 price) public payable {
      require(idToMarketItem[tokenId].owner == msg.sender, "Only item owner can perform this operation");
      require(msg.value == listingPrice, "Price must be equal to listing price");
      idToMarketItem[tokenId].sold = false;
      idToMarketItem[tokenId].price = price;
      idToMarketItem[tokenId].seller = payable(msg.sender);
      idToMarketItem[tokenId].owner = payable(address(this));
      _itemsSold.decrement();

      _transfer(msg.sender, address(this), tokenId);
    }

    /* Creates the sale of a marketplace item */
    /* Transfers ownership of the item, as well as funds between parties */
    function createMarketSale(
      uint256 tokenId
      ) public payable {
      uint price = idToMarketItem[tokenId].price;
      address seller = idToMarketItem[tokenId].seller;
      require(msg.value == price, "Please submit the asking price in order to complete the purchase");
      idToMarketItem[tokenId].owner = payable(msg.sender);
      idToMarketItem[tokenId].sold = true;
      idToMarketItem[tokenId].seller = payable(address(0));
      _itemsSold.increment();
      _transfer(address(this), msg.sender, tokenId);
      payable(owner).transfer(listingPrice);
      payable(seller).transfer(msg.value);
    }

    /* Returns all unsold market items */
    function fetchMarketItems() public view returns (MarketItem[] memory) {
      uint itemCount = _tokenIds.current();
      uint unsoldItemCount = _tokenIds.current() - _itemsSold.current();
      uint currentIndex = 0;

      MarketItem[] memory items = new MarketItem[](unsoldItemCount);
      for (uint i = 0; i < itemCount; i++) {
        if (idToMarketItem[i + 1].owner == address(this)) {
          uint currentId = i + 1;
          MarketItem storage currentItem = idToMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }

    /* Returns only items that a user has purchased */
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
      uint totalItemCount = _tokenIds.current();
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].owner == msg.sender) {
          itemCount += 1;
        }
      }

      MarketItem[] memory items = new MarketItem[](itemCount);
      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].owner == msg.sender) {
          uint currentId = i + 1;
          MarketItem storage currentItem = idToMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }

    /* Returns only items a user has listed */
    function fetchItemsListed() public view returns (MarketItem[] memory) {
      uint totalItemCount = _tokenIds.current();
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].seller == msg.sender) {
          itemCount += 1;
        }
      }

      MarketItem[] memory items = new MarketItem[](itemCount);
      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].seller == msg.sender) {
          uint currentId = i + 1;
          MarketItem storage currentItem = idToMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }
}