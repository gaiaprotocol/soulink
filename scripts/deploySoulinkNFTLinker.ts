import hardhat from "hardhat";

async function main() {
    console.log("deploy start")

    const Minter = await hardhat.ethers.getContractFactory("SoulinkMinter")
    const minter = await Minter.deploy("")
    console.log(`Minter address: ${minter.address}`)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
