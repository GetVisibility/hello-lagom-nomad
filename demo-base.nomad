job "demo-base" {

  datacenters = ["dc1"]

  type = "service"

  meta {
    CASSANDRA_USERNAME = "cassandra",
    CASSANDRA_PASSWORD = "cassandra"
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
