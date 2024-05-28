# Deploying an Ethereum Node on AWS with Kubernetes

## Introduction

Ethereum 2.0 introduces the Beacon Chain, which coordinates the network of shards and the new PoS consensus mechanism. Validators replace miners in PoS, staking ETH to propose and attest to new blocks. This setup enhances security, scalability, and energy efficiency.

This guide provides comprehensive steps to deploy a testnet Ethereum node on the Sepolia chain on AWS using Kubernetes (EKS). We'll deploy an Ethereum client (Geth), a Beacon Chain (Prysm), and a Validator (Prysm Validator) using Kubernetes pods. This setup aligns with Ethereum 2.0 and Proof of Stake (PoS) principles.

## Prerequisites

- AWS account
- kubectl and aws-cli installed and configured on your machine
- Terraform installed

## Definitions

### Geth
Geth (Go Ethereum) is a popular Ethereum client implemented in the Go programming language. It is used to run a full Ethereum node, enabling users to participate in the Ethereum network by validating transactions, executing smart contracts, and maintaining the blockchain's state. Geth allows developers and users to interact with the Ethereum network, deploy decentralized applications (dApps), and mine Ether (ETH).

### Prysm Beacon Chain
Prysm Beacon Chain is a client implementation for Ethereum 2.0 written in Go. The Beacon Chain is a central component of Ethereum 2.0, responsible for managing the consensus of the new Proof of Stake (PoS) protocol. It coordinates the network of shards and validators, processes cross-links, and ensures the overall security and synchronization of the blockchain. The Beacon Chain manages validators' activities, such as proposing and attesting blocks, and handles rewards and penalties.

### Prysm Validator
Prysm Validator is a client software that allows individuals to participate as validators in the Ethereum 2.0 network. Validators replace miners in the PoS consensus mechanism, staking their ETH to propose and attest to new blocks. The Prysm Validator client manages the validator's duties, including key management, signing blocks and attestations, and communicating with the Beacon Chain to ensure the integrity and security of the blockchain. Validators are rewarded with ETH for their participation and adherence to the protocol.

![0_tfwuH_A1WlxUZsjP](https://github.com/Yb2411/ethereum-node-aws-kubernetes-guide/assets/132000325/23da400d-6d09-45fe-9edb-fe85f5c22396)

## Steps to Deploy

### 1. Setting Up the Infrastructure with Terraform

- The Terraform files provision an EKS cluster with 3 worker nodes (2 `t3.medium` and 1 `t3.large`).
- Make the desired changes.
- Navigate to the `terraform` directory and run:

```
terraform init
terraform apply
```

### 2. Creating Kubernetes Secrets
#### Validator Keys
These keys are used by the Prysm Validator to sign blocks and attestations.
- Generate the validator keys following [this guide](https://github.com/ethereum/staking-deposit-cli?tab=readme-ov-file)
- Don't forget the password
- Then, create a Kubernetes secret:
```
kubectl create secret generic validator-keys --from-file=validator_keys/
```

#### JWT Secret
- Generate a JWT secret, which is used for authenticated communication between the Ethereum client and the Beacon Chain:
- Then create a Kubernetes secret:

```
openssl rand -hex 32 | tr -d "\n" > jwtsecret
kubectl create secret generic jwtsecret --from-file=jwtsecret
```

#### Wallet Password
- Create a file wallet-password.txt containing the password you will use to secure your Prysm wallet. This password will be used to manage and access the validator keys stored in the wallet.
- Then, create a Kubernetes secret:

```
kubectl create secret generic wallet-password --from-file=wallet-password.txt
```
- Note: In this example, we use the same password for both the wallet and the validator. This must NOT be done in a production environment. It has been done here only due to lazyness.

### 3. Deploying the Ethereum Node and Prysm Services
#### Deploy Geth
Apply the Geth deployment:

```
kubectl apply -f kubernetes/geth-deployment.yml
```
Check the logs to ensure Geth is running properly

```
kubectl logs -f <geth-pod-name>
```
#### Deploy Prysm Beacon Chain
Apply the Prysm Beacon Chain deployment:

```
kubectl apply -f kubernetes/prysm-beacon-deployment.yml
```
Check the logs to ensure the Beacon Chain is running properly:

```
kubectl logs -f <beacon-chain-pod-name>
```
#### Deploy Prysm Validator
Apply the Prysm Validator deployment:

```
kubectl apply -f kubernetes/prysm-validator-deployment.yml
```

Check the logs to ensure the Validator is running properly:

```
kubectl logs -f <validator-pod-name>
```

### 4. Monitoring and Adjustments

In this proof of concept, a 10GB storage was used. For a production deployment, consider the following:

#### Monitoring
- Implement comprehensive monitoring tools (Prometheus, Grafana).
- Set up centralized logging (ELK Stack, Fluentd).
- Configure alerts for resource usage and node failures.

#### Security
- Implement network security policies.
- Use Kubernetes RBAC for access control.
- Manage secrets securely (Kubernetes Secrets, HashiCorp Vault).

#### High Availability
- Deploy nodes across multiple availability zones.
- Implement load balancing (Kubernetes LoadBalancer, ingress controller).

#### Access Control
- Implement strict access control policies.

## Conclusion
By following these steps, you have successfully deployed an Ethereum node, a Beacon Chain, and a Validator on AWS using Kubernetes. This setup demonstrates the basic concept and can be scaled according to your requirements.

For further information and troubleshooting, refer to the official documentation of [Geth](https://geth.ethereum.org/docs), [Prysm](https://docs.prylabs.network/docs/getting-started), and Kubernetes.
