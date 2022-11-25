# Continuous Delivery Workshop Instructions

## Part 1 (Publish to Docker Hub)

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

## Part 2 (Deploy to Heroku)

### Deploy to Heroku manually

> ⚠️ M1 Mac users: Heroku uses x86-64 processors, so to build your image for Heroku use `--platform linux/amd64` when running `docker build`, and avoid using `heroku container:push`.

1. Create a free Heroku account: https://signup.heroku.com/.
2. Create a new Heroku app: https://dashboard.heroku.com/new-app. Do not click the button to integrate with a GitHub repository.
3. Build your docker image locally and deploy it to Heroku. See https://devcenter.heroku.com/articles/container-registry-and-runtime for instructions. In particular you want to [push an existing image](https://devcenter.heroku.com/articles/container-registry-and-runtime#building-and-pushing-image-s) then [release the image](https://devcenter.heroku.com/articles/container-registry-and-runtime#cli). The first steps will push the Docker image to Heroku's Docker Hub registry. Then the last step will deploy that image to your Heroku app.
> - The docs mention a "process-type". You want to use `web`
> - If you are using `ENTRYPOINT dotnet run`, that will not work on Heroku because of how it runs containers. You can use the "exec" syntax instead: `ENTRYPOINT ["dotnet", "run"]`
4. You should now see a log of the deployment on your Heroku app's dashboard: https://dashboard.heroku.com/apps/<HEROKU_APP_NAME> (replace `<HEROKU_APP_NAME>` with the name you gave your Heroku app when you created it).
5. You can see the app running by clicking the "Open app" button on the app's dashboard, or by going to <HEROKU_APP_NAME>.herokuapp.com.

### Automate deployment to Heroku

You will need an API key so that your pipeline can access Heroku. Manually run the command `heroku authorizations:create` to generate it.

#### **With GitHub Actions**

Add your API key as a GitHub Actions secret.

Add new steps to your publishing job in order to deploy to Heroku. You should be able to find an existing action to do this for you, or again, you could script it yourself. As with publishing to Docker Hub, this should only run on the "main" branch.

<details>
<summary>Hint</summary>

You might want to look [at this action](https://github.com/marketplace/actions/deploy-to-heroku).

<details>
<summary>Hint</summary>

See the example ["Deploy with Docker"](https://github.com/marketplace/actions/deploy-to-heroku#deploy-with-docker) section, and don't forget the `usedocker` flag
</details>
</details>

#### **With GitLab CI/CD**

Set your API key as an environment variable called "HEROKU_API_KEY".

Add a new job to your `.gitlab-ci.yml` file. You need to:

* Set up pre-requisites:
  * Run the job in a "Docker in Docker" image by setting `image: docker`
  * Add "Docker" service to your job by setting `services: [ docker:dind ]`. For both of these, you could pick a specific tag from [the repository](https://hub.docker.com/_/docker) to control the version of Docker.
  * Install Heroku CLI and its dependencies with:
  ```bash
  apk add --update-cache curl bash npm
  curl https://cli-assets.heroku.com/install.sh | sh
  ```

* Add all the commands that you ran manually before. Namely:
  * Build your image
  * Log in to the Heroku container registry
  * Push your image
  * Trigger a "release"

### Test your workflow again

Make a small, visible change again, push it to your repository and check that it automatically shows up on your Heroku website.

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

### (Stretch goal) Handle failure
How would you handle failure, for example if the healthcheck in the previous step fails? Write a custom action that will automatically roll-back a failed Heroku deployment. Make sure it sends an appropriate alert! Find a way to break your application and check this works.

### (Stretch goal) Monitor for failure
Failures don't always happen immediately after a deployment. Sometimes runtime issues will only emerge after minutes, hours or days in production. Set up a separate workflow which will use your healthcheck endpoint and send a notification if the healthcheck fails. Make sure this workflow runs every 5 minutes. Hint: https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions#onschedule.

### (Stretch goal) Multiple environments
Try making your workflow release to a different Heroku app environment for each branch of your repository.

### (Stretch goal) Promote when manually triggered
Currently we'll deploy every time a change is pushed to the main branch. However you might want to have more control over when deployments happen. Modify your Heroku and workflow setup so your main branch releases to a staging environment, and you instead manually trigger a workflow to release to production. 

### (Stretch goal) Jenkins
In one of the workshop 7 goals you were asked to set up a Jenkins job for the app (if you haven't done that yet it's worth going back to it now). Now modify the Jenkinsfile so that it will deploy to Heroku.
