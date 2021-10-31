// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./@openzeppelin/contracts/access/Ownable.sol";
import "./ERC721Tradable.sol";

/// @custom:security-contact koi.plur@gmail.com
contract KOIProject is ERC721, ERC721Enumerable, Ownable {
  using SafeMath for uint256;

  string public KOI_Provenance = "";

  uint256 public constant MAX_TOKENS = 30000;

  uint256 public constant MAX_TOKENS_PER_PURCHASE = 20;
  address public AURAcontract;

  uint256 private price = 50000000000000000; // start 0.05

  bool public isSaleActive = true;

  uint256 public constant AURAmaxSupply = 30000000e18;

  uint256 public AURAtotalSupply = 0;

  mapping(uint256 => uint256) public Luckymoney;
  mapping(uint256 => uint256) public Get_rich_log;
  mapping(uint256 => uint256) public Gender;
  mapping(uint256 => uint256) public level;
  mapping(uint256 => string) private Secrets;
  mapping(uint256 => uint256) public AURA;
  mapping(uint256 => mapping(uint256 => uint256)) public AURAallowance;
  mapping(uint256 => uint256) public TransferTimes;

  uint256 constant Luckymoney_per_day = 81e18; // add 81 Luckymoney
  uint256 constant DAY = 1 days;

  event Minted(address indexed owner, uint256 Gender, uint256 KOI_id);
  event leveled(address indexed owner, uint256 level, uint256 KOI_id);
  event eventSecrets(address indexed owner, string _Secrets, uint256 KOI_id);
  event AURATransfer(
    uint256 indexed _KOI_id,
    uint256 indexed to,
    uint256 amount
  );
  event AURAApproval(
    uint256 indexed _KOI_id,
    uint256 indexed to,
    uint256 amount
  );

  constructor() ERC721("KOI Project", "KOI") {}

  function setAURAcontract(address _AURAcontract) public onlyOwner {
    AURAcontract = _AURAcontract;
  }

  function utfStringLength(string memory str)
    private
    pure
    returns (uint256 length)
  {
    bytes memory bs = bytes(str);
    return bs.length;
  }

  //checked
  function AURAclaimable(uint256 _KOI_id)
    external
    view
    returns (uint256 amount)
  {
    require(
      AURAmaxSupply >= AURAtotalSupply,
      "There will be only 30 million AURA in existence"
    );
    require(_isApprovedOrOwner(msg.sender, _KOI_id));
    uint256 _current_level = level[_KOI_id];
    require(_current_level > 1, "Requires Level 2 or above can claim AURA!");
    amount = Luckymoney[_KOI_id].div(7e18);
  }

  //checked
  function AURAclaim(uint256 _KOI_id, uint256 _AURAamount) external {
    require(
      AURAmaxSupply >= AURAtotalSupply,
      "There will be only 30 million AURA in existence"
    );
    require(
      AURAmaxSupply >= AURAtotalSupply.add(_AURAamount),
      "There will be only 30 million AURA in existence"
    );
    require(_isApprovedOrOwner(msg.sender, _KOI_id));
    uint256 _current_level = level[_KOI_id];
    require(_current_level > 1, "Requires Level 2 or above can claim AURA!");
    uint256 _current_Luckymoney = Luckymoney[_KOI_id];
    require(
      _current_Luckymoney > _AURAamount.mul(1e18),
      "You luckymoney balance is low"
    );
    _AURAmint(_KOI_id, _AURAamount.mul(1e18));
  }

  //checked
  function _AURAmint(uint256 _KOI_id, uint256 amount) internal {
    AURAtotalSupply += amount;
    AURA[_KOI_id] += amount;
    Luckymoney[_KOI_id] -= amount.mul(7);
    emit AURATransfer(_KOI_id, _KOI_id, amount);
  }

  //checked
  function AURAapprove(
    uint256 _KOI_id,
    uint256 spender,
    uint256 amount
  ) external returns (bool) {
    require(_isApprovedOrOwner(msg.sender, _KOI_id));
    AURAallowance[_KOI_id][spender] = amount;
    _approve(AURAcontract, _KOI_id);

    emit AURAApproval(_KOI_id, spender, amount);
    return true;
  }

  //checked
  function AURAtransfer(
    uint256 _KOI_id,
    uint256 to,
    uint256 amount
  ) external returns (bool) {
    require(_isApprovedOrOwner(msg.sender, _KOI_id));
    _AURAtransferTokens(_KOI_id, to, amount);
    return true;
  }

  //checked
  function AURAtransferFrom(
    uint256 executor,
    uint256 _KOI_id,
    uint256 to,
    uint256 amount
  ) external returns (bool) {
    require(_isApprovedOrOwner(msg.sender, _KOI_id), "not Owner");
    uint256 spender = executor;
    uint256 spenderAllowance = AURAallowance[_KOI_id][spender];

    if (spender != _KOI_id && spenderAllowance != type(uint256).max) {
      uint256 newAllowance = spenderAllowance - amount;
      AURAallowance[_KOI_id][spender] = newAllowance;

      emit AURAApproval(_KOI_id, spender, newAllowance);
    }

    _AURAtransferTokens(_KOI_id, to, amount);
    return true;
  }

  //checked
  function _AURAtransferTokens(
    uint256 _KOI_id,
    uint256 to,
    uint256 amount
  ) internal {
    AURA[_KOI_id] -= amount;
    AURA[to] += amount;
    emit AURATransfer(_KOI_id, to, amount);
  }

  //checked
  function Get_rich(uint256 _KOI_id) public {
    require(_isApprovedOrOwner(msg.sender, _KOI_id));
    require(block.timestamp > Get_rich_log[_KOI_id]);
    Get_rich_log[_KOI_id] = block.timestamp + DAY;
    uint256 _current_level = level[_KOI_id];

    Luckymoney[_KOI_id] += (Luckymoney_per_day +
      (_current_level.mul(_current_level).mul(1e18)) +
      (TransferTimes[_KOI_id].mul(1e18)));
  }

  function Get_rich_All() external {
    uint256 tokenCount = balanceOf(msg.sender);
    if (tokenCount > 0) {
      uint256 index;
      uint256 _KOI_id;
      for (index = 0; index < tokenCount; index++) {
        _KOI_id = tokenOfOwnerByIndex(msg.sender, index);
        if (block.timestamp > Get_rich_log[_KOI_id]) {
          Get_rich(_KOI_id);
        }
      }
    }

  }

  //checked
  function spend_Luckymoney(uint256 _KOI_id, uint256 _Luckymoney) external {
    require(_isApprovedOrOwner(msg.sender, _KOI_id));
    Luckymoney[_KOI_id] -= _Luckymoney;
  }

  function level_up(uint256 _KOI_id) external {
    require(_isApprovedOrOwner(msg.sender, _KOI_id));
    uint256 _level = level[_KOI_id];
    uint256 _Luckymoney_required = Luckymoney_required(_level);
    Luckymoney[_KOI_id] -= _Luckymoney_required;
    level[_KOI_id] = _level + 1;
    emit leveled(msg.sender, _level, _KOI_id);
  }

  //checked
  function SetSecrets(uint256 _KOI_id, string memory _Secrets) external {
    require(_isApprovedOrOwner(msg.sender, _KOI_id));
    require(
      Luckymoney[_KOI_id] - utfStringLength(_Secrets).mul(1e18) > 0,
      "Luckymoney is not enough need "
    );
    Luckymoney[_KOI_id] -= utfStringLength(_Secrets).mul(1e18);
    Secrets[_KOI_id] = _Secrets;
    emit eventSecrets(msg.sender, _Secrets, _KOI_id);
  }

  //checked
  function ReadSecrets(uint256 _KOI_id)
    external
    view
    returns (string memory _Secrets)
  {
    require(
      _isApprovedOrOwner(msg.sender, _KOI_id),
      "Only KOI owner can read this"
    );
    _Secrets = Secrets[_KOI_id];
  }

  //checked
  function KOI_Profile(uint256 _KOI_id)
    external
    view
    returns (
      uint256 _Luckymoney,
      uint256 _AURA,
      uint256 _log,
      uint256 _Gender,
      uint256 _level,
      uint256 _TransferTimes
    )
  {
    _Luckymoney = Luckymoney[_KOI_id];
    _AURA = AURA[_KOI_id];
    _log = Get_rich_log[_KOI_id];
    _Gender = Gender[_KOI_id];
    _level = level[_KOI_id];
    _TransferTimes = TransferTimes[_KOI_id];
  }

  //checked
  function Luckymoney_required(uint256 curent_level)
    public
    pure
    returns (uint256 Luckymoney_to_next_level)
  {
    Luckymoney_to_next_level = curent_level * 256e18;
    for (uint256 i = 1; i < curent_level; i++) {
      Luckymoney_to_next_level += i * 256e18;
    }
  }

  //checked
  function dn(uint256 _KOI_id, uint256 _number) public view returns (uint256) {
    return _seed(_KOI_id) % _number;
  }

  //checked
  function _random(string memory input) internal pure returns (uint256) {
    return uint256(keccak256(abi.encodePacked(input)));
  }

  //checked
  function _seed(uint256 _KOI_id) internal view returns (uint256 rand) {
    rand = _random(
      string(
        abi.encodePacked(
          block.timestamp,
          blockhash(block.number - 1),
          _KOI_id,
          msg.sender
        )
      )
    );
  }

  //Set PROVENANCE , only owner
  //checked
  function setProvenanceHash(string memory _provenanceHash) public onlyOwner {
    KOI_Provenance = _provenanceHash;
  }

  //checked
  // function reserveTokens(address _to, uint256 _reserveAmount) public onlyOwner {
  //   uint256 supply = totalSupply();
  //   for (uint256 i = 0; i < _reserveAmount; i++) {
  //     uint256 _KOI_id = supply + i;
  //     Gender[_KOI_id] = dn(_KOI_id, 2);
  //     level[_KOI_id] = 1;
  //     TransferTimes[_KOI_id] = 0;
  //     _safeMint(_to, _KOI_id);
  //   }
  // }

  //checked
  function mint(uint256 _count) public payable {
    uint256 totalSupply = totalSupply();

    require(isSaleActive, "Sale is not active");
    require(
      _count > 0 && _count < MAX_TOKENS_PER_PURCHASE + 1,
      "Exceeds maximum tokens you can purchase in a single transaction"
    );
    require(
      totalSupply + _count < MAX_TOKENS + 1,
      "Exceeds maximum tokens available for purchase"
    );
    require(
      msg.value >= price.mul(_count),
      "Polygon value sent is not correct"
    );

    if (totalSupply > 5000) {
      setPrice(totalSupply.div(1000).sub(3).mul(50000000000000000));
    }

    for (uint256 i = 0; i < _count; i++) {
      uint256 _KOI_id = totalSupply + i;
      Gender[_KOI_id] = dn(_KOI_id, 2);
      uint256 _Gender = Gender[_KOI_id];
      level[_KOI_id] = 1;
      TransferTimes[_KOI_id] = 0;
      _safeMint(msg.sender, _KOI_id);
      emit Minted(msg.sender, _Gender, _KOI_id);
    }
  }

  //checked
  function baseURI() public view virtual returns (string memory) {
    return _baseURI();
  }

  //checked
  function setBaseURI(string memory _baseURI) public onlyOwner {
    _setBaseURI(_baseURI);
  }

  //checked
  function flipSaleStatus() public onlyOwner {
    isSaleActive = !isSaleActive;
  }

  //checked
  function setPrice(uint256 _newPrice) public onlyOwner() {
    price = _newPrice;
  }

  //checked
  function getPrice() public view returns (uint256) {
    return price;
  }

  //checked
  function withdraw() public onlyOwner {
    uint256 balance = address(this).balance;
    payable(msg.sender).transfer(balance);
  }

  function tokensByOwner(address _owner)
    external
    view
    returns (uint256[] memory)
  {
    uint256 tokenCount = balanceOf(_owner);
    if (tokenCount == 0) {
      return new uint256[](0);
    } else {
      uint256[] memory result = new uint256[](tokenCount);
      uint256 index;
      for (index = 0; index < tokenCount; index++) {
        result[index] = tokenOfOwnerByIndex(_owner, index);
      }
      return result;
    }
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal override(ERC721, ERC721Enumerable) {
    super._beforeTokenTransfer(from, to, tokenId);
  }

  function _afterTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal override(ERC721) {
    TransferTimes[tokenId] += 1;
    super._afterTokenTransfer(from, to, tokenId);
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721, ERC721Enumerable)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }
}
