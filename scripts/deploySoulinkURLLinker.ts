import hardhat from "hardhat";

async function main() {
    console.log("deploy start")

    const Linker = await hardhat.ethers.getContractFactory("SoulinkURLLinker")
    const linker = await Linker.deploy("")
    console.log(`Linker address: ${linker.address}`)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
