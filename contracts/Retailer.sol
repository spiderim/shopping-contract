pragma solidity >=0.7.0 <0.9.0;

contract Retailer {
    address public admin;
    uint256 numberOfItems;
    
    constructor(){
        admin=msg.sender;
        numberOfItems=0;
    }
    
    struct User{
        string name;
        address addrRetailer;
        bool userExist;
        string email;
        string phoneNumber;
        string shopAddress;
        uint256 userType;
    }
    
    struct Item{
        uint256 price;
        address addrRetailer;
        string title;
        string imgLink;
        string description;
        uint256 itemId;
        bool availableCashOnDelivery;
        uint256 quantity;
    }
    
    struct Order{
        uint256 orderId;
        uint256 price;
        address addrRetailer;
        address addrCustomer;
        uint256 orderStatus; //1->cashOnDeliveryOrder,2->payOnOrder,3->dispatchOrder,4->cancellOrder,5->deliveryOnPay,6->deliveryWithoutPay,7->replaceOrder
        uint256 itemId;
        string deliveryAddress;
        bool payStatus;
        string trackingId;
        string trackingCompanyName;
        uint256 quantity;
    }
    
    
    
    address[] retailerList;
    mapping(address=>Order[]) public orders;
    mapping(address=>User) public users;
    mapping(address=>Item[]) public items;

//user
    function isValidUser() external view returns(bool){
        if(users[msg.sender].userExist){
            return true;
        }
        return false;
    }
    function retailerSignUp(string memory _name,string memory _email,string memory _phoneNumber,string memory _shopAddress) public{
        require(!users[msg.sender].userExist,"user already exist");
        users[msg.sender].name= _name;
        users[msg.sender].addrRetailer= msg.sender;
        users[msg.sender].email = _email;
        users[msg.sender].userExist=true;
        users[msg.sender].phoneNumber=_phoneNumber;
        users[msg.sender].shopAddress=_shopAddress;
        users[msg.sender].userType=1;
        retailerList.push(msg.sender);
    }
    function getUserInfo() external view returns (User memory){
        require(users[msg.sender].userExist,"user doesn't exist! Signup first");
        return users[msg.sender];
    }
    function editUserInfo(string memory _name,string memory _email,string memory _phoneNumber,string memory _shopAddress) external{
        require(users[msg.sender].userExist,"user doesn't exist! Signup first");
        users[msg.sender].name=_name;
        users[msg.sender].email=_email;
        users[msg.sender].phoneNumber=_phoneNumber;
        users[msg.sender].shopAddress=_shopAddress;
    }

//Items
    function addItem(uint256 _price,string memory _title,string memory _imgLink,string memory _description,bool _availableCashOnDelivery,uint256 _quantity) public{
        require(users[msg.sender].userExist,"user doesn't exist! Signup first");
        require(_quantity>=1,"quantity must be valid");
        Item memory item;
        item.price=_price;
        item.addrRetailer=msg.sender;
        item.title=_title;
        item.imgLink=_imgLink;
        item.description=_description;
        item.availableCashOnDelivery=_availableCashOnDelivery;
        item.quantity=_quantity;
        numberOfItems+=1;
        item.itemId=numberOfItems;
        items[msg.sender].push(item);
    
    }
    
    function getAllItems() external view returns (Item[] memory){
        uint256 count=0;
        for(uint256 i=0;i<retailerList.length;i++){
            
            for(uint256 j=0;j<items[retailerList[i]].length;j++){
                
                count++;
            }
        }
        Item[] memory ans=new Item[](count);
        count=0;
        for(uint256 i=0;i<retailerList.length;i++){
            
            for(uint256 j=0;j<items[retailerList[i]].length;j++){
                
                ans[count]=items[retailerList[i]][j];
                count++;
            }
        }
        return ans;
    }
    function getItems() public view returns (Item[] memory){
        require(users[msg.sender].userExist,"user doesn't exist! Signup first");
        return items[msg.sender];
    }

    function editItemInfo(uint256 _itemId,uint256 _price,string memory _title,string memory _imgLink,string memory _description,bool _availableCashOnDelivery,uint256 _quantity) public{
       require(users[msg.sender].userExist,"user doesn't exist! Signup first");
       for(uint256 i=0;i<items[msg.sender].length;i++){
            
            if(items[msg.sender][i].itemId==_itemId){
                items[msg.sender][i].price=_price;
                items[msg.sender][i].title=_title;
                items[msg.sender][i].imgLink=_imgLink;
                items[msg.sender][i].description=_description;
                items[msg.sender][i].availableCashOnDelivery=_availableCashOnDelivery;
                items[msg.sender][i].quantity=_quantity;
                break;
            }
        }
       
    }

    function getItemInfo(uint256 _itemId,address _addrRetailer) public view returns(Item memory){
        for(uint256 i=0;i<items[_addrRetailer].length;i++){
            
            if(items[_addrRetailer][i].itemId==_itemId){
                return items[_addrRetailer][i];
            }
        }
        revert("item not found");
        
    }
    
//orders
    function getOrders() public view returns (Order[] memory){
        require(users[msg.sender].userExist,"user doesn't exist! Signup first");
        return orders[msg.sender];
    }
    function getOrderInfo(uint256 _orderId) external view returns(Order memory){
        require(users[msg.sender].userExist,"user doesn't exist! signup first");
        for(uint256 i=0;i<orders[msg.sender].length;i++){
            if(orders[msg.sender][i].orderId==_orderId){
                return orders[msg.sender][i];
            }
        }
        revert('item not found');
    }


    
   //call by customer

    function setDeliveryAddress(address _addrRetailer,uint256 _orderId,string memory _deliveryAddress)external{
        for(uint256 i=0;i<orders[_addrRetailer].length;i++){
            
            if(orders[_addrRetailer][i].orderId==_orderId){
                orders[_addrRetailer][i].deliveryAddress=_deliveryAddress;
                break;
            }
        }
    }
     function setOrderStatusDispatched(address _addrRetailer,uint256 _orderId,uint256 _orderStatus,string memory _trackingId,string memory _trackingCompanyName) external{   
        for(uint256 i=0;i<orders[_addrRetailer].length;i++){
            
            if(orders[_addrRetailer][i].orderId==_orderId){
                orders[_addrRetailer][i].orderStatus=_orderStatus;
                orders[_addrRetailer][i].trackingId=_trackingId;
                orders[_addrRetailer][i].trackingCompanyName=_trackingCompanyName;
                break;
            }
        }
    }
    function setOrderStatus(address _addrRetailer,uint256 _orderId,uint256 _orderStatus) external{   
        for(uint256 i=0;i<orders[_addrRetailer].length;i++){
            
            if(orders[_addrRetailer][i].orderId==_orderId){
                orders[_addrRetailer][i].orderStatus=_orderStatus;
                break;
            }
        }
    }

    function makeOrder(uint256 _orderId,uint256 _price,address _addrRetailer,address _addrCustomer,uint256 _orderStatus,uint256 _itemId,string memory _deliveryAddress,bool _payStatus,uint256 _quantity) external{
        Order memory order;
        order.orderId=_orderId;
        order.price=_price*_quantity;
        order.addrRetailer=_addrRetailer;
        order.orderStatus=_orderStatus;
        order.itemId=_itemId;
        order.deliveryAddress=_deliveryAddress;
        order.addrCustomer=_addrCustomer;
        order.payStatus=_payStatus;
        order.quantity=_quantity;
        order.trackingId="";
        order.trackingCompanyName="";
        orders[_addrRetailer].push(order);

        for(uint256 i=0;i<items[_addrRetailer].length;i++){
            
            if(items[_addrRetailer][i].itemId==_itemId){
                require(items[_addrRetailer][i].quantity-_quantity>0,"quantity is not enough");
                items[_addrRetailer][i].quantity-=_quantity;
                break;
            }
        }
    }
//call by admin
    function getOrdersAdmin(address _addrRetailer) external view returns(Order[] memory){
        require(msg.sender==admin,"you are not admin");
        
        return orders[_addrRetailer];
    } 
    
    function getRetailerInfo(address _addrRetailer) external view returns(User memory){
        require(msg.sender==admin,"you are not admin");
        return users[_addrRetailer];
    }
     
}