const path= require('path'); //standered modules to get path of a file
const fs= require('fs'); //standered modules to read a file
const solc=require('solc'); //getting solidity compiler

const RetailerPath= path.resolve(__dirname,'contracts','Retailer.sol');


const source= fs.readFileSync(RetailerPath,'utf-8');

// console.log(solc.compile(source,1));
// console.log('sonu sharma');

const input = {
    language: 'Solidity',
    sources: {
        'Retailer.sol': {
            content: source
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
 // console.log(output.contracts["Retailer.sol"]["Retailer"].interface);
var interfaceRetailer = output.contracts["Retailer.sol"]["Retailer"].abi;
 
var bytecodeRetailer = output.contracts['Retailer.sol']["Retailer"].evm.bytecode.object;
// console.log(interfaceRetailer);
// console.log(bytecode);
 
module.exports = { interfaceRetailer, bytecodeRetailer };