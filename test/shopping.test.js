const assert=require('assert');
const ganache=require('ganache-cli');
const Web3=require('web3');
const web3=new Web3(ganache.provider());
const {interfaceCustomer,bytecodeCustomer}=require('../compileCustomer');
const {interfaceRetailer,bytecodeRetailer}=require('../compileRetailer');


let accounts;
let customer;
let retailer;

beforeEach(async () =>{
	//get list of all account
	 accounts= await web3.eth.getAccounts();
	 // console.log(accounts);

	//Use one cls the account to deploy the contract
	retailer = await new web3.eth.Contract(interfaceRetailer)
    .deploy({data: bytecodeRetailer})
    .send({gas:6000000,from:accounts[0]});

    // console.log(retailer.options.address);
	customer = await new web3.eth.Contract(interfaceCustomer)
    .deploy({ data: bytecodeCustomer,arguments:[retailer.options.address] })
    .send({ gas: 6000000, from: accounts[0]});

    
});

describe('customer Contract',()=>{
	it('deploys customer contract',()=>{
		// console.log(inbox);
		//check if the address of deployment exist or not
		// console.log('customer');
		assert.ok(customer.options.address);
		// console.log(interfaceCustomer);
	});
	it('deploys retailer contract',()=>{
		assert.ok(retailer.options.address);


	});

	// it('retailer signup',async()=>{
	// 	// console.log(accounts[0]);
	// 	await retailer.methods.retailerSignUp("sonu sharma","sonusharma20188031@gmail.com","6204629588","motihari").send({
	// 		from: accounts[1],
	// 		gas: 4712388
	// 	});
	// 	await retailer.methods.retailerSignUp("satyam jaiswal","..@..","0000","no address").send({
	// 		from: accounts[2],
	// 		gas: 4712388
	// 	});
	// 	const user1=await retailer.methods.getUserInfo().call({from:accounts[1]});
	// 	const user2=await retailer.methods.getUserInfo().call({from:accounts[2]});

	// 	assert.equal("sonu sharma",user1.name);
	// 	assert.equal("satyam jaiswal",user2.name);
	// 	try{
	// 		await retailer.methods.getUserInfo().call({from:accounts[3]});
	// 		asert(false);
	// 	}catch(err){
	// 		assert.ok(err);
	// 	}
	// });

	// it('retailer add an item',async()=>{
	// 	await retailer.methods.retailerSignUp("sonu sharma","sonusharma20188031@gmail.com","6204629588","motihari").send({
	// 		from: accounts[1],
	// 		gas: 4712388
	// 	});
	// 	var cost=BigInt("2000000000000000000");
	// 	await retailer.methods.addItem(cost,"phone","https:://link","new phone infnix hot",false,10).send({
	// 		from: accounts[1],
	// 		gas: 4712388
	// 	});
	// 	const i=await retailer.methods.getItems().call({from:accounts[1]});
	// 	console.log(i);
	// 	await retailer.methods.editItemInfo(1,cost,"new phone","https:://link","new phone infnix hot",false,15).send({
 //        from:accounts[1],
 //        gas:4712388
 //      })
	// 	const ite=await retailer.methods.getItems().call({from:accounts[1]});
	// 	console.log(ite);


	// 	const items=await retailer.methods.getItems().call({from:accounts[1]});
	// 	const itemInfo1=await retailer.methods.getItemInfo(items[0].itemId,accounts[1]).call({from:accounts[1]});
	// 	assert.equal(cost,itemInfo1.price);

	// 	const newCost=BigInt("3000000000000000000");
	// 	await retailer.methods
	// 	.editItemInfo(items[0].itemId,newCost,items[0].title,items[0].imgLink,items[0].description,items[0].availableCashOnDelivery,items[0].quantity)
	// 		.send({from:accounts[1],gas:4712388});
	// 	const itemInfo2=await retailer.methods.getItemInfo(items[0].itemId,accounts[1]).call({from:accounts[1]});
	// 	assert.equal(newCost,itemInfo2.price);


	// 	try{
	// 		await retailer.methods.addItem(cost,"new phone infnix hot",false,10).send({
	// 			from: accounts[2],
	// 			gas: 4712388
	// 		});
	// 		assert(false);
	// 	}
	// 	catch(err){
	// 		assert.ok(err);
	// 	}

	// });
	it('customer add item to cart',async()=>{
		await customer.methods.customerSignUp("customer sharma","customer20188031@gmail.com","8795410843").send({
			from: accounts[2],
			gas: 4712388
		});
		await retailer.methods.retailerSignUp("sonu sharma","sonusharma20188031@gmail.com","6204629588","motihari").send({
			from: accounts[1],
			gas: 4712388
		});
		var cost=BigInt("2000000000000000000");
		await retailer.methods.addItem(cost,"phone","https:://link","new phone infnix hot",false,10).send({
			from: accounts[1],
			gas: 4712388
		});
		const itm=await retailer.methods.getItems().call({from:accounts[1]});
		console.log(itm);
		

		const itemInfo1=await retailer.methods.getItemInfo(itm[0].itemId,accounts[1]).call({from:accounts[1]});
		assert.equal(cost,itemInfo1.price);

		await customer.methods.addtoCart(itm[0].itemId,itm[0].addrRetailer,itm[0].imgLink,itm[0].price).send({
			from :accounts[2],
			gas: 4712388
		})

		const cartInfo=await customer.methods.getCartItemInfo().call({from:accounts[2]});

		console.log(cartInfo);


		await customer.methods.cashOnDeliveryOrder(itm[0].addrRetailer,itm[0].price,itm[0].itemId,"mnnit",1).send({
			from:accounts[2],
			gas: 4712388
		})

		const cartInfo1=await customer.methods.getCartItemInfo().call({from:accounts[2]});

		console.log(cartInfo1);

	});

	// it('customer order an item prepaid',async()=>{
	// 	await retailer.methods.retailerSignUp("retailer1","sonusharma20188031@gmail.com","6204629588","motihari").send({
	// 		from: accounts[1],
	// 		gas: 4712388
	// 	});

	// 	await customer.methods.customerSignUp("customer1","kumarvivek282880@gmal.com","83748946784").send({
	// 		from: accounts[2],
	// 		gas: 4712388
	// 	});
	// 	// console.log(await web3.eth.getBalance(accounts[1])/1000000000000000000);
	// 	// console.log(await web3.eth.getBalance(accounts[2])/1000000000000000000);

	// 	var cost=BigInt("2000000000000000000");
	// 	await retailer.methods.addItem(cost,"phone","https:://link","new phone infnix hot",false,10).send({
	// 		from: accounts[1],
	// 		gas: 4712388
	// 	});
	// 	const items=await retailer.methods.getItems().call({from:accounts[1]});



	// 	await customer.methods.payOnOrder(accounts[1],items[0].price,items[0].itemId,"delhi",2).send({
	// 		from: accounts[2],
	// 		gas: 4712388,
	// 		value: items[0].price*2
	// 	});

	// 	const orderCustomer=await customer.methods.getOrders().call({from: accounts[2]});
	// 	const orderRetailer=await retailer.methods.getOrders().call({from:accounts[1]});
	// 	// console.log(orderCustomer);
	// 	// console.log(orderRetailer);

	// 	const order=await retailer.methods.getOrderInfo(1).call({from:accounts[1]});
	// 	await customer.methods.setOrderStatusDispatched(order.addrCustomer,1).send({from:accounts[1],gas:4712388});
	// 	const orderInfo=await customer.methods.getOrderInfo(1).call({from:accounts[2]});
	// 	// console.log(orderInfo);
	// 	await customer.methods.deliveryWithoutPay(1,accounts[1]).send({from:accounts[2]});

	// 	// console.log(await web3.eth.getBalance(accounts[1])/1000000000000000000);
	// 	// console.log(await web3.eth.getBalance(accounts[2])/1000000000000000000);

	// });

	// it('customer order an item postpaid',async()=>{
	// 	await retailer.methods.retailerSignUp("retailer1","sonusharma20188031@gmail.com","6204629588","motihari").send({
	// 		from: accounts[1],
	// 		gas: 4712388
	// 	});

	// 	await customer.methods.customerSignUp("customer1","kumarvivek282880@gmal.com","83748946784").send({
	// 		from: accounts[2],
	// 		gas: 4712388
	// 	});
	// 	// console.log(await web3.eth.getBalance(accounts[1])/1000000000000000000);
	// 	// console.log(await web3.eth.getBalance(accounts[2])/1000000000000000000);
	// 	var cost=BigInt("2000000000000000000");
	// 	await retailer.methods.addItem(cost,"phone","https:://link","new phone infnix hot",false,10).send({
	// 		from: accounts[1],
	// 		gas: 4712388
	// 	});
	// 	const items=await retailer.methods.getItems().call({from:accounts[1]});



	// 	await customer.methods.cashOnDeliveryOrder(items[0].addrRetailer,items[0].price,items[0].itemId,"delhi",2).send({
	// 		from: accounts[2],
	// 		gas: 4712388,
	// 	});

	// 	const orderCustomer=await customer.methods.getOrders().call({from: accounts[2]});
	// 	const orderRetailer=await retailer.methods.getOrders().call({from:accounts[1]});
	// 	// console.log(orderCustomer);
	// 	// console.log(orderRetailer);
	// 	// console.log(accounts);

	// 	const order=await retailer.methods.getOrderInfo(1).call({from:accounts[1]});
	// 	// console.log(order);
	// 	const itemInfo=await retailer.methods.getItemInfo(1,accounts[1]).call({from:accounts[1]});
	// 	// console.log(itemInfo);
	// 	await customer.methods.setOrderStatusDispatched(order.addrCustomer,1).send({from:accounts[1],gas:4712388});
	// 	// const orderInfo=await customer.methods.getOrderInfo(1).call({from:accounts[2]});
	// 	// const orderInf=await retailer.methods.getOrderInfo(1).call({from:accounts[1]});
	// 	// console.log(orderInf);
	// 	// console.log(orderInfo);


	// 	await customer.methods.deliveryOnPay(1,order.addrRetailer).send({from:accounts[2],gas:4712388,value: orderCustomer[0].price});
	// 	// const orderInf=await customer.methods.getOrdersAdmin(accounts[2]).call({from:accounts[0]});
	// 	// console.log(orderInf);
	// 	// console.log(await web3.eth.getBalance(accounts[1])/1000000000000000000);
	// 	// console.log(await web3.eth.getBalance(accounts[2])/1000000000000000000);

		

	// });


});
