//const Todeploy = artifacts.require('KOIProject')
const Todeploy = artifacts.require('AURAWrapped')
module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(Todeploy)
}
