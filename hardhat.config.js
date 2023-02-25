/** @type import('hardhat/config').HardhatUserConfig */
// hardhat.config.js
require("dotenv").config();
require('@openzeppelin/hardhat-upgrades');

module.exports = {
  solidity: "0.8.17",
 networks:{ polygon:{
  url: process.env.ALCHEMY_API_KEY||"",
  accounts: [process.env.PrivateKey],
  },
},
};