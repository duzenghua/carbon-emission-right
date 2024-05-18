// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Dso {
  uint256 public userNum;
  address payable owner;
  //记录DSO匹配周期
  uint256 public numMatchTimes;
  struct User {
    string eaccessQuato;
    string elockQuato;
    uint256 userNum;
    string publicKey;
  }
  struct Traded {
    address  seller;
    address buyer;
    uint256 direction;
    string  eprice;
    string  eamount;
    uint256 matchTime;//所在周期
  }
  struct Declare{
    address  declarer;
    uint256 direction;//0代表卖出  1代表买入
    string eprice;
    string eamount;
    bool isDeal; //判断是否处理过
    uint256 declareTime;//申报时间
    uint256 matchTime;//所在周期
    uint256 deposit;//押金
  }
  mapping(address => User)  Users; //所有的用户
  mapping(address => Declare[]) myDeclares;//用户 => 用户的申报
  mapping(address => Traded[]) myTradeds;//用户 => 用户的交易
  mapping(uint =>  Declare[]) matchTimesTodeclare;//周期 =>周期内所有的申报
  mapping(uint => bool) matchTimeIsMatched;
  mapping(uint=> string) matchTimeHashs;//每个周期内的匹配结果hash
  event UserUpdateQuato(address user, string equato);
  event UserRefund(address user, uint256 money);
  event UserIsAgree(address user, bool isAgree);
  event Matched(bool matched);

  constructor() payable{
      owner = payable(msg.sender);
      //buyer_1-buyer_6
      Users[0xA67b22C5134a03fFABbDD103338873af26441Fe7] = User("1516742823853251366661481903015061097152060611825670565413927906841063673067791833474446687000794326122834459207758814246701132247710391248328887497608372","3205524148403378569522132112942473370461126142002193902058396256159634509165828315548342993828461838554721323028804285468982008825640838640135773107829977",3,"74831910337492100623361105454848424101022915621520994630872446028165214149879");
      Users[0x01dfba0A345ceA8BA6d02B3585D727f0B7A52a90] = User("1516742823853251366661481903015061097152060611825670565413927906841063673067791833474446687000794326122834459207758814246701132247710391248328887497608372","3205524148403378569522132112942473370461126142002193902058396256159634509165828315548342993828461838554721323028804285468982008825640838640135773107829977",4,"74831910337492100623361105454848424101022915621520994630872446028165214149879");
      Users[0xE62c7574C0E3e3367405efc45DD5505919E19BA4] = User("1516742823853251366661481903015061097152060611825670565413927906841063673067791833474446687000794326122834459207758814246701132247710391248328887497608372","3205524148403378569522132112942473370461126142002193902058396256159634509165828315548342993828461838554721323028804285468982008825640838640135773107829977",5,"74831910337492100623361105454848424101022915621520994630872446028165214149879");
      Users[0xbB38D58294C3d844B33A29DD1700Bd0e8aB4263c] = User("1516742823853251366661481903015061097152060611825670565413927906841063673067791833474446687000794326122834459207758814246701132247710391248328887497608372","3205524148403378569522132112942473370461126142002193902058396256159634509165828315548342993828461838554721323028804285468982008825640838640135773107829977",6,"74831910337492100623361105454848424101022915621520994630872446028165214149879");
      Users[0x9637dB82F37f04ea68018a240E99486ACf1C412A] = User("1516742823853251366661481903015061097152060611825670565413927906841063673067791833474446687000794326122834459207758814246701132247710391248328887497608372","3205524148403378569522132112942473370461126142002193902058396256159634509165828315548342993828461838554721323028804285468982008825640838640135773107829977",7,"74831910337492100623361105454848424101022915621520994630872446028165214149879");
      Users[0xf7bFA01f103D86f0A57Ee9A8bb57dd48B2499B1a] = User("1516742823853251366661481903015061097152060611825670565413927906841063673067791833474446687000794326122834459207758814246701132247710391248328887497608372","3205524148403378569522132112942473370461126142002193902058396256159634509165828315548342993828461838554721323028804285468982008825640838640135773107829977",8,"74831910337492100623361105454848424101022915621520994630872446028165214149879");
      // Users[0x6CBa2AFC48697e806bAbd26F91aA4476bc34d819] = User("1516742823853251366661481903015061097152060611825670565413927906841063673067791833474446687000794326122834459207758814246701132247710391248328887497608372","3205524148403378569522132112942473370461126142002193902058396256159634509165828315548342993828461838554721323028804285468982008825640838640135773107829977",10,"74831910337492100623361105454848424101022915621520994630872446028165214149879");
      // seller_1
      Users[0x14Be89F8bcED923a4EE9Da1D08800149F01d7a8c] = User("1516742823853251366661481903015061097152060611825670565413927906841063673067791833474446687000794326122834459207758814246701132247710391248328887497608372","3205524148403378569522132112942473370461126142002193902058396256159634509165828315548342993828461838554721323028804285468982008825640838640135773107829977",11,"74831910337492100623361105454848424101022915621520994630872446028165214149879");
      // seller_2
      Users[0x134C45f209c9236Cd5ab69aaF6303C3EfdFaAbe6] = User("1516742823853251366661481903015061097152060611825670565413927906841063673067791833474446687000794326122834459207758814246701132247710391248328887497608372","3205524148403378569522132112942473370461126142002193902058396256159634509165828315548342993828461838554721323028804285468982008825640838640135773107829977",12,"74831910337492100623361105454848424101022915621520994630872446028165214149879");
      // seller_3
      Users[0x5EEeA5BCE03Bcc158fCD526b3D6aD947Cd2B86Cc] = User("1516742823853251366661481903015061097152060611825670565413927906841063673067791833474446687000794326122834459207758814246701132247710391248328887497608372","3205524148403378569522132112942473370461126142002193902058396256159634509165828315548342993828461838554721323028804285468982008825640838640135773107829977",13,"74831910337492100623361105454848424101022915621520994630872446028165214149879");
      // seller_4
      Users[0x0C12776560FECC87A21fA22ED82512C926D6D450] = User("1516742823853251366661481903015061097152060611825670565413927906841063673067791833474446687000794326122834459207758814246701132247710391248328887497608372","3205524148403378569522132112942473370461126142002193902058396256159634509165828315548342993828461838554721323028804285468982008825640838640135773107829977",14,"74831910337492100623361105454848424101022915621520994630872446028165214149879");
      // seller_5
      Users[0xF5e99b9d4D35B46D80a1389c4067642e3c83Bdd0] = User("1516742823853251366661481903015061097152060611825670565413927906841063673067791833474446687000794326122834459207758814246701132247710391248328887497608372","3205524148403378569522132112942473370461126142002193902058396256159634509165828315548342993828461838554721323028804285468982008825640838640135773107829977",15,"74831910337492100623361105454848424101022915621520994630872446028165214149879");
      // seller_6
      Users[0x7242c236B1afA86398dDcCD8B55848Edd1F6B459] = User("1516742823853251366661481903015061097152060611825670565413927906841063673067791833474446687000794326122834459207758814246701132247710391248328887497608372","3205524148403378569522132112942473370461126142002193902058396256159634509165828315548342993828461838554721323028804285468982008825640838640135773107829977",0,"74831910337492100623361105454848424101022915621520994630872446028165214149879");
      // seller_7
      Users[0xdf98FF22544D1F58491aAc134CCe95fB5c895376] = User("1516742823853251366661481903015061097152060611825670565413927906841063673067791833474446687000794326122834459207758814246701132247710391248328887497608372","3205524148403378569522132112942473370461126142002193902058396256159634509165828315548342993828461838554721323028804285468982008825640838640135773107829977",1,"74831910337492100623361105454848424101022915621520994630872446028165214149879");
      // seller_8
      Users[0x6e6239f19FFC7A2ADf67628718338E7Cd9fD7641] = User("1516742823853251366661481903015061097152060611825670565413927906841063673067791833474446687000794326122834459207758814246701132247710391248328887497608372","3205524148403378569522132112942473370461126142002193902058396256159634509165828315548342993828461838554721323028804285468982008825640838640135773107829977",2,"74831910337492100623361105454848424101022915621520994630872446028165214149879");
  }
  //申报:只允许内部调用，当用户验证通过后，自己调用此方法
  function declare(uint256 direction, string memory dsoEprice, string memory dsoEamount, string memory ownEprice, string memory ownEamount) public payable  returns(uint256){
    //可以在这里做个角色控制
    uint256 len = matchTimesTodeclare[numMatchTimes].length;
    myDeclares[msg.sender].push(Declare(msg.sender,direction,ownEprice,ownEamount,false,block.timestamp,numMatchTimes,msg.value));
    matchTimesTodeclare[numMatchTimes].push(Declare(msg.sender,direction,dsoEprice, dsoEamount,false,block.timestamp,numMatchTimes,msg.value));
    //返回当前周期的申报序号
    return len;
  }
  //获取当前的匹配周期
  function getNumMatchTimes() public view returns(uint256) {
    return numMatchTimes;
  }
  //获取当前周期的申报长度
  function getDeclaresLen(uint256 matchTimeId) public view returns(uint256){
    require(matchTimeId <= numMatchTimes && matchTimeId >= 0);
    return matchTimesTodeclare[matchTimeId].length;
   }
  //获取当前周期的申报
  function getDeclare(uint256 matchTimeId,uint256 id) public view returns(address,uint256,string memory,string memory,uint256,uint256){
    require(matchTimeId <= numMatchTimes && matchTimeId >= 0);
    return (matchTimesTodeclare[matchTimeId][id].declarer, matchTimesTodeclare[matchTimeId][id].direction,
    matchTimesTodeclare[matchTimeId][id].eprice, matchTimesTodeclare[matchTimeId][id].eamount,
    matchTimesTodeclare[matchTimeId][id].declareTime,matchTimesTodeclare[matchTimeId][id].deposit);
  }
  //用户获取自己的申报长度
  function getOwnDeclaresLen(address user) public view returns(uint256){
    return myDeclares[user].length;
  }
  //用户获取自己的申报
  function getOwnDeclare(address user,uint256 id) public view  returns(address,uint256,string memory,string memory,uint256,uint256){
    return (myDeclares[user][id].declarer, myDeclares[user][id].direction,
    myDeclares[user][id].eprice, myDeclares[user][id].eamount,
    myDeclares[user][id].declareTime,myDeclares[user][id].matchTime );
  }
  //用户获取自己的交易长度
  function getOwnTradedsLen(address user) public view returns(uint256){
    return myTradeds[user].length;
  }
  //用户获取自己的交易
  function getOwnTraded(address user,uint256 id) public view returns(address,address,string memory,string memory,uint256){
    return (myTradeds[user][id].seller, myTradeds[user][id].buyer,
    myTradeds[user][id].eprice, myTradeds[user][id].eamount, myTradeds[user][id].matchTime);
  }

    //获取用户加密配额返回值有名称
  function getUserQuato(address user) public view returns(string memory,string memory ){
    return (Users[user].eaccessQuato, Users[user].elockQuato);
  }
  //用户报价阶段设置配额
  function setQuatoDeclare(address user, string memory  newElockQuato, string memory  newEAccessQuato) public{
    Users[user].eaccessQuato = newEAccessQuato;
    Users[user].elockQuato = newElockQuato;
  }
  //DSO调用此函数，将当前周期的申报中的isDeal设置为true
  function setIsDeal(uint256 matchTime) public {
    uint256 len = matchTimesTodeclare[matchTime].length;
    for(uint i = 0; i < len; i++){
        Declare storage d = matchTimesTodeclare[matchTime][i];
        d.isDeal = true;
    }
  }
  //DSO调用设置交易后的用户加密配额
  function setQuatoMatched(address user, string memory  newElockQuato, string memory newEAccessQuato) public {
    //此函数必须由DSO调用
    Users[user].eaccessQuato = newEAccessQuato;
    Users[user].elockQuato = newElockQuato;
  }
  //DSO将明文匹配结果上传IPFS，并将加密hash上传区块链，并在区块链上存储交易结果,此时的加密价格，加密数量是使用的用户的公钥，需要DSO分别使用seller和buyer的密钥加密一次
  function setTraded(address seller, address  buyer, string memory sellerEprice, string memory sellerEamount, string memory buyerEprice, string memory buyerEamount) public{
    //要求必须是DSO调用
    require(msg.sender == address(0x8d41F13313CA84974A3C43B79da492eD5A69Fb79));
    myTradeds[seller].push(Traded(seller,buyer,0,sellerEprice,sellerEamount,numMatchTimes));
    myTradeds[buyer].push(Traded(seller,buyer,1,buyerEprice,buyerEamount,numMatchTimes));
  }
  //DSO设置匹配完成，供用户监听:调用时机：当用户退款后，加密配额设置后，myTraded设置后,ipfsHash上传后
  function setIsMatched() public{
    require(msg.sender == address(0x8d41F13313CA84974A3C43B79da492eD5A69Fb79));
    matchTimeIsMatched[numMatchTimes] = true;
    numMatchTimes++;
    emit Matched(true);
  }
  //退款
  function refund(address payable buyer, uint256 refunds) public payable {
    //该函数必须由DSO调用
    require(msg.sender == address(0x8d41F13313CA84974A3C43B79da492eD5A69Fb79));
    buyer.transfer(refunds);
    emit UserRefund(buyer, refunds);
   
  }
  //用户上传自己同态公钥
  function setPublicKey(string memory publicKey) public{
    User storage u = Users[msg.sender];
    u.publicKey = publicKey;
  }
  function getPublick(address user) public view returns(string memory){
    return Users[user].publicKey;
  }
  function saveHash(string memory eHash) public{
    matchTimeHashs[numMatchTimes] = eHash;
  }
  function getMatchTime() public view returns(uint256){
    return numMatchTimes;
  }
  
}