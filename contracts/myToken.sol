pragma solidity ^0.6.0;

import "./IERC20.sol";
import "./Context.sol";
import "./SafeMath.sol";
//using SafeMath for uint256;

contract myToken is Context,IERC20 {
    using SafeMath for uint256;

    //contract's variables
    uint256 public _totalSupply;
    string public _ticker;
    uint8 public _decimalNumber;
    address public contractOwner;
    uint public nbBuyers;

    //contract's mappings
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping( address => bool ) public whiteList;

    //contract's constructor
    constructor() public{
        _totalSupply = 1000000000;
        _ticker = "MTK";
        _decimalNumber = 18;
        contractOwner = msg.sender;
        nbBuyers = 0;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    //contract's modifiers
    modifier onlyOwner(){
        require(msg.sender == contractOwner, "You are not allowed to whitelisted an address.");
        _;
    }

    //contract's classical functions
    function totalSupply() public override  view returns(uint){
        return _totalSupply - _balances[address(0)];
    }

    function balanceOf(address tokenOwner) public override view returns(uint balance){
        return _balances[tokenOwner];
    }

    function allowance( address tokenOwner, address spender) public override view returns(uint remaining){
        return _allowances[tokenOwner][spender];
    }

    function approve(address spender, uint tokens) public override returns (bool success){
        _allowances[msg.sender][spender] = tokens;
        emit Approval(msg.sender,spender,tokens);
        return true;
    }

    function transfer(address to, uint tokens) public override returns (bool success){
        _balances[msg.sender] = SafeMath.sub(_balances[msg.sender], tokens);
        _balances[to] = SafeMath.add(_balances[to], tokens);

        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public override returns (bool success){
        _balances[from] = SafeMath.sub(_balances[from], tokens);
        _allowances[from][msg.sender] = SafeMath.sub(_allowances[from][msg.sender],tokens);
        _balances[to] = SafeMath.add(_balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    //[WHITE LIST] -----------------------------------------------------------------
    //creation of a whitelist events
    event newAddressWhitelisted(address _address); //when you add an address to a white list
    event addressBlacklisted(address _address); //when you delete an address from a whitelist

    //only the owner of the contract can add an address to the whitelist
    function addWhiteList( address _newAddress) public payable onlyOwner(){
        whiteList[_newAddress] = true;
        emit newAddressWhitelisted(_newAddress);
    }

    function deleteWhiteList( address _address) public payable onlyOwner(){
        delete whiteList[_address];
        emit addressBlacklisted(_address);
    }


    //[MULTI LEVEL DISTRIBUTION] ---------------------------------------------------

    //events that broadcast the change rate for each transaction & the nb of buyers
    event txChangeRate(uint changeRate);
    event nbOfBuyers(uint nb);

    //function buy token
    function airDrop(address to, uint etherAmount) public {
        uint changeRate;
        if (nbBuyers < 100){
            changeRate = 50;
            transfer(to,changeRate*etherAmount);
        }
        else if (nbBuyers < 500){
            changeRate = 20;
            transfer(to,changeRate*etherAmount);
        }
        else if (nbBuyers < 1000){
            changeRate = 10;
            transfer(to,changeRate*etherAmount);
        }
        else{
            changeRate = 3;
            transfer(to,changeRate*etherAmount);
        }
        emit txChangeRate(changeRate);
        nbBuyers++;
        emit nbOfBuyers(nbBuyers);
    }
}