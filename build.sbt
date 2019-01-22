
organization in ThisBuild := "com.getvisibility"
version in ThisBuild := "1.0-SNAPSHOT"

// the Scala version that will be used for cross-compiled libraries
scalaVersion in ThisBuild := "2.12.4"

val macwire = "com.softwaremill.macwire" %% "macros" % "2.3.0" % "provided"
val scalaTest = "org.scalatest" %% "scalatest" % "3.0.4" % Test

// This project needs to be build and added to the ivy cache from https://github.com/jboner/lagom-service-locator-consul
val serviceLocatorForConsul = "com.lightbend.lagom" %% "lagom-service-locator-scaladsl-consul" % "1.4.0-SNAPSHOT"

// Allow akka cluster discovery/joining through consul
val akkaClusterBootstrap = Seq(
  "com.lightbend.akka.management" %% "akka-management-cluster-bootstrap" % "0.20.0",
  "com.lightbend.akka.discovery" %% "akka-discovery-consul" % "0.20.0"
)

lazy val `hello-lagom-nomad` = (project in file("."))
  .aggregate(`hello-lagom-nomad-api`, `hello-lagom-nomad-impl`)

lazy val `hello-lagom-nomad-api` = (project in file("hello-lagom-nomad-api"))
  .settings(
    libraryDependencies ++= Seq(
      lagomScaladslApi
    )
  )

lazy val `hello-lagom-nomad-impl` = (project in file("hello-lagom-nomad-impl"))
  .enablePlugins(LagomScala)
  .settings(
    libraryDependencies ++= Seq(
      lagomScaladslPersistenceCassandra,
      lagomScaladslKafkaBroker,
      lagomScaladslTestKit,
      macwire,
      scalaTest,
      serviceLocatorForConsul
    ) ++ akkaClusterBootstrap
  )
  .settings(lagomForkedTestSettings: _*)
  .settings(mainClass in assembly := Some("play.core.server.ProdServerStart"))
  .settings(assemblyMergeStrategy in assembly := {
    case PathList(ps@_*) if ps.last endsWith ".class" => MergeStrategy.first
    case PathList(ps@_*) if ps.last == "reference-overrides.conf" => MergeStrategy.concat
    case PathList(ps@_*) if ps.last == "io.netty.versions.properties" => MergeStrategy.concat
    case x =>
      val oldStrategy = (assemblyMergeStrategy in assembly).value
      oldStrategy(x)
  })
  .dependsOn(`hello-lagom-nomad-api`)
