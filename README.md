# power-bash
Immutable Bash script as powerful as Ansible Playbook

This self-developed script can be a light version of ansible playbook, gives you a fast-track solution easily run from your local to manage remote hosts, or deploy this script to any remote host, without installing Ansible and Python.

## Feature List:
* Run some command lines on remote hosts via ssh, mimicing ansible
* Special feature: Get ip address from lines of Thano/Prometheus query result
* Get host ip from .yml file
* ssh to all host to run command or excute the pre-defined script file

### Usage: dryrun by default (without apply)
```
sshcmd <host_name/file> <cmd/file> [apply]
 
#Examp 1:
sshcmd 1.2.3.4 date [apply]
sshcmd staging-bastion 'df -kh' [apply]
 
#Examp 2:
sshcmd . . [apply]
   #First . will use default host file: host-input.yml
   #Second . will use default script file: remote_script.sh
 
#Examp 3:
sshcmd 1.2.3.4 dep
   #Deploy this script to remote
   
 ```
   
