// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SupplyChainProvenance is ERC721, AccessControl {

    /**
      * @notice Represents the roles that can interact with the provenance system.
      * Producers can:
      * - Register new product batch
      * - Update status
      * Distributors can:
      * - Transfer ownership
      * - Update status
      * Warehouse can:
      * - Receive
      * - Store
      * - Transfer ownership
      * - Update status
      * Retailer can:
      * - Transfer ownership
      * - Update status
      * Consumer can:
      * - View full history
      */
    bytes32 public constant PRODUCER_ROLE = keccak256("PRODUCER_ROLE");
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");
    bytes32 public constant WAREHOUSE_ROLE = keccak256("WAREHOUSE_ROLE");
    bytes32 public constant RETAILER_ROLE = keccak256("RETAILER_ROLE");
    bytes32 public constant CONSUMER_ROLE = keccak256("CONSUMER_ROLE");

    // Delete this later
    enum Role {
        Producer,
        Distributor,
        Warehouse,
        Retailer,
        Consumer
    }

    /**
      * @notice Represents the status of a product
      * Originated  - Product registered by producer
      * Shipped     - Product shipped
      * Delivered   - Product received by retailer
      * Sold        - Product sold to end consumer
      */
    enum ProductStatus {
        Originated,  // Producer registers batch; only Producer can update from Originated to Shipped
        Shipped,  // Distributor ships product
        InStorage,  // Only Warehouse can change status from Shipped to InStorage
        Delivered,  // Warehouse has sent the product to Retailer
        InStock,  // Retailer receives product
        Sold  // Retailer updates status from Delivered to Sold when Consumer buys product
    }

    /**
     * @notice Data structure for a product batch.
     * @param batchId       Unique id
     * @param productName   Human-readable product name
     * @param origin        Origin of the product
     * @param currentOwner  Address of the current owner in the supply chain
     * @param status        Current status
     * @param createdAt     Block timestamp when the product was registered
     * @param metadataHash  Hash pointing to off-chain metadata
     * @param exists        Flag to check if a batch has been registered
     */
    struct Product {
        uint256 batchId;
        string productName;
        string origin;
        address currentOwner;
        ProductStatus status;
        uint256 createdAt;
        string metadataHash;
        bool exists;
    }

    mapping(address => Role) public userRoles;
    uint256 private nextBatchId;
    mapping(uint256 => Product) private products;

    event ProductRegistered(uint256 indexed batchId, address indexed producer, string productName);
    event OwnershipTransferred(uint256 indexed batchId, address indexed from, address indexed to);
    event StatusUpdated(uint256 indexed batchId, ProductStatus newStatus);

    /**
      * @notice Deploys the contract
      */
    constructor() ERC721("SupplyChainProvenance", "SCP") {
        userRoles[msg.sender] = Role.Producer;
        nextBatchId = 1;
    }

    /**
     * @notice Registers a new product batch
     * @param productName  Name of the product being registered
     * @param origin       Origin location or entity of the product
     * @param metadataHash Hash pointing to product metadata
     * @return batchId     The assigned batch ID
     */
    function registerProduct(
        string calldata productName,
        string calldata origin,
        string calldata metadataHash
    ) external onlyRole(PRODUCER_ROLE) returns (uint256) {
        uint256 batchId = nextBatchId;
        nextBatchId++;

        products[batchId] = Product({
            batchId: batchId;
            productName: productName,
            origin: origin,
            currentOwner: msg.sender,
            status: ProductStatus.Originated,
            createdAt: block.timestamp,
            metadataHash: metadataHash,
            exists: true
        });

        _safeMint(msg.sender, batchId);

        return batchId;
    }

    /**
     * @notice Transfers ownership of a product batch to a new participant.
     * @param batchId   The product batch to transfer
     * @param newOwner  Address of the incoming owner
     */
    function transferProduct(
        uint256 batchId,
        address newOwner
    ) external {
        // TODO
    }

    /**
     * @notice Updates the status of a product batch.
     * @param batchId   The product batch to update
     * @param newStatus The new ProductStatus value
     */
    function updateStatus(
        uint256 batchId,
        ProductStatus newStatus
    ) external {
        // TODO
    }
    

    /**
     * @notice Marks a product as received by the calling warehouse or retailer.
     * @param batchId  The product batch being received
     */
    function receiveProduct(
      uint256 batchId
    ) external {
        // TODO
    }

    /**
     * @notice Marks a product as sold to an end consumer.
     * @param batchId  The product batch being sold
     */
    function markAsSold(uint256 batchId) external {
        // TODO
    }

    /**
     * @notice Returns all stored data for a given product batch.
     * @param batchId  The product batch to query
     * @return product The requested Product struct
     */
    function getProduct(uint256 batchId) external view returns (Product memory product) {
        // TODO
    }
}
