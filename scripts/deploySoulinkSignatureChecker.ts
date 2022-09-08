import hardhat from "hardhat";

async function main() {
    console.log("deploy start")

    const SoulinkSignatureChecker = await hardhat.ethers.getContractFactory("SoulinkSignatureChecker")
    const checker = await SoulinkSignatureChecker.deploy()
    console.log(`SoulinkSignatureChecker address: ${checker.address}`)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });