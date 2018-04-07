##
## Copyright (C) 2015, 1st Playable Productions, LLC. All rights reserved.
##
## UNPUBLISHED -- Rights reserved under the copyright laws of the United
## States. Use of a copyright notice is precautionary only and does not
## imply publication or disclosure.
##
## THIS DOCUMENTATION CONTAINS CONFIDENTIAL AND PROPRIETARY INFORMATION
## OF 1ST PLAYABLE PRODUCTIONS, LLC. ANY DUPLICATION, MODIFICATION,
## DISTRIBUTION, OR DISCLOSURE IS STRICTLY PROHIBITED WITHOUT THE PRIOR
## EXPRESS WRITTEN PERMISSION OF 1ST PLAYABLE PRODUCTIONS, LLC.
###########################################################################

import logging
import sys

import DataMakeUtils
import ExcelUtils


TP_SETTINGS_SHEET_ID = 0
ASSET_LIST_SHEET_ID = 1
COL_HEADER_ROW_ID = 0
DATA_START_ROW = COL_HEADER_ROW_ID + 1

# TP Settings sheet consts
SETTING_ID_COL_ID = 0
DITHER_COL_ID = 1 # dither command in TP is formatted different than the others
ADDL_ARGS_START_COL = 2
ARG_NAME_IDX = 0
ARG_VAL_IDX = 1

# Asset paths sheet consts
PATH_COL_ID = 0
SETTING_COL_ID = 1
LOADGROUP_COL_ID = 2

DEFAULT_TP_SETTING_ID = "DEFAULT"
DEFAULT_LOAD_GROUP = "default"


################################################################################################
# Represents a load group / TP setting combination.
# The number of these created will be <= the number of rows in the Asset Paths sheet.
# This data will correspond to a single spritesheet (and each spritesheet will have an AssetGroup).
class AssetGroup(object):
    def __init__( self, groupID, tpConfig ):
        self.ID = groupID
        self.paths = []
        self.tpConfig = tpConfig

    def addPath( self, path ):
        if path in self.paths:
            sys.stderr.write( "Path '" + path + "' has already been added to asset group " + self.ID + "\n" )
            return

        self.paths.append( path )


################################################################################################
# Represents data from a single row of the TP Settings sheet in the Asset Manifest xls
class TpConfig(object):
    def __init__( self, settingID, dither, args ):
        self.ID = settingID
        #self.dither = dither
        #self.args = args

        self.command = ""

        if dither != "":
            self.command += " --" + dither

        for arg in args:
            self.command += " --" + str( arg[ ARG_NAME_IDX ] )+ " " + str( arg[ ARG_VAL_IDX ] )



################################################################################################
# Represents data from a single row of the Asset Paths sheet in the Asset Manifest xls
class AssetEntry(object):
    def __init__( self, path, tpSetting, loadGroup ):
        self.path = path
        self.tpSetting = tpSetting
        self.loadGroup = loadGroup


################################################################################################
################################################################################################
# ENTRY POINT
def parseAssetManifest( manifestPath ):
    assetData = ExcelUtils.gatherSpreadsheetInfo( manifestPath, ASSET_LIST_SHEET_ID, COL_HEADER_ROW_ID ) # an excel workbook object
    tpSettingsData = ExcelUtils.gatherSpreadsheetInfo( manifestPath, TP_SETTINGS_SHEET_ID, COL_HEADER_ROW_ID )

    tpSettingsMap = parseSettingsSheet( tpSettingsData )
    assetGroups = makeGroups( parseAssetSheet( assetData ), tpSettingsMap )

    return assetGroups


#------------------------------------------------------------------------------
# returns a dict mapping settingID -> TpConfig
def parseSettingsSheet( settingsData ):
    settingsMap = {}
    keys = sorted( settingsData.columnInfo.keys() )

    # Get each setting
    for curRow in range( DATA_START_ROW, settingsData.numRows ):
        settingID = getInUnicode( settingsData.sheetData[ curRow ][ SETTING_ID_COL_ID ] )

        if settingID in settingsMap:
            sys.stderr.write( "WARNING: duplicate TexturePacker settings entry detected in the asset manifest: " + settingID + "\n" )
            continue

        dither = getInUnicode( settingsData.sheetData[ curRow ][ DITHER_COL_ID ] )
        args = []

        # Get all of the properties for this setting
        for curCol in range( ADDL_ARGS_START_COL, len( keys ) ):
            val = settingsData.sheetData[ curRow ][ curCol ]
            key = settingsData.columnInfo[ curCol ]
            if val != "":
                args.append( [ key, val ] )

        # Map setting ID -> setting properties
        settingsMap[ settingID ] = TpConfig( settingID, dither, args )

    return settingsMap


