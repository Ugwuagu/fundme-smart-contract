-include .env

deploy:; forge script script/DeployFundMe.s.sol --rpc-url http:127.0.0.1:8545 --account defaultKey --broadcast
deploy-sepolia:; forge script script/DeployFundMe.s.sol --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast