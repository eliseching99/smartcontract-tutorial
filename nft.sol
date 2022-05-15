pragma solidity ^0.8.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@1001-digital/erc721-extensions/contracts/RandomlyAssigned.sol";

// EliseCash Edition ERC721 

// Calling mint mints a random CHACHING NFT until 15 have been minted
// Mint costs 0.0003 Ether ($1)
// 5 Kept for artist, developer & giveaways

// EliseCash

contract TestEliseCash is ERC721, Ownable, RandomlyAssigned {
  using Strings for uint256;
  bool public paused = false;
  bool public onlyWhitelisted = true;
  uint256 public currentSupply = 0;  
  uint256 public maxSupply = 15;
  uint256 public nftPerAddressLimit = 3;
  uint256 public maxMintAmount = 3;
  uint256 public cost = 0.0003 ether;
  mapping(address => bool) public whitelistedAddresses;
  mapping(address => uint256) public addressMintedBalance;
  
  string public baseURI = "https://gateway.pinata.cloud/ipfs/QmXrSwUxeX21zgWExkTUC3EuiHya5WY5Dk63ySMgfiTvqR";

  constructor() 
    ERC721("Elise Ching", "CHING")
    RandomlyAssigned(15,1) // Max. 15 NFTs available; Start counting from 1 (instead of 0) 
    {
       mint(5);
    }

  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  // in solidity, payable is to specify that an address or a function can receive Ether.
  function mint (uint256 _mintAmount)
      public
      payable
  {
      require(!paused, "the contract is paused");
      require( tokenCount() + 1 <= totalSupply(), "YOU CAN'T MINT MORE THAN MAXIMUM SUPPLY");
      require( availableTokenCount() - 1 >= 0, "YOU CAN'T MINT MORE THAN AVALABLE TOKEN COUNT"); 
      require( tx.origin == msg.sender, "CANNOT MINT THROUGH A CUSTOM CONTRACT");

      //if the person who mints is not the owner, check if only whitelisted is set to true
      // if yes, check if user is whitelisted 
      // check if the current minted amount of the person who mints + the amount he wants to mint has exceeded the nft per address limit
      
      // The msg. sender is the address that has called or initiated a function
      if (msg.sender != owner()) {
        if(onlyWhitelisted == true) {
            require(isWhitelisted(msg.sender), "user is not whitelisted");
            uint256 ownerMintedCount = addressMintedBalance[msg.sender];
            // only during whitelisting presale period, will we check that users can only mint the maximum limit we have set
            require(ownerMintedCount + _mintAmount <= nftPerAddressLimit, "max NFT per address exceeded");
        }
        require(msg.value >= cost * _mintAmount, "insufficient funds"); // to check if the received amount exceeds the cost 
    }
    
    for (uint256 i = 1; i <= _mintAmount; i++) {
        //get the next token Randomly
        uint256 id = nextToken();
        //Internal function of ECR721 to safely mint a new token.
        _safeMint(msg.sender, id);
        //make sure to increment the current supply
        currentSupply++;
        addressMintedBalance[msg.sender]++;
    }

  }

  // we dont like using for loops is bad when list is large
  // complexity O(N)
  // function isWhitelisted(address _user) public view returns (bool) {
  //   for (uint i = 0; i < whitelistedAddresses.length; i++) {
  //     if (whitelistedAddresses[i] == _user) {
  //         return true;
  //     }
  //   }
  //   return false;
  // }
  function isWhitelisted(address _user) public view returns(bool){
    if (whitelistedAddresses[_user]){
      return true;
    }
    return false;
  }



  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistant token"
    );

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), ".json"))
        : "";
  }
  
  function withdraw() public payable onlyOwner {
    require(payable(msg.sender).send(address(this).balance));
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setNftPerAddressLimit(uint256 _limit) public onlyOwner {
    nftPerAddressLimit = _limit;
  }

  function setOnlyWhitelisted(bool _state) public onlyOwner {
    onlyWhitelisted = _state;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }

  //Inputs: takes in list of addresses
  // 
  // function whitelistUsers(address[] calldata _users) public onlyOwner {
  //   delete whitelistedAddresses;
  //   whitelistedAddresses = _users;
  // }
  function whitelistUsers(address[] calldata _users) public onlyOwner {
    for (uint i=0; i<_users.length; i++) {
        whitelistedAddresses[_users[i]] = true;
        }
    } 
  
  function removeUsersFromWhiteList(address[] calldata _users) public onlyOwner {
  for (uint i=0; i<_users.length; i++) {
      whitelistedAddresses[_users[i]] = false;
      }
  } 





}

// ["address1","address2"]