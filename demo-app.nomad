job "demo-app" {

  datacenters = ["dc1"]

  type = "service"

  meta {
    CONSUL_HOST = "127.0.0.1",
    CONSUL_PORT = 8500,
    CASSANDRA_USERNAME = "cassandra",
    CASSANDRA_PASSWORD = "cassandra",
    PLAY_SECRET = "demo",
    CASSANDRA_SERVICE_NAME = "cassandra",
    KAFKA_SERVICE_NAME = "kafka"
  }

  group "app" {
    count = 1

    task "hello" {
      driver = "java"

      config {
        jvm_options = [
          "-Xmx1024m",
          "-Xms256m",
          "-Dplay.http.secret.key=${NOMAD_META_PLAY_SECRET}",
          "-Dplay.server.http.address=${NOMAD_IP_http}",
          "-Dplay.server.http.port=${NOMAD_PORT_http}",
          "-Dakka.remote.netty.tcp.hostname=${NOMAD_IP_akka_remote}",
          "-Dakka.remote.netty.tcp.port=${NOMAD_PORT_akka_remote}",
          "-Dakka.management.http.hostname=${NOMAD_IP_akka_management}",
          "-Dakka.management.http.port=${NOMAD_PORT_akka_management}",
          "-Dakka.management.cluster.bootstrap.contact-point-discovery.required-contact-point-nr=1",
          "-Dlagom.discovery.consul.agent-hostname=${NOMAD_META_CONSUL_HOST}",
          "-Dlagom.discovery.consul.agent-port=${NOMAD_META_CONSUL_PORT}",
          "-Dakka.discovery.akka-consul.consul-host=${NOMAD_META_CONSUL_HOST}",
          "-Dakka.discovery.akka-consul.consul-port=${NOMAD_META_CONSUL_PORT}",
          "-DCASSANDRA_SERVICE_NAME=${NOMAD_META_CASSANDRA_SERVICE_NAME}",
          "-Dcassandra-journal.authentication.username=${NOMAD_META_CASSANDRA_USERNAME}",
          "-Dcassandra-journal.authentication.password=${NOMAD_META_CASSANDRA_PASSWORD}",
          "-Dlagom.persistence.read-side.cassandra.authentication.username=${NOMAD_META_CASSANDRA_USERNAME}",
          "-Dlagom.persistence.read-side.cassandra.authentication.password=${NOMAD_META_CASSANDRA_PASSWORD}",
          "-Dcassandra-snapshot-store.authentication.username=${NOMAD_META_CASSANDRA_USERNAME}",
          "-Dcassandra-snapshot-store.authentication.password=${NOMAD_META_CASSANDRA_PASSWORD}",
          "-DKAFKA_SERVICE_NAME=${NOMAD_META_KAFKA_SERVICE_NAME}"
        ]
        jar_path = "local/hello-lagom-nomad-impl-assembly-1.0-SNAPSHOT.jar"
      }

      artifact {
        source = "http://<URL-OF-YOUR-ARTIFACT-REPOSITORY>/hello-lagom-nomad-impl-assembly-1.0-SNAPSHOT.jar"
      }

      resources {
        cpu    = 500 # MHz
        memory = 128 # MB
        network {
          port "http" {}
          port "akka_remote" {}
          port "akka_management" {}
        }
      }

      service {
        name = "hellolagomnomad"
        tags = [
          "system:hellolagomnomad",
          "akka-management-port:${NOMAD_PORT_akka_management}"
        ]
        address_mode = "host"
        port = "http"
        check {
          name = "alive"
          type = "tcp"
          interval = "30s"
          timeout = "2s"
        }
      }
    }
  }
}
