# Continuous Delivery Workshop Instructions

## Part 1 (Publish to Docker Hub)

Before we deploy our application, we are going to containerise it. In addition to the consistency advantage of knowing our deployed solution should run very similarly to our local container, another advantage of deploying a container is that we are less directly tied in to a particular hosting platform; many cloud providers provide various routes for running containers which gives us flexibility when selecting or even changing our architecture.

### Add a Dockerfile

Write a Dockerfile so that you can run the DotnetTemplate web app in a Docker container.

> You might already have a Dockerfile in your repository from workshop 7, but that should be deleted or moved. It was for running a Jenkins build server locally, not for running this application.

There are different approaches to writing the Dockerfile but we'd recommend starting from an [official dotnet SDK image](https://hub.docker.com/_/microsoft-dotnet-sdk/) and then [scripting the install of node/NPM](https://github.com/nodesource/distributions/blob/master/README.md#installation-instructions).

Then use the setup commands in the [README](./README.md) to install dependencies and build the app.

Finally, add an `ENTRYPOINT` that will start the app.

Once you've done that try building and running the Dockerfile locally to check it works.

> Troubleshooting:
> - If you are seeing a Node Sass error, try adding the `DotnetTemplate.Web/node_modules` folder to a `.dockerignore` file to avoid copying local build artefacts/dependencies into the image.
> - If you get errors from node-gyp while running `npm install`, try installing build tools with `apt-get update && apt-get install -y build-essential`
> - To build the dotnet code you'll need the correct version of the SDK (Software Development Kit) dotnet Docker image.
> - Note that you won't need to run `sudo` when building the image (as the default user is root).
> - Some instructions, like installing Node, might depend on the OS of an image - for a Linux image it might not be immediately obvious which distribution you have. Running the image and accessing a terminal can provide one approach to explore for an answer but Docker Hub might offer clues too - can you spot any on the dotnet SDK page?
>   - For many images, starting the container with `docker run -it --entrypoint /bin/bash <image>` will give us access to a terminal, from where we can explore further. A command like `cat /etc/*-release` might provide us with an answer from there

