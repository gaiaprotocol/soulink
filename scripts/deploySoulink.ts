import hardhat from "hardhat";

async function main() {
    console.log("deploy start")

    const Soulink = await hardhat.ethers.getContractFactory("Soulink")
    const soulink = await Soulink.deploy()
    console.log(`Soulink address: ${soulink.address}`)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
