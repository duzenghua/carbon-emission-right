// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Smart {
  uint256 value;
  uint256 userNum;
  event UserRegister(address indexed user);
  event UserDeclare(address indexed user, uint8 userTag, uint256 ePrice, uint256 eVolume);
  //注册
  function register() public  returns (uint256) {
    //DSO监听该事件后，为User分配公私密钥，使用User公钥加密碳配额上传到区块链
    emit UserRegister(msg.sender);
    return userNum++;
  }
  //使用DSO的公钥进行加密报价
  function declare(uint8 userTag, uint256 ePrice, uint256 eVolume) public {
    //DSO监听该事件后，收集该报价并进行解密
    emit UserDeclare(msg.sender, userTag, ePrice, eVolume);
  }
}