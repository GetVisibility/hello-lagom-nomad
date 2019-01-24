job "demo" {

  datacenters = ["dc1"]

  type = "service"

  meta {
    CONSUL_HOST = "localhost",
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

  group "db" {
    count = 1

    task "cassandra" {
      driver = "docker"

      config {
        image = "bitnami/cassandra:3.11.3"
        network_mode = "bridge"
        port_map {
          cql = 9042
        }
      }

      env {
        CASSANDRA_TRANSPORT_PORT_NUMBER = "${NOMAD_PORT_transport}"
        CASSANDRA_JMX_PORT_NUMBER = "${NOMAD_PORT_jmx}"
        CASSANDRA_CQL_PORT_NUMBER = "${NOMAD_PORT_cql}"
      }

      resources {
        memory = 5000
        network {
          port "transport" {}
          port "jmx" {}
          port "cql" {}
        }
      }

      service {
        name = "cassandra"
        port = "cql"
        check {
          name = "alive"
          type = "tcp"
          interval = "30s"
          timeout = "2s"
        }
      }
    }
  }

  group "bus" {
    count = 1

    task "zookeeper" {
      driver = "docker"

      config {
        image = "bitnami/zookeeper:3.4.12"
        network_mode = "host"
      }

      resources {
        network {
          port "client" {}
        }
      }

      env {
        ZOO_PORT_NUMBER = "${NOMAD_PORT_client}"
        ALLOW_ANONYMOUS_LOGIN = "yes"
      }

      service {
        name = "zookeeper"
        address_mode = "auto"
        port = "client"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "30s"
          timeout  = "2s"
        }
      }
    }

    task "kafka" {
      driver = "docker"

      config {
        image = "bitnami/kafka:0.11.0-1-r1"
        network_mode = "host"
      }

      resources {
        memory = 1024
        network {
          port "kafka" {}
        }
      }

      env {
        ALLOW_PLAINTEXT_LISTENER = "yes"
        KAFKA_PORT_NUMBER = "${NOMAD_PORT_kafka}"
        KAFKA_LISTENERS = "PLAINTEXT://${NOMAD_ADDR_kafka}"
        KAFKA_ADVERTISED_LISTENERS = "PLAINTEXT://${NOMAD_ADDR_kafka}"
        KAFKA_ZOOKEEPER_CONNECT = "${NOMAD_ADDR_zookeeper_client}"
      }

      service {
        name = "kafka"
        address_mode = "auto"
        port = "kafka"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "30s"
          timeout  = "2s"
        }
      }
    }
  }
}
