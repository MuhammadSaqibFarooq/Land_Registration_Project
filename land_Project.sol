// SPDX-License-Identifier:GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

contract Land_Registran {
    // State variable of type address for owner of Contract
    address private landDepartment;

    // State variable of type uint for Lands count
    uint public generateLandsId;

    // Constructor to make deployer of the contract Land Inspector
    constructor() {
        landDepartment = msg.sender;
    }
    
    // Event for registerOrUpdateLandInspector Function
    event inspectorRegister(
        string status,
        address id,
        string Name,
        uint Age,
        string Designation
    );

    // Event for registerOrUpdateSeller Function
    event sellerRegister(
        string status,
        string Name,
        uint Age,
        string City,
        uint CNIC,
        string Email
    );

    // Event for registerOrUpdateLandBuyer Function
    event buyerRegister(
        string status,
        string Name,
        uint Age,
        string City,
        uint CNIC,
        string Email
    );

    // Event for registerLand Function
    event landRegister(
        string status,
        uint landId,
        address seller
    );

    // Event for BuyLand Function
    event buyingLand(
        string status,
        uint landId,
        uint price,
        address seller,
        address buyer
    );

    // Event for transferOwnership Function
    event ownershipTransfer(
        address oldOwner,
        uint landId,
        address newOwner
    );

    // Struct to store Seller data
    struct sellerStruct {
        string Name;
        uint Age;
        string City;
        uint CNIC;
        string Email;
        bool isVerified;
    }

    // Struct to store Buyer data
    struct buyerStruct {
        string Name;
        uint Age;
        string City;
        uint CNIC;
        string Email;
        bool isVerified;
    }

    // Struct to store Land data
    struct landStruct {
        uint LandId;
        uint Area;
        string City;
        string State;
        uint LandPrice;
        
        bool isVerified;
    }

    // Mappings
    mapping(address => sellerStruct) private SellerMapping;
    mapping(address => buyerStruct) private BuyerMapping;
    mapping(uint => landStruct) public Lands;
    mapping(uint => address) private landOwnerMapping;
    mapping(address => uint) public ownerMapping;

    // landInspectorStruct type variable
    struct landInspectorStruct {
        address id;
        string Name;
        uint Age;
        string Designation;
    }

    landInspectorStruct private Inspector;
    
    // Function to register or update Land Inspector, only Contract Deployer can call this function
    function registerOrUpdateLandInspector(
        string memory _name,
        uint _age,
        string memory _designation
    ) public {
        require(msg.sender == landDepartment, "Only the Land_Department can add Land_inspector Details");
        Inspector = landInspectorStruct(landDepartment, _name, _age, _designation);
        emit inspectorRegister("Land Inspector data is successfully saved", msg.sender, _name, _age, _designation);
    }

    // Modifier to restrict some functions for Inspector only
    modifier onlyInspector() {
        require(msg.sender == Inspector.id, "You are not the Land Inspector");
        _;
    }

    // Function to register or update Seller
    // A buyer and Inspector cannot call this function
    function registerOrUpdateSeller(
        string memory _Name,
        uint _Age,
        string memory _City,
        uint _CNIC,
        string memory _Email
    ) public {
        require(msg.sender != Inspector.id, "The LandInspector cannot be seller");
        require(BuyerMapping[msg.sender].isVerified != true, "This Address/person is already registered as a Buyer");
        SellerMapping[msg.sender] = sellerStruct(_Name, _Age, _City, _CNIC, _Email, false);
        emit sellerRegister("Seller data is successfully saved", _Name, _Age, _City, _CNIC, _Email);
    }

    // Function to set the verification status of a seller
    // Only the Inspector can call this function
    function verifySeller(address _address, bool _status) public onlyInspector {
        SellerMapping[_address].isVerified = _status;
    }

    // Function to register Land
    // Land should not be registered already
    // Caller of the function should not be registered as a Buyer
    // Only a Seller can call this function
    // Seller should be verified
    function registerLand(
        uint _area,
        string memory _city,
        string memory _state,
        uint _price
        
    ) public {
        require(ownerMapping[msg.sender] == 0, "Land is already registered on this Address");
        require(BuyerMapping[msg.sender].isVerified != true, "This person is registered as a Buyer");
        require(SellerMapping[msg.sender].isVerified == true, "Frist verified the Seller  ");
        generateLandsId++;
        Lands[generateLandsId] = landStruct(generateLandsId, _area, _city, _state, _price, false);
        landOwnerMapping[generateLandsId] = msg.sender;
        ownerMapping[msg.sender] = generateLandsId;
        emit landRegister("Land data successfully saved", generateLandsId, msg.sender);
    }

    // Function to set verification status of Land
    // Only the Inspector can call this function
    function verifyLand(uint _landId, bool _status) public onlyInspector {
        Lands[_landId].isVerified = _status;
    }

    // Function to register or update Buyer
    // Caller of the function should not be registered as a Seller
    // Inspector cannot call this function
    // Anyone can call this function
    function registerOrUpdateBuyer(
        string memory _Name,
        uint _Age,
        string memory _City,
        uint _CNIC,
        string memory _Email
    ) public {
        require(msg.sender != Inspector.id, "Inspector cannot be a Buyer");
        require(SellerMapping[msg.sender].isVerified != true, "This person is registered as a Seller");
        BuyerMapping[msg.sender] = buyerStruct(_Name, _Age, _City, _CNIC, _Email, false);
        emit buyerRegister("Buyer data is successfully saved", _Name, _Age, _City, _CNIC, _Email);
    }

    // Function to set verification status of Buyer
    // Only the Inspector can call this function
    function verifyBuyer(address _address, bool _status) public onlyInspector {
        BuyerMapping[_address].isVerified = _status;
    }

    // Function to transfer ownership of Land
    // Only the land owner can call this function
    function TransferOwnership(uint _landId, address _address) public {
        require(landOwnerMapping[_landId] == msg.sender, "You are not the owner of this Land");
        require(msg.sender != _address, "Owner cannot transfer ownership to themselves");
        landOwnerMapping[_landId] = _address;
        ownerMapping[_address] = _landId;
        emit ownershipTransfer(msg.sender, _landId, _address);
    }

    // Function to buy Land by its Land Id
    // Owner of Land cannot buy it
    // Caller of the function should be a verified Buyer
    // Owner of the land should be a verified Seller
    // Land must be verified
    // Price sent by Buyer must be equal to Land Price
    function BuyLand(uint _landId) public payable {
    require(landOwnerMapping[_landId] != msg.sender, "You cannot buy Land because you are the Owner");
    require(BuyerMapping[msg.sender].isVerified == true, "Buyer is not verified");
    require(SellerMapping[landOwnerMapping[_landId]].isVerified == true, "Seller is not verified");
    require(Lands[_landId].isVerified == true, "Land is not verified");

    require(msg.value == Lands[_landId].LandPrice * 1 ether, "Sent Ether amount does not match the Land price");

    payable(landOwnerMapping[_landId]).transfer(msg.value);
    landOwnerMapping[_landId] = msg.sender;
    ownerMapping[msg.sender] = _landId;

    emit buyingLand(
        "Land bought successfully",
        _landId,
        Lands[_landId].LandPrice,
        landOwnerMapping[_landId],
        msg.sender
    );
}


    // Function to check Land Owner by Land Id
    // Anyone can call this function
    function LandOwner(uint _landId) public view returns(address _address) {
        return landOwnerMapping[_landId];
    }

    // Function to check if Land is verified or not by Land Id
    // Anyone can call this function
    function LandIsVerified(uint _landId) public view returns(bool) {
        return Lands[_landId].isVerified;
    }

    // Function to check if Seller is verified or not by their Address
    // Anyone can call this function
    function SellerIsVerified(address _address) public view returns(bool) {
        return SellerMapping[_address].isVerified;
    }

    // Function to check if Buyer is verified or not by their Address
    // Anyone can call this function
    function BuyerIsVerified(address _address) public view returns(bool) {
        return BuyerMapping[_address].isVerified;
    }

    // Function to check who is the Land Inspector
    // Anyone can call this function
    function CheckLandInspector() public view returns (landInspectorStruct memory) {
        return Inspector;
    }

    // Function to check what is the Land City by Land Id
    // Anyone can call this function
    function GetLandCity(uint _landId) public view returns(string memory) {
        return Lands[_landId].City;
    }

    // Function to check what is the Land Price by Land Id
    // Anyone can call this function
    function GetLandPrice(uint _landId) public view returns(uint) {
        return Lands[_landId].LandPrice;
    }

    // Function to check what is the area of Land by Land Id
    // Anyone can call this function
    function GetLandArea(uint _landId) public view returns(uint) {
        return Lands[_landId].Area;
    }

    // Function to check if caller of function is a Buyer
    // Anyone can call this function
    function isBuyer() public view returns(bool) {
        return BuyerMapping[msg.sender].isVerified;
    }

    // Function to check if caller of function is a Seller
    // Anyone can call this function
    function isSeller() public view returns(bool) {
        return SellerMapping[msg.sender].isVerified;
    }
}
