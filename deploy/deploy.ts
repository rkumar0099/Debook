import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from 'hardhat-deploy/types';

const func: DeployFunction = async function(hre: HardhatRuntimeEnvironment) {
    let owner: string = "0x92D73a8FB635Fd7C7B241Db4BbD7682ecFF8Bc62";
    const {
        deployments: { deploy },
        getNamedAccounts,
    } = hre;
    const { deployer } = await getNamedAccounts();

    const c1 = await deploy('Router', {
        from: deployer,
        args: [],
        log: true,
    })
    console.log(c1);
}

export default func;