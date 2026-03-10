buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Provide flutter extension properties for older plugins (e.g. geolocator_android)
    // that reference flutter.compileSdkVersion / flutter.minSdkVersion before evaluation.
    // Skip :app — it has the real Flutter plugin extension with source = "../.."
    if (project.name != "app") {
        project.extra.set("flutter", mapOf(
            "compileSdkVersion" to 36,
            "minSdkVersion" to 23,
            "targetSdkVersion" to 36
        ))
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
