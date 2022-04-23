const path= require('path'); //standered modules to get path of a file
const fs= require('fs'); //standered modules to read a file
const solc=require('solc'); //getting solidity compiler

const CustomerPath= path.resolve(__dirname,'contracts','Customer.sol');
const RetailerPath= path.resolve(__dirname,'contracts','Retailer.sol');


const source1= fs.readFileSync(CustomerPath,'utf-8');
const source2= fs.readFileSync(RetailerPath,'utf-8');

// console.log(solc.compile(source,1));
// console.log('sonu sharma');

const input = {
    language: 'Solidity',
    sources: {
        'Customer.sol': {
            content: source1
        },
        'Retailer.sol':{
            content: source2
        }
    },
    settings: {
        outputSelection: {
            '*': {
                '*': ['*']
            }
        }
    }
}

var output = JSON.parse(solc.compile(JSON.stringify(input)));
 
var interfaceCustomer = output.contracts["Customer.sol"]["Customer"].abi;
 
var bytecodeCustomer = output.contracts['Customer.sol']["Customer"].evm.bytecode.object;
// console.log(interfaceCustomer);
 
module.exports = { interfaceCustomer, bytecodeCustomer };