require("@nomiclabs/hardhat-waffle");

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
        mumbai: {
            url: 'https://matic-mumbai.chainstacklabs.com'
        }
    }
};
