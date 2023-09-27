#!/bin/bash

# Replace the following placeholders with actual values:
USER="your_username"
API_TOKEN="your_api_token"
JENKINS_HOST="jenkins.thetaskmasterernest.cyou"

# Define an array of job names and corresponding XML configuration files
job_names=("job1" "job2" "job3" "job4")
config_files=("path/to/job1_config.xml" "path/to/job2_config.xml" "path/to/job3_config.xml" "path/to/job4_config.xml")

# Iterate over the job names and configuration files
for ((i = 0; i < ${#job_names[@]}; i++)); do
    JOBNAME="${job_names[i]}"
    JOB_CONFIG_FILE="${config_files[i]}"

    # Construct the URL for creating the new Jenkins job
    CREATE_JOB_URL="https://${USER}:${API_TOKEN}@${JENKINS_HOST}/createItem?name=${JOBNAME}"

    # Send a POST request to create the new Jenkins job using the XML configuration file
    curl -X POST "${CREATE_JOB_URL}" \
    --header "Content-Type: application/xml" \
    --data-binary "@${JOB_CONFIG_FILE}"

    echo "Created job: ${JOBNAME}"
done
