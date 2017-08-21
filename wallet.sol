pragma solidity ^0.4.15;

contract etherDelta {
    function deposit() payable;
    function withdraw(uint amount);
    function depositToken(address token, uint amount);
    function withdrawToken(address token, uint amount);
    function balanceOf(address token, address user) constant returns (uint);
    function order(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce);
    function trade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount);
    function tradeBalances(address tokenGet, uint amountGet, address tokenGive, uint amountGive, address user, uint amount) private;
    function availableVolume(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s) constant returns(uint);
    function amountFilled(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s) constant returns(uint);
    function cancelOrder(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, uint8 v, bytes32 r, bytes32 s);
}

contract Token {
    function totalSupply() constant returns (uint256 supply);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
}

contract RemoteWallet {
    
    address public owner;
    string public version;
    etherDelta public deltaDeposits;
    address public ethDeltaDepositAddress;
    
    function RemoteWallet() {
        owner = msg.sender;
        version = "ALPHA 0.1";
        ethDeltaDepositAddress = 0x8d12A197cB00D4747a1fe03395095ce2A5CC6819;
        deltaDeposits = etherDelta(ethDeltaDepositAddress);
    }
    
    function() payable {
        
    }
    
    function tokenBalance(address tokenAddress) constant returns (uint) {
        Token token = Token(tokenAddress);
        return token.balanceOf(this);
    }
    
    function transferToken(address tokenAddress, address sendTo, uint256 amount) external {
        if (owner!=msg.sender) revert();
        Token token = Token(tokenAddress);
        token.transfer(sendTo, amount);
    }
    
    function transferFromToken(address tokenAddress, address sendTo, address sendFrom, uint256 amount) external {
        if (owner!=msg.sender) revert();
        Token token = Token(tokenAddress);
        token.transferFrom(sendTo, sendFrom, amount);
    }
    
    function changeEtherDeltaDeposit(address newEthDelta) external {
        if (owner!=msg.sender) revert();
        ethDeltaDepositAddress = newEthDelta;
        deltaDeposits = etherDelta(newEthDelta);
    }
    
    function changeOwner(address newOwner) external {
        if (owner!=msg.sender) revert();
        owner = newOwner;
    }
    
    function execute(address _to, uint _value, bytes _data) external returns (bytes32 _r) {
        if (owner!=msg.sender) revert();
        require(_to.call.value(_value)(_data));
        return 0;
    }
    
    function EtherDeltaWithdrawToken(address tokenAddress, uint amount) payable external {
        if (owner!=msg.sender) revert();
        deltaDeposits.withdrawToken(tokenAddress, amount);
    }
    
    function EtherDeltaDepositToken(address tokenAddress, uint amount) payable external {
        if (owner!=msg.sender) revert();
        deltaDeposits.depositToken(tokenAddress, amount);
    }
    
    function EtherDeltaApproveToken(address tokenAddress, uint amount) payable external {
        if (owner!=msg.sender) revert();
        Token token = Token(tokenAddress);
        token.approve(ethDeltaDepositAddress, amount);
    }
    
    function EtherDeltaDeposit(uint amount) payable external {
        if (owner!=msg.sender) revert();
        deltaDeposits.deposit.value(amount)();
    }
    
    function EtherDeltaWithdraw(uint amount) external {
        if (owner!=msg.sender) revert();
        deltaDeposits.withdraw(amount);
    }
    
}
