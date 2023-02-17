// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RenderV5.sol";
import "../src/CustomSkull.sol";
import "../src/Proxy.sol";

contract CounterTest is Test {
    CustomSkull cs;
    SkullsRender render;
    CustomSkull wcs;
    UUPSProxy proxy;

    function setUp() public {
        cs = new CustomSkull();
        render = new SkullsRender();

        proxy = new UUPSProxy(address(cs), "");
        wcs = CustomSkull(address(proxy));
        wcs.initialize();
        wcs.setRender(address(render));
        wcs.setMintActive();
    }

    function testMintAndRender() public {
        wcs.mint(0,6,2,4,10,2);
        console.log(wcs.tokenURI(1));
    }
}
