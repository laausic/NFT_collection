// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CroatianPixels is ERC721, ERC721Enumerable, ERC721Pausable, Ownable {
    
    uint256 private _nextTokenId = 1;
    uint256 public maxSupply = 15;

    bool public publicMintOpen = false;
    bool public allowListMintOpen = false;

    mapping(address => bool) public allowList;

    // Events
    event NFTMinted(address indexed minter, uint256 tokenId);
    event FundsWithdrawn(address indexed owner, uint256 amount);

    constructor(address initialOwner)
        ERC721("CroatianPixels", "CROP")
        Ownable(initialOwner)
    {}

    /**
     * @dev Returns the base URI for metadata.
     */
    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://Qmf6k1f2suxKNQsXGqWKZ3NxEgzQMNiCi5rNDUaB4YAaA3/";
    }

    /**
     * @dev Pauses all contract operations.
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @dev Resumes all contract operations.
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @dev Updates the minting windows.
     */
    function editMintWindow(bool _publicMintOpen, bool _allowListMintOpen) external onlyOwner {
        publicMintOpen = _publicMintOpen;
        allowListMintOpen = _allowListMintOpen;
    }

    /**
     * @dev Allows allowlist addresses to mint during the allowlist window.
     */
    function allowListMint() public payable {
        require(allowListMintOpen, "Allowlist mint is closed");
        require(allowList[msg.sender], "You are not on the allowlist");
        require(msg.value >= 0.0001 ether, "Insufficient funds");
        internalMint();
    }

    /**
     * @dev Allows public users to mint during the public minting window.
     */
    function publicMint() public payable {
        require(publicMintOpen, "Public mint is closed");
        require(msg.value >= 0.001 ether, "Insufficient funds");
        internalMint();
    }

    /**
     * @dev Handles the actual minting process.
     */
    function internalMint() internal {
        require(totalSupply() < maxSupply, "All NFTs have been minted");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
        emit NFTMinted(msg.sender, tokenId); // Emit event after minting
    }

    /**
     * @dev Allows the contract owner to withdraw funds.
     */
    function withdraw(address _address) external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(_address).transfer(balance);
        emit FundsWithdrawn(_address, balance); // Emit event after withdrawal
    }

    /**
     * @dev Populates the allowlist with addresses.
     */
    function setAllowList(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            allowList[addresses[i]] = true;
        }
    }

    // Overrides for compatibility with multiple OpenZeppelin extensions
    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Ensures only the owner can perform restricted actions.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }
}
