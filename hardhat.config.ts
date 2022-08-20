import 'hardhat-deploy';
import * as dotenv from 'dotenv';

import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
const {PRIVATE_KEY} = process.env;


const config: HardhatUserConfig = {
  solidity: "0.8.9",
  networks: {
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/d80f6ddd724b40048ab469115f8ed059",
      chainId: 4,
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
  namedAccounts: {
    deployer: 0,
  }
};

export default config;
