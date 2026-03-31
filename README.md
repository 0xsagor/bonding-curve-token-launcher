# Bonding Curve Token Launcher

A professional-grade implementation of a Bonding Curve contract. This repository allows a project to launch a token without an initial exchange listing. The contract acts as the market maker, minting tokens as users buy them and burning them as users sell them back, following a strict mathematical price function.

## Core Features
* **Automated Market Maker:** The price is a function of the current total supply: $P = f(S)$.
* **Guaranteed Liquidity:** Every token in circulation is backed by the reserve asset (ETH/USDC) held in the contract.
* **Instant Exit:** Users can sell back to the contract at any time, receiving the reserve asset based on the curve.
* **Flat Structure:** Contains the math engine, the ERC-20 logic, and the buy/sell interface in a single directory.

## Price Logic
This implementation uses a Linear Bonding Curve:
$$Price = slope \cdot Supply + initialPrice$$

## Setup
1. `npm install`
2. Deploy `BondingCurveToken.sol` with your desired slope and reserve asset address.
3. Call `buy()` with the reserve asset to mint new tokens.
