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
import os

import DataMakeUtils
from MappedData import Spritesheet


def initSpriteseets( mainMap, assetGroups, sheetDestDir ):
    for groupName in assetGroups:
        sheetDestPath = os.path.join( sheetDestDir, groupName )
        groupObj = assetGroups[ groupName ]

        logging.debug( "    making meta data for spritesheet " + sheetDestPath  )
        sheet = Spritesheet( groupName, groupObj, sheetDestPath )

        mainMap.addSpritesheet( sheet )


# Maps IFLS and Images to Spritesheets
def mapAssetsToSpritesheets( assets, sheetsByAssetPaths ):
    sheetKeys = sheetsByAssetPaths.keys()

    for assetName in assets:
        asset = assets[ assetName ]

        sheetKey = DataMakeUtils.find( assetName, sheetKeys, True )
        sheet = sheetsByAssetPaths[ sheetKey ]

        logging.debug( "    asset '" + assetName + "' will be placed in \n\t\tspritesheet '" + sheet.ID + "'"  )

        sheet.addAsset( asset )
        asset.spritesheet = sheet
