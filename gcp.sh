#!/bin/bash

function recommender_and_list
{
    ## List Idle Vms
    gcloud compute instances --project=static-epigram-143508 list | gcloud recommender recommendations list \
    --project=static-epigram-143508 \
    --location=us-central1-a \
    --recommender=google.compute.instance.MachineTypeRecommender \
    --format=json | grep "resourceName" | grep 'fullexecution\|squad5\|datavalidation\|cmcautomation\|engineloader\|upgrade\|datavalidationengineloader\|queryperformance\|views\|verifybuild|'| \
    awk '{print $2}' > recommender_vms.txt


    ## List The VMs to compare them with the above output 
    ## and make sure the output above is accurate
    gcloud compute instances --project=static-epigram-143508 list | \
    grep 'fullexecution\|squad5\|datavalidation\|cmcautomation\|engineloader\|upgrade\|datavalidationengineloader\|queryperformance\|views\|verifybuild|' | awk '{print $1}' > list_vms.txt 


    ## Remove the double quotes from VMs name
    sed -i 's/\"//g' recommender_vms.txt
}


function stop_VMs
{
    while read vm; 
    do
        gcloud compute instances stop $vm --zone=us-central1-a
        echo stopping.. $vm
    done <recommender_vms.txt
}


function Y_or_N
{
    while true; 
    do
        if [ -s idle_vms.txt ]
        then
            echo " "
            echo "----- VMs Names -----"
            cat idle_vms.txt
            echo "---------------------"
            stop_VMs

#             read -p "Do you want to stop the above VMs? [Y/N]" yn
#             case $yn in
#                 [Yy]* ) stop_VMs; 
#                 break;;
#                 [Nn]* ) exit;;
#                 * ) echo "Please answer [Y/N]";;
#             esac

        else
            echo "No Idle VMs Found!"
            break
        fi
    done
}


## Make sure the Recommender has provided an accurate output
function checking 
{
     awk 'NR==FNR{seen[$0]=1; next} seen[$0]' recommender_vms.txt list_vms.txt > idle_vms.txt
}


## MAIN
recommender_and_list
checking
Y_or_N


