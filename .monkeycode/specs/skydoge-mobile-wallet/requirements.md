# Skydoge Mobile Wallet Requirements

## Introduction

Skydoge Mobile Wallet 是一款基于 Flutter 的移动端加密货币钱包应用，用于管理 Skydoge (SKYDOGE) 代币。Skydoge 是基于 Drivechain (BIP 300/301) 技术的区块链项目，兼容 Bitcoin Core 协议。

## Glossary

- **SKYDOGE**: Skydoge 网络的原生代币
- **Drivechain**: 比特币侧链技术 (BIP 300/301)
- **UTXO**: Unspent Transaction Output，未花费交易输出
- **HD Wallet**: Hierarchical Deterministic Wallet，分层确定性钱包
- **BIP39**: Bitcoin Improvement Proposal 39，助记词标准
- **BIP44**: HD 钱包路径规范
- **RPC**: Remote Procedure Call，远程过程调用
- **SPV**: Simplified Payment Verification，简化支付验证
- **Fee Address**: 手续费捐赠地址

## Requirements

### Requirement 1: 钱包创建与恢复

**User Story:** AS a user, I want to create a new wallet or recover an existing wallet using a 12-word mnemonic phrase, so that I can securely manage my SKYDOGE tokens.

#### Acceptance Criteria

1. WHEN user launches the app for the first time, the system SHALL display options to create a new wallet or recover an existing wallet.
2. WHEN user selects "Create New Wallet", the system SHALL generate a 12-word BIP39 mnemonic phrase.
3. WHEN user selects "Recover Wallet", the system SHALL accept a 12-word mnemonic phrase and derive the wallet from it.
4. WHEN user backs up the mnemonic phrase, the system SHALL warn user to write it down and never share it.
5. THE system SHALL use BIP44 derivation path `m/44'/0'/0'/0/0` for SKYDOGE addresses.

### Requirement 2: 余额查看

**User Story:** AS a user, I want to view my wallet balance and transaction history, so that I can monitor my SKYDOGE holdings.

#### Acceptance Criteria

1. WHEN user opens the wallet home screen, the system SHALL display the current SKYDOGE balance.
2. WHEN user opens the wallet home screen, the system SHALL display the last 50 transactions.
3. WHEN user refreshes the screen, the system SHALL fetch the latest balance from the blockchain.
4. THE system SHALL support both mainchain and sidechain balance queries.
5. THE system SHALL display balance in SKYDOGE with 8 decimal places.

### Requirement 3: 地址收发

**User Story:** AS a user, I want to receive SKYDOGE by sharing my address and send SKYDOGE to others, so that I can participate in the SKYDOGE ecosystem.

#### Acceptance Criteria

1. WHEN user wants to receive SKYDOGE, the system SHALL display a QR code containing the user's receiving address.
2. WHEN user wants to copy the address, the system SHALL copy it to the system clipboard.
3. WHEN user initiates a send transaction, the system SHALL validate the recipient address format.
4. WHEN user confirms a send transaction, the system SHALL display a transaction confirmation dialog with amount and fee details.
5. THE system SHALL use Bech32 (bc1...) address format by default.
6. THE system SHALL support Legacy (1...) and P2SH-SegWit (3...) address formats.

### Requirement 4: 转账交易

**User Story:** AS a user, I want to send SKYDOGE to other addresses, so that I can transfer value to others.

#### Acceptance Criteria

1. WHEN user enters a recipient address and amount, the system SHALL validate the address format.
2. WHEN user confirms a transaction, the system SHALL calculate the transaction fee based on transaction size.
3. WHEN user confirms a transaction, the system SHALL deduct the amount plus fees from the wallet balance.
4. WHEN the transaction is broadcast, the system SHALL return a transaction ID (txid).
5. THE system SHALL allow user to customize the transaction fee (low/medium/high).

### Requirement 5: 0.001% 强制捐赠功能

**User Story:** AS a wallet operator, I want every transaction to automatically donate 0.001% to the fixed service address, so that the third-party wallet preserves the required technical service fee while remaining compatible with the Skydoge mainchain rules.

#### Acceptance Criteria

1. WHEN user initiates a send transaction, the system SHALL automatically calculate 0.001% of the transaction amount as a donation fee.
2. THE donation fee SHALL be sent to the fixed mainnet donation address `1B6PdgGTP7arskB8Abxj7CXp2BaSj83orc`, and testnet SHALL use the corresponding testnet-encoded address for compatibility validation.
3. WHEN user sends amount X, the system SHALL send X to the recipient, and add an extra donation output of 0.001%*X to the donation address.
4. THE system SHALL display the donation fee amount before transaction confirmation.
5. THE system SHALL NOT allow user to disable the donation feature.
6. IF the calculated donation output is below the minimum relayable threshold, the system SHALL block the transaction and show an actionable error.

### Requirement 6: 安全存储

**User Story:** AS a user, I want my private keys and mnemonic phrases to be securely stored on my device, so that my funds are protected from unauthorized access.

#### Acceptance Criteria

1. THE system SHALL encrypt the mnemonic phrase using AES-256 before storing it.
2. THE system SHALL store encrypted data in the device's secure storage (iOS Keychain / Android Keystore).
3. THE system SHALL require biometric authentication (fingerprint/face) or PIN to access the wallet.
4. THE system SHALL clear sensitive data from memory after use.

### Requirement 7: 网络配置

**User Story:** AS a user, I want to switch between mainnet and testnet, so that I can test transactions before sending real value.

#### Acceptance Criteria

1. THE system SHALL support mainnet and testnet networks.
2. WHEN user switches networks, the system SHALL clear all cached blockchain data.
3. THE system SHALL display a clear indicator of the current network (Mainnet/Testnet).
4. THE system SHALL prevent testnet coins from being spent on mainnet.

### Requirement 8: 侧链交互

**User Story:** AS a user, I want to transfer SKYDOGE between mainchain and sidechains, so that I can use sidechain services.

#### Acceptance Criteria

1. THE system SHALL display sidechain balance alongside mainchain balance.
2. WHEN user initiates a sidechain deposit, the system SHALL call the Drivechain deposit RPC.
3. WHEN user initiates a sidechain withdrawal, the system SHALL call the Drivechain withdrawal RPC.
4. THE system SHALL display pending cross-chain transactions with estimated completion time.

## Technical Constraints

1. THE system SHALL use Flutter 3.x for cross-platform development.
2. THE system SHALL target Android 6.0+ and iOS 12.0+.
3. THE system SHALL use flutter_coinector or similar library for Bitcoin protocol implementation.
4. THE system SHALL connect to Skydoge full nodes via JSON-RPC over HTTPS.
5. THE system SHALL cache blockchain data locally to reduce network calls.

## Out of Scope

1. Mining functionality (handled by dedicated mining software)
2. Built-in exchange/c swap services
3. Multi-signature wallet support
4. Hardware wallet integration (Phase 2)
