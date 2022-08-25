import { BigNumber, constants } from "ethers";
import hardhat from "hardhat";

async function main() {
    console.log("deploy start")

    const currentBlock = await hardhat.ethers.provider.getBlockNumber();

    const Soulink = await hardhat.ethers.getContractFactory("Soulink")
    const v1 = Soulink.attach("0x9f69C2a06c97fCAAc1E586b30Ea681c43975F052")

    const transferFilter = v1.filters.Transfer();
    const setLinkFilter = v1.filters.SetLink();
    const breakLinkFilter = v1.filters.BreakLink();

    const transferEvents = await v1.queryFilter(transferFilter, 15267068, currentBlock);
    const setLinkEvents = await v1.queryFilter(setLinkFilter, 15267068, currentBlock);
    const breakLinkEvents = await v1.queryFilter(breakLinkFilter, 15267068, currentBlock);

    const owners: string[] = [];
    for (const transferEvent of transferEvents) {
        // mint
        if (transferEvent.args[0] === constants.AddressZero) {
            owners.push(transferEvent.args[1]);
        }
        // burn
        if (transferEvent.args[1] === constants.AddressZero) {
            const index = owners.findIndex((o) => o === transferEvent.args[0]);
            if (index !== -1) {
                owners.splice(index, 1);
            }
        }
    }

    const connections: [BigNumber, BigNumber][] = [];
    for (const setLinkEvent of setLinkEvents) {
        const id0 = setLinkEvent.args[0];
        const id1 = setLinkEvent.args[1];
        if (id0.lte(id1)) {
            connections.push([id0, id1]);
        } else {
            connections.push([id1, id0]);
        }
    }

    for (const breakLinkEvent of breakLinkEvents) {
        const id0 = breakLinkEvent.args[0];
        const id1 = breakLinkEvent.args[1];
        if (id0.lte(id1)) {
            const index = connections.findIndex((c) => c[0].toHexString() === id0.toHexString() && c[1].toHexString() === id1.toHexString());
            if (index !== -1) {
                connections.splice(index, 1);
            }
        } else {
            const index = connections.findIndex((c) => c[0].toHexString() === id1.toHexString() && c[1].toHexString() === id0.toHexString());
            if (index !== -1) {
                connections.splice(index, 1);
            }
        }
    }

    const soulink = await Soulink.deploy(owners, connections)
    console.log(`Soulink address: ${soulink.address}`)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });