package com.getvisibility.hellolagomnomad.impl

import com.getvisibility.hellolagomnomad.api
import com.getvisibility.hellolagomnomad.api.HellolagomnomadService
import com.lightbend.lagom.scaladsl.api.ServiceCall
import com.lightbend.lagom.scaladsl.api.broker.Topic
import com.lightbend.lagom.scaladsl.broker.TopicProducer
import com.lightbend.lagom.scaladsl.persistence.{EventStreamElement, PersistentEntityRegistry}

/**
  * Implementation of the HellolagomnomadService.
  */
class HellolagomnomadServiceImpl(persistentEntityRegistry: PersistentEntityRegistry) extends HellolagomnomadService {

  override def hello(id: String) = ServiceCall { _ =>
    // Look up the hello-lagom-nomad entity for the given ID.
    val ref = persistentEntityRegistry.refFor[HellolagomnomadEntity](id)

    // Ask the entity the Hello command.
    ref.ask(Hello(id))
  }

  override def useGreeting(id: String) = ServiceCall { request =>
    // Look up the hello-lagom-nomad entity for the given ID.
    val ref = persistentEntityRegistry.refFor[HellolagomnomadEntity](id)

    // Tell the entity to use the greeting message specified.
    ref.ask(UseGreetingMessage(request.message))
  }


  override def greetingsTopic(): Topic[api.GreetingMessageChanged] =
    TopicProducer.singleStreamWithOffset {
      fromOffset =>
        persistentEntityRegistry.eventStream(HellolagomnomadEvent.Tag, fromOffset)
          .map(ev => (convertEvent(ev), ev.offset))
    }

  private def convertEvent(helloEvent: EventStreamElement[HellolagomnomadEvent]): api.GreetingMessageChanged = {
    helloEvent.event match {
      case GreetingMessageChanged(msg) => api.GreetingMessageChanged(helloEvent.entityId, msg)
    }
  }
}
