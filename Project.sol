// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Project {


    struct User_Project{
        address Creator;
        string Title;
        string Project_Type;
        string Location;
        string Description;
    }

    User_Project[] public User_Projects;

    function create_project(User_Project calldata _Project_Info) external {
        User_Project memory New_Project;

        New_Project = _Project_Info;
        User_Projects.push(New_Project);
    }
         
}
