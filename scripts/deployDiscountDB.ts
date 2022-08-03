import hardhat from "hardhat";

async function main() {
    console.log("deploy start")

    const DiscountDB = await hardhat.ethers.getContractFactory("DiscountDBV0")
    const discountDB = await DiscountDB.deploy()
    const SoulinkMinter = await hardhat.ethers.getContractFactory("SoulinkMinter")
    const soulinkMinter = SoulinkMinter.attach("0xECFFc91149b8B702dEa6905Ae304A9D36527060F");
    await soulinkMinter.setDiscountDB(discountDB.address);
    console.log(`DiscountDB address: ${discountDB.address}`)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });