// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../../lib/NomiconTest.sol";
import "../../finance/InitializablePaymentSplitter.sol";
import "../../EIP1967/BasicEIP1967Proxy.sol";

contract EIP1967ProxyInitializeTest is NomiconTest {
    PaymentSplitter public splitterImplementation;
    BasicEIP1967Proxy public proxy;
    address alice;
    address bob;

    function setUp() public {
        splitterImplementation = new PaymentSplitter();
        splitterImplementation.freezeImplementation();

        alice = account("alice");
        bob = account("bob");
        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);

        address[] memory payees = new address[](2);
        payees[0] = alice;
        payees[1] = bob;
        uint256[] memory shares = new uint256[](2);
        shares[0] = 1;
        shares[1] = 1;

        proxy =
        new BasicEIP1967Proxy(address(this), address(splitterImplementation), abi.encodeWithSignature("initialize(address[],uint256[])", payees, shares));

        vm.label(address(proxy), "Proxy Splitter");
        vm.label(address(splitterImplementation), "Splitter implementation");
    }

    function test_initialize() public {
        (, bytes memory proxyInitializedData) = address(proxy).call(abi.encodeWithSignature("isInitialized()"));
        uint8 proxyInitializationStatus = uint8(uint256(bytes32(proxyInitializedData)));
        uint8 implementationStatus = splitterImplementation.isInitialized();

        assert(proxyInitializationStatus == 1);
        assert(implementationStatus == 255);
    }
}
