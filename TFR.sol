pragma solidity ^0.4.19;


/////////////////////////////////////////////////////////
//                                                     //
//  ERC20 tokens, taken from OpenZeppelin.org.         //
//  Includes Ownable contract and SafeMath library.    //
//                                                     //
/////////////////////////////////////////////////////////

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


//////////////////////////////////////////////////////////////
//                                                          //
//  Token Federal Reserve, derived from OpenZeppelin ERC20  //
//                                                          //
//////////////////////////////////////////////////////////////


contract TokenFederalReserve is Ownable, StandardToken {

    string public constant standard = "ERC20 TokenFederalReserve";

    /* Public variables for the ERC20 token, defined when calling the constructor */
    string public name;
    string public symbol;
    uint8 public constant decimals = 8; // hardcoded to be a constant

    // Contract variables and constants
    uint256 public constant minPrice = 10e12;
    uint256 public buyPrice = minPrice;
    uint256 public sellPrice = applySpread(buyPrice);
    // constant to simplify conversion of token amounts into integer form
    uint256 private constant tokenUnit = uint(10)**decimals;
    
    // Spread in parts per 100 millions, such that expressing percentages is 
    // just to append the postfix 'e6'. For example, 4.53% is: spread = 4.53e6
    uint256 public spread;

    //Declare logging events
    event LogDeposit(address sender, uint amount);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function TokenFederalReserve(uint256 initialSupply, string tokenName, string tokenSymbol, uint256 tokenSpread) public {
        balances[msg.sender] = initialSupply; // Give the creator all initial tokens
        totalSupply = initialSupply;  // Update total supply
        name = tokenName;             // Set the name for display purposes
        symbol = tokenSymbol;         // Set the symbol for display purposes
        spread = tokenSpread;         // Amount of spread in parts per 100 millions
    }

    function () public payable {
        buy();   // Allow to buy tokens sending ether direcly to contract
    }
    
    function applySpread(uint256 askPrice) private view returns (uint256 bidPrice) {
        bidPrice = askPrice - (spread * askPrice) / 100e6;
        return bidPrice;
    }

    modifier status() {
        _;  // modified function code should go before prices update

        //stablish the buy price & sell price with the spread configured in the contract
        buyPrice = this.balance / totalSupply;

        if (buyPrice < minPrice) {
            buyPrice = minPrice;
        }
        sellPrice = applySpread(buyPrice);
    }

    function deposit() public payable status returns(bool success) {
        // Check for overflows;
        assert (this.balance + msg.value >= this.balance); // Check for overflows
   
        //executes event to reflect the changes
        LogDeposit(msg.sender, msg.value);
        
        return true;
    }

    function buy() public payable status {
        require (msg.sender.balance >= msg.value);  // Check if the sender has enought eth to buy
        assert (msg.sender.balance + msg.value >= msg.sender.balance); //check for overflows
         
        uint tokenAmount = (msg.value * tokenUnit) / buyPrice ;  // calculates the amount
        transfer(msg.sender, tokenAmount);
    }

    function sell(uint256 amount) public status {
        uint tokenAmount = amount * tokenUnit;
        uint etherAmount = amount * sellPrice;

        transferFrom(msg.sender, this, tokenAmount);

        // Sends ether to the seller. It's important
        // to do this last to avoid recursion attacks
        msg.sender.transfer(etherAmount);
    }

    /* Approve and then communicate the approved contract in a single tx */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public onlyOwner returns (bool success) {    

        tokenRecipient spender = tokenRecipient(_spender);

        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
}


contract tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public ; 
}

