#!/bin/bash
set -e

echo "=== Drosera Trap Setup Script ==="

# Step 0: Setup PATH
export PATH="$HOME/.local/bin:$HOME/.foundry/bin:$HOME/.bun/bin:$PATH"

echo "=== Step 1: Install Drosera CLI ==="
curl -L https://app.drosera.io/install | bash
command -v drosera >/dev/null || droseraup

echo "=== Step 2: Install Foundry CLI ==="
curl -L https://foundry.paradigm.xyz | bash
command -v forge >/dev/null || foundryup

echo "=== Step 3: Install Bun ==="
curl -fsSL https://bun.sh/install | bash
command -v bun >/dev/null || echo "⚠️ Bun install failed. Please check logs."

echo "=== Step 4: Prepare Project Directory ==="
mkdir -p ~/my-drosera-trap
cd ~/my-drosera-trap

read -p "Enter your GitHub Email: " GITHUB_EMAIL
read -p "Enter your GitHub Username: " GITHUB_USER
git config --global user.email "$GITHUB_EMAIL"
git config --global user.name "$GITHUB_USER"

echo "=== Step 5: Initialize Forge Project ==="
forge init -t drosera-network/trap-foundry-template

echo "=== Step 6: Compile Trap ==="
bun install
forge build

echo "=== Step 7: Deploy Trap ==="
read -p "Enter your DROSERA_PRIVATE_KEY (hex, no 0x): " DROSERA_PRIVATE_KEY
read -p "Enter your Ethereum RPC URL: " ETH_RPC_URL

DROSERA_PRIVATE_KEY="$DROSERA_PRIVATE_KEY" drosera apply --eth-rpc-url "$ETH_RPC_URL"

echo "=== Step 8: Existing User Trap Address Setup (optional) ==="
read -p "Are you an existing user needing to add trap address? (y/N): " EXISTING_USER
if [[ "$EXISTING_USER" =~ ^[Yy]$ ]]; then
  read -p "Enter your TRAP_ADDRESS (0x...): " TRAP_ADDRESS
  read -p "Enter whitelist operator addresses (comma-separated): " WHITELIST

  echo -e "\naddress = \"$TRAP_ADDRESS\"" >> drosera.toml
  echo "whitelist = [" >> drosera.toml
  IFS=',' read -ra ADDRS <<< "$WHITELIST"
  for addr in "${ADDRS[@]}"; do
    echo "  \"$addr\"," >> drosera.toml
  done
  echo "]" >> drosera.toml

  DROSERA_PRIVATE_KEY="$DROSERA_PRIVATE_KEY" drosera apply --eth-rpc-url "$ETH_RPC_URL"
fi

echo "=== Step 9: Check Trap on Dashboard ==="
echo "🔗 Visit: https://app.drosera.io/"
echo "💡 Click 'Traps Owned' or search by your Trap address."

echo "=== Step 10: Bloom Boost Trap ==="
echo "⚡ On the Dashboard, click 'Send Bloom Boost' to deposit Holesky ETH."

echo "=== Step 11: Dryrun Blocks ==="
drosera dryrun

echo "✅ Setup Complete. Happy trapping!"
