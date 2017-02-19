

terraform project
-------------------

The purpose of this scripts is to build a 2 tiers WebServer with a autoscalling group

Main features : 
- AutoScalling group with Launch Configuration Web Server based on nginx behind an ELB with a public DNS
- ssh connectivity through a ssh port by loading a local ssh key
- Role creation for SSM service usage (to issue command on EC2 after creation). Beware of on the deletion which is not fully automated yet (check out the TODO)
- You should check out the architecture after creation http://www.visualops.io/

multiple files for configuration and scripting :
- *.sh : utility scripts :
    * graph.sh : produce a graph based on dot (must installed, brew install dot)
    * apply.sh : remove RunCommands role then launch (apply) the infrastructure creation
    * plan.sh : runs plan

- *.tfvars for variable loading
    * DEV.tfvars : environnement variables for DEV

- *.tf, *.tpl : all terraform assets
    * infra_web.tf : the whole infrastructure creation
    * variables.tf : list all varaibles used in all scripts
    * output.tf : outputs from terraform
    * SSM_Role.tf : create RunCommandRole role and attach  SSM (AmazonEC2RoleforSSM) policy
    * user_data.tpl : template file for UserData (receive region as variable)


TODO :
-------
+ Automate RunCommand role to be completly removed