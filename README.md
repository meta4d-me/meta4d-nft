# marketplace-contracts

## Notice

- payment(from, to, amount, burnRate, feeRate):
    - balanceBefore = RPC.balanceOf(RPCRouter);
    - RPC.spend(from, RPCRouter, amount, burnRate);
    - balanceAfter = RPC.balanceOf(RPCRouter);
    - routerReceived = balanceAfter - balanceBefore;
    - applicationFee = routerReceived * feeRate;
    - RPC.transfer(to, routerReceived - applicationFee);

## deployments

### Mumbai

```
{
  MockRPC: '0x',
  RPCRouter: '0x',
  MetaMEME: '0x',
  MetaMEME2: '0x',
  MetaBatchMeme: '0x',
  Market: '0x',
  MarketProxy: '0x'
}
```
