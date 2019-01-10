pragma solidity ^0.4.24;

import "./Ownable.sol";

contract ParticipantFactory is Ownable {
    uint8 Manager = 1;
    uint8 Customer = 2;
    uint8 Executor = 3;
    
    //mapping where stored role for each user
    mapping(address => uint8) users;
    //array of all users
    address[] listOfAllUsers;
    //list of users for each role (if smb need list of all managers etc.)
    address[] listOfAllManagers;
    address[] listOfAllCustomers;
    address[] listOfAllExecutors;
    
    //list of events for catching them from web3
    event NewUser(
        address CreationEmitter,
        address UsersAddress, 
        uint8 UsersRole, 
        uint256 DateOfRegistration
    );
    event DeletedUser(
        address DeletionEmitter, 
        address UsersAddress, 
        uint8 UsersRole, 
        uint256 DateOfDeletion
    );
    
    //modifiers of access
    modifier onlyManager() {
        require(users[msg.sender] == Manager);
        _;
    }
    
    modifier onlyCustomer() {
        require(users[msg.sender] == Customer);
        _;
    }
 
    modifier onlyExecutor() {
        require(users[msg.sender] == Executor);
        _;
    }
    
    /**
     * @notice get users role via his address
     * @return index of role of user
     */ 
    function getUserRoleViaAddress(address _usersAddress) external view returns (uint8) {
        return users[_usersAddress];
    }
    
    /**
     * @notice get list of all users in the system
     * @return address[] array of addresses of users in this category
     */ 
    function getAllUsers() external view returns (address[]) {
        return listOfAllUsers;
    }
    
    /**
     * @notice get list of all Managers in the system
     * @return address[] array of addresses of users in this category
     */ 
    function getAllManagers() external view returns (address[]) {
        return listOfAllManagers;
    }
    
    /**
     * @notice get list of all Customers in the system
     * @return address[] array of addresses of users in this category
     */ 
    function getAllCustomers() external view returns (address[]) {
        return listOfAllCustomers;
    }
    
    /**
     * @notice get list of all Executors in the system
     * @return address[] array of addresses of users in this category
     */ 
    function getAllExecutors() external view returns (address[]) {
        return listOfAllExecutors;
    }
    
    /**
     * @notice function for registration of new user with role. User can create account only 1 time
     * @param _role index of role. 1 - Manager, 2 - Customer, 3 - Executor
     */ 
    function registration(uint8 _role) public {
        require(_role == Customer ||
                _role == Executor);
        addNewUser(msg.sender, _role);
    }
    
    /**
     * @notice deletion account of user (only user can delete his account)
     */ 
    function removeUser() public {
        deleteUserFromLists(msg.sender);
    }
    
    /**
     * @notice deletion account of user for admin. He can delete everybody
     * @param _usersAddress address of user for deletion
     */ 
    function removeCustomUser(address _usersAddress) public onlyOwner {
        deleteUserFromLists(_usersAddress);
    }
    
    /**
     * @notice owner can add account for user with custom address
     * @param _usersAddress address  of user for creation
     * @param _role role of new user
     */ 
    function createUser(address _usersAddress, uint8 _role) public onlyOwner {
        require(_role == Manager ||
                _role == Customer ||
                _role == Executor);
                
        addNewUser(_usersAddress, _role);
    }
    
    /**
     * @notice delete user from main list and list of his role
     * @param _usersAddress address of user for deletion
     */ 
    function deleteUserFromLists(address _usersAddress) internal {
        require(users[_usersAddress] > 0);
        
        uint8 role = users[_usersAddress];
        
        //remove from main list
        uint256 foundIndex;
        
        for(uint256 i = 0; i < listOfAllUsers.length; i++) {
            if(listOfAllUsers[i] == _usersAddress) {
                foundIndex = i;
                break;
            }
        }
        
        for(i = foundIndex; i < listOfAllUsers.length - 1; i++) {
            listOfAllUsers[i] = listOfAllUsers[i + 1];
        }      
        
        listOfAllUsers.length--;
        
        //removing from role list
        if(users[_usersAddress] == Manager) {
            for(i = 0; i < listOfAllManagers.length; i++) {
                if(listOfAllManagers[i] == _usersAddress) {
                    foundIndex = i;
                    break;
                }
            }
            
            for(i = foundIndex; i < listOfAllManagers.length - 1; i++) {
                listOfAllManagers[i] = listOfAllManagers[i + 1];
            }     
            
            listOfAllManagers.length--;
        } else if(users[_usersAddress] == Customer) {
            for(i = 0; i < listOfAllCustomers.length; i++) {
                if(listOfAllCustomers[i] == _usersAddress) {
                    foundIndex = i;
                    break;
                }
            }
            
            for(i = foundIndex; i < listOfAllCustomers.length - 1; i++) {
                listOfAllCustomers[i] = listOfAllCustomers[i + 1];
            }          
            
            listOfAllCustomers.length--;
        } else if(users[_usersAddress] == Executor) {
            for(i = 0; i < listOfAllExecutors.length; i++) {
                if(listOfAllExecutors[i] == _usersAddress) {
                    foundIndex = i;
                    break;
                }
            }
            
            for(i = foundIndex; i < listOfAllExecutors.length - 1; i++) {
                listOfAllExecutors[i] = listOfAllExecutors[i + 1];
            }       
            
            listOfAllExecutors.length--;
        }
        
        users[_usersAddress] = 0;
        
        emit DeletedUser(
            msg.sender,
            _usersAddress,
            role,
            now
        );
    }
    
    /**
     * @notice internal method for creation of users
     * @param _usersAddress address of new User
     * @param _role role of new user
     */ 
    function addNewUser(address _usersAddress, uint8 _role) internal {
        require(users[_usersAddress] == 0);
        
        users[_usersAddress] = _role;
        listOfAllUsers.push(_usersAddress);
        
        if(_role == Manager) {
            listOfAllManagers.push(_usersAddress);
        } else if(_role == Customer) {
            listOfAllCustomers.push(_usersAddress);
        } else if(_role == Executor) {
            listOfAllExecutors.push(_usersAddress);
        }
        
        emit NewUser(
            msg.sender,
            _usersAddress, 
            _role, 
            now
        );
    }
}