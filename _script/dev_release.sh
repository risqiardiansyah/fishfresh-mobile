#!/bin/sh

SP="$( cd -- "$(dirname "$0/..")" >/dev/null 2>&1 ; pwd -P )"

echo "\Applicaton release dev - Firebase.\n"

if [ -n "$1" ]; then
  DIRA="$SP/release_dev/$1/android"
#   DIRI="$SP/release_dev/$1/ios"

  if [ -d "$DIRA" ]; then
    echo "Android release_dev folder is exist."
  else
    mkdir -p "$DIRA/debug"
    CAN_BUILD=true
  fi

#   if [ -d "$DIRI" ]; then
#     echo "iOS release_dev folder is exist."
#   else
#     mkdir -p "$DIRI/debug"
#     CAN_BUILD=true
#   fi

  if [ "$CAN_BUILD" = true ]; then
    echo "\nBuilding Android Dev Release $1\n\n"

    flutter build apk --obfuscate --split-debug-info "$DIRA/debug"

    echo "\n\nCopy .apk\n"
    cp -v "$SP/build/app/outputs/flutter-apk/app-release.apk" "$DIRA/app-release.apk"
    

    # echo "\nBuilding iOS Dev Release $1\n\n"
    # flutter build ipa --flavor=dev --export-method ad-hoc --obfuscate --split-debug-info "$DIRI/debug"

    # echo "\nCopy ipa folder"
    # cp -rv "$SP/build/ios/ipa" "$DIRI"

    echo "\n\nBuild Done.\n\n"

    # if [ "$2" = "deploy" ]; then
    #   echo "\nPreparing deployment to Firebase.\n"

    #   echo "\nAndroid Dev Deployment.\n"
    #   firebase appdistribution:distribute $DIRA/app-release-dev.apk --app 1:690318570252:android:7e80a01c65d1faf3374f29 --release-notes-file "$SP/_scripts/release_notes/$1/notes.txt" --testers-file "$SP/_scripts/release_notes/$1/testers.txt"

    #   echo "\n iOS Dev Deployment.\n"
    #   firebase appdistribution:distribute $DIRI/ipa/SurV.ipa --app 1:690318570252:ios:23766d74bdd9703f374f29 --release-notes-file "$SP/_scripts/release_notes/$1/notes.txt" --testers-file "$SP/_scripts/release_notes/$1/testers.txt"

    #   echo "\nDeployment Done.\n"
    # fi
  else
    echo "\nBuild cancelled.\n\n"
  fi

else
  echo "Usage: $0 [versi]"
fi