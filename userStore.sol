pragma solidity ^0.4.0;
contract userStore {

    //stores a value with an exists flag for checking set values
    struct entry {
        bool exists;
        string value;
    }

    //stores permission flags
    struct permissions {
        bool read;
        bool write;
    }

    //stores site-specific data with delegated read/write permissions
    struct site {
        mapping(address => permissions) sitePermissions;
        mapping(string => entry) data;
    }

    //represents a user, contains default and site-specific data
    struct user {
        bool exists;
        mapping(string => entry) defaults;
        mapping(address => site) specific;
    }

    mapping(address => user) userList;

    //set default values for the current address
    function selfSetDefaults(string paramName, string param) public {
        userList[msg.sender].defaults[paramName].exists = true;
        userList[msg.sender].defaults[paramName].value = param;
    }

    //set site-specific values for the current address
    function selfSetSpecific(address siteAddress, string paramName, string param) public {
        userList[msg.sender].specific[siteAddress].data[paramName].exists = true;
        userList[msg.sender].specific[siteAddress].data[paramName].value = param;
    }

    //read default values
    function selfGetDefaults(string paramName) public constant returns (string ret) {
        entry storage result = userList[msg.sender].defaults[paramName];

        if (result.exists) {
            ret = result.value;
        }
        else {
            ret = "Not Set";
        }
    }

    //set read/write permissions for websites
    function siteSetDelegate(address userAddress, address delegateAddress, bool read, bool write) public {
        permissions storage settings = userList[userAddress].specific[msg.sender].sitePermissions[delegateAddress];
        settings.read = read;
        settings.write = write;
        
    }

    //allow a site to get the default values for a user
    function siteGetDefaults(address userAddress, string paramName) public constant returns (string ret) {
        entry storage result = userList[userAddress].defaults[paramName];

        if (result.exists) {
            ret = result.value;
        }
        else {
            ret = "Not Set";
        }
    }

    //allow a site to set its own values
    function siteSetSpecific(address userAddress, string paramName, string param) public {
        userList[userAddress].specific[msg.sender].data[paramName].exists = true;
        userList[userAddress].specific[msg.sender].data[paramName].value = param;
    }

    //allow a site to set values for sites that have given it write access
    function siteSetSpecific(address userAddress, address siteAddress, string paramName, string param) public returns (bool ret) {

        if (userList[userAddress].specific[siteAddress].sitePermissions[msg.sender].write) {
            userList[userAddress].specific[siteAddress].data[paramName].exists = true;
            userList[userAddress].specific[siteAddress].data[paramName].value = param;
            ret = true;
        }
        else {
            ret = false;
        }

    }

    //allow a site to get its own values
    function siteGetSpecific(address userAddress, string paramName) public constant returns (string ret) {
        entry storage result = userList[userAddress].specific[msg.sender].data[paramName];
        
        if (result.exists) {
            ret = result.value;
        }
        else {
            result = userList[userAddress].defaults[paramName];
        }
        if (result.exists) {
            ret = result.value;
        }
        else {
            ret = "Not Set";
        }
    }

    //allow a site to get values for sites that have given it read access
    function siteGetSpecific(address userAddress, address siteAddress, string paramName) public constant returns (string ret) {
        
        if (userList[userAddress].specific[siteAddress].sitePermissions[msg.sender].read) {
            entry storage result = userList[userAddress].specific[msg.sender].data[paramName];
            
            if (result.exists) {
                ret = result.value;
            }
            else {
                result = userList[userAddress].defaults[paramName];
            }
            if (result.exists) {
                ret = result.value;
            }
            else {
                ret = "Not Set";
            }
        }
        else {
            ret = "No Read Permissions";
        }
    }
}