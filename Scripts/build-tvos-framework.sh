#!/bin/sh

# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
set -e

# Sets the target folders and the final framework product.
TARGET_NAME="${PROJECT_NAME} tvOS Framework"
TARGET_NAME_APPCENTER="AppCenter tvOS Framework"

# The directory for final output of the framework.
PRODUCTS_DIR="${SRCROOT}/../AppCenter-SDK-Apple/tvOS"

# Build result paths.
SCRIPT_BUILD_DIR="${SRCROOT}/build"
DEVICE_SDK="appletvos"
SIMULATOR_SDK="appletvsimulator"
OUTPUT_DEVICE_DIR="${SCRIPT_BUILD_DIR}/${CONFIGURATION}-${DEVICE_SDK}"
OUTPUT_SIMULATOR_DIR="${SCRIPT_BUILD_DIR}/${CONFIGURATION}-${SIMULATOR_SDK}"

# Building both architectures.
build() {
  # Print only target name and issues. Mimic Xcode output to make prettify tools happy.
  echo "=== BUILD TARGET $1 OF PROJECT $3 WITH CONFIGURATION ${CONFIGURATION} ==="

  # OBJROOT must be customized to avoid conflicts with the current process.
  xcodebuild OBJROOT="${CONFIGURATION_TEMP_DIR}" PROJECT_TEMP_DIR="${PROJECT_TEMP_DIR}" ONLY_ACTIVE_ARCH=NO \
    -project "$3.xcodeproj" -configuration "${CONFIGURATION}" -target "$1" -sdk "$2"
}

# Clean building result folders.
rm -rf "${OUTPUT_DEVICE_DIR}"
rm -rf "${OUTPUT_SIMULATOR_DIR}"

if [ "${PROJECT_NAME}" != "AppCenter" ]; then

  # Build path to output folder for AppCenter frameworks.
  path="${OUTPUT_DEVICE_DIR/\//\\/}"
  path="${path/${PROJECT_NAME}/AppCenter}"
  path="${path/\\/}"

  # Clean building result folders.
  rm -rf "${path}"

  # Make folder for output builds.
  mkdir -p "${OUTPUT_DEVICE_DIR}"
  mkdir -p "${OUTPUT_SIMULATOR_DIR}"

  # Build AppCenter frameworks.
  build "${TARGET_NAME_APPCENTER}" "${DEVICE_SDK}" "${SRCROOT}/../AppCenter/AppCenter"
  build "${TARGET_NAME_APPCENTER}" "${SIMULATOR_SDK}" "${SRCROOT}/../AppCenter/AppCenter"

  # Copy AppCenter frameworks to module output folders.
  cp -RHv "${path}/AppCenter.framework" "${OUTPUT_DEVICE_DIR}"
  cp -RHv "${path}/AppCenter.framework" "${OUTPUT_SIMULATOR_DIR}"
fi

# Clean building result folder.
build "${TARGET_NAME}" "${DEVICE_SDK}" "${SRCROOT}/${PROJECT_NAME}"
build "${TARGET_NAME}" "${SIMULATOR_SDK}" "${SRCROOT}/${PROJECT_NAME}"

# Clean the previous build and copy the framework.
rm -rf "${PRODUCTS_DIR}/${PROJECT_NAME}.framework"
mkdir -p "${PRODUCTS_DIR}"
cp -RHv "${OUTPUT_DEVICE_DIR}/${PROJECT_NAME}.framework" "${PRODUCTS_DIR}"

# Uses the Lipo Tool to combine both binary files (i386/x86_64 + arm64) into one universal final product.
echo "Combine binary files into universal final product"
lipo -create \
  "${OUTPUT_DEVICE_DIR}/${PROJECT_NAME}.framework/${PROJECT_NAME}" \
  "${OUTPUT_SIMULATOR_DIR}/${PROJECT_NAME}.framework/${PROJECT_NAME}" \
  -output "${PRODUCTS_DIR}/${PROJECT_NAME}.framework/${PROJECT_NAME}"
lipo -info "${PRODUCTS_DIR}/${PROJECT_NAME}.framework/${PROJECT_NAME}"
