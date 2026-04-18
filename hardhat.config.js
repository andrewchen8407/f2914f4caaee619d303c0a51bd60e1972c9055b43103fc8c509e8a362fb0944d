require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      evmVersion: "cancun"
    }
  },
  networks: {
    hardhat: {},
    polygonAmoy: {
      url: "https://rpc-amoy.polygon.technology",
      accounts: []
    }
  }
};
