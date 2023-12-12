# Continuous Delivery Workshop Module 09

This repository is for learners on Corndel's DevOps apprenticeship.

If you attended workshop 7:
- For GitHub/GitLab: continue working with your repository from before. 
- For Azure DevOps: work with the fresh repository set up in your ADO project

If you do not have your own repository from workshop 7 for whatever reason, you will need to create one:
- On GitHub, fork this repository.
- On GitLab, create a new GitLab repository based on this one. See step 1 of [Workshop 7](https://github.com/CorndelWithSoftwire/DevOps-Course-Workshop-Module-07-Learners/blob/main/gitlab.md)
- For Azure DevOps: work with the fresh repository set up in your ADO project

There are valid workflow files included here as a starting point (`.github/workflows/continuous-integration-workflow.yml` for GitHub or `.gitlab-ci.yml` for GitLab)

During this workshop follow the instructions in [during_workshop.md](./during_workshop.md).

Refer back to [Workshop 7's instructions](https://github.com/CorndelWithSoftwire/DevOps-Course-Workshop-Module-07-Learners/blob/main/during_workshop_7.md) for a refresher on the basics or if you would like to go back and attempt those stretch goals.

## Set up the app

Whilst it is helpful to be able to experiment locally, getting the app running is not required for the exercise. Use the setup instructions to help write your Dockerfile.

### Build

1. Run `dotnet build` from the terminal in the project folder. This will build the C# code.
    * If you get errors resolving NuGet packages try running `dotnet nuget add source https://api.nuget.org/v3/index.json -n nuget.org` to add the main NuGet registry as a package source.
    You can use `dotnet nuget list source` to see what package sources NuGet is using.
2. From the `DotnetTemplate.Web` folder, run `npm install` (first time only) and then `npm run build`. This will install dependencies and then build the TypeScript code.
    * If you are on Windows and see errors during installation containing "gyp ERR", you may need to first run `npm install --global windows-build-tools` (and restart your terminal).
    * `npm ci` is another way of installing dependencies that will strictly follow the versions listed in package-lock.json. So this can be used for completely reproducible builds.

### Test

1. Run `dotnet test` inside the project folder. This will run the C# tests in the DotnetTemplate.Web.Tests project.
2. Run `npm t` inside the DotnetTemplate.Web folder. This will run the TypeScript tests in DotnetTemplate.Web/Scripts/spec. They're run using [Jasmine](https://jasmine.github.io/).
3. Run `npm run lint` inside the DotnetTemplate.Web folder. This will run linting on the TypeScript code, using [eslint](https://eslint.org/). Linting refers to checking the codebase for mistakes, either functional or stylistic. This project's linting currently reports zero errors, two warnings.

### Run

1. Run `dotnet run` in the DotnetTemplate.Web folder. This will start the app.
2. You can now see the website by going to [http://localhost:5000/](http://localhost:5000/). You should see something like the image below.
