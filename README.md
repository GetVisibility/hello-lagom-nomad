# Lagom hello world service with Hashicorp Nomad

- Website: [www.getvisibility.com](https://www.getvisibility.com/)

This project is an example of a Lagom microservice playing nicely with Nomad.

It has been generated by the lagom/lagom-scala.g8 template.

---

# Installation

## Prerequisites
* [Nomad](https://www.nomadproject.io/) will be used to deploy the application.
* [Consul](https://www.consul.io/) for service discovery, service location and akka clustering.
* [SBT](https://www.scala-sbt.org/) to build the microservice.

## Generating the service locator
We will be using an open source implementation of the Consul service locator for Lagom. The  first step is to build this dependant component.
* Download the project from `https://github.com/jboner/lagom-service-locator-consul.git`
* Open the project in an IDE and build it. (This will add it to your ivy cache and you can reference it in the `hello-lagom-nomad` project)

## Creating a JAR with dependencies (a.k.a. uber-JAR or fat JAR)
* Clone the repository and open a terminal in the `hello-lagom-nomad` folder.
* Run `sbt` to open the SBT environment.
* Set the current project to implementation of the microservice with `project hello-lagom-nomad-impl`.
* Finally create the JAR with `assembly`.

## Moving the JAR to an artifact registry
* Locate the generated JAR at `/hello-lagom-nomad/hello-lagom-nomad-impl/target/scala-2.12/hello-lagom-nomad-impl-assembly-1.0-SNAPSHOT.jar`
* Upload the JAR to a web server where it can be downloaded.
* Open the `demo-app.nomad` and replace the reference to `<URL-OF-YOUR-ARTIFACT-REPOSITORY>` with your web server (including the path to the artifact).

---

# Deployment

## Running the Nomad jobs
* You will need to have Nomad set up and running, for more information please see their [documentation](https://www.nomadproject.io/docs/index.html).
* You will also need to have Consul set up and running. For additional support please see their [docs](https://www.consul.io/docs/index.html).
* The jobs are split into 2 scripts. The base job runs *Zookeeper*, *Kafka* and *Cassandra*. The app job runs the *hello-lagom-nomad* microservice.
* Open a terminal in the `hello-lagom-nomad` directory and run the base job with `nomad job run demo-base.nomad`.
* Verify the base services have been registered in Consul. By default the Consul dashboard will be available at [http://localhost:8500/ui/](http://localhost:8500/ui/).
* Next run the app job with `nomad job run demo-app.nomad`.

## Testing the services
* To verify the akka cluster has been set up correctly:
    * Navigate to the Nomad UI at [http://localhost:4646/ui/](http://localhost:4646/ui/) and on the Jobs page open the demo-app.
    * Open the app Task Group link, and click on the running allocation.
    * Take note of the **http** and **akka_remote** urls, and open the **akka_management** link and append `/bootstrap/seed-nodes/` to the url.
    * You should see the self node and seed notes (with a single entity) reflecting the akka_remote url (from above).
    ```
    {
        "selfNode": "akka.tcp://hellolagomnomad@<AKKA-REMOTE-URL>",
        "seedNodes": [
            {
                "node": "akka.tcp://hellolagomnomad@<AKKA-REMOTE-URL>",
                "nodeUid": 1676770080,
                "status": "Up",
                "roles": [
                    "dc-default"
                ]
            }
        ]
    }
    ```
* To verify the service has been set up open the *http* link and append `/api/hello/world` to the url. The request should return the message *Hello, World!*
