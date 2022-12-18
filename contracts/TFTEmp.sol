// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TFTEmployee is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    //Structure containing employee data
    struct Employee {
        bytes32 emp_hash;
        bytes32 project_hash;
        bytes32 employeeHash;
    }

    event emp_details(
        bytes32 hash,
        uint256 tokenId,
        string name,
        string email,
        uint16 empcode,
        uint16 experience
    );

    event project_details(
        bytes32 hash,
        uint256 tokenId,
        string project_name,
        uint16 project_start,
        uint16 project_end,
        uint16 teamsize,
        string designation
    );

    event project_hash(
        uint256 tokenID,
        bytes32 empDetails_hash,
        bytes32 projectDetails_hash,
        bytes32 Employee_hash
    );

    //Mapping a employee data with index
    mapping(uint256 => Employee) public EmpData;

    constructor() ERC721("TFTEmployee", "TFTEMP") {}

    //Minting the token
    function safeMint(string memory uri) internal onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);
    }
    
    //for updating the hash of details
    function updateHash(uint16 _tokenID,string memory _project_name, uint16 _project_start, uint16 _project_end, uint16 _teamsize, string memory _designaion) internal onlyOwner returns(bytes32){

        //bytes32 _empDetailsHash = keccak256(abi.encode(_name,_emailID,_empCode,_experience);
        bytes32 _projectHash = keccak256(abi.encode(_project_name,_project_start,_project_end,_teamsize,_designaion));

        bytes32 _EmployeeHash = keccak256(abi.encode((EmpData[_tokenID].emp_hash),_projectHash));

        EmpData[_tokenID].project_hash = _projectHash;

        return _EmployeeHash;
    }

    //Adding employee info in struct and emiting the event when employee is added
    function addEmployee(string memory _name, string memory _emailID, uint16 _empCode, uint16 _experience, string memory _project_name, uint16 _project_start, uint16 _project_end, uint16 _teamsize, string memory _designaion) external onlyOwner{
        
        uint256 _tokenId = _tokenIdCounter.current();

        require(_exists(_tokenId) == false,"This token already exist with Metadata");
        require(_project_start<_project_end, "Start date cannot be greater than end date");
        
        bytes32 _projectHash = keccak256(abi.encode(_project_name,_project_start,_project_end,_teamsize,_designaion));

        bytes32 _empDetailsHash = keccak256(abi.encode(_name,_emailID,_empCode,_experience));

        bytes32 _EmployeeHash = keccak256(abi.encode(_empDetailsHash,_projectHash));

        EmpData[_tokenId] = Employee(_empDetailsHash,_projectHash,_EmployeeHash);

        safeMint(string(abi.encodePacked(_EmployeeHash)));

        emit emp_details(_empDetailsHash,_tokenId,_name,_emailID,_empCode,_experience);
        emit project_details(_projectHash,_tokenId,_project_name,_project_start,_project_end,_teamsize,_designaion);
        emit project_hash(_tokenId,_empDetailsHash, _projectHash , _EmployeeHash);

    }

    //Editing employee info in struct and emiting the event when employee is edited
    function editEmployee(uint256 _tokenID,string memory _project_name, uint16 _project_start, uint16 _project_end, uint16 _teamsize, string memory _designaion) external onlyOwner{
        
        require(_exists(_tokenID),"This token doesn't exist, Please mint a new token!");
        require(_project_start<_project_end, "Start date cannot be greater than end date");
        bytes32 _EmployeeHash = updateHash(uint16(_tokenID),_project_name,_project_start,_project_end,_teamsize,_designaion);

        setURI(_tokenID,string(abi.encodePacked(_EmployeeHash)));

        //Events emitting to captured in SubGraphs
        emit project_details((EmpData[_tokenID].project_hash), _tokenID, _project_name, _project_start, _project_end, _teamsize, _designaion);
        emit project_hash(_tokenID, (EmpData[_tokenID].emp_hash), (EmpData[_tokenID].project_hash), _EmployeeHash);        


    }

    //To check before the token is being minted or burned, if getting transfered then the transcation will be reverted
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId, /* firstTokenId */
        uint256 batchSize
    ) internal override virtual{
        require(from == address(0) || to == address(0), "You can't transfer this NFT");
    }


    //Setting the URI of the token (onlyOwner)
    function setURI(uint256 tokenId, string memory _uri) internal onlyOwner{
        _setTokenURI(tokenId,_uri);
    }

    //For burning the existing token
    function burn(uint256 tokenId) external onlyOwner{
        super._burn(tokenId);
        
    }



    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}
