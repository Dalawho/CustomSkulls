// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "openzeppelin/access/Ownable.sol";
import { Strings} from "openzeppelin/utils/Strings.sol";
import { Base64 } from "solady/utils/Base64.sol";
import 'ethier/utils/DynamicBuffer.sol';
import {SharedStructs as SSt} from "./sharedStructs.sol";
import "./interfaces/IIndelible.sol";

contract SkullsRender is Ownable, SSt {
    using Strings for uint256;
    using DynamicBuffer for bytes;

    string[6] layerNames = ["5p3c141", "0v32", "3y35", "und32", "5ku115", "84ck920und"];

    //Non indelible collections that need special treatment are here 
    IIndelible skulls = IIndelible(0x9251dEC8DF720C2ADF3B6f46d968107cbBADf4d4); // add addres
    
    ////////////////////////  Setters /////////////////////////////////

    function setSkulls( address _newSkulls) external onlyOwner {
        skulls = IIndelible(_newSkulls);
    }

    ////////////////////////  Trait Data functions functions /////////////////////////////////

    function getTraitDetails(uint8 _layerId, uint8 _traitId) public view returns(IIndelible.Trait memory) {
        return skulls.traitDetails(_layerId, _traitId);
    }

    // returns the base64 encoded layer including mimetype 
    function getTraitData(uint8 _layerId, uint8 _traitId) public view returns(string memory) { 
        IIndelible.Trait memory _traitDetails = getTraitDetails(_layerId, _traitId);
        string memory _dataType = string.concat('data:',_traitDetails.mimetype,';base64,');
        return string.concat(_dataType,Base64.encode(bytes(skulls.traitData(_layerId, _traitId))));
    }

    ////////////////////////  TokenURI and preview /////////////////////////////////

    function _traitJSON(SSt.OwnerStruct memory _data) internal view returns(string memory _outString) {
        uint8[6] memory _traits = [_data.special, _data.over, _data.eyes, _data.under, _data.skull, _data.background];
        bool addComma;
        for(uint i; i < 6; ++i) {
            if(_traits[i] == 0) continue;
            if(addComma) _outString = string.concat(_outString, ",");
            _outString = string.concat(_outString, '{"trait_type":"', layerNames[i], '","value":"', getTraitDetails(uint8(i), _traits[i]-1).name , '"}');
            addComma = true;
        }
        _outString = string.concat(_outString, ']');
    }

    function tokenURI(uint256 tokenId, SSt.OwnerStruct memory _data) external view returns (string memory) { 
        string memory _outString = string.concat('data:application/json,', '{', '"name" : "CustomSkulls ' , Strings.toString(tokenId), '", ',
            '"description" : "1337"');
        
        _outString = string.concat(_outString, ',"attributes":[');
        _outString = string.concat(_outString, _traitJSON(_data));

        _outString = string.concat(_outString,',"image": "data:image/svg+xml;base64,', Base64.encode(_drawTraits(_data)), '"');

        _outString = string.concat(_outString,'}');
        return _outString; 
    }

    function previewCollage(SSt.OwnerStruct memory _data) external view returns(string memory) {
        return(string(_drawTraits(_data)));
    }

    ////////////////////////  SVG functions /////////////////////////////////

    function _drawTraits(SSt.OwnerStruct memory _data) internal view returns(bytes memory) {
        bytes memory buffer = DynamicBuffer.allocate(2**23);
        uint8[6] memory _traits = [_data.special, _data.over, _data.eyes, _data.under, _data.skull, _data.background];
        buffer.appendSafe('<svg width="1200" height="1200" viewBox="0 0 1200 1200" version="1.2" xmlns="http://www.w3.org/2000/svg" style="background-color:transparent;background-image:url(');
        bool drawURL;
        for(uint256 i = 0; i < _traits.length; i++) {
            if(_traits[i] == 0) continue;
            if(drawURL) buffer.appendSafe('),url(');
            buffer.appendSafe(bytes(getTraitData(uint8(i), _traits[i]-1)));
            drawURL = true;
        }
        buffer.appendSafe(');background-repeat:no-repeat;background-size:contain;background-position:center;image-rendering:-webkit-optimize-contrast;-ms-interpolation-mode:nearest-neighbor;image-rendering:-moz-crisp-edges;image-rendering:pixelated;"></svg>');
        return buffer;
    }

}
