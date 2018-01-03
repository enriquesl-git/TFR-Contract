# TFR-Contract

## Reestructured contract, forked from TokenFederalReserve/TFR-Contract, with some corrections and improvements. 

### Main ideas for strategic refactoring

Clear separation between ERC20, which is taken from OpenZeppeling.org (OpenZeppelin/zeppelin-solidity), and the specific functions of main contract: deposit, buy, sell and few other helper internal functions, and the required extra ERC20 function approveAndCall. 

'buy' and 'sell' now use the ERC20 functions 'transfer' and 'transferFrom', so that most of the code is removed (as it is included in those functions), and the checks are better done, using implicitly safe math operations, overflow checks, and balance checks. 

Also, 'status()' is changed from function to modifier, and the check for minPrice has been moved there. It simplifies the 3 functions that use it: buy, sell and deposit. 


### Secondary changes

Constants don't consume gas, used now for 'decimals', which is hardcoded to 8 and removed from constructor arguments, and for 'minPrice'. Instead, 'spread' is added to constructor arguments in order that the creator decides it without modifing code. 

'spread' is also expressed in parts per 100 million, in order to manage more digits instead of integer percentage. That way, fixed point percentages have just to be multiplied by 1e6, so that 2.5% should be written 2.5e6. 

Some style and reordering was done, including the use of require and assert as recommended. 


### Extra corrections from the original forked contract: 

- sellPrice was wrongly recalculated when it is less than minPrice, producing a de facto spread greater than the proper one; comparation should be with respect to minPrice minus spread
- used 'transfer' instead of 'send' in function 'sell', to minimize reentrance problems
- amount was calculated 4 times with the same operations in function sell, now a variable is used to calculate it just once
- literal 10 cast to uint(10), in order to avoid warning of overflow in 10**decimals

