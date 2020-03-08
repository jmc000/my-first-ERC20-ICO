const Migrations = artifacts.require("Migrations");
var myToken = artifacts.require("myToken");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.link(Migrations, myToken);
  deployer.deploy(myToken);
};
