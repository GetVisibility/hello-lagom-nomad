package com.getvisibility.hellolagomnomadstream.api

import akka.NotUsed
import akka.stream.scaladsl.Source
import com.lightbend.lagom.scaladsl.api.{Service, ServiceCall}

/**
  * The hello-lagom-nomad stream interface.
  *
  * This describes everything that Lagom needs to know about how to serve and
  * consume the HellolagomnomadStream service.
  */
trait HellolagomnomadStreamService extends Service {

  def stream: ServiceCall[Source[String, NotUsed], Source[String, NotUsed]]

  override final def descriptor = {
    import Service._

    named("hello-lagom-nomad-stream")
      .withCalls(
        namedCall("stream", stream)
      ).withAutoAcl(true)
  }
}

