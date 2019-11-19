/*
  Lerninhalt:
    Versenden von Ether
    Contract haelt Ether
    Zugriffberechtigung nur fuer Owner
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

    uint8 public constant DECIMALS = 2;

    uint256 public INITIAL_AMOUNT = 100000;

    address public owner;

    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    uint256 public tokenInWei = 1000;
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    mapping (address => uint256) public balances;

    mapping (address => mapping (address => uint256)) public allowed;

    constructor() public {
        totalSupply = INITIAL_AMOUNT;
        balances[address(this)] = INITIAL_AMOUNT;
        owner = msg.sender;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {

        require(balances[msg.sender] >= _value, "Sender has not enought Token");

        balances[msg.sender] -= _value;
        balances[_to] += _value;

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
    function setTokenInWei(uint256 _value) public {
        require(msg.sender == owner);
        tokenInWei = _value;
    }

    function getTokenInWei() public view returns(uint256){
        return tokenInWei;
    }

    function buy(uint256 _amount) payable public {
      uint256 cost = tokenInWei * _amount;
      require(msg.value >= cost);

      if(msg.value > cost) {
        msg.sender.transfer(msg.value - cost);
      }

      balances[address(this)] -= _amount;

      balances[msg.sender] += _amount;
      emit Transfer(address(this), msg.sender, _amount);
    }

    function getAmountOfWeiFromContract() public view returns (uint256){
      require(msg.sender == owner);

      return address(this).balance;
    }

    function getWeiFromContract(uint256 _amount) public {
        require(msg.sender == owner);
        require(address(this).balance >= _amount);

        msg.sender.transfer(_amount);
    }

    function tokenLeft() public view returns (uint256){
        return balances[address(this)];
    }

    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
}
