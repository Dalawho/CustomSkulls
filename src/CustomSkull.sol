// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "openzeppelin-upgradable/access/OwnableUpgradeable.sol";
import "./ERC721.sol";
import {SharedStructs as SSt} from "./sharedStructs.sol";
import "openzeppelin-upgradable/proxy/utils/UUPSUpgradeable.sol";
// import "forge-std/console.sol";

interface IRender {
    function tokenURI(uint256 tokenId, SSt.OwnerStruct memory _data) external view returns (string memory); 
    function previewCollage(SSt.OwnerStruct memory _data) external view returns(string memory);
}

/// @title Skullszrender
/// @author OxDala
/// @notice The ERC721 contract allows you to mint custom on-chain NFTs combined from different collections
contract CustomSkull is ERC721, OwnableUpgradeable, UUPSUpgradeable {
    
    // Errors
    error mintNotStarted();
    error tokenDoesNotExist();

    // Variables / Constants
    IRender public render;
    //uint256 public constant MINT_PRICE = 0 ether;
    uint256 public constant MAX_SUPPLY = 3_333; 
    bool public mintActive;

    ////////////////////////  Initializer  /////////////////////////////////

    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __ERC721_init("CustomSkulls", "CS1337", 1);
        __Ownable_init();
        __UUPSUpgradeable_init();
        mintActive = false;
    }

    ////////////////////////  User Functions  /////////////////////////////////

    function mint(uint8 background, uint8 skull, uint8 under, uint8 eyes, uint8 over, uint8 special) external payable {
        if(!mintActive) revert mintNotStarted();
        // if(totalSupply() + 1 > MAX_SUPPLY) revert MaxSupplyReached();
        // if(msg.value < MINT_PRICE) revert payRightAmount();
        _mintAndSet(msg.sender, background, skull, under, eyes, over, special);
    }

    ////////////////////////  Management functions  /////////////////////////////////


    function setMintActive() external onlyOwner {
        mintActive = true;
    }

    function setRender( address _newRender) public onlyOwner {
        render = IRender(_newRender);
    }

    ////////////////////////  TokenURI /////////////////////////////////

    function tokenURI(uint256 tokenId) override public view returns (string memory) { 
        if(tokenId > totalSupply()) revert tokenDoesNotExist();
        SSt.OwnerStruct memory token = _ownerOf[tokenId];
        return render.tokenURI(tokenId, token);
    }

    ////////////////////////  Helper Function  /////////////////////////////////

    function previewToken(uint8 background, uint8 skull, uint8 under, uint8 eyes, uint8 over, uint8 special) external view returns (string memory) { 
        return render.previewCollage(SSt.OwnerStruct(address(0), background, skull, under, eyes, over, special));
    }

    //////////////////////// Withdraw ////////////////////////

    function withdraw() payable public onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}
}