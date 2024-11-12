// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract ChatApp {
    //USER STRUCT
    struct user {
        string name;
        friend[] friendList;
    }

    struct friend {
        address pubkey;
        string name;
    }

    struct message {
        address sender;
        uint256 timestamp;
        string message;
    }

     struct allUsers{
        string name;
        address accountAddress;
        uint256 phoneNumber;
     }

     allUsers[] getsAllusers;

    //USER MAPPING
    mapping(address => user) userList;
    mapping(bytes32 => message[]) allMessages;

    //CHECK USER EXIST
    function checkUserExist(address pubkey) public view returns (bool) {
        return bytes(userList[pubkey].name).length > 0;
    }

    //CREATE ACCOUNT
    function createAccount(string calldata name, uint256 phoneNumber) external {
        require(checkUserExist(msg.sender) == false, "User already exist");
        require(bytes(name).length > 0, "Name is required");

        userList[msg.sender].name = name;

        getsAllusers.push(allUsers(name, msg.sender, phoneNumber));
    }

    //GET USERNAME
    function getUsername(address pubkey) external view returns (string memory) {
        require(checkUserExist(pubkey), "User does not exist");
        return userList[pubkey].name;
    }

    //ADD FRIEND
    function addFriend(address friend_key, string calldata name) external {
        require(checkUserExist(msg.sender), "Create an account first");
        require(checkUserExist(friend_key), "Friend does not exist");
        require(msg.sender != friend_key, "You can't add yourself as a friend");

        require(
            checkAlreadyFriends(msg.sender, friend_key) == false,
            "Friend already added"
        );
        _addFriend(msg.sender, friend_key, name);
        _addFriend(friend_key, msg.sender, userList[msg.sender].name);
    }

    //checkAlreadyFrineds
    function checkAlreadyFriends(
        address pubkey1,
        address pubkey2
    ) internal view returns (bool) {
        if (
            userList[pubkey1].friendList.length >
            userList[pubkey2].friendList.length
        ) {
            address tmp = pubkey1;
            pubkey1 = pubkey2;
            pubkey2 = tmp;
        }

        for (uint256 i = 0; i < userList[pubkey1].friendList.length; i++) {
            if (userList[pubkey1].friendList[i].pubkey == pubkey2) {
                return true;
            }
        }
        return false;
    }

    function _addFriend(
        address me,
        address friend_key,
        string memory name
    ) internal {
        friend memory newFriend = friend(friend_key, name);
        userList[me].friendList.push(newFriend);
    }

    //GET MY FRIENDs
    function getMyFriendList() external view returns (friend[] memory) {
        userList[msg.sender].friendList;
    }

    //GET CAHT CODE
    function _getChatCode(
        address pubkey1,
        address pubkey2
    ) internal pure returns (bytes32) {
        if (pubkey1 > pubkey2) {
            return keccak256(abi.encodePacked(pubkey1, pubkey2));
        } else return keccak256(abi.encodePacked(pubkey2, pubkey1));
    }

    //SEND MESSAGE
    function sendMessage(address friend_key, string calldata _msg) external {
        require(checkUserExist(msg.sender), "Create an account first");
        require(checkUserExist(friend_key), "Friend does not exist");
        require(
            checkAlreadyFriends(msg.sender, friend_key),
            "You are not friends"
        );

        bytes32 chatCode = _getChatCode(msg.sender, friend_key);
        message memory newMessage = message(msg.sender, block.timestamp, _msg);
        allMessages[chatCode].push(newMessage);
    }

    //READ ME
    function readMessage(
        address friend_key
    ) external view returns (message[] memory) {
        bytes32 chatCode = _getChatCode(msg.sender, friend_key);
        return allMessages[chatCode];
    }

    function getAllAppUsers() public view returns(allUsers[] memory){
        return getsAllusers;
    }
}
