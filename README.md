"# CRM-Dev" 

Synopsis
 
This project aims to produce a autoamted deployment script of CRM and Sharepoint into Azure. A single execution of the script should be enough to create the VM's and install the vanilla install of the software.
 
Code Example
 
 .\CRMDeploy.ps1
 
No parameters are required to execute the script. 

A valid Azure Subscription is required.
 
Motivation

This is driven by the need to automatically deploy CRM and Sharepoints servers in a development setting quickly and simply without any need for knowledge of the install process. The vanilla install should be enough for developers to contiune to customise the software.

 
Installation
 
There is no installation required for this script, simply copy and paste to the required location. A copy of Sharepoint and CRM installers is required in a public cloud.