import hardhat from "hardhat";

async function main() {
    console.log("deploy start")

    const SoulinkMinter = await hardhat.ethers.getContractFactory("SoulinkMinter")
    const soulinkMinter = await SoulinkMinter.deploy("0x9f69C2a06c97fCAAc1E586b30Ea681c43975F052")
    const Soulink = await hardhat.ethers.getContractFactory("Soulink")
    const soulink = Soulink.attach("0x9f69C2a06c97fCAAc1E586b30Ea681c43975F052");
    await soulink.setMinter(soulinkMinter.address, true);
    console.log(`SoulinkMinter address: ${soulinkMinter.address}`)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });