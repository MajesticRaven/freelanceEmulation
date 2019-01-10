pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import "./Deal.sol";

/**
 * @notice this contract need 3562228 gas for deployment. don't forget to increase gas
 */ 

contract DealsFactory is Deal {
    event DealCreated(
        address CustomerAddress,
        address ExecutorAddress,
        string[] RequirementsList,
        uint256 IndexOfDeal
    );

    /**
     * @notice each customer can create deal for smb
     * @param executorAddress address of executor
     * @param requirementsList string array of requirements for executor 
     * (it can be bytes32, but it will be harder to set requirements for customer 'cause he will 
     * make bytes32 from each string and that's why here is experimental package)
     */ 
    function createDeal(
        address executorAddress,
        string[] requirementsList
    ) public onlyCustomer returns (uint256) {
        bool[] memory requirementsFinish = new bool[](requirementsList.length);
        uint8[] memory requirementsStatus = new uint8[](requirementsList.length);
            
        Details memory details = Details(
            msg.sender,
            executorAddress,
            requirementsFinish,
            requirementsStatus,
            requirementsList,
            false
        );
        
        dealsList[totalDeals] = details;
        activeDealsForUser[msg.sender].push(totalDeals);
        activeDealsForUser[executorAddress].push(totalDeals);
        totalDeals++;
        
        emit DealCreated(
            msg.sender,
            executorAddress,
            requirementsList,
            totalDeals - 1
        );
        
        return totalDeals - 1;
    }
    
    /**
     * @notice only managers or participants of deal can get deal details
     * @param _dealId id of deal for watching
     * @return customerAddress address of creator of deal
     * @return executorAddress address of executor of deal
     * @return requirementsFinish list of statuses about finishing some requirements from executor
     * @return requirementsStatus list of approvals of requirements from customer
     * @return requirementsList list of all requirements for executor
     */ 
    function getDealDetails(uint256 _dealId) 
    public view returns (
        address customerAddress,
        address executorAddress,
        bool[] requirementsFinish,
        uint8[] requirementsStatus,
        string[] requirementsList,
        bool isFinished
    ) {
        require(users[msg.sender] == Manager ||
                dealsList[_dealId].customerAddress == msg.sender ||
                dealsList[_dealId].executorAddress == msg.sender);
                
        customerAddress = dealsList[_dealId].customerAddress;
        executorAddress = dealsList[_dealId].executorAddress;
        requirementsFinish = dealsList[_dealId].requirementsFinish;
        requirementsStatus = dealsList[_dealId].requirementsStatus;
        requirementsList = dealsList[_dealId].requirementsList;
        isFinished = dealsList[_dealId].isFinished;
    }
    
    /**
     * @notice get all active deals of yourself
     * @return array of active deals
     */ 
    function getActiveDeals() public view returns (uint256[]) {
        return activeDealsForUser[msg.sender];
    }
}