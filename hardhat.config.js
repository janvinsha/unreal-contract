// require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");
require("hardhat-contract-sizer");

require("dotenv").config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.13",

        settings: {
          optimizer: {
            enabled: true,

            runs: 200,
          },
        },
      },

      {
        version: "0.8.9",

        settings: {
          optimizer: {
            enabled: true,

            runs: 200,
          },
        },
      },

      {
        version: "0.8.4",

        settings: {
          optimizer: {
            enabled: true,

            runs: 200,
          },
        },
      },

      {
        version: "0.8.2",

        settings: {
          optimizer: {
            enabled: true,

            runs: 200,
          },
        },
      },

      {
        version: "0.6.6",

        settings: {
          optimizer: {
            enabled: true,

            runs: 200,
          },
        },
      },

      {
        version: "0.6.2",

        settings: {
          optimizer: {
            enabled: true,

            runs: 200,
          },
        },
      },

      {
        version: "0.6.0",

        settings: {
          optimizer: {
            enabled: true,

            runs: 200,
          },
        },
      },
    ],
  },

  networks: {
    mumbai: {
      url: process.env.ALCHEMY_URL,
      accounts: [
       process.env.PRIVATE_KEY
      ],
    },
  },
  gasReporter: {
    enabled: true,
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
    disambiguatePaths: false,
  },
  // Rest of the config
  // etherscan: {
  //   // Your API key for Etherscan
  //   // Obtain one at https://etherscan.io/
  //   apiKey: process.env.ETHERSCAN_KEY,
  // },
};
