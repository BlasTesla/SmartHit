# Smart Token ($SMART)

Smart token is a token that can only be used my smart wallets (ERC-4337, Gnosis, any smart contract) until EIP-7702 is deplyoed. All approvals user TSTORE and TLOAD preventing EOA (secp256k1) accounts from handling the token.

To claim call `smart.prepareClaim()` followed by `smart.claim()` in a batch transaction. If successful the contract will mint `500_000e18` tokens every 10 minutes, with a total supply cap of `1_000_000_000e18`. If you accidentally transfer your tokens to an EOA, they are effectively burned.


### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
