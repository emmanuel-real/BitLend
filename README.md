# BitLend

**Decentralized Bitcoin-Collateralized Lending Protocol**
Built on [Stacks](https://www.stacks.co/), BitLend enables Bitcoin holders to unlock liquidity by borrowing stablecoins without selling their BTC.

---

## 🧩 Summary

BitLend is a non-custodial, decentralized lending platform where users can deposit Bitcoin as collateral to borrow stablecoins. By leveraging the security and finality of Bitcoin via Stacks, BitLend offers capital efficiency, trust-minimization, and institutional-grade protection for borrowers.

---

## 🚀 Features

* **Non-custodial**: Users retain control of their Bitcoin throughout the lending process.
* **BTC-Collateralized**: Only Bitcoin is used as collateral, ensuring pure BTC exposure.
* **Automated Liquidations**: Under-collateralized loans are automatically flagged and liquidated.
* **Dynamic Risk Parameters**: Governance-controlled collateral and liquidation thresholds.
* **Oracle Integration**: Real-time price feeds ensure accurate valuations.
* **Transparent & Verifiable**: All logic is on-chain, auditable, and deterministic.

---

## 🏗 Architecture Overview

```plaintext
                                 ┌────────────────────────┐
                                 │     BTC Collateral     │
                                 │     (via Stacks)       │
                                 └──────────┬─────────────┘
                                            │
                                            ▼
                               ┌──────────────────────────┐
                               │    BitLend Smart Contract│
                               │   (Clarity on Stacks)    │
                               └──────────┬───────────────┘
                                          │
         ┌────────────────────────────────┼──────────────────────────────────┐
         ▼                                ▼                                  ▼
┌──────────────────┐        ┌──────────────────────────┐         ┌────────────────────────┐
│   Loan Registry   │◄──────│ User Loan Tracking Map   │         │  Oracle Price Feeds    │
└──────────────────┘        └──────────────────────────┘         └────────────────────────┘

         ▲                                ▲                                  ▲
         │                                │                                  │
         └────────────────────────────────┴──────────────────────────────────┘
                                          │
                                          ▼
                                 ┌──────────────────┐
                                 │   Frontend / UI  │
                                 │  (Coming soon)   │
                                 └──────────────────┘
```

---

## 📦 Smart Contract Structure

* **Constants**: Defines system-wide configuration and error codes.
* **State Variables**: Tracks platform status, parameters, and global metrics.
* **Data Maps**:

  * `loans`: Records individual loan details.
  * `user-loans`: Tracks loan IDs per user.
  * `collateral-prices`: Maintains oracle-driven asset prices.
* **Public Functions**:

  * `initialize-platform`: Bootstraps protocol initialization.
  * `deposit-collateral`, `request-loan`, `repay-loan`: Main user actions.
  * Governance functions to update platform parameters and oracle feeds.
* **Private Functions**: Risk logic, interest calculation, liquidation triggers.

---

## 🔧 Getting Started

### Prerequisites

* [Clarity CLI](https://docs.stacks.co/docs/clarity/tools/clarity-cli/)
* [Stacks blockchain](https://docs.stacks.co/docs/start-here/overview/)
* [Clarinet](https://docs.stacks.co/docs/clarity/tools/clarinet/) for local development

### Installation

```bash
git clone https://github.com/emmanuel-real/BitLend.git
cd bitlend
clarinet check
```

---

## 🧪 Usage & Examples

### Initialize the Protocol

```clarity
(initialize-platform)
```

### Deposit Collateral

```clarity
(deposit-collateral u50000) ;; in satoshis
```

### Request a Loan

```clarity
(request-loan u50000 u25000)
```

### Repay a Loan

```clarity
(repay-loan u1 u25250) ;; loan ID 1, total with interest
```

### Update Oracle Price

```clarity
(update-price-feed "BTC" u30000)
```

---

## 🔐 Governance & Risk Management

* Only the `CONTRACT-OWNER` (defined at deployment) can update core risk parameters:

  * `minimum-collateral-ratio`
  * `liquidation-threshold`
  * `collateral-prices`
* Built-in assertions prevent malicious or misconfigured parameter updates.

---

## 📊 Read-Only Functions

* `get-loan-details` - Fetch metadata of a specific loan.
* `get-user-loans` - Retrieve a user's active loans.
* `get-platform-stats` - Overview of platform-wide metrics.
* `get-valid-assets` - View supported collateral assets.

---

## ⚠️ Risk Considerations

* Collateral may be liquidated if BTC price falls below the liquidation threshold.
* Accurate oracle pricing is critical; ensure timely feed updates via trusted governance.
* Max loan per user is limited by the 10-loan list cap in `user-loans`.

---


## 🤝 Contributing

Contributions, audits, and feedback are welcome. Please submit issues or PRs via GitHub.
