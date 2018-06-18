pragma solidity 0.4.23;

import "./Ownable.sol";

contract DDNS is Ownable {
    struct Receipt{
        uint amountPaidWei;
        uint timestamp;
        uint expires;
    }

    struct DomainInfo {
        uint256 endTime;
        bytes4 ip;
        address owner;
    }

    mapping(bytes => DomainInfo) private people;

      //This will create an automatic getter with 2 arguments: address and index of receipt
    mapping(address => Receipt[]) public receipts;

    modifier OnlyValidDomain(bytes _domain) {
        require(_domain.length >= 5);
        _;
    }

    modifier OnlyOwnerOfDomain(bytes _domain) {
        require(msg.sender == people[_domain].owner);
        _;
    }

    //the domain is bytes, because string is UTF-8 encoded and we cannot get its length
    //the IP is bytes4 because it is more efficient in storing the sequence
    function register(bytes _domain, bytes4 _ip) public payable OnlyValidDomain(_domain) {
        require(msg.value >= 1 ether);

        uint endDate;

        if(people[_domain].endTime != 0) {

            people[_domain].endTime = people[_domain].endTime + 1 years;

            endDate = people[_domain].endTime + 1 years;

        }
        else {
            people[_domain].endTime = now + 1 years;
            people[_domain].ip = _ip;
            people[_domain].owner = msg.sender;

            endDate = now + 1 years;

        }

        receipts[msg.sender].push(Receipt(msg.value, now, endDate));
    }
    
    function edit(bytes _domain, bytes4 _newIp) public OnlyValidDomain(_domain) OnlyOwnerOfDomain(_domain) {

        require(people[_domain].ip != _newIp);

        people[_domain].ip = _newIp;

    }
    
    function transferDomain(bytes _domain, address _newOwner) public OnlyValidDomain(_domain) OnlyOwnerOfDomain(_domain) {

        require(people[_domain].owner != _newOwner);

        people[_domain].owner = _newOwner;
    }
    
    function getIP(bytes _domain) public view returns (bytes4) {
        return people[_domain].ip;
    }
    
    function getPrice(bytes _domain) public view returns (uint) {
        // *
    }

    function getDomainInfo(bytes _domain) public view OnlyValidDomain(_domain) OnlyOwnerOfDomain(_domain) returns (uint256, bytes4) {
        return (people[_domain].endTime, people[_domain].ip);
    }

    /// @author Alex Stanoev
    /// @notice withdrawal all contract money to owner
    function withdraw() public onlyOwner {
        // initialize variable myAddress - hold contract address
        address myAddress = this;
        
        // declarete balance variable that will hold contract balance
        uint balance = myAddress.balance;
        
        // check if balance is more then zero
        require(balance > 0);
        
        // transfer all contract balance to the owner of the contract
        owner.transfer(balance);
    }
}