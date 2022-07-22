import { Soulink, SoulinkMinter, DiscountDBV0, ERC721Mock } from "../typechain-types";

import { ethers } from "hardhat";
import { expect } from "chai";
import { BigNumber, BigNumberish, BytesLike, Contract, utils, Wallet } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

const { constants, provider } = ethers;
const { solidityKeccak256, hexValue, defaultAbiCoder, parseEther } = utils;
const { MaxUint256, Zero, AddressZero, HashZero } = constants;

let deployer: SignerWithAddress, alice: SignerWithAddress, bob: SignerWithAddress, carol: SignerWithAddress, dan: SignerWithAddress, erin: SignerWithAddress;

let soulink: Soulink;
let minter: SoulinkMinter;
let db: DiscountDBV0;
let nft: ERC721Mock;
const setupTest = async () => {
    soulink = await (await ethers.getContractFactory("Soulink")).deploy();
    minter = await (await ethers.getContractFactory("SoulinkMinter")).deploy(soulink.address);
    db = await (await ethers.getContractFactory("DiscountDBV0")).deploy();
    nft = await (await ethers.getContractFactory("ERC721Mock")).deploy();

    await soulink.setMinter(minter.address, true);
};

describe("Soulink Minter", () => {
    before(async () => {
        const signers = await ethers.getSigners();
        [deployer, alice, bob, carol, dan, erin] = signers;
    });

    beforeEach(async () => {
        await setupTest();
    });

    const price = parseEther("0.1");
    describe("ownership functions", () => {
        context("when feeTo is changed", () => {
            it("updates feeTo", async () => {
                expect(await minter.feeTo()).to.be.equal(deployer.address);
                await expect(minter.setFeeTo(erin.address)).to.emit(minter, "SetFeeTo").withArgs(erin.address);
                expect(await minter.feeTo()).to.be.equal(erin.address);
            });
        });
        context("when limit is changed", () => {
            it("updates limit", async () => {
                const max96 = BigNumber.from(2).pow(96).sub(1);
                expect(await minter.limit()).to.be.equal(max96);
                await expect(minter.setLimit(10)).to.emit(minter, "SetLimit").withArgs(10);
                expect(await minter.limit()).to.be.equal(10);
            });
        });
        context("when mintPrice is changed", () => {
            it("updates mintPrice", async () => {
                expect(await minter.mintPrice()).to.be.equal(price);
                await expect(minter.setMintPrice(1000)).to.emit(minter, "SetMintPrice").withArgs(1000);
                expect(await minter.mintPrice()).to.be.equal(1000);
            });
        });
        context("when discountDB is changed", () => {
            it("updates discountDB", async () => {
                expect(await minter.discountDB()).to.be.equal(AddressZero);
                await expect(minter.setDiscountDB(db.address)).to.emit(minter, "SetDiscountDB").withArgs(db.address);
                expect(await minter.discountDB()).to.be.equal(db.address);
            });
        });
    });

    describe("mint", () => {
        context("when mint is called", () => {
            it("mints a token to user with userAddressId", async () => {
                const tokenId = BigNumber.from(alice.address);
                expect(await soulink.totalSupply()).to.be.equal(0);
                await expect(soulink.ownerOf(tokenId)).to.be.revertedWith("SBT: invalid token ID");

                await minter.connect(alice).mint(false, "0x", { value: price });
                expect(await soulink.totalSupply()).to.be.equal(1);
                expect(await soulink.ownerOf(tokenId)).to.be.equal(alice.address);
            });
        });
        context("when limit is reached", () => {
            it("reverts", async () => {
                await minter.setLimit(1);
                await minter.connect(alice).mint(false, "0x", { value: price });
                expect(await soulink.totalSupply()).to.be.equal(1);
                await expect(minter.connect(bob).mint(false, "0x", { value: price })).to.be.revertedWith("LIMIT_EXCEEDED");

                await minter.setLimit(2);
                await minter.connect(bob).mint(false, "0x", { value: price });
                expect(await soulink.totalSupply()).to.be.equal(2);
                await expect(minter.connect(carol).mint(false, "0x", { value: price })).to.be.revertedWith("LIMIT_EXCEEDED");
            });
        });
        context("when mint is called twice", () => {
            it("reverts", async () => {
                await minter.connect(alice).mint(false, "0x", { value: price });
                await expect(minter.connect(alice).mint(false, "0x", { value: price })).to.be.revertedWith("ALREADY_MINTED");
            });
        });
        context("when mint is called without discount", () => {
            it("collects exact mintPrice", async () => {
                await expect(minter.connect(alice).mint(false, "0x", { value: price.add(1) })).to.be.revertedWith("INVALID_MINTPRICE");
                await expect(minter.connect(alice).mint(false, "0x", { value: price.sub(1) })).to.be.revertedWith("INVALID_MINTPRICE");
                await expect(minter.connect(alice).mint(false, "0x", { value: price })).to.changeEtherBalances([alice, deployer], [price.mul(-1), price]);
            });
        });
        context("when discount mint is called but db doesn't exist", () => {
            it("reverts", async () => {
                await expect(minter.connect(alice).mint(true, "0x", { value: price })).to.be.revertedWith("NO_DISCOUNTDB");
            });
        });
        context("when discount mint is called", () => {
            it("collects discounted mintPrice", async () => {
                // bob,carol : 50% dc (0.05eth)
                // dan : 100% dc (complimentary)
                // nft holder : 70% dc (0.03eth)

                await minter.setDiscountDB(db.address);
                await db.updateUserDiscountRate([bob.address, carol.address, dan.address], [5000, 5000, 10000]);
                await db.updateNFTDiscountRate([nft.address], [7000]);

                await minter.connect(alice).mint(true, "0x", { value: price });

                const nftData = defaultAbiCoder.encode(["address"], [nft.address]);
                await nft.mint(bob.address, 1);
                await nft.mint(carol.address, 2);
                await minter.connect(bob).mint(true, "0x", { value: price.div(2) });
                await minter.connect(carol).mint(true, nftData, { value: price.mul(3).div(10) });
                await minter.connect(dan).mint(true, "0x");
                await expect(minter.connect(erin).mint(true, nftData, { value: price.mul(3).div(10) })).to.be.revertedWith("NOT_NFT_HOLDER");
            });
        });
    });
});
