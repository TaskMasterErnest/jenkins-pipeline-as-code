#  Setting Up The Microservice Applications
This repository contains the code that is passed and evaluated in Jenkins to build the microservice application needed to run the WatchList application.

## CheckList
- [ ] Setting up microservices in repositories
- [ ] Configuring GitHub webhook to work with Jenkins
- [ ] 

## Creating Repos For The Microservice applications
This is a table specifying the details regarding the microservice applications' functions, names and programming languages they are built with:
| Service     | Language/Framework     | Description                                                                                                                                                                                                         | Link                                                                                    |
|-------------|------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|
| Loader      | Python                 | Responsible for reading a JSON file containing a list of movies and pushing each movie item to an Amazon Queue Service (SQS).                                                                                       | [repo](https://github.com/TaskMasterErnest/jenkins-PAP-microservice-movies-loader)      |
| Parser      | Golang                 | Responsible for consuming movies by subscribing to SQS and scrapping movie information from the IMDb website (https://www.imdb.com/) and storing the metadata (movie’s name, cover, description, etc) into MongoDB. | [repo](https://github.com/TaskMasterErnest/jenkins-PAP-microservice-movies-parser)      |
| Store       | Node.JS                | Responsible for serving a RESTful API with endpoints to fetch a list of movies and insert new movies into the watch list database in the MongoDB server.                                                            | [repo](https://github.com/TaskMasterErnest/jenkins-PAP-microservice-movies-store)       |
| Marketplace | Angular and Typescript | Responsible for serving a frontend to browse movies by calling the Store RESTful API.                                                                                                                               | [repo](https://github.com/TaskMasterErnest/jenkins-PAP-microservice-movies-marketplace) |

## Creating a Pipeline for the Jobs in Jenkins
We now have 4 microservice applications that need to have separate pipelines in order to run. The repository organization style chosen for this project is the use of multiple repos. 

With this approach, the code can be developed, tested and deployed with less team coordination.
And also, having multiple projects in a mono-repo format will result in the creation of complex pipeline stages later in the CI/CD process.

The multi-repo format will result in multiple individual pipelines that have to be managed and also come code duplication amongst them. Jenkins has a solution to mitigate these challenges by introducing shared pipeline segments and having Groovy scripts shared code.

The microservice code has 3 branches each; master/main, develop and preprod. These branches each have Jenkinsfiles that will be used to perform CI/CD operations on the code in the branch.
The best choice of pipeline to use for these jobs is the MultiBranch Pipeline - where multiple pipelines can be created to handle different jobs in each repository.

### Steps to Integrate Jenkins with Git and GitHub
- Create a Jenkins job, create a name for the project and select MultiBranch Pipeline as the pipeline job to issue.
- Use any of the repos available to experiment on but I suggest starting with the Loader service repo
- Set up the GitHub credentials that will be used to gain access to the specific repo/ all repos in GitHub.
  - in setting this up, the recommended way is to generate and use a Personal Access Token.
  - here is a [video link](https://youtu.be/AG26QMUFzrw?feature=shared) on how to do the above.
- You may or may not have Jenkinsfiles already in the individual branches. To check for Jenkinsfiles, click on the Scan Repository Log button in Jenkins. This will trigger a scan for Jenkinsfiles in all branches of the repo.
For more on how to effectively work with MultiBranch Pipelines, here is a [resource](https://www.youtube.com/watch?v=fo36b23cpIU).

### Creating a Jenkinsfile
For now, we will start building the Jenkinsfile from scratch using the scripted approach. The declarative approach will be available once the initial CI pipeline has completed.

- Create a `Jenkinsfile` in the develop branch of the chosen repo and add the following code into it.
```Jenkinsfile
node('workers'){
  stage('Checkout'){
    checkout scm
  }
}
```
- commit the code into the develop branch and push it to GitHub.
- run the Scan Repository Log again, the scan will find the Jenkinsfile and automatically run the Jenkinsfile and execute the script present in it.
- Now we can copy the configuration from one pipeline job to another. Create a new MultiBranch pipeline and indicate to copy the configuration from the previously-run pipeline job to the current one. Do it for all the repos.
- Remember to update the clone URL, the job name and the job description for the new pipeline job. Also remember to add the Jenkinsfile above to the develop branch of each repo.

### Creating a Jenkins Job with Code
Another of the ways to create or clone a MultiBranch pipeline is to use the data of the `config.xml` file of the existing job.
This XMl file contains the configuration for the build job.

View this `config.xml` by going to the location `JENKINS_URL/job/JOB_NAME/config.xml`. To create the similar configs for other jobs, you only have to change the description, display_name, repository and repository_URL.

The `jobs` directory contains the XML configurations for the files.

When the configuration is updated for the various jobs, we have to issue an HTTP POST request to Jenkins for it to create the new jobs with the new XML configurations.

To accomplish this, we have to create an API token that can be used to send commands to Jenkins and we have CSRF protection enabled so we go through these steps:
- Open the Jenkins dashboard and login as your preferred user.
- Go to User Profile > Configure > 
- Locate the 'Add new Token' button, give a name (`api`) to the new token and click Generate.
- Copy the generated API token and replace it in the code in the `create-jobs.sh` code.
- You have to change the job_name for each iteration of the Jenkins job creation.

### Creating a GitHub Webhook
For this, we are going to use the Amazon API Gateway + Lambda to create a robust webhook that is sure to work with our Jenkins cluster.
The reason is that Jenkins might not be accessible from a public network.

The robust webhook will have the Lambda function receive the GitHub payload and relay it to the Jenkins server.
The API Gateway and Lambda will be created with Terraform scripts.

The neccessary code is all available in the `webhook` directory.

- the `index.js` and `package.json` files are code for the AWS Lambda function that acts as a receiver for GitHub webhook events. It has a purpose; to forward GitHub webhook payloads to a Jenkins server.
Zip this file up to be sent to AWS with the command `zip deployment.zip index.js`
- the `terraform/setup.tf` file contains code to set up the Terraform environment for AWS.
- the `terraform/lambda.tf` file contains code to define the Lambda resource.
- the `terraform/apigateway.tf` file contains code to define the API Gateway to trigger when a POST request hits the /webhook endpoint.
- the `terraform/outputs.tf` file contains a specification to output the payload URL that is generated to be used in the Webhook integration with GitHub.
- the `terraform/variables.tf` file contains the variables needed to configure the Terraform scripts.

The generated URL has to be applied to the payload URL of every microservice repo.