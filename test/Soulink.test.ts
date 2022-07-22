import { Soulink } from "../typechain-types";

import { ethers } from "hardhat";
import { expect } from "chai";
import { BigNumber, BigNumberish, BytesLike, Contract, utils, Wallet } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { time } from "@nomicfoundation/hardhat-network-helpers";

const { constants, provider } = ethers;
const { solidityKeccak256, hexValue, defaultAbiCoder, parseEther } = utils;
const { MaxUint256, Zero, AddressZero, HashZero } = constants;

let deployer: SignerWithAddress, alice: SignerWithAddress, bob: SignerWithAddress, carol: SignerWithAddress, dan: SignerWithAddress, erin: SignerWithAddress;

let sl: Soulink;
let aliceId: BigNumber, bobId: BigNumber, carolId: BigNumber;
describe("Soulink", () => {
    before(async () => {
        const signers = await ethers.getSigners();
        [deployer, alice, bob, carol, dan, erin] = signers;
        aliceId = BigNumber.from(alice.address);
        bobId = BigNumber.from(bob.address);
        carolId = BigNumber.from(carol.address);
    });

    beforeEach(async () => {
        sl = await (await ethers.getContractFactory("Soulink")).deploy();
    });

    describe("link", () => {
        beforeEach(async () => {
            await sl.mint(alice.address);
            await sl.mint(bob.address);
            await sl.mint(carol.address);
        });

        const domain = () => {
            return {
                name: "Soulink",
                version: "1",
                chainId: 31337,
                verifyingContract: sl.address,
            };
        };
        const types = {
            Request: [
                { name: "targetId", type: "uint256" },
                { name: "deadline", type: "uint256" },
            ],
        };
        it("link test", async () => {
            let cTime = (await provider.getBlock("latest")).timestamp;
            expect(await sl.isLinked(aliceId, bobId)).to.be.false;
            const aSig0 = await alice._signTypedData(domain(), types, { targetId: bobId, deadline: cTime + 100 });
            const bSig0 = await bob._signTypedData(domain(), types, { targetId: aliceId, deadline: cTime + 100 });

            await sl.connect(alice).setLink(bobId, [aSig0, bSig0], [cTime + 100, cTime + 100]);
            expect(await sl.isLinked(aliceId, bobId)).to.be.true;
            await expect(sl.connect(alice).setLink(bobId, [aSig0, bSig0], [cTime + 100, cTime + 100])).to.be.revertedWith("USED_SIGNATURE");

            const aSig1 = await alice._signTypedData(domain(), types, { targetId: bobId, deadline: cTime + 99 });
            const bSig1 = await bob._signTypedData(domain(), types, { targetId: aliceId, deadline: cTime + 99 });

            await expect(sl.connect(alice).setLink(bobId, [aSig1, bSig1], [cTime + 99, cTime + 99])).to.be.revertedWith("ALREADY_LINKED");

            await expect(sl.connect(bob).breakLink(bobId)).to.be.revertedWith("IDENTICAL_ADDRESSES");
            await expect(sl.connect(bob).breakLink(aliceId)).to.emit(sl, "BreakLink").withArgs(bobId, aliceId);
            expect(await sl.isLinked(aliceId, bobId)).to.be.false;
            await expect(sl.connect(alice).setLink(bobId, [aSig0, bSig0], [cTime + 100, cTime + 100])).to.be.revertedWith("USED_SIGNATURE");

            await expect(sl.connect(alice).setLink(bobId, [aSig1, bSig1], [cTime + 99, cTime + 99]))
                .to.emit(sl, "SetLink")
                .withArgs(aliceId, bobId);
            expect(await sl.isLinked(aliceId, bobId)).to.be.true;

            await time.increase(cTime + 100);
            await expect(sl.connect(alice).setLink(bobId, [aSig1, bSig1], [cTime + 99, cTime + 99])).to.be.revertedWith("EXPIRED_DEADLINE");

            expect(await sl.isLinked(aliceId, bobId)).to.be.true;
            await expect(sl.connect(alice).burn(bobId)).to.be.revertedWith("UNAUTHORIZED");

            await sl.connect(alice).burn(aliceId);
            await expect(sl.isLinked(aliceId, bobId)).to.be.reverted;

            await sl.mint(alice.address);
            expect(await sl.isLinked(aliceId, bobId)).to.be.false;
        });
    });
});
