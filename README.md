# f2914f4caaee619d303c0a51bd60e1972c9055b43103fc8c509e8a362fb0944d
"ASU CSE 540 Spring 2026 Team 13 Blockchain-Based Supply Chain Provenance System"

# CSE 540 Engineering Blockchain Applications | 2026 Spring B | Team 13 | Tokenized Asset Tracking System

This project implements a **Tokenized Asset Tracking System** on the Polygon Amoy testnet. Each product batch is represented as a unique ERC-721 NFT that records its full provenance (origin, custody transfers, status updates) on an immutable blockchain ledger. The system creates a transparent, traceable, and trustworthy record for products moving through the supply chain.

## Smart Contract (Interim Demo)
`SupplyChainProvenance.sol` – ERC-721 + AccessControl implementation with proper role enforcement.

## Dependencies
```bash
Node.js == 20.0.0
Hardhat == 2.19.0
OpenZeppelin Contracts == 5.0.0
Ethers.js == 6.16.0
Solidity == 0.8.20
React == 18.3.1
```

## Network & Infrastructure
IPFS - Used for decentralized storage of rich metadata and certificates
MetaMask - Latest browser extension version
Polygon Amoy Testnet - Currency (POL)

## Setup Instructions
**Clone the repository:**
```bash
git clone https://github.com/andrewchen8407/f2914f4caaee619d303c0a51bd60e1972c9055b43103fc8c509e8a362fb0944d.git
cd f2914f4caaee619d303c0a51bd60e1972c9055b43103fc8c509e8a362fb0944d

**Install dependencies:**
npm install
```

## Usage & Deployment
To compile the smart contracts and generate artifacts, then run the code:
```bash
npx hardhat compile
npx hardhat run scripts/demo.js --network hardhat
```

## Deploying to Polygon Amoy Testnet
To deploy the contract to the live testnet environment
1. Ensure your MetaMask wallet is connected to Polygon Amoy.
2. Obtain test POL tokens from the [Polygon Faucet](https://faucet.polygon.technology/)
3. Run the deployment script:
```bash
npx hardhat run [deploy script] --network amoy
```

## Product information, roles, and actions
Every product log has the following information:
- Product Batch ID
- CreatedAt Timestamp (yyyy-mm-dd hh:mm:ss) 
- Who created the product
- Status of the product (Shipped, Received)
- Current owner of the product

Roles and Authorized Actions:
- Producer 
- Create/Register new product batch
	- Update status 
- Distributor
	- Transfer ownership
	- Update status
- Warehouse
	- Receive
	- Store
	- Transfer ownership
	- Update status
- Retailer
	- Transfer ownership (receive or sell)
	- Update status
- Consumer
	- View full history / provenance (read-only)

## Class variables
- ProductBatch
- batchId (uint256)
- metadataHash (bytes32, linked to IPFS)
- creator (address)
- currentOwner (address)
- status (ProductStatus)
- createdAt (timestamp)

     struct Product {
uint256 batchId;
string productName;
string origin;
address currentOwner;
Status status;
uint256 createdAt;
string metadataHash;
bool exists;
}

## Core Functions
- registerProduct(uint256 batchId, bytes32 metadataHash)
- transferProduct(uint256 batchId, address newOwner)
- updateStatus(uint256 batchId, ProductStatus newStatus)
- receiveProduct(uint256 batchId)
- markAsSold(uint256 batchId)
- getProduct(uint256 batchId)
- getProductHistory(uint256 batchId)

## High-Level Contract Design Comments

## Roles
Defines the business roles that can modify product lifecycle data and their permissions.

enum Role:
- Producer: creates new product batches
- Distributor: transports and transfers products
- Warehouse: stores and forwards products
- Retailer: final receiver and seller

## Consumer Access
Consumers are read-only participants and do not require explicit role assignment.
Consumers can:
- View product details
- Check current ownership
- View product provenance history
- Confirm sale status

## ProductStatus
Represents the lifecycle state of a product batch.

enum 
- ProductStatus: (Originated, Shipped, Received, Delivered, Sold)
- CreatedAt: product is registered by producer
- InTransit: product is being transported
- Stored: product is stored in warehouse
- Received: product is received by retailer
- IsSold: product is sold to end consumer

## Core Logic
- Only authorized roles can perform write operations
- Consumers use public read functions for provenance verification
- Ownership transfer reflects real-world product movement
- Status updates track lifecycle stages
- All major actions emit blockchain events for transparency
