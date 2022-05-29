require('@typechain/hardhat');
require("@nomiclabs/hardhat-waffle");
require('@openzeppelin/hardhat-upgrades');
require("@nomiclabs/hardhat-etherscan");

const env = require('./.env.json');

PRIV_1 = env.PRIVATE_KEY_1;
PRIV_2 = env.PRIVATE_KEY_2;
PRIV_3 = env.PRIVATE_KEY_3;
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    solidity: {
        compilers: [
            {
                version: '0.8.12',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200
                    }
                }
            },
            {
                version: "0.4.11",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200
                    }
                },
            },
            {
                version: "0.7.6",
                settings: {
                    optimizer: {
                        enabled: false,
                        runs: 200
                    }
                },
            },
        ]
    },
    networks: {
        mainnet: {
            url: `https://mainnet.infura.io/v3/${env.INFURA}`,
            accounts: [`0x${PRIV_1}`, `0x${PRIV_2}`, `0x${PRIV_3}`]
        },
        mumbai: {
            url: 'https://matic-mumbai.chainstacklabs.com',
            accounts: [`0x${PRIV_1}`, `0x${PRIV_2}`, `0x${PRIV_3}`]
        }
    }
};
