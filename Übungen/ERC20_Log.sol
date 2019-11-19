/*
  Lerninhalt:
    Erstellen einer Struct
    Initialisierung von Arrays innerhalb und außerhalb von Funktionen
    Handhabung von Arrays
    Handhabung von For-Schleifen
*/

pragma solidity ^0.5.0;

contract ERC20Interface {

    uint256 public totalSupply;

    function balanceOf(address _owner) public view returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}


contract ERC20 is ERC20Interface {

    string public constant NAME = "FIM Token";

    string public constant SYMBOL = "FIM";

    uint8 public constant DECIMALS = 18;

    uint256 public INITIAL_AMOUNT = 100000;

    address public owner;
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    struct Log {
      address from;
      address to;
      uint256 value;
      uint256 timeStamp;
    }

    Log[] public logs;
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    mapping (address => uint256) public balances;

    mapping (address => mapping (address => uint256)) public allowed;

    constructor() public {
        totalSupply = INITIAL_AMOUNT;
        balances[msg.sender] = INITIAL_AMOUNT;
        owner = msg.sender;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {

        require(balances[msg.sender] >= _value, "Sender has not enought Token");

        balances[msg.sender] -= _value;
        balances[_to] += _value;
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        generateLog(msg.sender, _to, _value);
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][_to];
        require(balances[_from] >= _value, "Sender has not enought Token");
        require(allowance >= _value, "There is no allowance for this value");

        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        generateLog(_from, _to, _value);
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    function generateLog(address _from, address _to, uint256 _value) public {
      logs.push(Log({
        from: _from,
        to: _to,
        value: _value,
        timeStamp: now
      }));
    }

    function getLog() public view returns (address[] memory from, address[] memory to, uint256[] memory value, uint256[] memory  timeStamp){
      uint256 length = logs.length;
      address[] memory logTo = new address[](length);
      address[] memory logFrom = new address[](length);
      uint256[] memory logValue = new uint256[](length);
      uint256[] memory logTimeStamp = new uint256[](length);

      for(uint i = 0; i < length; i++){
        logTo[i] = logs[i].to;
        logFrom[i] = logs[i].from;
        logValue[i] = logs[i].value;
        logTimeStamp[i] = logs[i].timeStamp;
      }

      return (logTo, logFrom, logValue, logTimeStamp);
    }
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

}
