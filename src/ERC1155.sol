// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {IERC1155} from "./IERC1155.sol";
import {IERC1155TokenReceiver} from "./IERC1155Receiver.sol";

// ERC1155 doesnt natively have mint and burn functions
contract ERC1155 is IERC1155 {

    //////////////////////////////
    //////// ERRORS //////////////
    //////////////////////////////
    error ERC1155__ZeroAddress();
    error ERC1155__CallBackFailed();
    error ERC1155__IncorrectArraySIzesForTokenTransfer();

    //////////////////////////////
    //////// EVENTS //////////////
    //////////////////////////////

    event TransferSingle(address indexed Operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(
        address indexed Operator, address indexed from, address indexed to, uint256[] ids, uint256[] values
    );
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);

    //////////////////////////////
    //// STATE VARIABLES /////////
    //////////////////////////////

    // used to keep track of the balances 
    mapping(address => mapping(uint256 => uint256)) private _balanceOf;

    // used to keep track of the approvals 
    mapping(address => mapping(address => bool)) private _IsApprovedForAll;



    //////////////////////////////
    /////// FUNCTIONS ////////////
    //////////////////////////////

    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes calldata data) external {}

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external {}

    function balanceOf(address owner, uint256 id) external view returns (uint256) {
        return _balanceOf[owner][id];
    }

    function balanceOfBatch(address[] calldata owners, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory)
    {}

    function setApprovalForAll(address operator, bool approved) external {}

    function isApprovedForAll(address owner, address operator) external view returns (bool) {
        return _IsApprovedForAll[owner][operator];
    }

    // this is function is used to verify if the EIP is followed and used a measure to tell other contracts 
    // that the below token EIPs are supported 
    function supportsInterface(bytes4 interfaceId)
        external
        pure
        returns (bool)
    {
        return interfaceId == 0x01ffc9a7 // ERC165 Interface ID for ERC165
            || interfaceId == 0xd9b67a26 // ERC165 Interface ID for ERC1155
            || interfaceId == 0x0e89341c; // ERC165 Interface ID for ERC1155MetadataURI
    }

    // ERC1155 Metadat URI 
    function uri(uint256 id) public view virtual returns (string memory) {}

    // this is not part of the EIP but we are declaring to use it in our token 
    function _mint(address to, uint256 id, uint256 amountToMint, bytes memory data) internal {
        if (to == address(0)) {
            revert ERC1155__ZeroAddress();
        }

        _balanceOf[to][id] += amountToMint;

        emit TransferSingle(msg.sender, address(0), to, id , amountToMint);

        if (to.code.length > 0) {
            if (IERC1155TokenReceiver(to).onERC1155Received(
                msg.sender,
                address(0),
                id,
                amountToMint,
                data
            ) != IERC1155TokenReceiver.onERC1155Received.selector) {
                revert ERC1155__CallBackFailed();
            }
        }
    }


    function _batchmint(address to, uint256[] calldata ids, uint256[] calldata amountsToMint, bytes memory data) 
    internal {
        if (to == address(0)) {
            revert ERC1155__ZeroAddress();
        }

        uint256 arrayLenOfIDs = ids.length;

        if (arrayLenOfIDs != amountsToMint.length) {
            revert ERC1155__IncorrectArraySIzesForTokenTransfer();
        }

        for(uint256 i = 0; i < arrayLenOfIDs; i++) {
            _balanceOf[to][ids[i]] += amountsToMint[i];
        }   

        emit TransferBatch(msg.sender, address(0), to, ids, amountsToMint);

        if (to.code.length > 0) {
            if (IERC1155TokenReceiver(to).onERC1155BatchReceived(
                msg.sender,
                address(0),
                ids,
                amountsToMint,
                data
            ) != IERC1155TokenReceiver.onERC1155BatchReceived.selector) {
                revert ERC1155__CallBackFailed();
            }
        }
    }

}

// using this handle to add the extra functionality of minting and burning tokens
contract MyMultiToken is ERC1155 {
    function mint(uint256 id, uint256 value, bytes calldata data) external {}

    function batchMint(uint256[] calldata ids, uint256[] calldata values, bytes calldata data) external {}

    function burn(uint256 id, uint256 value) external {}

    function batchBurn(uint256[] calldata ids, uint256[] calldata values) external {}
}
