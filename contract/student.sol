// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EduChain {
    // Structure to store student details
    struct Student {
        string name;
        string rollNo;
        string mobile;
        uint8 semester;
        string cgpa;
        string linkedin;
        string github;
    }

    // Mapping from student roll number to their details
    mapping(string => Student) private students;

    // Event to be emitted when a new student is added or updated
    event StudentAddedOrUpdated(string rollNo, string name);

    // Modifier to ensure that the student exists
    modifier studentExists(string memory _rollNo) {
        require(bytes(students[_rollNo].rollNo).length != 0, "Student does not exist!");
        _;
    }

    // Function to add a new student with validation
    function addStudent(
        string memory _name,
        string memory _rollNo,
        string memory _mobile,
        uint8 _semester,
        string memory _cgpa,
        string memory _linkedin,
        string memory _github
    ) public {
        // Validate that student does not already exist
        require(bytes(students[_rollNo].rollNo).length == 0, "Student already exists!");

        // Perform validation for each field
        _validateStudentDetails(_name, _rollNo, _mobile, _semester, _cgpa, _linkedin, _github);

        // Create a new student record
        students[_rollNo] = Student({
            name: _name,
            rollNo: _rollNo,
            mobile: _mobile,
            semester: _semester,
            cgpa: _cgpa,
            linkedin: _linkedin,
            github: _github
        });

        // Emit the event
        emit StudentAddedOrUpdated(_rollNo, _name);
    }

    // Function to update student details
    function updateStudent(
        string memory _rollNo,
        string memory _name,
        string memory _mobile,
        uint8 _semester,
        string memory _cgpa,
        string memory _linkedin,
        string memory _github
    ) public studentExists(_rollNo) {
        // Perform validation for each field
        _validateStudentDetails(_name, _rollNo, _mobile, _semester, _cgpa, _linkedin, _github);

        // Update the student record
        students[_rollNo].name = _name;
        students[_rollNo].mobile = _mobile;
        students[_rollNo].semester = _semester;
        students[_rollNo].cgpa = _cgpa;
        students[_rollNo].linkedin = _linkedin;
        students[_rollNo].github = _github;

        // Emit the event
        emit StudentAddedOrUpdated(_rollNo, _name);
    }

    // Internal function to validate student details
    function _validateStudentDetails(
        string memory _name,
        string memory _rollNo,
        string memory _mobile,
        uint8 _semester,
        string memory _cgpa,
        string memory _linkedin,
        string memory _github
    ) internal pure {
        // Validate name
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_name).length <= 100, "Name is too long");

        // Validate roll number
        require(bytes(_rollNo).length > 0, "Roll number cannot be empty");

        // Validate mobile number
        require(bytes(_mobile).length > 0, "Mobile number cannot be empty");
        require(bytes(_mobile).length == 10, "Mobile number must be 10 digits long");

        // Validate semester
        require(_semester >= 1 && _semester <= 8, "Semester must be between 1 and 8");

        // Validate CGPA
        require(bytes(_cgpa).length > 0, "CGPA cannot be empty");
        require(isValidCGPA(_cgpa), "CGPA must be between 0.0 and 10.0");

        // Validate LinkedIn URL
        require(bytes(_linkedin).length > 0, "LinkedIn URL cannot be empty");
        require(_isValidURL(_linkedin), "Invalid LinkedIn URL");

        // Validate GitHub URL
        require(bytes(_github).length > 0, "GitHub URL cannot be empty");
        require(_isValidURL(_github), "Invalid GitHub URL");
    }

    // Function to get student details by roll number
    function getStudent(string memory _rollNo) public view returns (
        string memory name,
        string memory rollNo,
        string memory mobile,
        uint8 semester,
        string memory cgpa,
        string memory linkedin,
        string memory github
    ) {
        Student memory student = students[_rollNo];
        require(bytes(student.rollNo).length != 0, "Student does not exist!");

        return (
            student.name,
            student.rollNo,
            student.mobile,
            student.semester,
            student.cgpa,
            student.linkedin,
            student.github
        );
    }

    // Function to convert CGPA string to a fixed-point integer
    function parseCGPA(string memory _cgpa) internal pure returns (uint256) {
        bytes memory b = bytes(_cgpa);
        uint256 integerPart = 0;
        uint256 decimalPart = 0;
        bool decimalFlag = false;
        uint256 decimalDivisor = 1;

        for (uint i = 0; i < b.length; i++) {
            if (b[i] >= '0' && b[i] <= '9') {
                if (decimalFlag) {
                    decimalPart = decimalPart * 10 + (uint8(b[i]) - 48);
                    decimalDivisor *= 10;
                } else {
                    integerPart = integerPart * 10 + (uint8(b[i]) - 48);
                }
            } else if (b[i] == '.') {
                require(!decimalFlag, "Multiple decimal points not allowed");
                decimalFlag = true;
            } else {
                revert("Invalid CGPA format");
            }
        }

        return integerPart * 100 + decimalPart;
    }

    // Function to check if CGPA is within a valid range
    function isValidCGPA(string memory _cgpa) internal pure returns (bool) {
        uint256 cgpaValue = parseCGPA(_cgpa);
        return cgpaValue >= 0 * 100 && cgpaValue <= 10 * 100;
    }

    // Internal function to check if a URL is valid
    function _isValidURL(string memory url) internal pure returns (bool) {
        bytes memory urlBytes = bytes(url);
        if (urlBytes.length < 7) {
            return false; // URL too short
        }
        bytes memory httpPrefix = bytes("http://");
        bytes memory httpsPrefix = bytes("https://");

        if (_startsWith(url, httpPrefix) || _startsWith(url, httpsPrefix)) {
            // Ensure there is at least one character after the prefix
            if (urlBytes.length > (httpPrefix.length + 1) || urlBytes.length > (httpsPrefix.length + 1)) {
                return true;
            }
        }
        return false;
    }

    // Internal utility function to check if a string starts with a given prefix
    function _startsWith(string memory str, bytes memory prefix) internal pure returns (bool) {
        bytes memory strBytes = bytes(str);
        if (prefix.length > strBytes.length) {
            return false;
        }
        for (uint i = 0; i < prefix.length; i++) {
            if (strBytes[i] != prefix[i]) {
                return false;
            }
        }
        return true;
    }
}