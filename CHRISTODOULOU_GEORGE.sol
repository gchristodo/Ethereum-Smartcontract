pragma solidity >=0.5.11 <0.7.0;

// ETHEREUM ASSIGNMENT, CHRISTODOULOU GEORGE AM:55
contract Assignment {

    // Initialization of Doner struct. Every Doner object contains its amount donated and its address
    struct HighestDonor{
        uint hd_amount;
        address hd_address;
    }

    // member variables
    address owner;                  // The address that deplays the contract
    address payable[] charity;      // List of addresses of the charities
    uint public totalCharityBalance = 0;    // Total Balance of all charities / Charity fund tracker
    HighestDonor[] private donor_list;   // An array containing all donors structs with their address and donated amount

    // constructor declaring the owner of the contract
    constructor(address payable[] memory _charity) public {
        charity = _charity;
        owner = msg.sender;
    }

    // A modifier to be used for destroySmartContract and highestDonor methods.
    modifier onlyOwner {
        require(msg.sender == owner, "You are not allowed!");
        _;
    }

    //Event Initialization
    event MoneySent(address _origin, uint _amount);

    // sendMoney function: A method that sends ethers from the sender to the reveiver and the charity.
    // parameters:
    // 1. address payable _receiver: The address of the person we want to send money to
    // 2. uint _charity_index: an integer indicating a specific address within the charity list.
    // raises the following errors:
    // 1. "Index should be a non negative number", if the sender accidentally inserts a negative number as index.
    // 2. "Index not valid.", if the sender accidentally inserts a not valid index.
    // Comments: This method calls the splitMoney method.
    function sendMoney(address payable _receiver, uint _charity_index) public payable{
        // After discussion during lecture, a transaction cannot be initialized by default if the sender doesn't have sufficient funds:
        // require(msg.sender.balance >= msg.value, "The user sending money to the contract doesn't have sufficient funds");
        require(_charity_index >= 0, "Index should be a non negative number");
        require(_charity_index < charity.length, "Index not valid." );
        address payable _to_charity_address = charity[_charity_index];
        uint _amount = msg.value;
        address _sentfrom = msg.sender;
        splitMoney(_sentfrom, _receiver, _to_charity_address, _amount);
    }

    // splitMoney function: A method that splits the money sent from the sender to the right proportions as defined by the assignment:
    // 10% goes to the charity while the rest to the initial reveiver.
    // parameters:
    // 1. address _sentfrom: The address that the money came from.
    // 2. address payable _to_address: The address that the money are sent to.
    // 3. address payable _to_charity_address: The address of the charity that a portion of the  money are sent to.
    // 4. uint _amount: The initial amount of the money sent by the sender.
    // Emits a log event indicating the origin of the donation (the address that the money came from) and the donated amount.
    // Comments: This method splits the initial amount of the sender to 90% and 10%. 90% of the total amount are sent to the target address,
    // while 10% to the indicating charity address. This method also adds the donated amount to the totalCharityBalance variable. The donor is
    // inserted into HighestDonor list as object containing its address and its donation. Finally an event is emiited in logs, indicating the
    // donor's address and his/her donation.
    function splitMoney(address _sentfrom, address payable _to_address, address payable _to_charity_address, uint _amount) private {
        uint _donation = _amount/ 10;
        uint _transaction = _amount * 9 / 10;
        address donation_origin = _sentfrom;
        _to_address.transfer(_transaction);
        _to_charity_address.transfer(_donation);
        totalCharityBalance += _donation;
        donor_list.push(HighestDonor(_donation, donation_origin));
        emit MoneySent(donation_origin, _donation);
    }

    // sendMoney function: A method that sends ethers from the sender to the reveiver and the charity
    // parameters:
    // 1. address payable _receiver: The address of the person we want to send money to
    // 2. uint _charity_index: an integer indicating a specific address within the charity list.
    // 3. uint _donated_amount: A value indicating the amount of the original money to be transfered to the charity
    // raises the following errors:
    // 1. "Index should be a non negative number", if the sender accidentally inserts a negative number as index.
    // 2. "Index not valid.", if the sender accidentally inserts a not valid index.
    // 3. "Donated amount should be at least 1% of the total amount transfered.", if the donated amount is less than 1% of the original amount transfered.
    // 4. "Donated amount cannot exceed half of the total amount transfered.", if the donated amount is more than the half of the original amount transfered.
    // Comments: This method calls the splitMoney method.
    function sendMoney(address payable _receiver, uint _charity_index, uint _donated_amount) public payable{
        // After discussion during lecture, a transaction cannot be initialized by default if the sender doesn't have sufficient funds:
        // require(msg.sender.balance >= msg.value, "The user sending money to the contract doesn't have sufficient funds");
        require(_charity_index >= 0, "Index should be a non negative number");
        require(_charity_index < charity.length, "Index not valid." );
        address  payable _to_charity_address = charity[_charity_index];
        uint _donation = _donated_amount;
        uint _amount = msg.value;
        address _sentfrom = msg.sender;
        require(_donation >= _amount/100, "Donated amount should be at least 1% of the total amount transfered.");
        require(_donation <= _amount / 2, "Donated amount cannot exceed half of the total amount transfered.");
        splitMoney(_sentfrom, _receiver, _to_charity_address, _amount, _donation);

    }
    // splitMoney function: A method that splits the money sent from the sender to the right proportions as defined by the assignment.
    // parameters:
    // 1. address _sentfrom: The address that the money came from.
    // 2. address payable _to_address: The address that the money are sent to.
    // 3. address payable _to_charity_address: The address of the charity that a portion of the  money are sent to.
    // 4. uint _amount: The initial amount of the money sent by the sender.
    // 5. uint _donation: The amount of money that the user wants to donate from his/her original transfer.
    // Emits a log event indicating the origin of the donation (the address that the money came from) and the donated amount.
    // Comments: This method subtracts the donated amount from the original amount to be sent. The result of the subtraction is sent to
    // the address of the reveiver, while the rest are sent to the charity address.
    // This method also adds the donated amount to the totalCharityBalance variable. The donor is
    // inserted into HighestDonor list as object containing its address and its donation. Finally an event is emiited in logs, indicating the
    // donor's address and his/her donation.
    function splitMoney(address _sentfrom, address payable _to_address, address payable _to_charity_address, uint _amount, uint _donation) private {
        uint _amount_to_receiver = _amount - _donation;
        address donation_origin = _sentfrom;
        _to_address.transfer(_amount_to_receiver);
        _to_charity_address.transfer(_donation);
        totalCharityBalance += _donation;
        donor_list.push(HighestDonor(_donation, donation_origin));
        emit MoneySent(donation_origin, _donation);
    }

    // highestDonor function: A method that returns the highest Donor address and its donated amount among a list of donors.
    // parameters: None
    // Comments: Only the owner of the contract has the ability to use this method. This method calls the highestDonor method.
    function highestDonor() public view onlyOwner returns (address _address, uint _donated_amount){
        uint highestDonorIndex = findHighestDonor();
        _address = donor_list[highestDonorIndex].hd_address;
        _donated_amount = donor_list[highestDonorIndex].hd_amount;
    }

    // findHighestDonor function: A method that iterates over a list of donors and returns the index of the highest Donor.
    // parameters: None
    // raises the following errors:
    // 1. "There are no donors yet!", if no donation has been done yet.
    function findHighestDonor() private view returns (uint highestDonorIndex){
        require(donor_list.length !=0 , "There are no donors yet!" );
        uint highestDonation = 0;
        for(uint i = 0; i < donor_list.length; i++){
            if(donor_list[i].hd_amount > highestDonation){
                highestDonation = donor_list[i].hd_amount;
                highestDonorIndex = i;
            }
        }
    }

    // destroySmartContract function: A method that destroys the smart contract, usable only by the owner of the contract.
    // parameters:
    // 1. address payable _to: an address payable variable
    // raises the following errors:
    // 1. "You are not the owner", if the address doesn't match with the deployer's address.
    function destroySmartContract(address payable _owner_address) public onlyOwner{
        selfdestruct(_owner_address);
    }
}
