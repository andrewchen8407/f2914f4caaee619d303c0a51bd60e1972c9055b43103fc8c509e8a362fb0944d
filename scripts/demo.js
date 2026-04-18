const hre = require("hardhat");

async function main() {
  const [producer, distributor, warehouse, retailer, consumer] = await hre.ethers.getSigners();

  const SupplyChainProvenance = await hre.ethers.getContractFactory("SupplyChainProvenance");
  const contract = await SupplyChainProvenance.deploy();
  await contract.waitForDeployment();

  console.log("[+] Contract deployed at:", contract.target);
  await (await contract.grantRole(await contract.DISTRIBUTOR_ROLE(), distributor.address)).wait();
  await (await contract.grantRole(await contract.WAREHOUSE_ROLE(), warehouse.address)).wait();
  await (await contract.grantRole(await contract.RETAILER_ROLE(), retailer.address)).wait();

  const tx1 = await contract.connect(producer).registerProduct(
    "Organic Soybean Batch #1",
    "Canada",
    "ipfs://QmExampleHash123"
  );
  await tx1.wait();
  console.log("[+] Producer registered product -> Batch ID: 1");

  const tx2 = await contract.connect(producer).transferProduct(1, distributor.address);
  await tx2.wait();
  console.log("[+] Transferred to Distributor");

  const tx3 = await contract.connect(distributor).updateStatus(1, 1);
  await tx3.wait();
  console.log("[+] Status updated to Shipped");

  console.log("[+] Producer -> Distributor workflow completed successfully");
}

main().catch(console.error);
