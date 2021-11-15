// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;
import "./@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./@openzeppelin/contracts/access/Ownable.sol";

// TODO

// [V] Collect all fortune gold at once
// [V] Collecting Fortune Gold in bulk for specified IDs
// [V] Upgrade all at once
// [V] Batch upgrade for specified ID
// [V] Convert all the money to Aura at once
// [V] Batch conversion of AURA for specified ID
// [V] Transfer all AURA to the specified ID
// [V] Batch AURA to specified ID
// [V] Count all AURA
// [V] Count all unraised AURA
// [V] transfer all KOI to other ADDRESS
// [V] Specify ID to transfer KOI to other ADDRESS in batch
// [V] Specify the ID to transfer KOI to multiple ADDRESSes

interface IKOI {
  //mappings
  function Luckymoney(uint256) external view returns (uint256);

  function Get_rich_log(uint256) external view returns (uint256);

  function AURA(uint256) external view returns (uint256);

  function level(uint256) external view returns (uint256);

  function Gender(uint256) external view returns (uint256);

  //check
  function AURAclaimable(uint256) external view returns (uint256);

  function AURAallowance(uint256, uint256) external view returns (uint256);

  function AURAcontract() external view returns (address);

  function Luckymoney_required(uint256) external pure returns (uint256);

  function AURAmaxSupply() external view returns (uint256);

  function AURAtotalSupply() external view returns (uint256);

  function totalSupply() external view returns (uint256);

  //View
  function getApproved(uint256) external view returns (address);

  function ownerOf(uint256) external view returns (address);

  function tokenOfOwnerByIndex(address, uint256)
    external
    view
    returns (uint256);

  function tokensByOwner(address) external view returns (uint256[] memory);

  //Write
  function AURAclaim(uint256, uint256) external;

  function AURAapprove(
    uint256,
    uint256,
    uint256
  ) external returns (bool);

  function Get_rich(uint256) external;

  function Get_rich_All() external;

  function level_up(uint256) external;

  function AURAtransferFrom(
    uint256,
    uint256,
    uint256,
    uint256
  ) external returns (bool);

  function AURATransfer(
    uint256,
    uint256,
    uint256
  ) external returns (bool);
}

interface IAURA {
  function wrap(uint256, uint256) external;
}

