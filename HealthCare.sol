// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.12;

contract HealthCare {
    address private owner; // owner is Insurance Company

    mapping (uint=> Record) public records;
    enum RecordStatus {PENDING, APPROVED, DENIED}

    struct Record {
        uint id;
        address patientAddr;
        address hospitalAddr;
        string billId; // points to the pdf stored in supabase
        uint price;
        mapping (address => RecordStatus) status; // status of the record
        bool isValid; // variable to check if reacord has already been created or not
    }

    constructor() { // set owner on deploy as deployer address
        owner = msg.sender;
    }

    // Helpers
    modifier onlyOwner {
        require(owner == msg.sender, 'Not Authorised');
        _;
    }

    function setOwner(address _owner) onlyOwner external { 
        owner = _owner;
    }

    // Events
    event recordCreated(uint id, address patientAddr, address hospitalAddr, uint price);
    event recordSigned(uint id, address patientAddr, address hospitalAddr, address owner, uint price, RecordStatus status, string statusMsg);

    // Functions
    function newRecord(uint _id, address _hospitalAddr, string memory _billId, uint _price) public {
        Record storage _newRecord = records[_id];
        require(!records[_id].isValid, "Record of entered id already exists.");
        require(msg.sender != _hospitalAddr, "Patient address and Hospital Address cannot be same.");

        _newRecord.id = _id;
        _newRecord.patientAddr = msg.sender;
        _newRecord.hospitalAddr = _hospitalAddr;
        _newRecord.billId = _billId;
        _newRecord.price = _price;
        _newRecord.isValid = true;
        
        emit recordCreated(_newRecord.id, _newRecord.patientAddr, _newRecord.hospitalAddr, _newRecord.price);
    }

    function signRecord(uint _id, RecordStatus _status, string memory _statusMsg ) public { // status msg says why record was approved or disapproved
        Record storage record = records[_id];
        require(records[_id].isValid, "Record does not exist.");
        require(msg.sender == owner || (record.hospitalAddr == msg.sender), "You are not allowed to sign this Record.");
        require(record.status[msg.sender] == RecordStatus.PENDING, "Record has already been signed.");

        record.status[msg.sender] = _status;
        emit recordSigned(record.id, record.patientAddr, record.hospitalAddr, owner, record.price, _status, _statusMsg);
    }

}