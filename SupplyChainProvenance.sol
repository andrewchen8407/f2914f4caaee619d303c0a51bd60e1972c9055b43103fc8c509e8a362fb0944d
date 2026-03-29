pragma solidity ^0.8.20;


contract SupplyChainProvenance {

    /**
      * @notice Represents the roles that can interact with the provenance system.
      * Producers:
      * - can register new product batch
      * - can update status
      * Distributors:
      * - can transfer ownership
      * - can update status
      * Warehouse:
      * - can receive
      * - can store
      * - can transfer ownership
      * - can update status
      * Retailer:
      * - can transfer ownership
      * - can update status
      * Consumer:
      * - can view full history
      */
    enum Role {
        Producer,
        Distributor,
        Warehouse,
        Retailer,
        Consumer,
    }

    /**
      * @notice Represents the status of a product
      * Originated  - Product registered by producer
      * Shipped     - Product shipped
      * Delivered   - Product received by retailer
      * Sold        - Product sold to end consumer
      */
    enum ProductStatus {
        Originated,
        Shipped,
        Received,
        Delivered,
        Sold,
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

    /**
      * @notice Deploys the contract
      */
    constructor() {
        // TODO: set up permission stuff
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
    ) external returns (uint256 batchId) {
        // TODO
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
    function markAsSold(uint256 batchId) external onlyRole(RETAILER_ROLE) {
        // TODO
    }

    /**
     * @notice Returns all stored data for a given product batch.
     * @param batchId  The product batch to query
     * @return product The requested Product struct
     */
    function getProduct(uint256 batchId) external view returns (Product product) {
        // TODO
    }
}
