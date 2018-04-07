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

import os
import logging
import re
import shutil
import subprocess
import sys
import time

from PIL import Image as PILImage
from MappedData import Image, IFL
from SourceMapper import is9Patch


# Multipack is not currently supported by haxelib
ALLOW_MULITPACK = False


#TODO: make this a class to prevent eg tpImageNameMod pass all over the place

def generateSpritesheets( sourceDir, tempDir, sheetDestDir, spritesheets, tpLogPath, tpImageNameMod ):
    sourceDir = os.path.abspath( sourceDir )
    sheetDestDir = os.path.abspath( sheetDestDir )

    # Redirect TP output, since it will fight with print for stdout otherwise
    # (without this, TP output will be jumbled in with print output)
    tpLogPath = os.path.abspath( tpLogPath )

    tempDir = os.path.abspath( tempDir )
    clearTempDir( tempDir, sourceDir )

    logging.debug( "    sourceDir    : '" + sourceDir + "'"  )
    logging.debug( "    tempDir      : '" + tempDir + "'"  )
    logging.debug( "    sheetDestDir : '" + sheetDestDir + "'"  )

    for sheetname in spritesheets:
        sheet = spritesheets[ sheetname ]
        logging.debug( "\n    Making: " + sheet.ID  )

        # copy images to a temp directory; this is needed because
        # TP is not great at pulling individual images in from different dirs
        copyFilesToTemp( tempDir, sheet, tpImageNameMod )

        # set up args
        sheetDest = sheetDestDir + os.sep + sheetname
        tpCmd = sheet.manifestData.tpConfig.command
        tpArgs = getTpArgs( sheetDest, tpCmd, tempDir )
        sheet.jsonFilePath = sheetDest + ".json"

        sys.stderr.write( "\n   Making " + sheetname )
        #sys.stderr.write( "\n   args " + tpArgs.join( " " ) )

        # run TP
        runTP( tpArgs, tpLogPath )

        # delete temp, and if we fail try again up to three times
        for _ in range( 0, 3 ):
            try:
                clearTempDir( tempDir, sourceDir )
                break
            except:
                logging.debug( "\n    Error clearing the temp dir, waiting 5 seconds before trying again..." )
                time.sleep( 5 )
                continue

    sys.stderr.write( "\n\n" )



def clearTempDir( tempDir, sourceDir ):
    if os.path.isdir( tempDir ):
        os.chdir( sourceDir ) #make sure we're not in the dir we're deleting
        shutil.rmtree( tempDir )


def copyFilesToTemp( tempDir, sheet, tpImageNameMod ):
    for assetname in sheet.assets:
        asset = sheet.assets[ assetname ]

        if isinstance( asset, Image ):
            copyFile( asset, tempDir, tpImageNameMod )
        elif isinstance( asset, IFL ):
            for frame in asset.images:
                copyFile( frame, tempDir, tpImageNameMod )
        else:
            sys.stderr.write( "WARNING: spritesheet '" + sheet.ID + "' has unknown asset: " + str(asset) + "\n" )


def copyFile( image, destDir, tpImageNameMod ):
    imgRelPath = fixRelPath( image.relPath, tpImageNameMod )
    destPath = os.path.join( destDir, os.path.relpath( imgRelPath ) )
    logging.debug( "        copying '" + imgRelPath + "' ---> '" + destPath + "'"  )

    destDir = os.path.split( destPath )[0]
    if not os.path.exists( destDir ):
        os.makedirs( destDir )

    if is9Patch( image.relPath ):
        trim9Patch( image.fullOsPath, destPath )
    else:
        shutil.copy2( image.fullOsPath, destPath )

def trim9Patch( imageFullOsPath, destPath ):

    logging.debug( "INFO: 9-slice trim from: '" + imageFullOsPath + "' to: " + destPath + "\n" )

    with PILImage.open( imageFullOsPath ) as rawImage:
        imgSize = rawImage.size
        imgWidth = imgSize[0]
        imgHeight = imgSize[1]

        newWidth = imgWidth - 1
        newHeight = imgHeight - 1

        with PILImage.new( rawImage.mode, (newWidth,newHeight) ) as newImage:
            newImage.paste( rawImage, (-1,-1) )
            newImage.save( destPath )


def fixRelPath( path, tpImageNameMod ):
    # TP will automatically create animations out of files matching the pattern:  image-name-prefix_####.ext
    # eg: "myImage_001."png, "myImage_002.png" become an animation named "myImage"
    # We want to retain control over what are counted as animations, so temporarily mangle the name to confuse TP
    # New name replaces the '_' before the digits with TP_IMAGE_NAME_MOD
    match = re.search( r'.+(?P<digits>_\d+)\.[a-zA-Z]+', path )
    if match != None:
        matchLoc = match.start( "digits" )
        path = path[:matchLoc] + tpImageNameMod + path[matchLoc+1:]

    return path



def getTpArgs( spritesheetPath, imageSettings, srcDir ):
    args = []

    args.append( "TexturePacker" )

    # defines where the sheet's png(s) will be placed
    args.append( "--sheet" )
    if ALLOW_MULITPACK:
        args.append( spritesheetPath + "{n}.png" )
        args.append( "--multipack" )
    else:
        args.append( spritesheetPath + ".png" )

    # defines where the sheet's json will be placed
    args.append( "--data" )
    args.append( spritesheetPath + ".json" )

    # Various settings; see https://www.codeandweb.com/texturepacker/documentation#command-line
    # These (and more) can be migrated to your project's AssetManifest as needed;
    # for more info, see (TODO: wiki link; for now see danielle@1stplayable.com)
    args.append( "--format" )
    args.append( "easeljs" )
    args.append( "--algorithm" )
    args.append( "MaxRects" )
    args.append( "--maxrects-heuristics" )
    args.append( "Best" )
    args.append( "--pack-mode" )
    args.append( "Best" )
    args.append( "--border-padding" )
    args.append( "0" )

    # mostly for debugging
    # TODO: enable this for Jenkins autobuilds
    args.append( "--verbose" )

    # Custom commands specified in your project's Asset Manifest
    commands = imageSettings.split()
    for cmd in commands:
        # TODO: temp code to not get stuck waiting on TP while working on tool
        if str(cmd) == "3" or str(cmd) == "5":
            cmd = "1"
        args.append( cmd )

    args.append( srcDir )

    return args


def runTP( args, tpLogPath ):
    tpLog = open( tpLogPath, 'w' )

    ret = subprocess.call( args, stdout=tpLog, stderr=tpLog )

    tpLog.close()

    #tpLog = open( tpLogPath, 'r' )
    #logging.debug( "\n\n        --- Begin TP output for this sheet ---\n"  )
    #for line in tpLog:
    #    logging.debug( "            " + line )
    #logging.debug( "        ---End TP output for this sheet ---\n\n"  )
    #tpLog.close()

    if ret != 0:
        sys.stderr.write( "\n!!!ERROR: TexturePacker failed.\n" )
        sys.exit( 1 )

    logging.debug( "\n   Finished with this spritesheet!"  )


