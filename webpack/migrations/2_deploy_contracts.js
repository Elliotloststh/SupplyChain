const ConvertLib = artifacts.require("ConvertLib");
const LifeLine = artifacts.require("LifeLine");

module.exports = function(deployer) {
  deployer.deploy(ConvertLib);
  deployer.link(ConvertLib, LifeLine);
  deployer.deploy(LifeLine);
};
