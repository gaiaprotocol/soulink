import hardhat from "hardhat";

async function main() {
    console.log("deploy start")

    const SoulinkMinter = await hardhat.ethers.getContractFactory("SoulinkMinter")
    const soulinkMinter = await SoulinkMinter.deploy("0xb5a453d6d079d3aE2A103E1B2Daef33b698F706E", { nonce: 150 })
    const Soulink = await hardhat.ethers.getContractFactory("Soulink")
    const soulink = Soulink.attach("0xb5a453d6d079d3aE2A103E1B2Daef33b698F706E");
    await soulink.setMinter(soulinkMinter.address, true);
    console.log(`SoulinkMinter address: ${soulinkMinter.address}`)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });