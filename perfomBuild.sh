#!/bin/bash
#This script is for AWS network layout and create the variables file for the rest of the sub-projects

terraformbin="/Users/anilkasu/Downloads/Softwares/terraform"

#create the network layout


#Check if the tfstate file exists
if [[ -f $terraformbin ]]; then
  if [[ ! -f "./terraform.tfstate" ]]; then
    $terraformbin apply -auto-approve

    if [[ $? != 0 ]]; then
      exit 1
    fi
  fi

  #redirect the terraform output to file and prepare the variables file for the sub projects
  #loop through the file/output and prepare the variables file
  terraform output | awk -F' = ' '{print "variable \""$1"\" \{ \n\ttype = \"string\" \n\tdefault = \""$2"\" \n\}"}' > outputVariables.out

  #copy the variables file to all sub directories
  for i in $(ls -l | grep ^d | awk '{print $NF}'); do
    cp outputVariables.out $i/variables.tf
    if [[ $? != 0 ]]; then
      echo "Unable to copy the variables.tf file to the folder $i"
    fi
  done
fi
