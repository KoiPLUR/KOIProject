// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "./@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IAURA {
  function ownerOf(uint256) external view returns (address);

  function getApproved(uint256) external view returns (address);

  function AURA(uint256) external view returns (uint256);

  function AURAallowance(uint256, uint256) external view returns (uint256);

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

contract AURAWrapped is ERC20("KOI Aura", "AURA") {
  IAURA KOIContract = IAURA(0x67Bba38865a7C7aDa68D51082DA7fa33c3959d85);
  //IRarity rarityContract = IRarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);

  uint256 public _Treasurer; //
  event AURAGotWrapped(uint256 indexed _KOI_ID, uint256 amount);
  event AURAGotUnwrapped(uint256 amount, uint256 indexed to_KOI_ID);

  constructor() {
    _Treasurer = 17;
  }

  modifier ownerOrApproved(uint256 _KOI_ID) {
    require(
      KOIContract.ownerOf(_KOI_ID) == msg.sender ||
        KOIContract.getApproved(_KOI_ID) == msg.sender,
      "Neither owner nor approved"
    );
    _;
  }

  modifier hasEnoughAndApproved(uint256 _KOI_ID, uint256 amount) {
    require(
      KOIContract.AURA(_KOI_ID) >= amount,
      "Summoner doesnt have enough $AURA"
    );
    require(
      KOIContract.AURAallowance(_KOI_ID, _Treasurer) >= amount,
      "Not enough allowance to Treasurer"
    );
    _;
  }
  
  
  function wrap(uint256 _KOI_ID, uint256 amountToWrap)
    external
    ownerOrApproved(_KOI_ID)
    hasEnoughAndApproved(_KOI_ID, amountToWrap)
  {
    KOIContract.AURAtransferFrom(
        _Treasurer,
        _KOI_ID,
        _Treasurer,
        amountToWrap);
    _mint(msg.sender, amountToWrap);

    emit AURAGotWrapped(_KOI_ID, amountToWrap);
  }

  function unwrap(uint256 amountToUnwrap, uint256 to_KOI_ID) external {
    _burn(msg.sender, amountToUnwrap);
    require(
      KOIContract.AURATransfer(_Treasurer, to_KOI_ID, amountToUnwrap),
      "Transfer of $AURA failed"
    );

    emit AURAGotUnwrapped(amountToUnwrap, to_KOI_ID);
  }
}