### Manually publish to Docker Hub
1. Create a personal free account on [Docker Hub](https://hub.docker.com/) (if you haven't already).
2. Create a public repository in Docker Hub: https://hub.docker.com/repository/create. Don't connect it to GitHub, and name it dotnettemplate.
3. Build your Docker image locally and push it to Docker Hub. See https://docs.docker.com/docker-hub/repos/ for instructions.

### Automatically publish to Docker Hub

You should already have a pipeline which builds and tests the app. You will now extend it to automatically build the Docker image and publish it to Docker Hub.

Use one of **GitHub Actions** or **GitLab CI/CD** for this workshop - GitHub Actions is the default if you're not sure which to choose.

#### **With GitHub Actions**

You could add new steps to your existing job, but let's create a new job to handle this. Make sure your new job only runs after the testing job completes successfully, by using the ["needs"](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idneeds) option.

You can search the GitHub Actions marketplace for actions to publish a Docker image, or you could script it yourself. Either way, make sure to store credentials securely, not directly in the yaml file.

Try tagging your published image with the name of the branch that triggered the build. You can use the `github` context to find out the branch name. See [here](https://docs.github.com/en/actions/reference/context-and-expression-syntax-for-github-actions#contexts) for details.

> Note that default environment variables won't be available in a `with: ` section because that's evaluated during workflow processing, before it is sent to the runner.

#### **With GitLab CI/CD**

Add a new job to your .gitlab-ci.yml file. It should belong to a new stage so that it only runs after all tests have completed successfully.

To have access to the Docker command line, your new job needs to use the `docker` image and a `docker:dind` "service" (which means a container running alongside your job's container)

```yml
image: docker
services: [ docker:dind ]
```

In the new job, run the correct Docker CLI commands to build the image and publish it to Docker Hub.

Make sure to store credentials securely, not directly in the yaml file.
You do this via the GitLab website (Settings -> CI/CD -> Variables). CI/CD Variables are available to your pipeline script as environment variables.

Try tagging your published image with the name of the branch that triggered the build. Find the appropriate environment variable from [GitLab's documentation](https://docs.gitlab.com/ee/ci/variables/predefined_variables.html).

### Test your workflow
To test that publishing to Docker Hub is working:
1. Make some change to the application code. Don't worry if you don't know anything about C#, find some visible text to modify in DotnetTemplate.Web/Views/Home/FirstPage.cshtml.
2. Commit your changes to git, and push them.
3. Check your pipeline completes successfully.
4. Download and run your new image from Docker Hub (or you could also get someone else to).

### Publish only on main
Modify the workflow so that it will only publish to Docker Hub when run on certain branches, for example only when the main branch is updated.

### (Stretch goal) Publish to Docker Hub with Jenkins
In one of the workshop 7 goals you were asked to set up a Jenkins job for the app (if you haven't done that yet it's worth going back to it now). Modify the Jenkinsfile so that it will publish to Docker Hub.

## Part 2 (Deploy to Azure)

### Deploy to Azure manually

1. Sign into [the Azure portal](https://portal.azure.com/) - you should have been given account credentials by a trainer.
2. Locate your resource groups. You should find you have two, one ending with `_Workshop` which we'll be using today.
> A resource group is a logical container into which Azure resources, such as web apps, databases, and storage accounts, are deployed and managed. [More Azure Terminology can be found here](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/overview#terminology).
3. Create a Web App to run our container
<details><summary> Click for instructions using the portal </summary>

  * From within your Resource Group, select the "Create" option at the top
  * Select the "Web App" option shown, or if you can't see it then search for it
    * We want precisely "Web App", watch out for & avoid similar resources such as "Static Web App" or "Web App for Containers"
  * Set the relevant options:
    * Make sure the Resource Group points to your `_Workshop` group
    * Choose a name for your app - this will need to be globally unique so including your initials may be sensible
    * For the "Publish" option, select "Docker Container"
    * Under “App Service Plan”, it should default to creating a new one, which is correct. Just change the “Sku and size” to “B1”.
    * On the next screen, select Docker Hub in the “Image Source” field, and enter the details of your image.
</details>
<details><summary> Click for instructions using the CLI </summary>

* First make sure that you've logged into the right account with `az login` (or `az login --use-device-code` on GitPod)
  * You can check which account you're logged into with `az account list`
* First create an App Service Plan: `az appservice plan create --resource-group <resource_group_name> -n <appservice_plan_name> --sku B1 --is-linux`
* Then create the Web App: `az webapp create --resource-group <resource_group_name> --plan <appservice_plan_name> --name <webapp_name> --deployment-container-image-name docker.io/<dockerhub_username>/<container-image-name>:latest`
  </details>
<br>

4. Configure the [`WEBSITES_PORT` app setting](https://learn.microsoft.com/en-us/azure/app-service/configure-custom-container?tabs=debian&pivots=container-linux#configure-port-number) which identifies which port in the container requests should be forwarded to (which will likely be port 5000 for your container image).
5. You can see the app running by using the "Browse" button from within the new resource's overview page or by visiting `https://<webapp_name>.azurewebsites.net` directly.

> Troubleshooting:
>
> 1: Deployment logs can be found the Deployment Center tab on the App Service's page in the Azure portal.
>  * This only covers pulling and running the container image. For logs not related to deployment please consult the *Log Stream* tab
>
> 2: You can trigger a redeployment of the container image by calling the Webhook URL with a POST request ([see the next section below](#calling-the-deployment-webhook)).
>  * This is necessary if you have updated the container image on Docker hub *after* creating the App Service (restarting the App Service will *not* trigger a redeployment!)
>
> 3: If you see the following message when deploying from an M1/M2 Mac:
> ```
> 2023-02-02T10:33:51.938273952Z standard_init_linux.go:228: exec user process caused: exec format error
> ```
> Then it's possible the container image has been built with the wrong architecture. To fix this pass the `--platform linux/amd64` flag when running `docker build`.
> 
> 4: If you are seeing an error like the following:
> ```
> ERROR - failed to register layer: Error processing tar file(exit status 1): Container ID 110779 cannot be mapped to a host IDErr: 0, Message: failed to register layer: Error processing tar file(exit status 1): Container ID 110779 cannot be mapped to a host ID
> ```
> This is likely due to [Docker User Namespace remapping running on the App Service VM](https://azureossd.github.io/2022/06/30/Docker-User-Namespace-remapping-issues/index.html).
> To fix this message replace `RUN npm install` in your Dockerfile with 
> ```
> RUN npm install && find ./node_modules/ ! -user root | xargs chown root:root
> ```
> Next rebuild the image and push to Docker Hub (don't forget to call [the Webhook](#calling-the-deployment-webhook)).


### Automate deployment to Azure

Simply pushing a new image to DockerHub will not re-deploy your app service by default. We can enable that behaviour for specific container registries (including DockerHub) by [switching on the "Continuous Deployment" option](https://learn.microsoft.com/en-us/azure/app-service/deploy-ci-cd-custom-container?tabs=acr&pivots=container-linux#4-enable-cicd) in the "Deployment Center", but for today we'll set this up manually so we can see what's going on and better control it.

#### Calling the Deployment Webhook
To automate this, you will first need to find your Web App's deployment webhook under the "Deployment Center" tab from your Web App.

Test that now by running a curl command locally from a bash shell:
* Take the webhook provided by the previous step, add in a backslash to escape the $, and run: `curl -dH -X POST "<webhook>"`
* eg: `curl -dH -X POST "https://\$<deployment_username>:<deployment_password>@<webapp_name>.scm.azurewebsites.net/docker/hook"`

This should return a link to a log-stream relating to the re-deployment of your application.

Once you've demonstrated that working locally, add your webhook as a secret to your repository called `AZURE_WEBHOOK`, and run the relevant curl command as a final step in your deployment job pipeline.

> A nice addition here can be adding the [--fail](https://curl.se/docs/manpage.html#-f) flag to your curl command, as otherwise curl reports success as long as a successful connection was made, even if the response reports a failure (e.g. a status code > 400) which can lead to confusing pipeline results

Check that your pipeline output still shows the log-stream result after making the `curl` request.

#### **With GitHub Actions**

<details>
<summary>Hint</summary>

Escaping secrets in GitHub Actions can be fiddly; consider the following concerns:

* Secrets are interpreted _before_ the shell sees the command
* Using single quotes around something tells bash to treat it literally (`echo '$PATH'` will literally print the word `$PATH` not the variable)
* GitHub Actions appears to escape strings itself when converting secrets to environment variables

<details>
<summary>Hint</summary>

Because of the above, if you've _not_ escaped your secret before adding it to GitHub's secrets, you may want a command like:
```
- run: curl -dH --fail -X POST '${{ secrets.RAW_WEBHOOK }}'
```
Whereas if you _have_ escaped the secret already, try something like:
```
- run: curl -dH --fail -X POST "${{ secrets.ESCAPED_WEBHOOK }}"
```

Alternatively, let GitHub actions handle your escaping by adding an env block:
```
env:
  ESCAPED_WEBHOOK: '${{ secrets.RAW_WEBHOOK }}'
```
And then using the environment variable:
```
- run: curl -dH --fail -X POST $ESCAPED_WEBHOOK
```

</details>
</details>

### Test your workflow again

Make a small, visible change again, push it to your repository and check that it automatically shows up on your deployed Azure website.

###  (Stretch goal) Multistage Dockerfile
You may have noticed that the image our Dockerfile builds is pretty sizeable (~1.5GB) and, apart from taking up space, it slows our pipeline down during the upload step. .NET allows us to separate the dependencies needed to build the code (part of the SDK) from those needed to run the compiled binary (the runtime), with the latter being much smaller. This offers a good opportunity to optimise the speed of our deployment pipeline.

Try writing your Dockerfile as a multistage build. The structure of your Dockerfile will look like this:

```docker
FROM <parent-image-1> as build-stage
# Some commands

FROM <parent-image-2>
# Some commands
```

In this way you use a large parent (`dotnet/sdk`) to build the app and then use a smaller parent (`dotnet/aspnet`) for your final image that will run the application. The second stage just needs to copy the build artefact from the earlier stage with a COPY command of the form: `COPY --from=build-stage ./source ./destination`.

For [an example that closely matches this project see here](https://github.com/dotnet/dotnet-docker/blob/main/samples/aspnetapp/Dockerfile) - or [see the Docker docs](https://docs.docker.com/samples/dotnetcore/#create-a-dockerfile-for-an-aspnet-core-application) for another approach.


To make the first example linked above work:
- Replace any mention of "aspnetapp" with "DotnetTemplate.Web". 
- Remove the `dotnet restore` line
- Remove the "--no-restore" option from the publish command
- Keep your instructions that install node, but you no longer need the "npm ..." commands (they are included in DotnetTemplate.Web.csproj and run as part of `dotnet publish`).

Check that you can still run the app locally using your new image, and then push your changes. You should see a decrease in the image size locally from ~1.5GB to a few hundred MB - does your pipeline speed up?

### (Stretch goal) Healthcheck
Sometimes the build, tests and deployment will all succeed, however the app won't actually run. In this case it can be useful if your workflow can tell you if this has happened. Modify your workflow so that it does a healthcheck.

As part of this it can be useful to add a new healthcheck endpoint to the app, see [this microsoft guide](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/health-checks?view=aspnetcore-5.0#basic-health-probe) for an example of how to do this. This article is long and detailed, and that can make it look intimidating - but everything we need to know is just in the "Basic health probe" section. Try working through it! You should find that we can add this healthcheck endpoint with just two lines of code.

At the end of your workflow, check that the response from the healthcheck endpoint is correct.

### (Stretch goal) Monitor for failure
Failures don't always happen immediately after a deployment. Sometimes runtime issues will only emerge after minutes, hours or days in production. Set up a separate workflow which will use your healthcheck endpoint and send a notification if the healthcheck fails. Make sure this workflow runs every 5 minutes. Hint: https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions#onschedule.

### (Stretch goal) Handle failure
How would you handle failure, for example if one of the healthchecks from the previous two steps fail? Modify your existing workflows so that they will automatically roll-back a failed Azure deployment. Make sure they send an appropriate alert! Find a way to break your application and check this works.

### (Stretch goal) Promote when manually triggered
Currently we'll deploy every time a change is pushed to the main branch. However you might want to have more control over when deployments happen. Modify your Azure and workflow setup so your main branch releases to a staging environment, and you instead manually trigger a workflow to release to production.

### (Stretch goal) Jenkins
In one of the workshop 7 goals you were asked to set up a Jenkins job for the app (if you haven't done that yet it's worth going back to it now). Now modify the Jenkinsfile so that it will deploy to Azure.
