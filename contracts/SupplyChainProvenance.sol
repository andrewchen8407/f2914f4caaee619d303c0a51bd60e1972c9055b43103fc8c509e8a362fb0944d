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
        Originated,
        InTransitToDistributor,
        AtDistributor,
        InTransitToWarehouse,
        AtWarehouse,
        InTransitToRetailer,
        AtRetailer,
        Sold
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
    // TODO: Check whether Warehouse and Retailer roles still need to be assigned
    // separately for demo/testing.
    constructor() ERC721("SupplyChainProvenance", "SCP") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PRODUCER_ROLE, msg.sender);
        _grantRole(DISTRIBUTOR_ROLE, msg.sender);
        _grantRole(WAREHOUSE_ROLE, msg.sender);
        _grantRole(RETAILER_ROLE, msg.sender);
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
     // TODO: Align transferProduct() with the new architecture diagram.

    // TODO: When transferring, also update status automatically:
    // Producer -> InTransitToDistributor
    // Distributor -> InTransitToWarehouse
    // Warehouse -> InTransitToRetailer
    //
    // Also restrict transfer path to:
    // Producer -> Distributor -> Warehouse -> Retailer
    function transferProduct(uint256 batchId, address newOwner) external {
        require(products[batchId].exists, "Product does not exist");
        require(ownerOf(batchId) == msg.sender, "Not current owner");

        // require(
        //     hasRole(PRODUCER_ROLE, msg.sender) ||
        //     hasRole(DISTRIBUTOR_ROLE, msg.sender) ||
        //     hasRole(WAREHOUSE_ROLE, msg.sender),
        //     "Not authorized to transfer"
        // );

        ProductStatus newStatus;

        if (hasRole(PRODUCER_ROLE, msg.sender)) {
            require(hasRole(DISTRIBUTOR_ROLE, newOwner), "Producer can only transfer to Distributor");
            newStatus = ProductStatus.InTransitToDistributor;
        }
        else if (hasRole(DISTRIBUTOR_ROLE, msg.sender)) {
            require(hasRole(WAREHOUSE_ROLE, newOwner), "Distributor can only transfer to Warehouse");
            newStatus = ProductStatus.InTransitToWarehouse;
        }
        else if (hasRole(WAREHOUSE_ROLE, msg.sender)) {
            require(hasRole(RETAILER_ROLE, newOwner), "Warehouse can only transfer to Retailer");
            newStatus = ProductStatus.InTransitToRetailer;
        }
        else {
            revert("Not authorized to transfer");
        }

        _transfer(msg.sender, newOwner, batchId);
        products[batchId].currentOwner = newOwner;
        console.log("Owner is:", ownerOf(batchId));
        products[batchId].status = newStatus;

        emit StatusUpdated(batchId, newStatus);
        emit OwnershipTransferred(batchId, msg.sender, newOwner);
    }

    // /**
    //  * @notice Updates the status of a product batch.
    //  * @param batchId The product batch to update
    //  * @param newStatus The new ProductStatus value
    //  */
    // // TODO: UpdatStatus can be removed.
    // // Status should no longer be changed manually.
    // // It should now be controlled only by:
    // // - registerProduct()
    // // - transferProduct()
    // // - receiveProduct()
    // // - markAsSold()
    // function updateStatus(uint256 batchId, ProductStatus newStatus) external {
    //     require(products[batchId].exists, "Product does not exist");
    //     console.log("Owner is:", ownerOf(batchId));

    //     // initially problematic; might have to investigate
    //     require(
    //         hasRole(PRODUCER_ROLE, msg.sender) ||
    //         hasRole(DISTRIBUTOR_ROLE, msg.sender) ||
    //         hasRole(WAREHOUSE_ROLE, msg.sender) ||
    //         hasRole(RETAILER_ROLE, msg.sender),
    //         "Not authorized to update status"
    //     );

    //     products[batchId].status = newStatus;
    //     emit StatusUpdated(batchId, newStatus);
    // }

    /**
     * @notice Marks a product as received by the calling warehouse or retailer.
     * @param batchId The product batch being received
     */
     // TODO: Align receiveProduct() with the new architecture diagram.
    // TODO: receiveProduct() should only confirm receipt, not change ownership.
    //
    // Add checks:
    // - caller must be current owner
    // - status must match the expected in-transit stage
    //
    // Then update status to:
    // Distributor -> AtDistributor
    // Warehouse -> AtWarehouse
    // Retailer -> AtRetailer
    function receiveProduct(uint256 batchId) external {
        require(products[batchId].exists, "Product does not exist");
        require(ownerOf(batchId) == msg.sender, "Only current owner can receive");

        // require(
        //     hasRole(DISTRIBUTOR_ROLE, msg.sender) ||
        //     hasRole(WAREHOUSE_ROLE, msg.sender) ||
        //     hasRole(RETAILER_ROLE, msg.sender),
        //     "Only Distributor, Warehouse and Retailer can receive"
        // );
        
        // if (hasRole(DISTRIBUTOR_ROLE, msg.sender)) {
        //     products[batchId].status = ProductStatus.AtDistributor;
        //     emit StatusUpdated(batchId, ProductStatus.AtDistributor);
        // }
        // else if (hasRole(WAREHOUSE_ROLE, msg.sender)) {
        //     products[batchId].status = ProductStatus.AtWarehouse;
        //     emit StatusUpdated(batchId, ProductStatus.AtWarehouse);
        // }
        // else if (hasRole(RETAILER_ROLE, msg.sender)) {
        //     products[batchId].status = ProductStatus.AtRetailer;
        //     emit StatusUpdated(batchId, ProductStatus.AtRetailer);
        // }
        // // else-block theoretically should not run
        // else {
        //     assert(false);
        // }

        ProductStatus current = products[batchId].status;
        ProductStatus newStatus;

        if (current == ProductStatus.InTransitToDistributor) {
            require(hasRole(DISTRIBUTOR_ROLE, msg.sender), "Only Distributor can receive");
            newStatus = ProductStatus.AtDistributor;
        }
        else if (current == ProductStatus.InTransitToWarehouse) {
            require(hasRole(WAREHOUSE_ROLE, msg.sender), "Only Warehouse can receive");
            newStatus = ProductStatus.AtWarehouse;
        }
        else if (current == ProductStatus.InTransitToRetailer) {
            require(hasRole(RETAILER_ROLE, msg.sender), "Only Retailer can receive");
            newStatus = ProductStatus.AtRetailer;
        }
        else {
            revert("Product is not in a valid transit state");
        }

        products[batchId].status = newStatus;
        emit StatusUpdated(batchId, newStatus);
    }

    /**
     * @notice Marks a product as sold to an end consumer.
     * @param batchId The product batch being sold
     */
    // TODO: markAsSold() should only be allowed when:
    // - caller is Retailer
    // - caller is current owner
    // - product status is AtRetailer
    // TODO: Decide whether "sold" means only Product.currentOwner = address(0),
    // or whether ERC721 ownership should also be changed/burned.
    function markAsSold(uint256 batchId) external onlyRole(RETAILER_ROLE) {
        require(products[batchId].exists, "Product does not exist");
        require(products[batchId].status == ProductStatus.AtRetailer, "Product must be at retailer");

        products[batchId].currentOwner = address(0);
        products[batchId].status = ProductStatus.Sold;
        emit StatusUpdated(batchId, ProductStatus.Sold);
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