#------------------------------------------------------------------------------
# returns a dict mapping asset path -> AssetEntry
def parseAssetSheet( assetData ):
    assetEntries = {}

    for curRow in range( DATA_START_ROW, assetData.numRows ):
        assetPath = getInUnicode( assetData.sheetData[ curRow ][ PATH_COL_ID ] )
        tpSettingID = getInUnicode( assetData.sheetData[ curRow ][ SETTING_COL_ID ] )
        loadGroup = getInUnicode( assetData.sheetData[ curRow ][ LOADGROUP_COL_ID ] )

        # All other paths will use this format, so modify this to conform
        # (it will eventually get stripped back out when we bake to .hx)
        assetPath = "./" + assetPath

        if assetPath in assetEntries:
            print "WARNING: duplicate asset entry detected in the asset manifest: '" + assetPath + "'"
            continue

        assetEntries[ assetPath ] = AssetEntry( assetPath, tpSettingID, loadGroup )

    return assetEntries


#------------------------------------------------------------------------------
# returns a dict mapping "loadGroup_tpSetting" -> AssetGroup
def makeGroups( assetEntries, tpSettingsMap ):
    assetGroups = {}

    # Sorting by path length (shortest first) ensures that, if values aren't defined for a child dir/file,
    # we'll have already defined a value for the parent (which the child can then inherit)
    keys = sorted( assetEntries.keys(), DataMakeUtils.sortAssetKeys )

    for key in keys:

        entry = assetEntries[ key ]
        path = entry.path
        tpSettingName = entry.tpSetting
        loadGroup = entry.loadGroup

        # Inherit TP settings if needed
        if tpSettingName == "":
            tpSettingName = findTpSettingName( path, assetEntries )

        # Inherit LoadGroup if needed
        if loadGroup == "":
            loadGroup = findLoadGroup( path, assetEntries )


        # Look up the TP settings data based on the TP setting ID
        tpSetting = tpSettingsMap.get( tpSettingName, DEFAULT_TP_SETTING_ID )
        if tpSetting is None and len( tpSettingsMap ) > 0:
            tpSetting = tpSettingsMap.values()[0]

        # Create a name for this group (this will become one spritesheet)
        groupName = loadGroup + "_" + tpSettingName

        if groupName not in assetGroups:
            assetGroups[ groupName ] = AssetGroup( groupName, tpSetting )
            logging.debug( "    + Created new  asset group '" + groupName + "'"  )

        # Add the current entry to the group
        assetGroups[ groupName ].addPath( path )

    return assetGroups


############### HELPER FUNCTIONS: ################

# Attempts to find a parent's TP setting ID to inherit
def findTpSettingName( targetPath, assetEntries ):
    keys = assetEntries.keys()
    newPath = DataMakeUtils.find( targetPath, assetEntries.keys(), False )

    if newPath != targetPath and newPath in keys:
        return assetEntries[ newPath ].tpSetting
    else:
        return DEFAULT_TP_SETTING_ID


#------------------------------------------------------------------------------
# Attempts to find a parent's load group to inherit
def findLoadGroup( targetPath, assetEntries ):
    keys = assetEntries.keys()
    newPath = DataMakeUtils.find( targetPath, assetEntries.keys(), False )

    if newPath != targetPath and newPath in keys:
        loadGroup = assetEntries[ newPath ].loadGroup
        if loadGroup != "":
            return loadGroup

    return DEFAULT_LOAD_GROUP



#------------------------------------------------------------------------------
# Helper function to ensure unicode data
def getInUnicode( value ):
    uniValue = ""
    try:
        uniValue = unicode( value ).encode('utf-8')
    except UnicodeEncodeError:
        sys.stderr.write( "ERROR: Can't encode utf-8: " + repr( value ) + "\n" )
    except Exception:
        sys.stderr.write( "ERROR: Can't encode this cell (not UnicodeEncodeError): " + repr( value ) + "\n" )

    return str( uniValue )



