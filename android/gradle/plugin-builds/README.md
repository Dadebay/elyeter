# Android plugin build scripts

The app uses AGP 9.0.1 with built-in Kotlin. Flutter 3.47 scans Gradle source
text for legacy Kotlin plugin declarations, including inactive conditional
branches. The published `firebase_core 4.15.0` and `location 10.0.2` build
scripts still contain those branches, producing false migration warnings.

These copies remove the legacy Kotlin application blocks. Firebase's compiler
options are configured unconditionally for built-in Kotlin, and location's
unused standalone Kotlin classpath is removed. All other upstream build
settings are preserved. Licenses are included alongside the scripts.

`android/settings.gradle.kts` selects these scripts for the two pinned package
versions. Native sources, manifests, resources and auxiliary Gradle files still
come from the original packages; the Pub cache and Flutter SDK are not edited.

When upgrading either package, review its Android build script first. Remove
its mapping and these files once its published build script no longer declares
the legacy Kotlin plugin (or Flutter fixes the conditional-declaration scan).
The version check prevents a newer package silently using an old build script.

Verify changes with `flutter build apk --debug` from the project root. Keep
`android.builtInKotlin=true` and `android.newDsl=false` for Flutter 3.47.
