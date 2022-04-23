const HDWalletProvider= require('truffle-hdwallet-provider');
const Web3=require('web3');
const {interfaceRetailer,bytecodeRetailer}=require('./compileRetailer');

const provider=new HDWalletProvider(
'metamask memonic',
'infura link',
0,
4
);
// const INITIAL_STRING='Hi i am sonu sharma';28960000

const web3=new Web3(provider);

const deploy = async ()=>{
	const accounts=await web3.eth.getAccounts();
	console.log(web3.version);
	console.log('Attempting to deploy from account',accounts[0]);
	// web3.eth.getBalance(accounts[0]).then(console.log);
	const result = await new web3.eth.Contract(interfaceRetailer).deploy({data: bytecodeRetailer}).send({from:accounts[0],gas: 10000000});

	console.log(interfaceRetailer);
	// console.log(await result.methods.admin().call());

	// console.log('sonu sharma');
	console.log('Contract deployed to ',result.options.address);
};
deploy();
