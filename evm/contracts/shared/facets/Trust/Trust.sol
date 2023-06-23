// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Trust Contract
 * @dev A contract for managing a trust with trustees, documents, and meetings.
 */
contract Trust {
  struct TrusteeData {
    address trustee; // Address of the trustee
    bool accepted; // Flag indicating whether the trustee has been accepted
    bool resigned; // Flag indicating whether the trustee has resigned
    bool terminated; // Flag indicating whether the trustee has been terminated
    mapping(address => bool) votes; // Mapping of trustee addresses to vote status
  }

  struct Document {
    string name; // Name of the document
    string docType; // Type of the document
    uint256 datetimePublished; // Timestamp of when the document was published
    bytes32 contentHash; // Hash of the document content
    string url; // URL of the document
  }

  struct Meeting {
    string title; // Title of the meeting
    uint256 inviteUrl; // URL for inviting attendees to the meeting
    uint256 minutesUrl; // URL for the meeting minutes
    uint256 startTime; // Timestamp of the meeting start time
    bool adjourned; // Flag indicating whether the meeting has been adjourned
    uint256 totalAttendees; // Total number of attendees
    mapping(address => bool) attendees; // Mapping of attendee addresses to attendance status
  }

  mapping(address => TrusteeData) public trusteeData; // Mapping of trustee addresses to trustee data
  address[] public trustees; // Array of trustee addresses
  mapping(uint256 => Document) public documents; // Mapping of document IDs to documents
  mapping(uint256 => Meeting) public meetings; // Mapping of meeting IDs to meetings

  uint256 public trusteeCount; // Total count of trustees
  uint256 public totalDocs; // Total count of documents
  uint256 public totalMeetings; // Total count of meetings

  uint256 public requiredVotes; // Number of votes required for accepting a new trustee

  event TrusteeAdded(address trustee); // Event emitted when a new trustee is added
  event TrusteeAccepted(address trustee); // Event emitted when a trustee is accepted
  event TrusteeResigned(address trustee); // Event emitted when a trustee resigns
  event TrusteeTerminated(address trustee); // Event emitted when a trustee is terminated
  event DocumentAdded(
    uint256 docId,
    string name,
    string docType,
    uint256 datetimePublished,
    bytes32 contentHash,
    string url
  ); // Event emitted when a new document is added
  event MeetingCreated(
    uint256 meetingId,
    string title,
    uint256 inviteUrl,
    uint256 startTime
  ); // Event emitted when a new meeting is created
  event AttendeeAdded(uint256 meetingId, address attendee); // Event emitted when an attendee is added to a meeting
  event MeetingMinutesUpdated(uint256 meetingId, uint256 minutesUrl); // Event emitted when the meeting minutes are updated
  event TrusteeVote(address voter, address newTrustee); // Event emitted when a trustee votes for a new trustee

  /**
   * @dev Modifier that checks if the caller is a trustee.
   */
  modifier onlyTrustee() {
    require(trusteeData[msg.sender].trustee != address(0), "Caller is not a trustee");
    _;
  }

  /**
   * @dev Modifier that checks if the caller is an accepted trustee.
   */
  modifier onlyAcceptedTrustee() {
    require(trusteeData[msg.sender].accepted, "Caller has not been accepted as a trustee");
    _;
  }

  /**
   * @dev Adds a new trustee to the trust.
   * @param newTrustee The address of the new trustee.
   */
  function addTrustee(address newTrustee) external {
    // Ensure the new trustee address is not zero
    require(newTrustee != address(0), "Invalid trustee address");

    // Ensure the new trustee is not already a trustee
    require(trusteeData[newTrustee].trustee == address(0), "Trustee already exists");

    trusteeData[newTrustee].trustee = newTrustee;
    trusteeData[newTrustee].accepted = false;
    trusteeData[newTrustee].resigned = false;
    trusteeData[newTrustee].terminated = false;
    trusteeCount++;

    trustees.push(newTrustee);

    emit TrusteeAdded(newTrustee);
  }

  /**
   * @dev Accepts the role of a trustee.
   */
  function acceptTrustee() external {
    // Ensure the caller is a trustee
    require(trusteeData[msg.sender].trustee != address(0), "Caller is not a trustee");
    require(!trusteeData[msg.sender].accepted, "Trustee has already been accepted");

    trusteeData[msg.sender].accepted = true;

    emit TrusteeAccepted(msg.sender);
  }

  /**
   * @dev Resigns from the role of a trustee.
   */
  function resignTrustee() external {
    // Ensure the caller is a trustee
    require(trusteeData[msg.sender].trustee != address(0), "Caller is not a trustee");

    trusteeData[msg.sender].resigned = true;

    emit TrusteeResigned(msg.sender);
  }

  /**
   * @dev Terminates a trustee and removes them from the trust.
   * @param trustee The address of the trustee to be terminated.
   */
  function terminateTrustee(address trustee) external onlyTrustee {
    // Ensure the trustee to be terminated is not the caller
    require(trustee != msg.sender, "Cannot terminate yourself");

    // Ensure the trustee to be terminated is a trustee
    require(trusteeData[trustee].trustee != address(0), "Trustee does not exist");

    // Ensure there is a proposal to terminate the trustee
    require(trusteeData[trustee].terminated, "No termination proposal for the trustee");

    // Calculate the majority votes required
    uint256 majorityVotes = (trusteeCount - 1) / 2 + 1;

    // Count the votes for termination
    uint256 terminationVotes;
    for (uint256 i = 0; i < trustees.length; i++) {
      if (trusteeData[trustees[i]].votes[trustee]) {
        terminationVotes++;
      }
    }

    // Ensure the termination proposal has enough votes
    require(terminationVotes >= majorityVotes, "Insufficient votes to terminate trustee");

    // Terminate the trustee
    trusteeData[trustee].terminated = true;
    trusteeCount--;

    emit TrusteeTerminated(trustee);
  }

  /**
   * @dev Adds a new document to the trust.
   * @param name The name of the document.
   * @param docType The type of the document.
   * @param datetimePublished The timestamp of when the document was published.
   * @param contentHash The hash of the document content.
   * @param url The URL of the document.
   */
  function addDocument(
    string memory name,
    string memory docType,
    uint256 datetimePublished,
    bytes32 contentHash,
    string memory url
  ) external onlyAcceptedTrustee {
    uint256 docId = totalDocs;

    documents[docId] = Document({
      name: name,
      docType: docType,
      datetimePublished: datetimePublished,
      contentHash: contentHash,
      url: url
    });

    totalDocs++;

    emit DocumentAdded(docId, name, docType, datetimePublished, contentHash, url);
  }

  /**
  * @dev Creates a new meeting.
  * @param title The title of the meeting.
  * @param inviteUrl The URL for inviting attendees to the meeting.
  * @param startTime The timestamp of the meeting start time.
  */
  function createMeeting(
    string memory title,
    uint256 inviteUrl,
    uint256 startTime
  ) external onlyAcceptedTrustee {
    uint256 meetingId = totalMeetings;

    // Create a new Meeting struct and assign its members individually
    Meeting storage newMeeting = meetings[meetingId];
    newMeeting.title = title;
    newMeeting.inviteUrl = inviteUrl;
    newMeeting.minutesUrl = 0;
    newMeeting.startTime = startTime;
    newMeeting.adjourned = false;
    newMeeting.totalAttendees = 0;

    totalMeetings++;

    emit MeetingCreated(meetingId, title, inviteUrl, startTime);
  }

  /**
   * @dev Adds an attendee to a meeting.
   * @param meetingId The ID of the meeting.
   * @param attendee The address of the attendee.
   */
  function addAttendee(uint256 meetingId, address attendee) external onlyAcceptedTrustee {
    // Ensure the meeting ID is valid
    require(meetingId < totalMeetings, "Invalid meeting ID");

    // Ensure the attendee address is not zero
    require(attendee != address(0), "Invalid attendee address");

    Meeting storage meeting = meetings[meetingId];

    // Ensure the meeting has not been adjourned
    require(!meeting.adjourned, "Meeting has been adjourned");

    // Ensure the attendee is not already added to the meeting
    require(!meeting.attendees[attendee], "Attendee already added");

    meeting.attendees[attendee] = true;
    meeting.totalAttendees++;

    emit AttendeeAdded(meetingId, attendee);
  }

  /**
   * @dev Updates the minutes URL of a meeting.
   * @param meetingId The ID of the meeting.
   * @param minutesUrl The URL for the meeting minutes.
   */
  function updateMeetingMinutes(uint256 meetingId, uint256 minutesUrl) external onlyAcceptedTrustee {
    // Ensure the meeting ID is valid
    require(meetingId < totalMeetings, "Invalid meeting ID");

    Meeting storage meeting = meetings[meetingId];

    // Ensure the meeting has not been adjourned
    require(!meeting.adjourned, "Meeting has been adjourned");

    meeting.minutesUrl = minutesUrl;

    emit MeetingMinutesUpdated(meetingId, minutesUrl);
  }

  /**
   * @dev Votes for a new trustee.
   * @param newTrustee The address of the new trustee.
   */
  function voteForTrustee(address newTrustee) external onlyAcceptedTrustee {
    // Ensure the new trustee address is not zero
    require(newTrustee != address(0), "Invalid trustee address");

    // Ensure the new trustee is not already a trustee
    require(trusteeData[newTrustee].trustee == address(0), "Trustee already exists");

    // Iterate through all trustees
    for (uint256 i = 0; i < trustees.length; i++) {
      address trustee = trustees[i];

      // Ensure the trustee has not already voted for the new trustee
      require(!trusteeData[trustee].votes[newTrustee], "Trustee has already voted");

      // Add the vote for the new trustee
      trusteeData[trustee].votes[newTrustee] = true;

      emit TrusteeVote(trustee, newTrustee);
    }
  }
}
