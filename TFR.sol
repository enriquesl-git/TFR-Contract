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


///////////////////////////////////////////////////////////////
//                                                           //
//  Token Federal Reserve, derived from OpenZeppelin ERC20.  //
//                                                           //
///////////////////////////////////////////////////////////////

contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData)public ; }

contract TokenFederalReserve is Ownable, StandardToken {

	/* Public variables of the token */
	string public standard = "ERC20 TokenFederalReserve";
	string public name;
	string public symbol;
	uint8 public decimals;
	uint256 public totalSupply;

	//Declare public contract variables
	
	uint256 public minPrice=10000000000000;
	uint256 public buyPrice=10000000000000;
	uint256 public sellPrice=2000000000000;

	uint8 public spread=5;

	mapping (address => bool) public frozenAccount;

	/* This generates a public event on the blockchain that will notify clients */
	event FrozenFunds(address target, bool frozen);

	/* Initializes contract with initial supply tokens to the creator of the contract */
	function token(
		uint256 initialSupply,
		string tokenName,
		uint8 decimalUnits,
		string tokenSymbol
		) public {
		balances[msg.sender] = initialSupply;              // Give the creator all initial tokens
		totalSupply = initialSupply;                        // Update total supply
		name = tokenName;                                   // Set the name for display purposes
		symbol = tokenSymbol;                               // Set the symbol for display purposes
		decimals = decimalUnits;                            // Amount of decimals for display purposes
	}


	/* Approve and then communicate the approved contract in a single tx */
	function approveAndCall(address _spender, uint256 _value, bytes _extraData) public onlyOwner
		returns (bool success)  {    
		tokenRecipient spender = tokenRecipient(_spender);
		if (approve(_spender, _value)) {
			spender.receiveApproval(msg.sender, _value, this, _extraData);
			return true;
		}
	}

	//Declare logging events
	event LogDeposit(address sender, uint amount);

	event LogBuy(address receiver, uint amount);
	event LogTransfer(address sender, address to, uint amount);


	function status() internal {


	//stablish the buy price & sell price with the spread configured in the contract
	
		buyPrice=(this.balance/totalSupply);
		sellPrice=buyPrice-(buyPrice*spread)/100;
		


	}




	function buy() public payable {
	

			if (frozenAccount[msg.sender]) revert();                        // Check if frozen   
				
				if(buyPrice<minPrice) {
				buyPrice=minPrice;
				}

			 if (msg.sender.balance < msg.value) revert();                 // Check if the sender has enought eth to buy
			 if (msg.sender.balance + msg.value < msg.sender.balance) revert(); //check for overflows
			 
			uint dec=decimals; 
					 
			uint amount = (msg.value / buyPrice)*(10**dec) ;                // calculates the amount
			 
			if (amount <= 0) revert();  //check amount overflow
			if (balances[msg.sender] + amount < balances[msg.sender]) revert(); // Check for overflows
			if (balances[this] < amount) revert();            // checks if it has enough to sell

			balances[this] -= amount;                         // subtracts amount from seller's balance
			balances[msg.sender] += amount;                   // adds the amount to buyer's balance

			Transfer(this, msg.sender, amount);         //send the tokens to the sendedr
				//update status variables of the contract
			status();

		
	}



	function deposit() public payable returns(bool success) {
	// Check for overflows;
		if (this.balance + msg.value < this.balance) revert(); // Check for overflows
   
	//executes event to reflect the changes
		LogDeposit(msg.sender, msg.value);
		
		//update contract status
		 status();
		return true;
	}





	function sell(uint256 amount) public {
	

		if (frozenAccount[msg.sender]) revert();                        // Check if frozen   
		   uint dec=decimals; 
			if (balances[this] + amount < balances[this]) revert(); // Check for overflows
			if (balances[msg.sender] < amount*(10**dec) ) revert();        // checks if the sender has enough to sell
		   

			if(sellPrice<minPrice) {
				sellPrice=minPrice-(minPrice*spread)/100;
		 
			}
			

			balances[msg.sender] -= amount*(10**dec);                   // subtracts the amount from seller's balance
			balances[this] += amount*(10**dec);                         // adds the amount to owner's balance
		// Sends ether to the seller. It's important
	  
 
		if (!msg.sender.send(amount*sellPrice)) {
			revert();                                         // to do this last to avoid recursion attacks
		} else {
			 // executes an event reflecting on the change
			 Transfer(msg.sender, this, amount*(10**dec));
			 //update contract status
			 status();

			
		}  
  
	}

    function () public payable {
		buy();   // Allow to buy tokens sending ether direcly to contract
	}
}
