pragma solidity ^0.8.19;

import "@imtbl/contracts/contracts/token/erc721/erc721psi/ERC721PsiBurnable.sol";

contract MyERC721 is ERC721PsiBurnable {
    address public owner;
    address public miner;
    uint256 public mintCap;
    string baseurl;
    error IImmutableERC721ANotOwnerOrOperator(uint256 tokenId);
    error NotOwnerAuthorized();
    error NotMineAuthorized();

    constructor(
        string memory name,
        string memory symbol,
        string memory _baseurl,
        uint256 _mintCap,
        address _miner
    ) ERC721Psi(name, symbol) {
        mintCap = _mintCap;
        miner = _miner;
        baseurl = _baseurl;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwnerAuthorized();
        _;
    }

    modifier onlyMiner() {
        if (msg.sender != miner) revert NotMineAuthorized();
        _;
    }

    function updateOwner(address newowner) external onlyOwner {
        require(newowner != address(0), "Invalid Owner");
        owner = newowner;
    }

    function updateMiner(address newminer) external onlyOwner {
        require(newminer != address(0), "Invalid miner");
        miner = newminer;
    }

    function updateBaseURL(string memory _baseurl) external onlyOwner {
        require(bytes(_baseurl).length != 0, "Invalid baseurl");
        baseurl = _baseurl;
    }

    function isOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {
        require(
            _exists(tokenId),
            "ERC721Psi: operator query for nonexistent token"
        );
        address nftowner = ownerOf(tokenId);
        return spender == nftowner;
    }

    function burn(uint256 tokenId) public virtual {
        if (!isOwner(_msgSender(), tokenId)) {
            revert IImmutableERC721ANotOwnerOrOperator(tokenId);
        }
        _burn(tokenId);
    }

    function mint(address to, uint256 quantity) external virtual onlyMiner {
        require(_totalMinted() + quantity <= mintCap, "Exceed mintCap");
        _safeMint(to, quantity);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseurl;
    }
}
