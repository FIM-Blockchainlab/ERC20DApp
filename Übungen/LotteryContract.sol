pragma solidity ^0.5.0;
contract lottery{
    struct Deposit  {
        address payable sender;
        uint8 number;
        uint blockNumber;
    }
    Deposit[] public deposits;
    uint public jackpot = 0; 
    function depositValue(uint8 number) payable public{
        require(msg.value == 100000, "Wrong value. 100000 Wei");
        require(number <= 15, "Number Range 0-15");
        deposits.push( Deposit({
            sender : address(msg.sender), 
            number : number,
            blockNumber: block.number
        })); 
        jackpot += msg.value; 
    }
    function checkWin() public view returns (bool success, uint index){
        for(uint i = 0; i < deposits.length; i++){
            if(address(msg.sender)==deposits[i].sender){
                uint8 rand =   blockhashToUint8(blockhash(deposits[i].blockNumber));
                if(rand /16 == deposits[i].number){
                    return (true,  i);
                }
            }
        }
        return (false, 0); 
    }
    function payoutWin() public {
        (bool jackpotWon, uint index)  = checkWin();  
        require(jackpotWon, "No Jackpot won"); 
        uint8 rand =  blockhashToUint8(blockhash(deposits[index].blockNumber)) ;
        if(rand  == deposits[index].number){
            deposits[index].sender.transfer(jackpot);
            jackpot = 0; 
            delete deposits;
        }
    }
    function blockhashToUint8(bytes32  b) public pure returns (uint8){
        //Picks last byte of blockhash (32 bytes = 64 digits)
        return uint8(b[31]);
    }

 
}