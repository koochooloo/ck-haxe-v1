#!/bin/bash
#
# Copyright (C) 2013-2017, 1st Playable Productions, LLC. All rights reserved.
#
# UNPUBLISHED -- Rights reserved under the copyright laws of the United
# States. Use of a copyright notice is precautionary only and does not
# imply publication or disclosure.
#
# THIS DOCUMENTATION CONTAINS CONFIDENTIAL AND PROPRIETARY INFORMATION
# OF 1ST PLAYABLE PRODUCTIONS, LLC. ANY DUPLICATION, MODIFICATION,
# DISTRIBUTION, OR DISCLOSURE IS STRICTLY PROHIBITED WITHOUT THE PRIOR
# EXPRESS WRITTEN PERMISSION OF 1ST PLAYABLE PRODUCTIONS, LLC.
############################################################################
#
#  $HeadURL: https://svn.1stplayable.com/speck/trunk/Engineering/autobuild-ios.sh $
#     $Date: 2017-11-30 15:05:00 -0800 (Thu, 30 Nov 2017) $
#   $Author: mattnolin $
# $Revision: 658 $
#
############################################################################
#
# Usage: ./autobuild.sh
#
# Requires a few PROV_PASSWORD_* environment variables; see below.
#
# Builds this project in multiple configs.  Suitable for use by jenkins.
#

##
## Shell Options
##

set -o errexit  # Exit if a simple command exits w/ non-zero status.
set -o pipefail # Checks exit status on all commands in a pipe chain.
set -o nounset  # Treat unset variables as an error when expanding.
set -o xtrace   # Display expanded commands before executing.

# Start in the same directory as the script, without symlinks.
readonly SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SCRIPTDIR}"


##
## Support Methods
##

source autobuild/script_support.sh
source autobuild/build_support.sh
source autobuild/provisioning_support.sh
source tools/env_mac.sh


##
## Settings (customize me)
##

default_workspace_here

# You'll need either an XCWORKSPACE or an XCPROJECT.
# You also need an XCSCHEME.
#
#readonly XCWORKSPACE=
readonly XCSCHEME=speck
readonly XCPROJECT="${SCRIPTDIR}/bin/ios/speck.xcodeproj"

# APPNAME should match PRODUCT_NAME in the .pbxproj and the
# CFBundleName in the .plist.
#
readonly APPNAME=speck

# BUILD_BASE_DIR is something at or above the build directory, that's
# safe to completely nuke on "superclean".
#
readonly BUILD_BASE_DIR="${PWD}/bin/ios/build"

# BUILD_DIR may vary per configuration, but is often the same
# as the BUILD_BASE_DIR.
#
readonly BUILD_DIR="${BUILD_BASE_DIR}"

# If you need a suffix appended to the final package names before .ipa
# and .dSYM.zip, you can put it in APP_PRODUCT_SUFFIX.  For example,
# APP_PRODUCT_SUFFIX="-CHEATS"
#
# Both SHORTNAME and APP_PRODUCT_SUFFIX will be appended, usually.
# SHORTNAME is required, though.
#
#readonly APP_PRODUCT_SUFFIX=""

##
## Keys, Certs, and Provisioning Profiles
##

PROV_SUBDIR=provisioning_common/1P/development
PROV_PASSWORD_VAR="PROV_PASSWORD_1P_DEV" #fill in in environment
provision_import_all

# TODO put "Tobi Saulnier" private key .p12 in here?
PROV_SUBDIR=provisioning_common/1P/distribution
PROV_PASSWORD_VAR="PROV_PASSWORD_1P_DIST" #fill in in environment
provision_import_all

#PROV_SUBDIR=provisioning_common/1P/enterprise
#PROV_PASSWORD_VAR="PROV_PASSWORD_1P_ENT_DIST" #fill in in environment
#provision_import_all

# exit 0 # uncomment to stop after importing provisions (temporary, don't check in)

##
## Clean
##

superclean_everything

##
## Haxe (neko) steps
##

echo "Revision: ${SVN_REVISION:-0}" > assets/data/version.txt
echo "Build: ${BUILD_NUMBER:-0}" >> assets/data/version.txt
echo "Machine: ${HOST:-unknown}" >> assets/data/version.txt

# Build the AWS native extension
pushd extensions/AmazonWebServices
haxelib run lime rebuild . ios -verbose -clean
popd

# Force IS_AUTOBUILD=1 to disable tunables generation.
# Change -Dbuild_cheats to -Dshipping to switch to shipping builds.
env IS_AUTOBUILD=1 haxelib run openfl update ios -verbose -clean -Dshipping
# Possible workaround https://github.com/HaxeFoundation/haxe/issues/6671
mkdir -p bin/ios/speck/haxe/build
# Workaround for missing schemes in xcodeproj
cp -Rp xcshareddata "${XCPROJECT}"/

##
## Builds
##

############################################################
## 1st Playable Distribution -- Enterprise

#reset_local_build_vars

#EXPORT_METHOD=enterprise
#PLIST="${SCRIPTDIR}/bin/ios/speck/speck-Info.plist"
#PRODUCT_RDN="com.firstplayable.speck"
#CODESIGN_AS="iPhone Distribution: 1st Playable Productions LLC"

# Distribution - Enterprise #
#SHORTNAME=1PEnterprise
#BUILD_CONFIG="Release"
#MOBILEPROVISION="./provisioning_common/1P/enterprise/iOS_Enterprise_Distribution_comfirstplayable.mobileprovision"
#build_one_config

############################################################
## 1st Playable Development

reset_local_build_vars

EXPORT_METHOD=development
PLIST="${SCRIPTDIR}/bin/ios/speck/speck-Info.plist"
PRODUCT_RDN="com.firstplayable.speck"
CODESIGN_AS="iPhone Distribution: 1st Playable Productions LLC (YYSX9L5KLV)"
#DEVELOPMENT#CODESIGN_AS="iPhone Developer: Michael Hasty (N2U6QJ7YRU)"
#DEVELOPMENT#EXPORT_METHOD="development"

# Release #
SHORTNAME=1PRelease
BUILD_CONFIG="Release"
EXPORT_METHOD="app-store"
MOBILEPROVISION="./provisioning_common/1P/distribution/1PWildcardAppStoreDist.mobileprovision"
#DEVELOPMENT#MOBILEPROVISION="./provisioning_common/1P/development/1PWildcard.mobileprovision"
build_one_config

# Debug #
SHORTNAME=1PDebug
BUILD_CONFIG="Debug"
EXPORT_METHOD="ad-hoc"
MOBILEPROVISION="./provisioning_common/1P/distribution/1PWildcardAdHocDist.mobileprovision"
#DEVELOPMENT#MOBILEPROVISION="./provisioning_common/1P/development/1PWildcard.mobileprovision"
build_one_config
