organization in ThisBuild := "com.getvisibility"
version in ThisBuild := "1.0-SNAPSHOT"

// the Scala version that will be used for cross-compiled libraries
scalaVersion in ThisBuild := "2.12.4"

val macwire = "com.softwaremill.macwire" %% "macros" % "2.3.0" % "provided"
val scalaTest = "org.scalatest" %% "scalatest" % "3.0.4" % Test

lazy val `hello-lagom-nomad` = (project in file("."))
  .aggregate(`hello-lagom-nomad-api`, `hello-lagom-nomad-impl`, `hello-lagom-nomad-stream-api`, `hello-lagom-nomad-stream-impl`)

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
      scalaTest
    )
  )
  .settings(lagomForkedTestSettings: _*)
  .dependsOn(`hello-lagom-nomad-api`)

lazy val `hello-lagom-nomad-stream-api` = (project in file("hello-lagom-nomad-stream-api"))
  .settings(
    libraryDependencies ++= Seq(
      lagomScaladslApi
    )
  )

lazy val `hello-lagom-nomad-stream-impl` = (project in file("hello-lagom-nomad-stream-impl"))
  .enablePlugins(LagomScala)
  .settings(
    libraryDependencies ++= Seq(
      lagomScaladslTestKit,
      macwire,
      scalaTest
    )
  )
  .dependsOn(`hello-lagom-nomad-stream-api`, `hello-lagom-nomad-api`)
