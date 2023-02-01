pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

contract SupplyChain {
    struct Batch {
        address owner;
        string batchID;
        string harvestDate;
        string location;
        address processor;
        string packagingDate;
        bool isProcessed;
    }

    mapping(string => Batch) public batches;
    mapping(string => SupplyChainEvent[]) public batchHistory;

    struct SupplyChainEvent {
        string eventType;
        uint timestamp;
        string eventData;
    }

    function createBatch(string memory _batchID) public {
        batches[_batchID] = Batch({
            owner: msg.sender,
            batchID: _batchID,
            harvestDate: "",
            location: "",
            processor: address(0),
            packagingDate: "",
            isProcessed: true
        });
    }

    function addBatchInfo(string memory _batchID, string memory _harvestDate, string memory _location) public {
        require(msg.sender == batches[_batchID].owner);
        batches[_batchID].harvestDate = _harvestDate;
        batches[_batchID].location = _location;
        bytes memory data = abi.encode(_harvestDate, " | ", _location);
        string memory dataString = string(data);
        addSupplyChainEvent(_batchID, "Harvest", dataString);
    }

    function updateHarvestDate(string memory _batchID, string memory _newHarvestDate) public {
        require(msg.sender == batches[_batchID].owner);
        batches[_batchID].harvestDate = _newHarvestDate;
        addSupplyChainEvent(_batchID, "Harvest Date Updated", _newHarvestDate);
    }

    function updateTransportationInfo(string memory _batchID, string memory _carrier, string memory _route) public {
        require(msg.sender == batches[_batchID].owner);
        bytes memory data = abi.encode(_carrier," | ", _route);
        string memory dataString = string(data);
        addSupplyChainEvent(_batchID, "Transportation", dataString);
    }

    function updateBatchStatus(string memory _batchID, string memory _currentStatus) public {
        require(msg.sender == batches[_batchID].owner);
        addSupplyChainEvent(_batchID, "Status Update", _currentStatus);
    }

    function transferOwnership(string memory _batchID, address _newOwner) public {
        require(msg.sender == batches[_batchID].owner);
        batches[_batchID].owner = _newOwner;
        addSupplyChainEvent(_batchID, "Ownership Transfer", addressToString(_newOwner));
    }

    function verifyCompliance(string memory _batchID) public view returns (bool) {
    // Placeholder function, implementation would depend on specific regulations
        return true;
    }

    function addSupplyChainEvent(string memory _batchID, string memory _eventType, string memory _eventData) internal {
        batchHistory[_batchID].push(SupplyChainEvent(_eventType, block.timestamp, _eventData));
    }

    function getBatchHistory(string memory _batchID) view public returns (SupplyChainEvent[] memory) {
        bytes memory data = abi.encode(batchHistory[_batchID]);
        return abi.decode(data, (SupplyChainEvent[]));
    }



    function addressToString(address _address) internal pure returns (string memory) {
        return toString(abi.encodePacked(_address));
    }
    function toString(bytes memory data) public pure returns(string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2+i*2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }
}
