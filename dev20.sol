pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";

contract SupplyChain {
    struct Batch {
        address owner;
        string batchID;
        string harvestDate;
        string location;
        address processor;
        string packagingDate;
        string uniqueString;
        string iotData;
        string batchHistory;
        string transportationInfo;
        string batchStatus;
        bool isProcessed;
    }

    mapping(string => Batch) public batches;

    function createBatch(string memory _batchID) public {
        batches[_batchID] = Batch({
            owner: msg.sender,
            batchID: _batchID,
            harvestDate: "-null-",
            location: "-null-",
            processor: address(0),
            packagingDate: "-null-",
            isProcessed: true,
            uniqueString: "-null",
            iotData: "-null-",
            transportationInfo: "-null",
            batchStatus: "Created",
            batchHistory: string(
                abi.encodePacked(
                    "||-> Batch created on ->",
                    Strings.toString(block.timestamp)
                )
            )
        });
    }

    function addBatchInfo(
        string memory _batchID,
        string memory _harvestDate,
        string memory _location,
        string memory _uniqueString
    ) public {
        require(msg.sender == batches[_batchID].owner);
        batches[_batchID].harvestDate = _harvestDate;
        batches[_batchID].location = _location;
        batches[_batchID].uniqueString = _uniqueString;
        batches[_batchID].batchStatus = "Basic Info Added (check history)";
        batches[_batchID].batchHistory = string(
            abi.encodePacked(
                batches[_batchID].batchHistory,
                " ||-> batch info updated on blocktime ->",
                Strings.toString(block.timestamp)
            )
        );
    }

    function updateHarvestDate(
        string memory _batchID,
        string memory _newHarvestDate
    ) public {
        require(msg.sender == batches[_batchID].owner);
        batches[_batchID].harvestDate = _newHarvestDate;
        batches[_batchID].batchStatus = "Harvest date updated (check history)";
        batches[_batchID].batchHistory = string(
            abi.encodePacked(
                batches[_batchID].batchHistory,
                " ||-> harvest date updated on blocktime ->",
                Strings.toString(block.timestamp)
            )
        );
    }

    function updateTransportationInfo(
        string memory _batchID,
        string memory _carrier,
        string memory _route
    ) public {
        require(msg.sender == batches[_batchID].owner);
        // bytes memory data = abi.encode(_carrier," | ", _route);
        // string memory dataString = string(data);
        batches[_batchID].transportationInfo = _carrier;
        batches[_batchID]
            .batchStatus = "Transportation updated (check history)";
        batches[_batchID].batchHistory = string(
            abi.encodePacked(
                batches[_batchID].batchHistory,
                " ||-> transport info added on blocktime ->",
                Strings.toString(block.timestamp)
            )
        );
    }

    function updateBatchStatus(
        string memory _batchID,
        string memory _currentStatus
    ) public {
        require(msg.sender == batches[_batchID].owner);
        batches[_batchID].batchStatus = _currentStatus;
        batches[_batchID].batchHistory = string(
            abi.encodePacked(
                batches[_batchID].batchHistory,
                " ||-> batch status updated on blocktime ->",
                Strings.toString(block.timestamp)
            )
        );
    }

    function transferOwnership(
        string memory _batchID,
        address _newOwner
    ) public {
        require(msg.sender == batches[_batchID].owner);
        string memory _oldOwner = addressToString(batches[_batchID].owner);
        batches[_batchID].owner = _newOwner;
        batches[_batchID].batchHistory = string(
            abi.encodePacked(
                batches[_batchID].batchHistory,
                " ||-> owner transferred from ->",
                _oldOwner,
                "to ->",
                addressToString(_newOwner),
                "on block timestamp - >",
                Strings.toString(block.timestamp)
            )
        );
    }

    function verifyCompliance(string memory _batchID) public returns (bool) {
        // Placeholder function, implementation would depend on specific regulations
        batches[_batchID].batchHistory = string(
            abi.encodePacked(
                batches[_batchID].batchHistory,
                " ||-> batch status updated on blocktime ->",
                Strings.toString(block.timestamp)
            )
        );
        return true;
    }

    function addIoTData(
        string memory _batchID,
        string memory _iotData,
        string memory _signature
    ) public {
        require(
            keccak256(bytes(_signature)) ==
                keccak256(bytes(batches[_batchID].uniqueString)),
            "Invalid signature"
        );
        batches[_batchID].iotData = string(
            abi.encodePacked(batches[_batchID].iotData, _iotData)
        );
        batches[_batchID].batchHistory = string(
            abi.encodePacked(
                batches[_batchID].batchHistory,
                " ||-> IoT data modified on block time->",
                Strings.toString(block.timestamp)
            )
        );
    }

    function getIoTData(
        string memory _batchID
    ) public view returns (string memory) {
        require(
            msg.sender == batches[_batchID].owner,
            "Only the owner can retrieve the IoT data input"
        );

        return batches[_batchID].iotData;
    }

    function getBatchHistory(
        string memory _batchID
    ) public view returns (string memory) {
        return batches[_batchID].batchHistory;
    }

    function getBatchContents(
        string memory _batchID
    ) public view returns (string memory) {
        string memory dataString = string(
            abi.encodePacked(
                "||Owner->",
                addressToString(batches[_batchID].owner),
                "||BatchID->",
                batches[_batchID].batchID,
                "||Location of Crop->",
                batches[_batchID].location,
                "||Harvest Date->",
                batches[_batchID].harvestDate,
                "||Packaging Information->",
                batches[_batchID].packagingDate,
                "||Data embedded by IoT->",
                batches[_batchID].iotData,
                "||Transportatoin Details->",
                batches[_batchID].transportationInfo,
                "||Batch Current Status->",
                batches[_batchID].batchStatus
            )
        );

        return dataString;
    }

    function addressToString(
        address _address
    ) internal pure returns (string memory) {
        return toString(abi.encodePacked(_address));
    }

    function toString(bytes memory data) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint256(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint256(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }
}
