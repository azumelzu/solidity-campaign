pragma solidity ^0.4.18;

contract CampaignFactory {
    address[] public deployedCampaigns;

    function createCampaign(uint minimum) public {
        address newCampaign = new Campaign(minimum, msg.sender);
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns (address[]) {
        return deployedCampaigns;
    }
}

contract Campaign {
    
    struct Request {
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
    }
    
    address public manager;
    uint public minimumContribution;
    mapping(address => bool) public approvers;
    uint public approversCount;
    Request[] public requests;
    
    modifier restricted() {
        require(msg.sender == manager, "Only manager can execute this action");
        _;
    }

    event RequestCreated(address indexed recipient, string description, uint value);
    event RequestApproved(address indexed approver);
    event RequestCompleted(address indexed recipient, uint index, uint value);
    
    constructor (uint minimum, address creator) public {
        manager = creator;
        minimumContribution = minimum;
    }
    
    function contribute() public payable {
        require(msg.value >= minimumContribution, "Contribution is not enough");
        approvers[msg.sender] = true;
    }
    
    function createRequest(string description, uint value, address recipient) public restricted {
        Request memory req = Request({
            description: description,
            value: value,
            recipient: recipient,
            complete: false,
            approvalCount: 0
        });

        requests.push(req);

        emit RequestCreated(recipient, description, value);
    }
    
    function approveRequest(uint index) public {
        
        Request storage request = requests[index];
        
        require(approvers[msg.sender], "Only contributors can approve a spending request");
        require(!request.approvals[msg.sender], "Spending request can not be approved more than once by the same contributor");
        request.approvals[msg.sender] = true;
        request.approvalCount ++;
        emit RequestApproved(msg.sender);
    }
    
    function finalizeRequest(uint index) public restricted {
        Request storage request = requests[index];
        require(!request.complete, "Spending request already finalized");
        require(request.approvalCount > (approversCount / 2), "Not enough approvals");
        require(address(this).balance >= request.value, "Not enough balance to transfer");
        request.complete = true;
        request.recipient.transfer(request.value);
        
        emit RequestCompleted(request.recipient, index, request.value);
    }

    function getSummary() public view returns (
      uint, uint, uint, uint, address
      ) {
        return (
          minimumContribution,
          address(this).balance,
          requests.length,
          approversCount,
          manager
        );
    }

    function getRequestsCount() public view returns (uint) {
        return requests.length;
    }
}