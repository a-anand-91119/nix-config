# Personal Java setup

The personal profile retains the existing JDKs and jenv. The initial work profile
does not install Java, jenv, Maven or Gradle, and does not run their shell hooks.

For a project that needs Java, select the required JDK version explicitly. Use
`/usr/libexec/java_home -V` to inspect system-registered JDKs. Homebrew OpenJDK
installations may require the registration described by `brew info openjdk@21`.

Register the actual installed JDK with jenv rather than copying an unrelated
Temurin 8 path. For example, after installing the chosen Java 21 formula:

```sh
jenv add "$(brew --prefix openjdk@21)/libexec/openjdk.jdk/Contents/Home"
jenv enable-plugin export
jenv versions
```

Use the matching installed JDK path for other versions, including Corretto 8.
Choose a project version with jenv and prefer the repository's Maven/Gradle
wrapper when provided. Do not enable these integrations in work until the
corresponding packages and runtime requirements have been selected.
