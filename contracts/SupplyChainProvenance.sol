// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "hardhat/console.sol";

contract SupplyChainProvenance is ERC721, AccessControl {

    bytes32 public constant PRODUCER_ROLE = keccak256("PRODUCER_ROLE");
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");
    bytes32 public constant WAREHOUSE_ROLE = keccak256("WAREHOUSE_ROLE");
    bytes32 public constant RETAILER_ROLE = keccak256("RETAILER_ROLE");

    uint256 private _nextTokenId = 1;

    /**
      * @notice Represents the status of a product
      * Originated - Product registered by producer
      * Shipped - Product shipped
      * Delivered - Product sent to retailer by warehouse
      * InStock - Product received by retailer
      * Sold - Product sold to end consumer
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
     * @param batchId Unique id
     * @param productName Human-readable product name
     * @param origin Origin of the product
     * @param currentOwner Address of the current owner in the supply chain
     * @param status Current status
     * @param createdAt Block timestamp when the product was registered
     * @param metadataHash Hash pointing to off-chain metadata
     * @param exists Flag to check if a batch has been registered
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

    mapping(uint256 => Product) private products;

    event ProductMinted(uint256 indexed batchId, address indexed producer, string productName);
    event OwnershipTransferred(uint256 indexed batchId, address indexed from, address indexed to);
    event StatusUpdated(uint256 indexed batchId, ProductStatus newStatus);

    /**
     * @notice Deploys the contract
     */
    constructor() ERC721("SupplyChainProvenance", "SCP") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PRODUCER_ROLE, msg.sender);
        _grantRole(DISTRIBUTOR_ROLE, msg.sender);
    }

    /**
     * @notice Registers a new product batch
     * @param productName  Name of the product being registered
     * @param origin Origin location or entity of the product
     * @param metadataHash Hash pointing to product metadata
     * @return batchId The assigned batch ID
     */
    function registerProduct(
        string calldata productName,
        string calldata origin,
        string calldata metadataHash
    ) external onlyRole(PRODUCER_ROLE) returns (uint256 batchId) {
        batchId = _nextTokenId;
        _nextTokenId++;

        products[batchId] = Product({
            batchId: batchId,
            productName: productName,
            origin: origin,
            currentOwner: msg.sender,
            status: ProductStatus.Originated,
            createdAt: block.timestamp,
            metadataHash: metadataHash,
            exists: true
        });

        _mint(msg.sender, batchId);
        emit ProductMinted(batchId, msg.sender, productName);
        console.log("Owner is:", ownerOf(batchId));
        return batchId;
    }

    /**
     * @notice Transfers ownership of a product batch to a new participant.
     * @param batchId The product batch to transfer
     * @param newOwner Address of the incoming owner
     */
    function transferProduct(uint256 batchId, address newOwner) external {
        require(products[batchId].exists, "Product does not exist");
        require(ownerOf(batchId) == msg.sender, "Not current owner");

        require(
            hasRole(PRODUCER_ROLE, msg.sender) ||
            hasRole(DISTRIBUTOR_ROLE, msg.sender) ||
            hasRole(WAREHOUSE_ROLE, msg.sender) ||
            hasRole(RETAILER_ROLE, msg.sender),
            "Not authorized to transfer"
        );

        _transfer(msg.sender, newOwner, batchId);
        products[batchId].currentOwner = newOwner;
        console.log("Owner is:", ownerOf(batchId));
        emit OwnershipTransferred(batchId, msg.sender, newOwner);
    }

    /**
     * @notice Updates the status of a product batch.
     * @param batchId The product batch to update
     * @param newStatus The new ProductStatus value
     */
    function updateStatus(uint256 batchId, ProductStatus newStatus) external {
        require(products[batchId].exists, "Product does not exist");
        console.log("Owner is:", ownerOf(batchId));

        // initially problematic; might have to investigate
        require(
            hasRole(PRODUCER_ROLE, msg.sender) ||
            hasRole(DISTRIBUTOR_ROLE, msg.sender) ||
            hasRole(WAREHOUSE_ROLE, msg.sender) ||
            hasRole(RETAILER_ROLE, msg.sender),
            "Not authorized to update status"
        );

        products[batchId].status = newStatus;
        emit StatusUpdated(batchId, newStatus);
    }

    /**
     * @notice Marks a product as received by the calling warehouse or retailer.
     * @param batchId The product batch being received
     */
    function receiveProduct(uint256 batchId) external {
        require(products[batchId].exists, "Product does not exist");
        require(
            hasRole(WAREHOUSE_ROLE, msg.sender) ||
            hasRole(RETAILER_ROLE, msg.sender),
            "Only Warehouse or Retailer can receive"
        );
        
        if (hasRole(WAREHOUSE_ROLE, msg.sender)) {
            products[batchId].status = ProductStatus.InStorage;
        }
        else if (hasRole(RETAILER_ROLE, msg.sender)) {
            products[batchId].status = ProductStatus.InStock;
        }
        // else-block theoretically should not run
        else {
            products[batchId].status = ProductStatus.Delivered;
        }
    }

    /**
     * @notice Marks a product as sold to an end consumer.
     * @param batchId The product batch being sold
     */
    function markAsSold(uint256 batchId) external {
        require(products[batchId].exists, "Product does not exist");
        require(hasRole(RETAILER_ROLE, msg.sender), "Only Retailer can mark as sold");
        products[batchId].status = ProductStatus.Sold;
    }

    /**
     * @notice Returns all stored data for a given product batch.
     * @param batchId The product batch to query
     * @return product The requested Product struct
     */
    function getProduct(uint256 batchId) external view returns (Product memory) {
        require(products[batchId].exists, "Product does not exist");
        return products[batchId];
    }

    function supportsInterface(bytes4 interfaceId)
        public view override(ERC721, AccessControl) returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
