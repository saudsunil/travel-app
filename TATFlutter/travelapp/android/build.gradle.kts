buildscript {
    val kotlin_version by extra("1.9.10")


    repositories {
        google()
        mavenCentral()
    }


 dependencies {
     
      classpath("com.android.tools.build:gradle:8.1.0")
      // Add the Maven coordinates and latest version of the plugin
      classpath ("com.google.gms:google-services:4.4.2")
      classpath(kotlin("gradle-plugin", version = kotlin_version))
    }

}
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
