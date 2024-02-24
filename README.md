helm upgrade my-release /path/to/local/chart --set deployment.image.tag="2"

<a href="https://www.instagram.com/ttomasferrari/">
    <img align="right" alt="Abhishek's Instagram" width="22px" 
    src="https://i.imgur.com/EzpyGdV.png" />
</a>
<a href="https://twitter.com/tomasferrari">
    <img align="right" alt="Abhishek Naidu | Twitter" width="22px"         
    src="https://i.imgur.com/eFVBTVz.png" />
</a>
<a href="https://www.linkedin.com/in/tomas-ferrari-devops/">
    <img align="right" alt="Abhishek's LinkedIN" width="22px" 
    src="https://i.imgur.com/pMzVPqj.png" />
</a>
<p align="right">
    <a >Find me here: </a>
</p>
<!-- <p align="right">
    <a  href="/docs/readme_es.md">Versión en Español</a>
</p> -->

<p title="All The Things" align="center"> <img src="https://i.imgur.com/0zlneYu.png"> </p>

# INDEX

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Customising Backstage](#customising-backstage)
  - [Plugins I've Added](#plugins-ive-added)
  - [Templates I've Created](#templates-ive-created)
- [Initial Setup](#initial-setup)
- [Backstage Local Setup](#backstage-local-setup)
- [Run In Kubernetes Environment](#run-in-kubernetes-environment)
- [Excercise](#excercise)
  - [What we are starting off with](#what-we-are-starting-off-with)
  - [What we are doing](#what-we-are-doing)


</br>
</br>

# INTRODUCTION
This is a spinoff of my [Automate All The Things](https://github.com/tferrari92/automate-all-the-things) project. While working on the [Nirvana Edition](https://github.com/tferrari92/automate-all-the-things-nirvana), which will include a Developer Portal built with Backstage, I'm creating this smaller lab for anyone who wants to start experimenting with this tool.

Backstage is a framework for creating developer portals. This developer portal should act as a centralized hub for your organization, providing access to documentation, infrastructure, tooling, and code standards. It gives developers everything they need to create and manage their projects in a consistent and standardized manner. If you are new to Backstage, I invite you to read [this brilliant series of articles](https://www.kosli.com/blog/evaluating-backstage-1-why-backstage/) by Alexandre Couedelo.

<!-- RELOADED -->
<!-- We'll be using a GitOps methodology with Helm, ArgoCD and the App Of Apps Pattern. There is some extra information [here](/docs/argocd-notes.md), but you are expected to know about these things. -->

</br>
</br>

# PREREQUISITES
- minikube installed
- kubectl installed
- helm installed
- vim installed

</br>
</br>

# CUSTOMISING BACKSTAGE
Backstage is designed to be flexible and allow every organization to adapt it to their own needs. It is not a black-box application where you install plugins; rather, you maintain your own source code and can modify it as needed.

I've already added some custom stuff to the default Backstage installation that I think are essential. 

</br>

## Plugins I've added

### Kubernetes plugin
The [Kubernetes plugin](https://backstage.io/docs/features/kubernetes/) in Backstage is a tool that's designed around the needs of service owners, not cluster admins. Now developers can easily check the health of their services no matter how or where those services are deployed — whether it's on a local host for testing or in production on dozens of clusters around the world.

It will elevate the visibility of errors where identified, and provide drill down about the deployments, pods, and other objects for a service.

### GitHub Discovery plugin 
The [GitHub Discovery plugin](https://backstage.io/docs/integrations/github/discovery) automatically discovers catalog entities within a GitHub organization. The provider will crawl the GitHub organization and register entities matching the configured path. This can be useful as an alternative to static locations or manually adding things to the catalog. This is the preferred method for ingesting entities into the catalog.

I've installed it without events support. Updates to the catalog will rely on periodic scanning rather than real-time updates.

### GitHub Actions plugin 
https://roadie.io/backstage/plugins/github-actions/

<!-- ## ArgoCD plugin
https://roadie.io/backstage/plugins/argo-cd/

## GitHub Insights plugin
https://roadie.io/backstage/plugins/github-insights/

## Grafana plugin
https://roadie.io/docs/integrations/grafana/ -->

<!-- ## GitHub Security Insights plugin ## ESTE NO SE SI REQUIERE TAMBEN EL DE LOGIN CON GITHUB. HAY   PROBARLO 
https://www.kosli.com/blog/implementing-backstage-4-security-and-compliance/
https://roadie.io/backstage/plugins/security-insights/ -->

<!-- ## Homepage plugin
https://backstage.io/docs/getting-started/homepage/ 
https://www.kosli.com/blog/succeeding-with-backstage-part-1-customizing-the-look-and-feel-of-backstage/-->


<!-- ## Changed App Theme
https://www.kosli.com/blog/succeeding-with-backstage-part-1-customizing-the-look-and-feel-of-backstage/ -->

</br>

## Templates I've created
<!-- #### New nodejs in new repo
lorem ipsum -->
### New backstage group
Creates a new Backstage group with the provided information. 

It generates a Pull Request which includes a new Group catalog entity manifest. If merged, the Group catalog entity will be automatically added to the Backstage catalog by the GitHub Discovery plugin.

### New backstage user
Creates a new Backstage user with the provided information. 

It generates a Pull Request which includes a new User catalog entity manifest. If merged, the User catalog entity will be automatically added to the Backstage catalog by the GitHub Discovery plugin.

### New nodejs in existing repo
lorem ipsum


<!-- #### New documentation -->
</br>

## My arbitrary rules

### Users and groups hierarchy
I decided that user and group hierarchy should be defined from the bottom up. To me, it makes more sense that childs should keep track of their parents than parents of their childs.

So we will not define the members of a group in the Group manifest, but we will define the group a user belongs to in the spec.memberOf of the User manifest. 

Also, we will always have the spec.children value of Group manifests as an empty array and the spec.parent value filled with whoever the parent group of that group is. If it has no parent, the value of spec.parent should be "root".

</br>
</br>

# INITIAL SETUP
In order to turn this whole deployment into your own thing, we need to do some initial setup:

1. Fork this repo. Keep the repository name "backstage-minikube-lab".
1. Clone the repo from your fork:

```bash
git clone https://github.com/<your-github-username>/backstage-minikube-lab.git
```

2. Move into the directory:

```bash
cd backstage-minikube-lab
```

2. Run the initial setup script. Come back when you are done:

```bash
chmod +x initial-setup.sh
./initial-setup.sh
```

4. Hope you enjoyed the welcome script! Now push your customized repo to GitHub:

```bash
git add .
git commit -m "customized repo"
git push
```

</br>
</br>

# BACKSTAGE LOCAL SETUP
Before deploying Backstage in a Kubernetes environment (Minikube), we need to build it locally. Testing the change you make to your Backstage implementation is also recommended to be done locally since it's much quicker than building the image, pushing it, etc. to test in in K8S.

#### Install NVM
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
nvm install 18
nvm use 18
nvm alias default 18
```

#### Install yarn
```bash
npm install --global yarn
yarn set version 1.22.19
yarn --version
yarn global add concurrently
```

#### Get GitHub PAT (Personal Access Token)
You can do the following to create a GitHub PAT:

Navigate to the GitHub PAT creation page.
In the Note field, enter the name of the token, such as backstage-token.
Choose a value for Expiration and select the scope of your token. When creating a template, you’ll need to select at least the repo scope.

<p title="GitHub Token" align="center"> <img src="https://i.imgur.com/x28b4Q5.png"> </p>



#### Local testing
Create en env var for your GitHub token
```bash
export GITHUB_TOKEN=<your-github-token>
```

Then run
```bash
cd backstage/my-backstage/
yarn install
yarn tsc
yarn dev
```

This should open backstage in your browser. If all runs smoothly, we can proceed to deploying backstage in Minikube. 

Every time you make changes to the Backstage code, it's recommended you test it by running it locally with "yarn dev", since it will be much faster that testing it in Minikube.

"Ctrl + C" to stop the running process and let's continue...

</br>
</br>

# RUN IN KUBERNETES ENVIRONMENT

#### Build and push backstage container image to DockerHub
To build and push the Docker image, run the build-push-image.sh script
```bash
chmod +x build-push-image.sh
./build-push-image.sh
```

#### Update image tag in backstage chart values
Update the value of backstage.image.tag in the backstage values-custom.yaml 
```bash
cd ../..
vim helm/infra/backstage/values-custom.yaml
```
<!-- RELOADED -->
<!-- Save and push to repo
```bash
git add .
git commit -m "Updated backstage image tag"
git push
``` -->

#### Minikube Environment Setup
Run the start.sh script to get everything setup
```bash
chmod +x backstage/deploy-in-minikube.sh
backstage/deploy-in-minikube.sh
```

<!-- Run the start.sh script to get everything setup
```bash
chmod +x backstage/deploy-k8s-environment.sh
backstage/deploy-k8s-environment.sh
``` -->

Now go to localhost:8080 on your browser and Voilá!

</br>
</br>


# EXCERCISE

## What we are starting off with
We are starting off with a Redis database and a backend. Everytime the backend recieves a request it gets the value of "count" from the Redis db and returns it to the user. Before returning it, it adds +1 to "count".

You can test it like this:
```bash
kubectl get pods -n my-app -l app=my-app-backend -o name | xargs -I {} kubectl exec -n my-app {} -- curl -s localhost:3000
```

You should get:
```bash
{"count":1}%
```

If you run it again, you'll get:
```bash
{"count":2}%
```

And so on... If this works fine, we can continue.

<!-- You can test it on the other environments too:
```bash
kubectl get pods -n my-app-stage -l app=my-app-backend-stage -o name | xargs -I {} kubectl exec -n my-app-stage {} -- curl -s localhost:3000
kubectl get pods -n my-app-prod -l app=my-app-backend-prod -o name | xargs -I {} kubectl exec -n my-app-prod {} -- curl -s localhost:3000
``` -->

## What we are doing
We are going to create the missing piece of this puzzle with the help of backstage, the frontend.

Let's analyze the backend. With this setup we have, there's a number of things that need to exist in order for the backend service to be deployed. These are:
<!-- RELOADED -->
<!-- Let's analyze the backend. With this Gitops setup we have, there's a number of things that need to exist in order for the backend service to be deployed. These are: -->
1. The [my-app/backend directory](/my-app/backend/): In a real world scenario, the backend service would have its own repo where we would store all the application code. In this small lab we'll just save it in its own directory.
2. The [helm/my-app/backend directory](/helm/my-app/backend/): Here we save the Helm chart for our backend service. This of course would also be in its own repo on a real world scenario.
<!-- RELAODED -->
<!-- 3. The [backend service argocd application manifests](/argo-cd/applications/my-app/backend/): These are read by the App of Apps to  -->
4. The [backend build and push pipeline](/.github/workflows/build-push-my-app-backend.yml): In a real world scenario, the build and push workflow would probably exist within the .github/workflows of the backend applciation code repo. In this case, since we are using one repo for everything, we'll put it in the .github/workflows of this repo.

All of these files and directories we need to create for any new service we want to deploy. Luckily, we have Backstage Software Templates.

## How we are doing it
Let's go into our Backstage console. In the Create tab on the left, we'll find the "New NGNIX in Existing Repo" Software Template. Click "Choose" on that card and complete with this info:
- System: my-app
- Service: frontend
- Description: Frontend for the my-app system
- Owner: my-app-frontend-subteam

On the next, under Owner complete with your GitHub username and under Repository complete with "backstage-minikube-lab". Click Review and then Create.

If all goes well, you should see a few green ticks and a "Go to PR" button. Click on the button.

</br>
</br>




# Customizing Your Backstage

# Paso a paso para buildear nueva imgen y utilizarla

## Creating new templates
create template directory save it in backstage/entities/templates/



#### Backstage needs github api token to access software catalog. Get one on github console.

When creating a personal access token on GitHub, you must select scopes to define the level of access for the token. The scopes required vary depending on your use of the integration: https://backstage.io/docs/integrations/github/locations/#token-scopes
Reading software components:
    repo        
Reading organization data:
    read:org
    read:user
    user:email
Publishing software templates:
    repo
    workflow (if templates include GitHub workflows)



























##### Info interesante:
https://backstage.spotify.com/learn/backstage-for-all/software-catalog/4-modeling/
https://backstage.spotify.com/learn/standing-up-backstage/putting-backstage-into-action/8-integration/
https://backstage.spotify.com/learn/onboarding-software-to-backstage/onboarding-software-to-backstage/5-register-component/

##### Info datallada sobre objetos de tipo template:
https://backstage.io/docs/features/software-catalog/descriptor-format#kind-template
##### Aqui las acciones q puede hacer el template:
http://localhost:3000/create/actions
##### Para acciones q no existen default:
https://backstage.io/docs/features/software-templates/writing-custom-actions/
##### A note on RepoUrlPicker
In the template.yaml file of the template we created, you must have noticed ui:field: RepoUrlPicker in the spec.parameters field. This is known as Scaffolder Field Extensions.

These field extensions are used in taking certain types of input from users like GitHub repository URL, teams registered in catalog for the owners field, etc. Such field extensions can also be customized for your own organization. See https://backstage.io/docs/features/software-templates/writing-custom-field-extensions/

##### Aca hay ejemplos de templates:
https://github.com/backstage/software-templates

##### Software Templates at Spotify
At Spotify, we have dozens of Software Templates. We divide them into several disciples like Backend, Frontend, Data pipelines, etc. Inside Spotify, we also have stakeholder groups for Web, Backend, Data, etc. separately. These Software Templates are hosted on our internal GitHub enterprise, maintained and reviewed by the concerned experts in the discipline.

The Technical Architecture Group (TAG) at Spotify is the body responsible for reducing fragmentation by deciding on the various Backend, Frontend, Data frameworks to be used inside Spotify. Hence, new Software Templates with completely new frameworks are carefully discussed and reviewed.

Our Software Templates are fundamental to the concept of Golden Paths at Spotify. The Golden Path is the opinionated and supported way to build something (for example, build a backend service, put up a website, create a data pipeline). The Golden Path Tutorial is a step-by-step instructions that walks you through this opinionated and supported path.

The blessed tools — those on the Golden Path — are visualized in the Explore section of Backstage. Read more https://engineering.atspotify.com/2020/08/how-we-use-golden-paths-to-solve-fragmentation-in-our-software-ecosystem/


##### Component objects:
https://backstage.io/docs/features/software-catalog/descriptor-format/#overall-shape-of-an-entity





# Following this approach, no template will load in the UI if any one of those is broken!!!
  locations:
    - type: url
      target: https://github.com/tomasferrarisenda/backstage/blob/main/templates/all-templates.yaml
      rules:
        - allow: [Template]


## USAR PLUGIN DE AUTODISCOVERY POR LA MODALIDAD ACTUAL NO BORRA USERSAL SACARLOS DEL REPO
# EXPLICAR LO DE app-config.yaml y app-config.production.ymal
uno se usa para local (yarn dev), el otro apra el cluster. Ppalmente por la config para la bbdd postgress (en local no la utilizamos)




# BACKSTAGE
If the only change you've made is to the app-config.yaml (or other configuration files) and not to the application code itself, you don't necessarily need to run yarn build or yarn build:backend. The Docker image build process should copy the updated configuration files into the image.





# COSAS MODIFICADAS:
values custom de argo, ingress.enabled cambiado a false


AGREGARLE DESCRIPTION AL REPO DE GHUB




Searching through App Metadata with Backstage Search
The Backstage Search feature allows you to integrate custom search engine providers. You can also use any of the three default search engines: Lunr, Postgres, or Elasticsearch. Lunr is the current search engine enabled on your Backstage app. However, the documentation does not recommend this setup for a production environment because this search engine may not perform indexing well enough when the volume of app metadata and documentation increases.
https://www.kosli.com/blog/implementing-backstage-2-using-the-core-features/

Optimizing Search Highlighting
For a better search highlighting experience, add these lines of config to app-config.yaml:
```yaml
search:
  pg:
    highlightOptions:
      useHighlight: true
      maxWord: 35 # Used to set the longest headlines to output. The default value is 35.
      minWord: 15 # Used to set the shortest headlines to output. The default value is 15.
      shortWord: 3 # Words of this length or less will be dropped at the start and end of a headline, unless they are query terms. The default value of three (3) eliminates common English articles.
      highlightAll: false # If true the whole document will be used as the headline, ignoring the preceding three parameters. The default is false.
      maxFragments: 0 # Maximum number of text fragments to display. The default value of zero selects a non-fragment-based headline generation method. A value greater than zero selects fragment-based headline generation (see the linked documentation above for more details).
      fragmentDelimiter: ' ... ' # Delimiter string used to concatenate fragments. Defaults to " ... ".
```
https://www.kosli.com/blog/implementing-backstage-2-using-the-core-features/







VER PORQ EL RESOURCE REDIS NO APARECE BAJO OWNERSHIP DEL GRUPO REDIS
PORQ My-App Redis Subteam no muestra ownership de resource redis??? http://localhost:3000/catalog/default/group/my-app-redis-subteam


Pipeline is out of the scope of this lab



PASARLE LEABLES A DPL DE BACKEND POR VALUES!!!!


AVECES TARDE EN LEVANTAR EL POD DE POSTGRESS. HASTA Q ESE NO ESTE LISTO BS NO VA  A ANDAR, QUIZAS HAYA Q TIRAR PORT FORWARD VARIAS VECES, SACAR PF DE SCRRIPT Y PONER LA INSTRUCCION EN EL README
