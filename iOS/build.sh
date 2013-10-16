#!/bin/bash
set -e -u -x
TARGET_SDK="iphoneos"
PROJECT_BUILDDIR="${PWD}/Builds/"
DEVELOPER_NAME="Yury Melnichek"
PROVISIONING_PROFILE_CONST="${PWD}/Profiles/"
BUILD_CONFIGURATION="Production"
DATE=$(date +%F)
APP_DSYM_FOLDER="${PROJECT_BUILDDIR}APP_AND_DSYM-${DATE}"
RELEASE_ADHOC="adhoc"
RESULT_DIR="${PROJECT_BUILDDIR}"

declare arr=(UK Japan Russia Spain Hawaii California Germany Italy France Turkey Switzerland Greece)

if [ $# == 1 ];
then
	BUILD_CONFIGURATION=$"Release"
	PROVISIONING_PROFILE="${PROVISIONING_PROFILE_CONST}GuideWithMe_AdHoc.mobileprovision"
    RESULT_DIR="${RESULT_DIR}Release-${DATE}"
 else
 	RESULT_DIR="${RESULT_DIR}Production-${DATE}"
fi

if [ -d "$APP_DSYM_FOLDER" ]; then
    rm -rf "${APP_DSYM_FOLDER}"
fi
mkdir -p "$APP_DSYM_FOLDER"

if [ -d "$RESULT_DIR" ]; then
    rm -rf "${RESULT_DIR}"
fi
mkdir -p "$RESULT_DIR"

for i in ${arr[@]}
do
   if [ $# -lt 1 ]; then
     PROVISIONING_PROFILE="${PROVISIONING_PROFILE_CONST}${i}_GuideWithMe_Distribution.mobileprovision"
   fi
   xcodebuild -target "${i}" -sdk "${TARGET_SDK}" -configuration "${BUILD_CONFIGURATION}" SYMROOT="${PROJECT_BUILDDIR}${i}"
   xcrun -sdk "${TARGET_SDK}" PackageApplication -v "${PROJECT_BUILDDIR}/${i}/${BUILD_CONFIGURATION}-${TARGET_SDK}/${i}.app" -o "${RESULT_DIR}/${i}.ipa" --sign "${DEVELOPER_NAME}" --embed "${PROVISIONING_PROFILE}"
   cp -r "${PROJECT_BUILDDIR}${i}/${BUILD_CONFIGURATION}-${TARGET_SDK}/"* "$APP_DSYM_FOLDER"
   rm -rf "${PROJECT_BUILDDIR}${i}"
done
zip -r -9 "${RESULT_DIR}/APP_AND_DSYM.zip" "${APP_DSYM_FOLDER}"
rm -rf "${APP_DSYM_FOLDER}"