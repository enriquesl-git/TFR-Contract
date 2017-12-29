pragma solidity ^0.4.18;


//Declare owned , structure to admin functions only by the owner
contract owned {
	address public owner;
	function owned()internal{
	    owner=msg.sender;
	    
	}

	modifier onlyOwner {
		if (msg.sender != owner) revert();
		_;
	}

	//transfer owner property
	function transferOwnership(address newOwner) public onlyOwner {
		owner = newOwner;
	}
}

//Standard token ERC20 structure declaration

//
contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData)public ; }

contract token is owned{
	/* Public variables of the token */
	string public standard = "ERC20 TokenFederalReserve";
	string public name;
	string public symbol;
	uint8 public decimals;
	uint256 public totalSupply;

	/* This creates an array with all balances */
	mapping (address => uint256) public balanceOf;
	mapping (address => mapping (address => uint256)) public allowance;

	/* This generates a public event on the blockchain that will notify clients */
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);

	/* Initializes contract with initial supply tokens to the creator of the contract */
	function token(
		uint256 initialSupply,
		string tokenName,
		uint8 decimalUnits,
		string tokenSymbol
		) public {
		balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
		totalSupply = initialSupply;                        // Update total supply
		name = tokenName;                                   // Set the name for display purposes
		symbol = tokenSymbol;                               // Set the symbol for display purposes
		decimals = decimalUnits;                            // Amount of decimals for display purposes
	}

	/* Send coins */
	function transfer(address _to, uint256 _value) public {
		if (balanceOf[msg.sender] < _value) revert();           // Check if the sender has enough
		if (balanceOf[_to] + _value < balanceOf[_to]) revert(); // Check for overflows
		balanceOf[msg.sender] -= _value;                     // Subtract from the sender
		balanceOf[_to] += _value;                            // Add the same to the recipient
		Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
	}

	/* Allow another contract to spend some tokens in your behalf */
	function approve(address _spender, uint256 _value) public onlyOwner returns (bool success)  {
		allowance[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		return true;
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

	/* A contract attempts to get the coins */
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
		if (balanceOf[_from] < _value) revert();                 // Check if the sender has enough
		if (balanceOf[_to] + _value < balanceOf[_to]) revert();  // Check for overflows
		if (_value > allowance[_from][msg.sender]) revert();   // Check allowance
		balanceOf[_from] -= _value;                          // Subtract from the sender
		balanceOf[_to] += _value;                            // Add the same to the recipient
		allowance[_from][msg.sender] -= _value;
		Transfer(_from, _to, _value);
		return true;
	}

	/* This unnamed function is called whenever someone tries to send ether to it */
//	function () {
	//	buy();   // Allow to buy tokens sending ether direcly to contract
//	}
}

contract TokenFederalReserve is owned, token {

	//Declare public contract variables
	
	uint256 public minPrice=10000000000000;
	uint256 public buyPrice=10000000000000;
	uint256 public sellPrice=2000000000000;

	uint8 public spread=5;




	mapping (address => bool) public frozenAccount;

	/* This generates a public event on the blockchain that will notify clients */
	event FrozenFunds(address target, bool frozen);

	/* Initializes contract with initial supply tokens to the creator of the contract */
	function TokenFederalReserve(
		uint256 initialSupply,
		string tokenName,
		uint8 decimalUnits,
		string tokenSymbol
	) public token (initialSupply, tokenName, decimalUnits, tokenSymbol) {}

	/* Send coins */
	function transfer(address _to, uint256 _value) public {
		if (balanceOf[msg.sender] < _value) revert();           // Check if the sender has enough
		if (balanceOf[_to] + _value < balanceOf[_to]) revert(); // Check for overflows
		if (frozenAccount[msg.sender]) revert();                // Check if frozen
		balanceOf[msg.sender] -= _value;                     // Subtract from the sender
		balanceOf[_to] += _value;                            // Add the same to the recipient
		Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
	}


	/* A contract attempts to get the coins */
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
		if (frozenAccount[_from]) revert();                        // Check if frozen            
		if (balanceOf[_from] < _value) revert();                 // Check if the sender has enough
		if (balanceOf[_to] + _value < balanceOf[_to]) revert();  // Check for overflows
		if (_value > allowance[_from][msg.sender]) revert();   // Check allowance
		balanceOf[_from] -= _value;                          // Subtract from the sender
		balanceOf[_to] += _value;                            // Add the same to the recipient
		allowance[_from][msg.sender] -= _value;
		Transfer(_from, _to, _value);
		return true;
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
			if (balanceOf[msg.sender] + amount < balanceOf[msg.sender]) revert(); // Check for overflows
			if (balanceOf[this] < amount) revert();            // checks if it has enough to sell

			balanceOf[this] -= amount;                         // subtracts amount from seller's balance
			balanceOf[msg.sender] += amount;                   // adds the amount to buyer's balance

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
			if (balanceOf[this] + amount < balanceOf[this]) revert(); // Check for overflows
			if (balanceOf[msg.sender] < amount*(10**dec) ) revert();        // checks if the sender has enough to sell
		   

			if(sellPrice<minPrice) {
				sellPrice=minPrice-(minPrice*spread)/100;
		 
			}
			

			balanceOf[msg.sender] -= amount*(10**dec);                   // subtracts the amount from seller's balance
			balanceOf[this] += amount*(10**dec);                         // adds the amount to owner's balance
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

