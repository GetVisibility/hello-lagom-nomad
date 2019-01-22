package com.getvisibility.hellolagomnomad.impl

import akka.management.AkkaManagement
import akka.management.cluster.bootstrap.ClusterBootstrap
import com.getvisibility.hellolagomnomad.api.HellolagomnomadService
import com.lightbend.lagom.scaladsl.broker.kafka.LagomKafkaComponents
import com.lightbend.lagom.scaladsl.devmode.LagomDevModeComponents
import com.lightbend.lagom.scaladsl.discovery.consul.ConsulServiceLocatorComponents
import com.lightbend.lagom.scaladsl.persistence.cassandra.CassandraPersistenceComponents
import com.lightbend.lagom.scaladsl.server._
import com.softwaremill.macwire._
import play.api.libs.ws.ahc.AhcWSComponents

class HellolagomnomadLoader extends LagomApplicationLoader {

  override def load(context: LagomApplicationContext): LagomApplication =
    new HellolagomnomadApplication(context) with ConsulServiceLocatorComponents {
      AkkaManagement(actorSystem).start()
      ClusterBootstrap(actorSystem).start()
    }

  override def loadDevMode(context: LagomApplicationContext): LagomApplication =
    new HellolagomnomadApplication(context) with LagomDevModeComponents

  override def describeService = Some(readDescriptor[HellolagomnomadService])
}

abstract class HellolagomnomadApplication(context: LagomApplicationContext)
  extends LagomApplication(context)
    with CassandraPersistenceComponents
    with LagomKafkaComponents
    with AhcWSComponents {

  // Bind the service that this server provides
  override lazy val lagomServer = serverFor[HellolagomnomadService](wire[HellolagomnomadServiceImpl])

  // Register the JSON serializer registry
  override lazy val jsonSerializerRegistry = HellolagomnomadSerializerRegistry

  // Register the hello-lagom-nomad persistent entity
  persistentEntityRegistry.register(wire[HellolagomnomadEntity])
}
