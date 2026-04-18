const hre = require("hardhat");

async function main() {
  const [producer, distributor, warehouse, retailer, consumer] = await hre.ethers.getSigners();

  const SupplyChainProvenance = await hre.ethers.getContractFactory("SupplyChainProvenance");
  const contract = await SupplyChainProvenance.deploy();
  await contract.waitForDeployment();

  console.log("[+] Contract deployed at:", contract.target);

  // Grant roles for the demo accounts
  await (await contract.grantRole(await contract.DISTRIBUTOR_ROLE(), distributor.address)).wait();
  await (await contract.grantRole(await contract.WAREHOUSE_ROLE(), warehouse.address)).wait();
  await (await contract.grantRole(await contract.RETAILER_ROLE(), retailer.address)).wait();

  console.log("[+] Roles granted to Distributor, Warehouse, and Retailer");

  // 1. Producer registers product
  const tx1 = await contract.connect(producer).registerProduct(
    "Organic Soybean Batch #1",
    "Canada",
    "ipfs://QmExampleHash123"
  );
  await tx1.wait();
  console.log("[+] Producer registered product -> Batch ID: 1");

  let product = await contract.getProduct(1);
  console.log("[i] Current status after register:", product.status.toString());
  console.log("[i] Current owner after register:", product.currentOwner);

  // 2. Producer transfers product to Distributor
  const tx2 = await contract.connect(producer).transferProduct(1, distributor.address);
  await tx2.wait();
  console.log("[+] Producer transferred product to Distributor");

  product = await contract.getProduct(1);
  console.log("[i] Current status after Producer transfer:", product.status.toString());
  console.log("[i] Current owner after Producer transfer:", product.currentOwner);

  // 3. Distributor receives product
  const tx3 = await contract.connect(distributor).receiveProduct(1);
  await tx3.wait();
  console.log("[+] Distributor received product");

  product = await contract.getProduct(1);
  console.log("[i] Current status after Distributor receive:", product.status.toString());
  console.log("[i] Current owner after Distributor receive:", product.currentOwner);

  // 4. Distributor transfers product to Warehouse
  const tx4 = await contract.connect(distributor).transferProduct(1, warehouse.address);
  await tx4.wait();
  console.log("[+] Distributor transferred product to Warehouse");

  product = await contract.getProduct(1);
  console.log("[i] Current status after Distributor transfer:", product.status.toString());
  console.log("[i] Current owner after Distributor transfer:", product.currentOwner);

  // 5. Warehouse receives product
  const tx5 = await contract.connect(warehouse).receiveProduct(1);
  await tx5.wait();
  console.log("[+] Warehouse received product");

  product = await contract.getProduct(1);
  console.log("[i] Current status after Warehouse receive:", product.status.toString());
  console.log("[i] Current owner after Warehouse receive:", product.currentOwner);

  // 6. Warehouse transfers product to Retailer
  const tx6 = await contract.connect(warehouse).transferProduct(1, retailer.address);
  await tx6.wait();
  console.log("[+] Warehouse transferred product to Retailer");

  product = await contract.getProduct(1);
  console.log("[i] Current status after Warehouse transfer:", product.status.toString());
  console.log("[i] Current owner after Warehouse transfer:", product.currentOwner);

  // 7. Retailer receives product
  const tx7 = await contract.connect(retailer).receiveProduct(1);
  await tx7.wait();
  console.log("[+] Retailer received product");

  product = await contract.getProduct(1);
  console.log("[i] Current status after Retailer receive:", product.status.toString());
  console.log("[i] Current owner after Retailer receive:", product.currentOwner);

  // 8. Retailer marks product as sold
  const tx8 = await contract.connect(retailer).markAsSold(1);
  await tx8.wait();
  console.log("[+] Retailer marked product as sold");

  product = await contract.getProduct(1);
  console.log("[i] Final status after sale:", product.status.toString());
  console.log("[i] Final business owner after sale:", product.currentOwner);

  console.log("[+] Full Producer -> Distributor -> Warehouse -> Retailer -> Sold workflow completed successfully");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
})