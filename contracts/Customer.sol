pragma solidity >=0.7.0 <0.9.0;
import './Retailer.sol';

contract Customer{
    address retailer;
    address public admin;
    uint256 numberOfOrders;
    constructor(address ad){
        admin=msg.sender;
        numberOfOrders=0;
        retailer=ad;
    }
    
    struct User{
        string name;
        address addrCustomer;
        bool userExist;
        string email;
        string phoneNumber;
        uint256 userType;
    }
    
    struct Order{
        uint256 orderId;
        uint256 price;
        address addrRetailer;
        address addrCustomer;
        uint256 orderStatus; //1->cashOnDeliveryOrder,2->payOnOrder,3->dispatchOrder,4->cancellOrder,5->deliveryOnPay,6->deliveryWithoutPay,7->replaceOrder,8->returnOrderStart,9->returnOrderPickedUp,10->returnOrderSucessful
        uint256 itemId;
        string deliveryAddress;
        bool payStatus;
        uint256 quantity;
        string trackingId;
        string trackingCompanyName;
    }

    mapping(address=> User) public users;
    mapping(address=> Order[]) public orders;

//User

    function isValidUser() external view returns(bool){
        if(users[msg.sender].userExist){
            return true;
        }
        return false;
    }

    function customerSignUp(string memory _name,string memory _email,string memory _phoneNumber) external{
        require(!users[msg.sender].userExist,"user already exist");
        users[msg.sender].name= _name;
        users[msg.sender].addrCustomer= msg.sender;
        users[msg.sender].email = _email;
        users[msg.sender].userExist=true;
        users[msg.sender].phoneNumber=_phoneNumber;
        users[msg.sender].userType=2;
    }

    function getUserInfo() external view returns (User memory){
        require(users[msg.sender].userExist,"user doesn't exist! Signup first");
        return users[msg.sender];
    }
    
    function editUserInfo(string memory _name,string memory _email,string memory _phoneNumber) external {
        require(users[msg.sender].userExist,"user doesn't exist! Signup first");
        users[msg.sender].name=_name;
        users[msg.sender].email=_email;
        users[msg.sender].phoneNumber=_phoneNumber;
    }

//order
    function cashOnDeliveryOrder(address _addrRetailer,uint _price,uint256 _itemId,string memory _deliveryAddress,uint256 _quantity) external {
        require(users[msg.sender].userExist,"user doesn't exist! Signup first");
        require(_quantity>0,"quantity is not valid");
        Order memory order;
        order.price=_price*_quantity;
        order.addrRetailer=_addrRetailer;
        order.addrCustomer=msg.sender;
        numberOfOrders+=1;
        order.orderId=numberOfOrders;
        order.orderStatus=1;
        order.itemId=_itemId;
        order.trackingId="";
        order.trackingCompanyName="";
        order.deliveryAddress=_deliveryAddress;
        order.payStatus=false;
        order.quantity=_quantity;
        orders[msg.sender].push(order);
        Retailer ret=Retailer(retailer);
        ret.makeOrder(order.orderId,_price,_addrRetailer,msg.sender,1,_itemId,_deliveryAddress,false,_quantity);


    }
    
    function payOnOrder(address _addrRetailer,uint _price,uint256 _itemId,string memory _deliveryAddress,uint256 _quantity) external payable {
        require(users[msg.sender].userExist,"user doesn't exist! Signup first");
        require(_quantity>0,"quantity is not valid");
        require(msg.value==_price*_quantity,"amount must match price");
        Order memory order;
        order.price=_price*_quantity;
        order.addrRetailer=_addrRetailer;
        order.addrCustomer=msg.sender;
        numberOfOrders+=1;
        order.orderId=numberOfOrders;
        order.itemId=_itemId;
        order.trackingId="";
        order.trackingCompanyName="";
        order.orderStatus=2;
        order.quantity=_quantity;
        order.deliveryAddress=_deliveryAddress;
        order.payStatus=true;
        orders[msg.sender].push(order);
        Retailer ret=Retailer(retailer);
        ret.makeOrder(order.orderId,_price,_addrRetailer,msg.sender,2,_itemId,_deliveryAddress,true,_quantity);

    }
    

    
    function setDeliveryAddress(address _addrRetailer,uint _orderId,string memory newAddress) external{
        require(users[msg.sender].userExist,"user doesn't exist! Signup first");
        
        for(uint256 i=0;i<orders[msg.sender].length;i++){
            
            if(orders[msg.sender][i].orderId==_orderId){
                
                orders[msg.sender][i].deliveryAddress=newAddress;
                break;
            }
        }
        Retailer ret=Retailer(retailer);
        ret.setDeliveryAddress(_addrRetailer,_orderId,newAddress);
    }

    function cancelOrder(uint256 _orderId,address _addrRetailer) public{
       require(users[msg.sender].userExist,"user doesn't exist! Signup first");

        for(uint256 i=0;i<orders[msg.sender].length;i++){//_price value is in wei
            
            if(orders[msg.sender][i].orderId==_orderId){

                require(orders[msg.sender][i].orderStatus<4,'item already delivered');
                if(orders[msg.sender][i].payStatus==true){
                   payable(msg.sender).transfer(orders[msg.sender][i].price); 
                }
                orders[msg.sender][i].orderStatus=4;
                break;
            }
        }

        Retailer ret=Retailer(retailer);
        ret.setOrderStatus(_addrRetailer,_orderId,4);
        
    }
    
    function deliveryOnPay(uint256 _orderId,address _addrRetailer) public payable{
        require(users[msg.sender].userExist,"user doesn't exist! Signup first");

        for(uint256 i=0;i<orders[msg.sender].length;i++){//_price value is in wei
            
            if(orders[msg.sender][i].orderId==_orderId){
                require(msg.value==orders[msg.sender][i].price,'enter exact amount');
                payable(orders[msg.sender][i].addrRetailer).transfer(orders[msg.sender][i].price);
                orders[msg.sender][i].orderStatus=5;
                break;
            }
        }

        Retailer ret=Retailer(retailer);
        ret.setOrderStatus(_addrRetailer,_orderId,5);
   
    }
    
    
    function deliveryWithoutPay(uint256 _orderId,address _addrRetailer) public{
        require(users[msg.sender].userExist,"user doesn't exist! Signup first");
        
        for(uint256 i=0;i<orders[msg.sender].length;i++){
            
            if(orders[msg.sender][i].orderId==_orderId){
                payable(orders[msg.sender][i].addrRetailer).transfer(orders[msg.sender][i].price);
                orders[msg.sender][i].orderStatus=6;
                break;
            }
        }
        Retailer ret=Retailer(retailer);
        ret.setOrderStatus(_addrRetailer,_orderId,6);
    }

    
    function getOrders() external view returns (Order[] memory){
        require(users[msg.sender].userExist,"user doesn't exist! Signup first");
        return orders[msg.sender];
    }
 
    function getOrderInfo(uint256 _orderId) external view returns(Order memory){
        require(users[msg.sender].userExist,"user doesn't exist! Signup first");
        for(uint256 i=0;i<orders[msg.sender].length;i++){
            if(orders[msg.sender][i].orderId==_orderId){
                return orders[msg.sender][i];
            }
        }
        revert('order not found');
    }

// call by retailer
    function setOrderStatusDispatched(address _addrCustomer,uint256 _orderId,string memory _trackingId,string memory _trackingCompanyName) external{

        for(uint256 i=0;i<orders[_addrCustomer].length;i++){
            
            if(orders[_addrCustomer][i].orderId==_orderId){
                orders[_addrCustomer][i].orderStatus=3;
                orders[_addrCustomer][i].trackingId=_trackingId;
                orders[_addrCustomer][i].trackingCompanyName=_trackingCompanyName;
                break;
            }
        }
        Retailer ret=Retailer(retailer);
        ret.setOrderStatusDispatched(msg.sender,_orderId,3,_trackingId,_trackingCompanyName);
    }

    function returnOrderSucess(address _addrCustomer,uint256 _orderId) external{

        for(uint256 i=0;i<orders[_addrCustomer].length;i++){
            
            if(orders[_addrCustomer][i].orderId==_orderId){
                orders[_addrCustomer][i].orderStatus=10;
                break;
            }
        }
        Retailer ret=Retailer(retailer);
        ret.setOrderStatus(msg.sender,_orderId,10);
    }

//call by admin
    function getOrdersAdmin(address _addrCustomer) external view returns(Order[] memory){
        require(msg.sender==admin,"you are not admin");
        
        return orders[_addrCustomer];
    } 
    
    function getCustomerInfo(address _addrCustomer)external  view returns(User memory){
        require(msg.sender==admin,"you are not admin");
        return users[_addrCustomer];
    }
    
     
}