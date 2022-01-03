var Ballot = artifacts.require("Ballot"); // 배포해야 할 스마트 컨트랙트 이름과 동일한 걸로 설정해야 함
 
module.exports = function(deployer) {
    deployer.deploy(Ballot, 4); // 4는 constructor 구성하는 수, 여기서는 제안 4개 (remix에서 deploy 할 때 받는 파라미터랑 동일)
};