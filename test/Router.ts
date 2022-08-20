import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import {solidity} from 'ethereum-waffle';
import chai from 'chai';
chai.use(solidity);

const {expect} = chai;

import {
    Router,
    Router__factory
} from '../typechain-types';
import { Signer } from "ethers";
import { ethers } from "hardhat";

describe('Router', function() {
    let routerFactory: Router__factory, router: Router;
    let dev: SignerWithAddress, user1: SignerWithAddress, users: SignerWithAddress[];

    this.beforeEach(async function() {
        [dev, user1, ...users] = await ethers.getSigners();
        routerFactory = await ethers.getContractFactory("Router");
        router = await routerFactory.deploy();
        await router.deployed();
    });
    it('add book', async function() {
        await router.connect(user1).addBook("hello", 100, true);
        const res = await router.exists("hello");
        expect(res).to.equal(true);
    });
})