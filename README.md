# EcoImpact Protocol

A decentralized environmental sustainability incentive system that rewards eco-friendly actions on the Stacks blockchain with carbon credits and verifiable NFT impact certificates.

## Overview

EcoImpact Protocol is designed to incentivize and reward environmental sustainability actions through a tokenized carbon credit system. By completing eco-friendly actions and maintaining consistency streaks, participants earn carbon credits that can be claimed or pledged for additional benefits. Additionally, users receive NFT impact certificates as verifiable proof of their environmental contributions.

## Features

- **Eco-Action Rewards**: Earn base carbon credits for completing environmental actions
- **Consistency Streaks**: Build a streak by taking daily eco-actions for bonus rewards
- **Credit Pledging**: Pledge earned credits to demonstrate commitment to sustainability
- **Impact Tracking**: Monitor your environmental contributions and completed actions on-chain
- **NFT Impact Certificates**: Receive unique, transferable NFTs for each eco-action completion
- **Verifiable Impact**: Share and prove your environmental contributions with blockchain-backed NFTs

## How It Works

1. **Registration**: Users register eco-actions by specifying the expected impact level
2. **Completion**: Upon completing an action, users receive base credits plus streak bonuses and an NFT certificate
3. **Streaks**: Maintaining consistent eco-friendly behavior (daily actions) increases streak multipliers
4. **Claiming**: Earned carbon credits can be claimed at any time
5. **Pledging**: Optional pledging of credits for longer-term environmental commitment
6. **NFT Management**: Impact certificates can be viewed and transferred to other users

## Technical Details

### Reward Structure

- Base action reward: 10 carbon credits per eco-action
- Consistency bonus: 2 additional credits per streak tier (up to 7 tiers)
- Maximum potential reward per completion: 24 credits (10 base + 14 consistency bonus)
- Total carbon credit reserve: 1,000,000 credits

### Streak Mechanics

- Daily eco-action completions build your streak tier
- Missing a day resets your streak to tier 1
- Each tier increases your rewards by 2 credits
- Maximum streak tier is 7 (for a 14 credit bonus)

### Pledge System

- Credits can be pledged to demonstrate commitment to sustainability
- Minimum pledge period: 288 blocks (approximately 2 days)
- Early withdrawal penalty: 10% of pledged amount
- Successful completion of pledge period returns 100% of pledged credits

### NFT Certificate System

- Each eco-action completion generates a unique NFT impact certificate
- NFTs contain metadata about the action impact, completion date, and streak level
- Impact certificates are transferable between users
- Each user can hold up to 100 impact certificates

## Usage

### For Environmentalists

```clarity
;; Register an eco-action with specified impact
(contract-call? .eco-impact register-eco-action u100)

;; Complete an eco-action after required impact period
(contract-call? .eco-impact complete-eco-action u100)

;; Check your current carbon credit balance
(contract-call? .eco-impact get-credit-balance tx-sender)

;; Claim your earned carbon credits
(contract-call? .eco-impact claim-carbon-credits)

;; Pledge your credits for environmental commitment
(contract-call? .eco-impact pledge-credits u50)

;; Withdraw your pledge after commitment period
(contract-call? .eco-impact withdraw-pledge)

;; View your NFT impact certificates
(contract-call? .eco-impact get-user-certificates tx-sender)

;; View platform statistics
(contract-call? .eco-impact get-platform-stats)

Getting Started

1. Deploy the EcoImpact contract to a Stacks blockchain node
2. Register your first eco-action by calling `register-eco-action`
3. Complete the action after the required impact period
4. Build your streak by completing eco-actions daily
5. Claim or pledge your carbon credits
6. View and manage your NFT impact certificates


Future Development

- Integration with environmental monitoring systems
- Expansion of eco-action types and specialized sustainability paths
- Community environmental initiatives and group actions
- Enhanced NFT metadata with visual representations of environmental impact
- Cross-platform environmental credential verification
- Marketplace for trading impact certificates and carbon credits