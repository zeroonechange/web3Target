
```json
        Network(
          name: "Optimism Goerli",
          testnetData: _TestnetData(testnetForChainId: 10),
          visible: false,
          color: const Color.fromARGB(255, 255, 137, 225),
          nativeCurrency: 'ETH',
          chainId: BigInt.from(420),
          explorerUrl: "https://goerli-optimism.etherscan.io",
          //
          coinGeckoAssetPlatform: "optimistic-ethereum",
          candideBalances: EthereumAddress.fromHex("0x97A8c45e8Da6608bAbf09eb1222292d7B389B1a1"),
          //
          safeSingleton: EthereumAddress.fromHex("0x23e4fd58F38cD9c75957a182DB90bB449879A6A3"),
          proxyFactory: EthereumAddress.fromHex("0xb73Eb505Abc30d0e7e15B73A492863235B3F4309"),
          fallbackHandler: EthereumAddress.fromHex("0x9a77CD4a3e2B849f70616c82A9c69BdA1C2296ff"),
          socialRecoveryModule: EthereumAddress.fromHex("0xCbf67d131Fa0775c5d18676c58de982c349aFC0b"),
          entrypoint: EthereumAddress.fromHex("0x0576a174D229E3cFA37253523E645A78A0C91B57"),
          multiSendCall: EthereumAddress.fromHex("0x40A2aCCbd92BCA938b02010E17A5b8929b49130D"),
          gasEstimator: L2GasEstimator(chainId: 420, ovmGasOracle: EthereumAddress.fromHex("0x420000000000000000000000000000000000000F")),
          client: Web3Client(Env.optimismGoerliRpcEndpoint, Client()),
          features: {
            "deposit": {
              "deposit-address": true,
              "deposit-fiat": false,
            },
            "transfer": {
              "basic": true
            },
            "swap": {
              "basic": false
            },
            "social-recovery": {
              "family-and-friends": true,
              "magic-link": true,
              "hardware-wallet": false,
            },
          },
        )

```
 
