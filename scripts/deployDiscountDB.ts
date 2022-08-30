import hardhat from "hardhat";

async function main() {
    console.log("deploy start")

    const DiscountDB = await hardhat.ethers.getContractFactory("DiscountDBV1")
    const discountDB = await DiscountDB.deploy()
    const SoulinkMinter = await hardhat.ethers.getContractFactory("SoulinkMinter")
    const soulinkMinter = SoulinkMinter.attach("0x838A1B44d56a8fb9D8Ee72cb12ECB15fe2aE711F");
    await soulinkMinter.setDiscountDB(discountDB.address);
    console.log(`DiscountDB address: ${discountDB.address}`)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });