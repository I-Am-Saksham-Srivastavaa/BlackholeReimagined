allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional — only if you truly want to change root project's build dir
buildDir = file("../build")

subprojects {
    // Set custom build directory per subproject
    buildDir = file("${rootProject.buildDir}/${project.name}")

    // Only use evaluationDependsOn for specific projects if truly needed
    if (project.name != "app") {
        evaluationDependsOn(":app")
    }
}

// Global clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
