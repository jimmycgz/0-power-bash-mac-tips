#!/bin/bash

# Feature List:
# Run some command lines via ssh, mimicing ansible
# Special feature: Get ip address from lines of Thano query result
# Get host ip from .yml file
# ssh to all host to run command or pre-defined script file

run_cmd () {
    if [[ $cmd_arg == "." ]] ; then
        export cmd_line="bash ./$remote_script;rm ./$remote_script"
    else
        export cmd_line=$cmd_arg
    fi

    for pri_ip in $host_names
    do
        #export pri_ip='15.137.3.11'
        echo " "
        if [[ $dry_run == "YES" ]]; then
            if [[ $cmd_arg == "." ]] ; then
                echo scp $remote_script $pri_ip:$remote_script
            fi
            echo "ssh $pri_ip \"$cmd_line\""

        else
            export cmd_output='cmd_history.log'
            echo " " >> $cmd_output
            echo " " >> $cmd_output
            echo " * Node: $pri_ip" >> $cmd_output

            if [[ $cmd_arg == "." ]] ; then
                echo scp $remote_script $pri_ip:$remote_script
                scp $remote_script $pri_ip:$remote_script
            fi
            echo "ssh $pri_ip \"$cmd_line\""
            ssh $pri_ip "$cmd_line" >> $cmd_output

            if [[ $? -eq 0 ]]; then
                echo " Done cmd "
                tail $cmd_output | grep -A 3 " * Node: $pri_ip"
            else
                echo " Failed command !"
            fi
            
        fi
    done
}


get_host_from_file () {

    if [ -f $input_file ]; then
        export host_names=""
        while read -r line || [[ -n $line ]]; do
        #Get hostnames or ip list
            #Get ip address from thano query result
            if [[ "$line" =~ "instance=" ]]; then
                export pri_ip=$(echo $line | grep -o 'instance="[^"]*' | sed  -e 's/instance="//g' -e 's/:9090//g')
                export host_names="$host_names $pri_ip"

            elif [[ ! $line =~ ^\# ]]; then #Filter commented lines
            #if [[ $line =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then #Use this line to filter IP address
                export host_names="$host_names $line"
                #echo "instance IP: $pri_ip "                 
            fi
            
        done < "$input_file"
    else
        echo "Missing Host File: $input_file! "
    fi
}
 
#Start from here 
export dry_run="YES" #default
export input_file='host-input.yml'
export remote_script='remote_script.sh'
echo " "

if [[ $# -lt 1 ]]
then
    echo " "
    echo "Run some command on remote host via ssh"
    echo " Special feature: Get ip address from lines of Thano query result "
    echo " "
    echo "Usage: dryrun by default (without apply)"
    export script_name='sshcmd'
    #export script_name=${BASH_SOURCE[0]}
    echo "$script_name <host_name/file> <cmd/file> [apply]"
    echo " "
    echo "Examp 1:"
    echo "$script_name 1.2.3.4 date [apply]"
    echo "$script_name stag-jump-server 'df -kh' [apply]"
    echo " "
    echo "Examp 2:"    
    echo "$script_name . . [apply]"
    echo "   First . will use default host file: $input_file"
    echo "   Second . will use default script file: $remote_script"
    echo " "
    echo "Examp 3:"    
    echo "$script_name 1.2.3.4 dep"
    echo "   Deploy this script to remote"
    echo " "
else
    export script_file=$1

    if [[ $3 == "apply" ]]
    then 
        export dry_run="NO"
    else
        export dry_run="YES"
    fi

    if [[ $1 == "." ]] ; then
        get_host_from_file
    else
        export host_names=$1
    fi

    if [[ $host_names != "" ]] ; then

        if [[ $2 == "dep" ]] ; then
        #deploy this script file to the first host
            scp $script_name $1:$script_name
            ssh $1 "sudo chmod +x $script_name"
            echo "deployed to host $1"
            echo "ssh $1"
        else
            export cmd_arg=$2
            run_cmd
        fi

    else
        echo " No host specified!"
    fi

fi
echo " "
