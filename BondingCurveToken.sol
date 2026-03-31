// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract BondingCurveToken is ERC20, ReentrancyGuard {
    uint256 public constant SCALE = 10**18;
    uint256 public immutable slope;
    uint256 public immutable initialPrice;
    
    uint256 public poolBalance;

    event Minted(address indexed buyer, uint256 amount, uint256 cost);
    event Burned(address indexed seller, uint256 amount, uint256 refund);

    constructor(
        string memory name, 
        string memory symbol, 
        uint256 _slope, 
        uint256 _initialPrice
    ) ERC20(name, symbol) {
        slope = _slope;
        initialPrice = _initialPrice;
    }

    /**
     * @dev Simple linear integral to calculate cost for amount
     * Cost = integral from S to S+n of (slope*x + initialPrice)
     */
    function calculateMintCost(uint256 _amount) public view returns (uint256) {
        uint256 s = totalSupply();
        uint256 n = _amount;
        
        // Cost = n * (initialPrice + (slope * (2*s + n) / 2)) / SCALE
        uint256 cost = n * (initialPrice + (slope * (2 * s + n)) / (2 * SCALE)) / SCALE;
        return cost;
    }

    function buy(uint256 _amount) external payable nonReentrant {
        uint256 cost = calculateMintCost(_amount);
        require(msg.value >= cost, "Insufficient ETH sent");

        poolBalance += cost;
        _mint(msg.sender, _amount);
        
        if (msg.value > cost) {
            payable(msg.sender).transfer(msg.value - cost);
        }
        
        emit Minted(msg.sender, _amount, cost);
    }

    function sell(uint256 _amount) external nonReentrant {
        require(balanceOf(msg.sender) >= _amount, "Insufficient balance");
        
        // Simple linear integral for refund (calculating previous step)
        uint256 s = totalSupply();
        uint256 n = _amount;
        uint256 refund = n * (initialPrice + (slope * (2 * s - n)) / (2 * SCALE)) / SCALE;

        poolBalance -= refund;
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(refund);
        
        emit Burned(msg.sender, _amount, refund);
    }

    receive() external payable {
        // Fallback for simple ETH transfers if needed
    }
}
