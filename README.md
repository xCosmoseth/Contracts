This repository contains contracts that I'm coding, whether for fun or otherwise.

**DISCLAIMER: I am currently in the learning process of using Solidity. You are welcome to suggest improvements and are advised to test the code on your own before using it.**


## **AInime Folder**

This directory holds the smart contract for the AInime collection. For more information about the project, visit https://www.ainime.xyz/.

It supports a multi-phase minting process and implements a minting limit per wallet/transaction. While the whitelist could be enhanced using Merkle Trees, I admittedly took a shortcut here :)

## **Experimentations Folder**

In this section, I will share experimental contracts that cater to specific use cases.

- **FundMyNFTWithAuth.sol**: This contract was designed for individuals who wish to publicly raise funds to purchase an NFT. The authorized addresses should belong to individuals recognized as trustworthy within the space. For instance, if you intend to gather donations for buying a particular NFT, you could designate the project's team members as authorizers. They would then possess the authority to allow you to access the funds for your NFT purchase. Naturally, you retain control over the funds once approved for withdrawal, but since this is a public action, your reputation could be impacted in case of any misuse ;)