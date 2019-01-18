pragma solidity >=0.4.22 <0.6.0;
pragma experimental ABIEncoderV2;

import "./ConvertLib.sol";

contract LifeLine {
    address owner;
    struct Customer{
        bytes32 owner;
        bytes32 name;
        bytes32 info;
        bytes32 password;
    }
    struct Producer{
        bytes32 owner;
        bytes32 name;
        bytes32 info;
        bytes32 password;
    }
    struct Dealer{
        bytes32 owner;
        bytes32 name;
        bytes32 info;
        bytes32 password;
    }
    struct Retailer{
        bytes32 owner;
        bytes32 name;
        bytes32 info;
        bytes32 password;
    }

    mapping (bytes32 => Customer) customer;
    mapping (bytes32 => Producer) producer;
    mapping (bytes32 => Dealer) dealer;
    mapping (bytes32 => Retailer) retailer;

    bytes32[] customers; 
    bytes32[] producers; 
    bytes32[] dealers; 
    bytes32[] retailers;

    enum Actor{ Dealer, Retailer, Customer, Producer }

    struct Sale {
        bytes32 saleId;
        bytes32 goodId;
        bytes32 buyer;             //买家
        bytes32 saleTime;            //转售时间
        bytes32 salePrice;           //转售价格
        Actor actor;                //买家的类别
    }   
    mapping (bytes32 => Sale) sale;
    bytes32[] sales;

    struct Good { 
        bytes32 goodId;
        bytes32 goodName;
        bytes32 producer;
        bytes32 produceTime;
        bytes32[] sales;
        bytes32 owner;
        uint ownertype;
        bytes32[] components;
    }

    mapping (bytes32 => Good) good;    
    bytes32[] goods;

    constructor() public {
        owner = msg.sender;
    }

    event NewUser(address sender,bool isSuccess,string message); 
    function newUser(string memory _userAddrStr, string memory _password, uint _type, string memory _name, string memory _info) public payable{
        bytes32 _userAddr = ConvertLib.stringToBytes32(_userAddrStr);
        if(_type == 0) {    //customer
            if(!isUserAlreadyRegister(_userAddr, _type)) {
                customer[_userAddr].owner = _userAddr; 
                customer[_userAddr].password = ConvertLib.stringToBytes32(_password); 
                customer[_userAddr].name = ConvertLib.stringToBytes32(_name);
                customer[_userAddr].info = ConvertLib.stringToBytes32(_info);
                customers.push(_userAddr);
                emit NewUser(msg.sender, true, "注册成功");
                return;
            }else {
                emit NewUser(msg.sender, false, "该账户已经注册"); 
                return;
            } 
        } else if (_type == 1) {    //producer
            if(!isUserAlreadyRegister(_userAddr, _type)) {
                producer[_userAddr].owner = _userAddr; 
                producer[_userAddr].password = ConvertLib.stringToBytes32(_password); 
                producer[_userAddr].name = ConvertLib.stringToBytes32(_name);
                producer[_userAddr].info = ConvertLib.stringToBytes32(_info);
                producers.push(_userAddr);
                emit NewUser(msg.sender, true, "注册成功");
                return;
            }else {
                emit NewUser(msg.sender, false, "该账户已经注册"); 
                return;
            } 
        } else if (_type == 2) {    //dealer
            if(!isUserAlreadyRegister(_userAddr, _type)) {
                dealer[_userAddr].owner = _userAddr; 
                dealer[_userAddr].password = ConvertLib.stringToBytes32(_password); 
                dealer[_userAddr].name = ConvertLib.stringToBytes32(_name);
                dealer[_userAddr].info = ConvertLib.stringToBytes32(_info);
                dealers.push(_userAddr);
                emit NewUser(msg.sender, true, "注册成功");
                return;
            }else {
                emit NewUser(msg.sender, false, "该账户已经注册"); 
                return;
            } 
        } else if (_type == 3) {    //retailer
            if(!isUserAlreadyRegister(_userAddr, _type)) {
                retailer[_userAddr].owner = _userAddr; 
                retailer[_userAddr].password = ConvertLib.stringToBytes32(_password); 
                retailer[_userAddr].name = ConvertLib.stringToBytes32(_name);
                retailer[_userAddr].info = ConvertLib.stringToBytes32(_info);
                retailers.push(_userAddr);
                emit NewUser(msg.sender, true, "注册成功");
                return;
            }else {
                emit NewUser(msg.sender, false, "该账户已经注册"); 
                return;
            } 
        }    
    }

    function isUserAlreadyRegister(bytes32 _addr, uint _type) internal view returns(bool) {
        if(_type == 0) {
            for(uint i = 0; i < customers.length; i++) {
                if(customers[i] == _addr) {
                    return true;
                }
            }
            return false;
        } else if(_type == 1){
            for(uint i = 0; i < producers.length; i++) {
                if(producers[i] == _addr) {
                    return true;
                }
            }
        } else if(_type == 2){
            for(uint i = 0; i < dealers.length; i++) {
                if(dealers[i] == _addr) {
                    return true;
                }
            }
        } else if(_type == 3){
            for(uint i = 0; i < retailers.length; i++) {
                if(retailers[i] == _addr) {
                    return true;
                }
            }
        }
        return false;
    }

    function getUserPwd(string memory _addrStr, uint _type) public view returns(bool, string memory) {
        bytes32 _addr = ConvertLib.stringToBytes32(_addrStr);
        if(isUserAlreadyRegister(_addr, _type)) {
            if(_type == 0) {
                return (true, ConvertLib.bytes32ToString(customer[_addr].password));
            } else if (_type == 1) {
                return (true, ConvertLib.bytes32ToString(producer[_addr].password));
            } else if (_type == 2) {
                return (true, ConvertLib.bytes32ToString(dealer[_addr].password));
            } else if (_type == 3) {
                return (true, ConvertLib.bytes32ToString(retailer[_addr].password));
            }
        } else {
            return (false, "");
        }
    }

    event ProduceGood(address sender,bool isSuccess,string message);
    function produceGood(string memory _id, string memory _name, string memory _src, string[] memory _CompStr, string memory _produceT) public {
        bytes32 tmpid = ConvertLib.stringToBytes32(_id);
        bytes32[] memory _Components = new bytes32[](_CompStr.length);
        for(uint i = 0; i < _CompStr.length; i++) {
            _Components[i] = ConvertLib.stringToBytes32(_CompStr[i]);
        }
        if(!isGoodAlreadyExist(tmpid)) {
            bool res1;
            uint res2;
            (res1, res2) = isComponentsAllExist(_Components);
            if(res1) {
                good[tmpid].goodId = tmpid;
                good[tmpid].goodName = ConvertLib.stringToBytes32(_name);
                good[tmpid].ownertype = 1;
                good[tmpid].owner = ConvertLib.stringToBytes32(_src);
                good[tmpid].producer = ConvertLib.stringToBytes32(_src);
                good[tmpid].components = _Components;
                good[tmpid].produceTime = ConvertLib.stringToBytes32(_produceT);
                goods.push(tmpid);
                emit ProduceGood(msg.sender, true, "创建商品成功"); 
            } else {
                emit ProduceGood(msg.sender, false, "有零件不存在，请确认后操作"); 
                return;
            }
            
        } else {
            emit ProduceGood(msg.sender, false, "该件商品已经添加，请确认后操作"); 
            return;
        }
    }

    function isGoodAlreadyExist(bytes32 _id) internal view returns(bool) {
        for(uint i = 0; i < goods.length; i++) {
            if(goods[i] == _id) {
                return true;
            }
        }
        return false;
    }

    function isSellAlreadyExist(bytes32 _id) internal view returns(bool) {
        for(uint i = 0; i < sales.length; i++) {
            if(sales[i] == _id) {
                return true;
            }
        }
        return false;
    }

    function isComponentsAllExist(bytes32[] memory _ids) internal view returns(bool, uint) {
        bool flag;
        for(uint i = 0; i < _ids.length; i++) {
            flag = false;
            for(uint j = 0; j < goods.length; j++) {
                if(_ids[i] == goods[j]) {
                    flag = true;
                    break;
                }
            }
            if(!flag) {
                return (false, i+1);
            }
        }
        return (true, 0);
    }
    
    event SellGood(address sender,bool isSuccess,string message);
    function sellGood(string memory _gid, string memory _id, string memory _brs, string memory _time, string memory _p, uint _t, string memory _srs, uint _st) public payable{
        bytes32 tmpid = ConvertLib.stringToBytes32(_id);
        bytes32 goodid = ConvertLib.stringToBytes32(_gid);
        bytes32 _br = ConvertLib.stringToBytes32(_brs);
        bytes32 _sr = ConvertLib.stringToBytes32(_srs);
        if(good[goodid].owner != _sr && good[goodid].ownertype != _st) {
            emit SellGood(msg.sender, false, "没有操作权限"); 
            return;
        } else if(!isUserAlreadyRegister(_br, _t)) {
            emit SellGood(msg.sender, false, "买家不存在"); 
            return;
        } else if(!isSellAlreadyExist(tmpid)) {
            sale[tmpid].saleId = tmpid;
            sale[tmpid].goodId = goodid;
            sale[tmpid].buyer = _br;
            sale[tmpid].saleTime = ConvertLib.stringToBytes32(_time);
            sale[tmpid].salePrice = ConvertLib.stringToBytes32(_p);
            if(_t == 2) {
                sale[tmpid].actor = Actor.Dealer;
            } else if(_t == 3) {
                sale[tmpid].actor = Actor.Retailer;
            } else if(_t == 0) {
                sale[tmpid].actor = Actor.Customer;
            } else if(_t == 1) {
                sale[tmpid].actor = Actor.Producer;
            }
            sales.push(tmpid);
            good[goodid].owner = _br;
            good[goodid].ownertype = _t;
            good[goodid].sales.push(tmpid);
            emit SellGood(msg.sender, true, "出售商品成功");
            return;
        } else {
            emit SellGood(msg.sender, false, "该交易号已使用，请确认后操作"); 
            return;
        }
    }

    function debugGood(string memory _id) public view returns (string memory) {
        bytes32 id = ConvertLib.stringToBytes32(_id);
        if(isGoodAlreadyExist(id)) {
            string memory goodName = ConvertLib.bytes32ToString(good[id].goodName);
            string memory srcStr;
            srcStr = queryUser(good[id].producer, 1);
            bytes32[] memory goodSales = good[id].sales;
            bytes32[] memory goodComponents = good[id].components;
            uint[] memory buyerType = new uint[](goodSales.length);
            string[] memory goodSalesStr = new string[](goodSales.length);
            string[] memory goodComponentsStr = new string[](goodComponents.length);
            for(uint i = 0; i < goodSales.length; i++) {
                (goodSalesStr[i], buyerType[i]) = querySale(goodSales[i]);
            }
            for(uint i = 0; i < goodComponents.length; i++) {
                goodComponentsStr[i] = ConvertLib.bytes32ToString(goodComponents[i]);
            }
            string memory produceT = ConvertLib.bytes32ToString(good[id].produceTime);
            string memory res = string(abi.encodePacked("{'ID':'",_id,"','Name':'",goodName,"','ProduceTime':'",produceT,"','Producer':[",srcStr,"],'Sales':["));
            for(uint i = 0; i < goodSales.length; i++) {
                if(i != 0) {
                    res = string(abi.encodePacked(res, ","));
                }
                res = string(abi.encodePacked(res, goodSalesStr[i]));
            }
            res = string(abi.encodePacked(res, "],'Compenents':'"));
            for(uint i = 0; i < goodComponents.length; i++) {
                if(i != 0) {
                    res = string(abi.encodePacked(res, "/"));
                }
                res = string(abi.encodePacked(res, goodComponentsStr[i]));
            }
            res = string(abi.encodePacked(res, "'}"));
            return res;
        } else {
            return " ";
        }
    }


    event QueryGood(address sender,bool isSuccess,string message);
    function queryGood(string memory _id) public {
        bytes32 id = ConvertLib.stringToBytes32(_id);
        if(isGoodAlreadyExist(id)) {
            string memory res = debugGood(_id);
            emit QueryGood(msg.sender, true, res); 
            return;
        } else {
            emit QueryGood(msg.sender, false, "商品不存在"); 
            return;
        }
    }

    function queryUser(bytes32 _addr, uint _type) public view returns (string memory) {
        string memory name;
        string memory info;
        string memory utype;
        if(_type == 0) {
            name = ConvertLib.bytes32ToString(customer[_addr].name);
            info = ConvertLib.bytes32ToString(customer[_addr].info);
            utype = "消费者";
        } else if(_type == 1) {
            name = ConvertLib.bytes32ToString(producer[_addr].name);
            info = ConvertLib.bytes32ToString(producer[_addr].info);
            utype = "生产商";
        } else if(_type == 2) {
            name = ConvertLib.bytes32ToString(dealer[_addr].name);
            info = ConvertLib.bytes32ToString(dealer[_addr].info);
            utype = "经销商";
        } else if(_type == 3) {
            name = ConvertLib.bytes32ToString(retailer[_addr].name);
            info = ConvertLib.bytes32ToString(retailer[_addr].info);
            utype = "零售商";
        }
        string memory s = string(abi.encodePacked("{'Type':'",utype,"','Name':'",name,"','Info':'",info,"'}"));
        return s;
    }

    function querySale(bytes32 _id) public view returns (string memory, uint) {
        bytes32 buyer;
        string memory time;
        string memory price;
        string memory utype;
        uint s2;
        Actor a = sale[_id].actor;
        buyer = sale[_id].buyer;
        time = ConvertLib.bytes32ToString(sale[_id].saleTime);
        price = ConvertLib.bytes32ToString(sale[_id].salePrice);
        if(a == Actor.Dealer) {
            utype = "经销商";
            s2 = 2;
        } else if(a == Actor.Retailer) {
            utype = "零售商";
            s2 = 3;
        } else if(a == Actor.Customer) {
            utype = "消费者";
            s2 = 0;
        } else if(a == Actor.Producer) {
            utype = "生产商";
            s2 = 0;
        } 
        string memory buyerStr = ConvertLib.bytes32ToString(buyer);
        string memory s1 = string(abi.encodePacked("{'BuyerType':'",utype,"','Buyer':'",buyerStr,"','Time':'",time,"','Price':'",price,"'}"));
        return (s1, s2);
    }
}