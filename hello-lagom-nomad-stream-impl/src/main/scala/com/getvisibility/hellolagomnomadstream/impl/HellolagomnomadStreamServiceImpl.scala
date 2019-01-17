package com.getvisibility.hellolagomnomadstream.impl

import com.lightbend.lagom.scaladsl.api.ServiceCall
import com.getvisibility.hellolagomnomadstream.api.HellolagomnomadStreamService
import com.getvisibility.hellolagomnomad.api.HellolagomnomadService

import scala.concurrent.Future

/**
  * Implementation of the HellolagomnomadStreamService.
  */
class HellolagomnomadStreamServiceImpl(hellolagomnomadService: HellolagomnomadService) extends HellolagomnomadStreamService {
  def stream = ServiceCall { hellos =>
    Future.successful(hellos.mapAsync(8)(hellolagomnomadService.hello(_).invoke()))
  }
}
