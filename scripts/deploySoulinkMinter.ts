import hardhat from "hardhat";

async function main() {
    console.log("deploy start")

    const SoulinkMinter = await hardhat.ethers.getContractFactory("SoulinkMinter")
    const soulinkMinter = await SoulinkMinter.deploy("0xD50ED1BE18c3C4023c2ba3632C362028fb01fD03")
    console.log(`SoulinkMinter address: ${soulinkMinter.address}`)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });