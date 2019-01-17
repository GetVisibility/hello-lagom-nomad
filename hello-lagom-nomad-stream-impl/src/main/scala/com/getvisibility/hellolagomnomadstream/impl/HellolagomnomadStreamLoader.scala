package com.getvisibility.hellolagomnomadstream.impl

import com.lightbend.lagom.scaladsl.api.ServiceLocator.NoServiceLocator
import com.lightbend.lagom.scaladsl.server._
import com.lightbend.lagom.scaladsl.devmode.LagomDevModeComponents
import play.api.libs.ws.ahc.AhcWSComponents
import com.getvisibility.hellolagomnomadstream.api.HellolagomnomadStreamService
import com.getvisibility.hellolagomnomad.api.HellolagomnomadService
import com.softwaremill.macwire._

class HellolagomnomadStreamLoader extends LagomApplicationLoader {

  override def load(context: LagomApplicationContext): LagomApplication =
    new HellolagomnomadStreamApplication(context) {
      override def serviceLocator = NoServiceLocator
    }

  override def loadDevMode(context: LagomApplicationContext): LagomApplication =
    new HellolagomnomadStreamApplication(context) with LagomDevModeComponents

  override def describeService = Some(readDescriptor[HellolagomnomadStreamService])
}

abstract class HellolagomnomadStreamApplication(context: LagomApplicationContext)
  extends LagomApplication(context)
    with AhcWSComponents {

  // Bind the service that this server provides
  override lazy val lagomServer = serverFor[HellolagomnomadStreamService](wire[HellolagomnomadStreamServiceImpl])

  // Bind the HellolagomnomadService client
  lazy val hellolagomnomadService = serviceClient.implement[HellolagomnomadService]
}
