

terraform project
-------------------

The purpose of this scripts is to build a 2 tiers WebServer.

Main features : 
- Simple Web Server based on nginx behind a simple ELB with a public DNS
- ssh connectivity through a ssh port by loading a local ssh key
- Role creation for SSM service usage (to issue command on EC2 after creation). Beware of on the deletion which is not fully automated yet (check out the TODO)

multiple files for configuration and scripting :
- *.sh : utility scripts :
    * graph.sh : produce a graph based on dot (must installed, brew install dot)
    * apply.sh : remove RunCommands role then launch (apply) the infrastructure creation
    * plan.sh : runs plan

- *.tfvars for variable loading
    * DEV.tfvars : environnement variables for DEV

- *.tf, *.tpl : all terraform assets
    * variables.tf : list all varaibles used in all scripts
    * infra_web.tf : the whole infrastructure creation
    * output.tf : outputs from terraform
    * SSM_Role.tf : create RunCommandRole role and attach  SSM (AmazonEC2RoleforSSM) policy
    * user_data.tpl : template file for UserData (receive region as variable)


TODO :
-------
+ Automate RunCommand role to be finnished