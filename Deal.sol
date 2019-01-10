pragma solidity ^0.4.24;

import "./ParticipantFactory.sol";

contract Deal is ParticipantFactory {
    //struct for each deal
    struct Details {
        address customerAddress;
        address executorAddress;
        bool[] requirementsFinish;
        uint8[] requirementsStatus;
        string[] requirementsList;
        bool isFinished;
    }
    
    //statuses
    uint8 Pending = 0;
    uint8 Resolve = 1;
    uint8 Reject = 2;
    
    //list of deals
    mapping(uint256 => Details) dealsList;
    mapping(address => uint256[]) activeDealsForUser;
    uint256 totalDeals;
    
    //list of events for web3
    event ExecutorChangedStatus(
        address Emitter,
        uint256 DealID,
        uint256 RequirementID,
        bool NewStatus,
        uint256 Timestamp
    );
    event CustomerChangedStatus(
        address Emitter,
        uint256 DealID,
        uint256 RequirementID,
        uint8 NewStatus,
        uint256 Timestamp
    );
    event ManagerChangedStatus(
        address Emitter,
        uint256 DealID,
        uint256 RequirementID,
        uint8 NewStatus,
        uint256 Timestamp
    );
    event ProjectFinished(
        address Emitter,
        uint256 DealID,
        uint256 Timestamp
    );
    
    /**
     * @notice executor can change status to finished when he done requirement
     * @param _dealId id of deal for changing. Id getting from list of deals (index in array or number in list of active deals)
     * @param _requirementId index of requirement from list of requirement
     * @param _status false if unfinished and true if finished
     */ 
    function changeRequirementStatusForExecutor(uint256 _dealId, uint256 _requirementId, bool _status) public onlyExecutor {
        require(!dealsList[_dealId].isFinished);
        require(dealsList[_dealId].executorAddress == msg.sender);
        require(_requirementId < dealsList[_dealId].requirementsList.length);
        
        dealsList[_dealId].requirementsFinish[_requirementId] = _status;
        
        emit ExecutorChangedStatus(
            msg.sender,
            _dealId,
            _requirementId,
            _status,
            now
        );
    }
    
    /**
     * @notice Customer can change status to finished when Executor has done requirement
     * @param _dealId id of deal for changing. Id getting from list of deals (index in array or number in list of active deals)
     * @param _requirementId index of requirement from list of requirement
     * @param _status index of status of deal
     */ 
    function changeRequirementStatusForCustomer(uint256 _dealId, uint256 _requirementId, uint8 _status) public onlyCustomer {
        require(!dealsList[_dealId].isFinished);
        require(dealsList[_dealId].customerAddress == msg.sender);
        require(_requirementId < dealsList[_dealId].requirementsList.length);
        require(_status == Pending ||
                _status == Resolve ||
                _status == Reject);
        
        dealsList[_dealId].requirementsStatus[_requirementId] = _status;
        
        emit CustomerChangedStatus(
            msg.sender,
            _dealId,
            _requirementId,
            _status,
            now
        );
    }
    
    /**
     * @notice Customer can change status to finished when Executor has done requirement
     * @param _dealId id of deal for changing. Id getting from list of deals (index in array or number in list of active deals)
     * @param _requirementId index of requirement from list of requirement
     * @param _status index of status of deal
     */ 
    function changeRequirementStatusForManager(uint256 _dealId, uint256 _requirementId, uint8 _status) public onlyManager {
        require(!dealsList[_dealId].isFinished);
        require(_status == Pending ||
                _status == Resolve ||
                _status == Reject);
        require(_requirementId < dealsList[_dealId].requirementsList.length);
        
        dealsList[_dealId].requirementsStatus[_requirementId] = _status;
        
        emit ManagerChangedStatus(
            msg.sender,
            _dealId,
            _requirementId,
            _status,
            now
        );
    }
    
    function finishProject(uint256 _dealId) public {
        require(!dealsList[_dealId].isFinished);
        require(dealsList[_dealId].customerAddress == msg.sender ||
                users[msg.sender] == Manager);
                
        dealsList[_dealId].isFinished = true;
        
        emit ProjectFinished(
            msg.sender,
            _dealId,
            now
        );
    }
}