contract KOITools is Ownable {
  event Log(string message);
  event LogAddress(address message);
  event Loguint(uint256 message);
  event LogBytes(bytes message);

  address _KOIContract = 0x67Bba38865a7C7aDa68D51082DA7fa33c3959d85;
  address _AURAContract = 0x5e2ED6898D8Aa28467A6B2e024D55d79cA72d84B;

  //for test
  // address _KOIContract = 0x7E13c36aCC833BbA1CA219d344d71BB3767EFdA3;
  // address _AURAContract = 0xA627903e540CfFC35fF4C1C95DaAFC27D6E1F865;

  modifier ownerOrApproved(uint256 _KOI_ID) {
    require(
      KOIContract.ownerOf(_KOI_ID) == msg.sender ||
        KOIContract.getApproved(_KOI_ID) == msg.sender,
      "Neither owner nor approved"
    );
    _;
  }

  IKOI KOIContract = IKOI(_KOIContract);

  IAURA AURAContract = IAURA(_AURAContract);

  function SumAllLuckyMoney() external view returns (uint256) {
    uint256 _totalSupply = KOIContract.totalSupply();
    uint256 _AllLuckyMoney = 0;
    for (uint256 i = 0; i < _totalSupply; i++) {
      _AllLuckyMoney += KOIContract.Luckymoney(i);
    }
    return _AllLuckyMoney;
  }

  function SumAllAURAinKOI() external view returns (uint256) {
    uint256 _totalSupply = KOIContract.totalSupply();
    uint256 _AllAURA = 0;
    for (uint256 i = 0; i < _totalSupply; i++) {
      _AllAURA += KOIContract.AURA(i);
    }
    return _AllAURA;
  }

  function SumAllLuckyMoneyByAddress(address _address)
    external
    view
    returns (uint256)
  {
    uint256[] memory _KOI_ids = KOIContract.tokensByOwner(_address);
    uint256 _AllLuckyMoney = 0;
    for (uint256 i = 0; i < _KOI_ids.length; i++) {
      _AllLuckyMoney += KOIContract.Luckymoney(_KOI_ids[i]);
    }
    return _AllLuckyMoney;
  }

  function SumAllAURAByAddress(address _address)
    external
    view
    returns (uint256)
  {
    uint256[] memory _KOI_ids = KOIContract.tokensByOwner(_address);
    uint256 _AllAURA = 0;
    for (uint256 i = 0; i < _KOI_ids.length; i++) {
      _AllAURA += KOIContract.AURA(_KOI_ids[i]);
    }
    return _AllAURA;
  }

  function GenderStats() external view returns (uint256[] memory) {
    uint256 _totalSupply = KOIContract.totalSupply();
    uint256 _Gender;

    uint256[] memory output = new uint256[](2);
    for (uint256 i = 0; i < _totalSupply; i++) {
      _Gender = KOIContract.Gender(i);
      if (output[_Gender] > 0) {
        output[_Gender] = output[_Gender] + 1;
      } else {
        output[_Gender] = 1;
      }
    }
    return output;
  }

  function LevelStats() external view returns (uint256[] memory) {
    uint256 _totalSupply = KOIContract.totalSupply();
    uint256 _Level;
    uint256 _MAX_Level = 0;

    for (uint256 i = 0; i < _totalSupply; i++) {
      _Level = KOIContract.level(i);
      if (_Level > _MAX_Level) {
        _MAX_Level = _Level;
      }
    }
    uint256[] memory output = new uint256[](_MAX_Level + 1);

    for (uint256 i = 0; i < _totalSupply; i++) {
      _Level = KOIContract.level(i);
      if (output[_Level] > 0) {
        output[_Level] = output[_Level] + 1;
      } else {
        output[_Level] = 1;
      }
    }
    return output;
  }

  function CollectLuckyMoney(uint256 _KOI_ID) public ownerOrApproved(_KOI_ID) {
    KOIContract.Get_rich(_KOI_ID);
  }

  function CollectLuckyMoneySpec(uint256[] memory _KOI_IDs) public {
    uint256 tokenCount = _KOI_IDs.length;
    if (tokenCount > 0) {
      uint256 index;
      uint256 _KOI_id;
      for (index = 0; index < tokenCount; index++) {
        _KOI_id = _KOI_IDs[index];
        // emit Loguint(block.timestamp);
        // emit Loguint(KOIContract.Get_rich_log(_KOI_id));
        // emit LogAddress(KOIContract.ownerOf(_KOI_id));
        // emit LogAddress(msg.sender);
        if (
          block.timestamp > KOIContract.Get_rich_log(_KOI_id) &&
          KOIContract.ownerOf(_KOI_id) == msg.sender
        ) {
          CollectLuckyMoney(_KOI_id);
        }
      }
    }
  }

  //Collect LuckyMoney All but in Limite
  function CollectLuckyMoneyAllLimite(uint256 _limite) external {
    uint256[] memory _KOI_ids = KOIContract.tokensByOwner(msg.sender);
    uint256 index = 0;
    uint256 indexDo = 0;
    uint256 _KOI_id;
    uint256 _KOI_idsLen = _KOI_ids.length;

    while (index < _limite) {
      _KOI_id = _KOI_ids[indexDo];
      if (
        block.timestamp > KOIContract.Get_rich_log(_KOI_id) &&
        KOIContract.ownerOf(_KOI_id) == msg.sender
      ) {
        CollectLuckyMoney(_KOI_id);
        //KOIContract.Get_rich(_KOI_id);
        index += 1;
        //  emit Loguint(_KOI_id);
      }

      indexDo += 1;
      if (indexDo >= _KOI_idsLen) {
        index = _limite;
      }
    }
  }

  function LevelUp(uint256 _KOI_id) public {
    uint256 _level = KOIContract.level(_KOI_id);
    uint256 _Luckymoney_required = KOIContract.Luckymoney_required(_level);
    uint256 _Luckymoney = KOIContract.Luckymoney(_KOI_id);

    if (
      _Luckymoney >= _Luckymoney_required &&
      KOIContract.ownerOf(_KOI_id) == msg.sender
    ) {
      KOIContract.level_up(_KOI_id);
    }
  }

  function LevelUpSpec(uint256[] memory _KOI_ids) public {
    uint256 _KOI_id;
    uint256 _level;
    uint256 _Luckymoney_required;
    uint256 _Luckymoney;
    for (uint256 i = 0; i < _KOI_ids.length; i++) {
      _KOI_id = _KOI_ids[i];
      _level = KOIContract.level(_KOI_id);
      _Luckymoney_required = KOIContract.Luckymoney_required(_level);
      _Luckymoney = KOIContract.Luckymoney(_KOI_id);

      if (
        _Luckymoney >= _Luckymoney_required &&
        KOIContract.ownerOf(_KOI_id) == msg.sender
      ) {
        LevelUp(_KOI_id);
      }
    }
  }

  function LevelUpAllLimite(uint256 _limite) external {
    uint256[] memory _KOI_ids = KOIContract.tokensByOwner(msg.sender);
    uint256 index = 0;
    uint256 indexDo = 0;
    uint256 _KOI_id;
    uint256 _KOI_idsLen = _KOI_ids.length;
    uint256 _level;
    uint256 _Luckymoney_required;
    uint256 _Luckymoney;
    while (index < _limite) {
      _KOI_id = _KOI_ids[indexDo];
      _level = KOIContract.level(_KOI_id);
      _Luckymoney_required = KOIContract.Luckymoney_required(_level);
      _Luckymoney = KOIContract.Luckymoney(_KOI_id);
      if (
        _Luckymoney >= _Luckymoney_required &&
        KOIContract.ownerOf(_KOI_id) == msg.sender
      ) {
        LevelUp(_KOI_id);
        index += 1;
      }

      indexDo += 1;
      if (indexDo >= _KOI_idsLen) {
        index = _limite;
      }
    }
  }

  function ClaimAURA(uint256 _KOI_id) public {
    require(
      KOIContract.AURAmaxSupply() >= KOIContract.AURAtotalSupply(),
      "There will be only 30 million AURA in existence"
    );
    uint256 _AURAclaimable;

    try KOIContract.AURAclaimable(_KOI_id) returns (uint256 _result) {
      _AURAclaimable = _result;
    } catch {
      _AURAclaimable = 0;
    }

    if (
      _AURAclaimable > 0 &&
      KOIContract.AURAmaxSupply() >= KOIContract.AURAtotalSupply() &&
      KOIContract.AURAmaxSupply() >=
      (KOIContract.AURAtotalSupply() + _AURAclaimable) &&
      KOIContract.level(_KOI_id) > 1 &&
      KOIContract.ownerOf(_KOI_id) == msg.sender
    ) {
      KOIContract.AURAclaim(_KOI_id, _AURAclaimable);
    }
  }

  function ClaimAURASpec(uint256[] memory _KOI_ids) public {
    require(
      KOIContract.AURAmaxSupply() >= KOIContract.AURAtotalSupply(),
      "There will be only 30 million AURA in existence"
    );
    uint256 _KOI_id;
    uint256 _AURAclaimable;
    for (uint256 i = 0; i < _KOI_ids.length; i++) {
      _KOI_id = _KOI_ids[i];

      try KOIContract.AURAclaimable(_KOI_id) returns (uint256 _result) {
        _AURAclaimable = _result;
      } catch {
        _AURAclaimable = 0;
      }

      if (
        _AURAclaimable > 0 &&
        KOIContract.AURAmaxSupply() >= KOIContract.AURAtotalSupply() &&
        KOIContract.AURAmaxSupply() >=
        (KOIContract.AURAtotalSupply() + _AURAclaimable) &&
        KOIContract.level(_KOI_id) > 1 &&
        KOIContract.ownerOf(_KOI_id) == msg.sender
      ) {
        ClaimAURA(_KOI_id);
      }
    }
  }

  function ClaimAURAAllLimite(uint256 _limite) external {
    require(
      KOIContract.AURAmaxSupply() >= KOIContract.AURAtotalSupply(),
      "There will be only 30 million AURA in existence"
    );
    uint256[] memory _KOI_ids;
    uint256 index = 0;
    uint256 indexDo = 0;
    uint256 _KOI_id;
    uint256 _AURAclaimable;
    _KOI_ids = KOIContract.tokensByOwner(msg.sender);
    uint256 _KOI_idsLen = _KOI_ids.length;

    while (index < _limite) {
      _KOI_id = _KOI_ids[indexDo];
      try KOIContract.AURAclaimable(_KOI_id) returns (uint256 _result) {
        _AURAclaimable = _result;
      } catch {
        _AURAclaimable = 0;
      }

      if (
        _AURAclaimable > 0 &&
        KOIContract.level(_KOI_id) > 1 &&
        KOIContract.ownerOf(_KOI_id) == msg.sender
      ) {
        ClaimAURA(_KOI_id);
        index += 1;
      }

      indexDo += 1;
      if (indexDo >= _KOI_idsLen) {
        index = _limite;
      }
    }
  }

  function AURAtransferOneToOne(uint256 _KOI_id, uint256 _to_id) public {
    uint256 _AURA = KOIContract.AURA(_KOI_id);
    if (_AURA > 0 && KOIContract.ownerOf(_KOI_id) == msg.sender) {
      KOIContract.AURAapprove(_KOI_id, _to_id, _AURA);
      KOIContract.AURAtransferFrom(_to_id, _KOI_id, _to_id, _AURA);
    }
  }

  function AURAtransferSpecIDToOne(uint256[] memory _KOI_ids, uint256 _to_id)
    public
  {
    uint256 _KOI_id;
    uint256 _AURA;
    for (uint256 i = 0; i < _KOI_ids.length; i++) {
      _KOI_id = _KOI_ids[i];
      _AURA = KOIContract.AURA(_KOI_id);
      if (_AURA > 0 && KOIContract.ownerOf(_KOI_id) == msg.sender) {
        AURAtransferOneToOne(_KOI_id, _to_id);
      }
    }
  }

  function AURAtransferAllIDToOne(uint256 _limite, uint256 _to_id) external {
    uint256[] memory _KOI_ids;
    uint256 index = 0;
    uint256 indexDo = 0;
    uint256 _KOI_id;
    _KOI_ids = KOIContract.tokensByOwner(msg.sender);
    uint256 _KOI_idsLen = _KOI_ids.length;
    uint256 _AURA;
    while (index < _limite) {
      _KOI_id = _KOI_ids[indexDo];
      _AURA = KOIContract.AURA(_KOI_id);

      if (
        _AURA > 0 &&
        _KOI_id != _to_id &&
        KOIContract.ownerOf(_KOI_id) == msg.sender
      ) {
        AURAtransferOneToOne(_KOI_id, _to_id);
        index += 1;
      }

      indexDo += 1;
      if (indexDo >= _KOI_idsLen) {
        index = _limite;
      }
    }
  }

  function WarpAURAOneID(uint256 _KOI_id) public {
    uint256 _AURA;
    _AURA = KOIContract.AURA(_KOI_id);
    if (_AURA > 0 && KOIContract.ownerOf(_KOI_id) == msg.sender) {
      KOIContract.AURAapprove(_KOI_id, 17, _AURA);
      AURAContract.wrap(_KOI_id, _AURA);
    }
  }

  function WarpAURASpecID(uint256[] memory _KOI_ids) external {
    uint256 _KOI_id;
    uint256 _AURA;
    for (uint256 i = 0; i < _KOI_ids.length; i++) {
      _KOI_id = _KOI_ids[i];
      _AURA = KOIContract.AURA(_KOI_id);
      if (_AURA > 0 && KOIContract.ownerOf(_KOI_id) == msg.sender) {
        WarpAURAOneID(_KOI_id);
      }
    }
  }

  function WarpAllAURA() external {
    uint256[] memory _KOI_ids = KOIContract.tokensByOwner(msg.sender);
    uint256 _KOI_id;
    uint256 _AURA;
    for (uint256 i = 0; i < _KOI_ids.length; i++) {
      _KOI_id = _KOI_ids[i];
      _AURA = KOIContract.AURA(_KOI_id);
      if (_AURA > 0 && KOIContract.ownerOf(_KOI_id) == msg.sender) {
        WarpAURAOneID(_KOI_id);
      }
    }
  }

  function KOI_LuckyMoneyCollectable(address _owner) external view returns (uint256) {
    uint256[] memory _KOI_ids = KOIContract.tokensByOwner(_owner);
    uint256 index = 0;
    uint256 r = 0;
    uint256 _KOI_id;
    uint256 _KOI_idsLen = _KOI_ids.length;

    for (index = 0; index < _KOI_idsLen; index++) {
      _KOI_id = _KOI_ids[index];
      if (
        block.timestamp > KOIContract.Get_rich_log(_KOI_id) &&
        KOIContract.ownerOf(_KOI_id) == _owner
      ) {
        r += 1;
      }
    }
    return r;
  }

  function KOI_LevelUpable(address _owner) external view returns (uint256) {
    uint256[] memory _KOI_ids = KOIContract.tokensByOwner(_owner);
    uint256 index = 0;
    uint256 r = 0;
    uint256 _KOI_id;
    uint256 _KOI_idsLen = _KOI_ids.length;
    uint256 _level;
    uint256 _Luckymoney_required;
    uint256 _Luckymoney;

    for (index = 0; index < _KOI_idsLen; index++) {
      _KOI_id = _KOI_ids[index];
      _level = KOIContract.level(_KOI_id);
      _Luckymoney_required = KOIContract.Luckymoney_required(_level);
      _Luckymoney = KOIContract.Luckymoney(_KOI_id);
      if (
        _Luckymoney >= _Luckymoney_required &&
        KOIContract.ownerOf(_KOI_id) == _owner
      ) {
        r += 1;
      }
    }
    return r;
  }

  function KOI_AURAClaimable(address _owner) external view returns (uint256) {
    uint256[] memory _KOI_ids = KOIContract.tokensByOwner(_owner);
    uint256 index = 0;
    uint256 r = 0;
    uint256 _KOI_id;
    uint256 _KOI_idsLen = _KOI_ids.length;
    uint256 _AURAclaimable;

    try KOIContract.AURAclaimable(_KOI_id) returns (uint256 _result) {
      _AURAclaimable = _result;
    } catch {
      _AURAclaimable = 0;
    }

    for (index = 0; index < _KOI_idsLen; index++) {
      _KOI_id = _KOI_ids[index];
      if (
        _AURAclaimable > 0 &&
        KOIContract.AURAmaxSupply() >= KOIContract.AURAtotalSupply() &&
        KOIContract.AURAmaxSupply() >=
        (KOIContract.AURAtotalSupply() + _AURAclaimable) &&
        KOIContract.level(_KOI_id) > 1 &&
        KOIContract.ownerOf(_KOI_id) == _owner
      ) {
        r += 1;
      }
    }
    return r;
  }

  // transfer Specify KOI to one Address
  //CHECKED
  function ERC721multisend_SpecTokenToAddress(
    address _to,
    uint256[] memory _KOI_ids
  ) public returns (uint256) {
    uint256 i = 0;
    while (i < _KOI_ids.length) {
      if (KOIContract.ownerOf(_KOI_ids[i]) == msg.sender) {
        ERC721(_KOIContract).transferFrom(msg.sender, _to, _KOI_ids[i]);
      }
      i += 1;
    }
    return (i);
  }

  // transfer Specify KOIs to Specify Addresses
  //CHECKED
  function ERC721multisend_SpecTokenToSpecAddress(
    address[] memory _to,
    uint256[][] memory _KOI_ids
  ) public returns (uint256) {
    uint256 i = 0;
    while (i < _to.length) {
      ERC721multisend_SpecTokenToAddress(_to[i], _KOI_ids[i]);
      i += 1;
    }
    return (i);
  }

  // transfer all KOIs to one Address
  //CHECKED
  function ERC721multisend_AllTokenToAddress(address _to)
    public
    returns (uint256)
  {
    uint256 i = 0;

    uint256[] memory _KOI_ids = KOIContract.tokensByOwner(msg.sender);
    ERC721multisend_SpecTokenToAddress(_to, _KOI_ids);
    return (i);
  }

  //For Donation
  //CHECKED

  function withdraw() public onlyOwner {
    uint256 balance = address(this).balance;
    payable(msg.sender).transfer(balance);
  }
}
