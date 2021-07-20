#!/bin/bash

# Add labels to VM, finding a list of labels from a text file
# Delete labels for commented lines

create_instance () {
    gcloud compute instances create ... \
        --labels webserver=backend,media=images
    gcloud compute instances describe example-disk --format="default(labels)"
}

add_label () {
  gcloud compute instances update $INSTANCE_Name --zone=us-central1-a --update-labels=$LABEL_KEY=$LABEL_V 
}

delete_label () {
  gcloud compute instances update $INSTANCE_Name --zone=us-central1-a --remove-labels=$LABEL_KEY 
}

get_label_from_file () {
  
  while IFS="" read -r p || [ -n "$p" ]
  do
    if [[ $p =~ ^\# ]]; then #Filter commented lines

        export LABEL_KEY=$(printf '%s\n' "$p"|cut -d '#' -f 2|awk '{print $1}')
        # export LABEL_V=$(printf '%s\n' "$p"|awk '{print $2}')
        if [[ -z $LABEL_KEY ]]; then 
            echo "ERROR: Can't find label key from line: $p"
        else
            echo Label Key: $LABEL_KEY
            # delete_label
        fi
    elif [[ ! -z $p ]] && [[ ! $p =~ ^\t ]]; then
        export LABEL_KEY=$(printf '%s\n' "$p"|awk '{print $1}')
        export LABEL_V=$(printf '%s\n' "$p"|awk '{print $2}')
        if [[ -z $LABEL_KEY ]]; then 
            echo "ERROR: Can't find label key from line: $p"
        else
            echo Key-Value: $LABEL_KEY $LABEL_V
            # add_label
        fi

    fi
  done < ./list-label.txt

}  

add_projects_from_string () {
  for PROJECT_NAME in $PROJECT_NAMES
  do 
    echo $PROJECT_NAME
    add_project
  done
}

set_variables (){
    export MY_Zone='us-central1-a'
    export INSTANCE_Name='instance-1'
    export INSTANCE_Name='instance-2'

}

# Bash script starts here
echo " "
  set_variables
  # Run any of below functions
  get_label_from_file
  # add_projects_from_string

echo " "
