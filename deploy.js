const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const compiledFactory = require('./build/CampaignFactory.json');

const provider = new HDWalletProvider(
    'anger boy acoustic normal lesson chest shoulder name leader pair trade rescue',
    'https://rinkeby.infura.io/v3/8763ca703dc94f10bb6d008ba57228eb'
  );
  
const web3 = new Web3(provider);

const deploy = async () => {
  const accounts = await web3.eth.getAccounts();

  console.log('Attempting to deploy from account', accounts[0]);

  const result = await new web3.eth.Contract(JSON.parse(compiledFactory.interface))
  .deploy({data: '0x' + compiledFactory.bytecode})
  .send({from: accounts[0]});

  console.log('Contract deployed to', result.options.address);
};
deploy();
