##
## Copyright (C) 2015-2017, 1st Playable Productions, LLC. All rights reserved.
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
import re
import sys
import json
import logging

#from operator import methodcaller
from collections import defaultdict

from MappedData import IFL


TP_CREDIT_STR = "\"Created with TexturePacker (https://www.codeandweb.com/texturepacker) for EaselJS\""
FP_MOD_STR = "\"Modified by 1st Playable Productions using https://svn.1stplayable.com/hxlib/trunk/tools/spritesheet/SpritesheetModifier.py\""

ANIM_BLOCK_START_STR = "\"animations\": {"


def writeFile( outfile, outstr ):
    # Disabled.   No need for credits in data!  It's just bloat.
    #if outstr.find( FP_MOD_STR ) == -1:
    #    location = outstr.find( TP_CREDIT_STR )
    #    if location == -1:
    #        sys.stderr.write( "WARNING: Can't find where to add 'modified by 1P' string to spritesheet json\n" )
    #    else:
    #        location = location + len( TP_CREDIT_STR )
    #        outstr = outstr[:location] + ",\n        " + FP_MOD_STR + "\n" + outstr[location:]

    outfile.write( outstr )


def fixImageNames( spritesheetsByID, tpImgNameMod ):
    for key in spritesheetsByID.keys():
        sheet = spritesheetsByID[ key ]
        logging.debug( "    checking: " + sheet.jsonFilePath  )

        jsonPath = os.path.abspath( sheet.jsonFilePath )
        jsonFile = open( jsonPath, 'r' )

        strToWrite = ""

        for line in jsonFile:
            if line.find( tpImgNameMod ) != -1:
                newline = line.replace( tpImgNameMod, "_" )
                line = newline
            strToWrite += line

        jsonFile.close()

        jsonFile = open( jsonPath, 'w' )
        writeFile( jsonFile, strToWrite )
        jsonFile.close()


# call *AFTER* addIFLsToSpritesheets for full operation
def addParamsToSpritesheets( theMap ):
    logging.debug( "adding params" )
    for sheet in theMap.spritesheetsByID.values():
        jsonPath = sheet.jsonFilePath
        logging.debug( "adding params to sheet: " + str( jsonPath ) )
        try:
            jsonAbsPath = os.path.abspath( jsonPath )
            with open( jsonAbsPath, 'r' ) as jsonFile:
                jsonObj = json.load( jsonFile )

            for animationName in jsonObj['animations'].keys():
                logging.debug( "adding params to anim: " + str( animationName ) )
                try:

                    # Fixup to be closer to the TexturePacker 4.2.0 format if needed.
                    animationVal = jsonObj['animations'][animationName]
                    if isinstance( animationVal, list ):
                        # Convert to from array (aka list) object (aka dict).
                        jsonObj['animations'][animationName] = { 'frames' : animationVal }

                    paramsDict = theMap.getParams( animationName )
                    if ( paramsDict is None ) or ( len( paramsDict ) == 0 ):
                        # No params?  No mods needed.
                        logging.debug( "skipping {}: no params.".format( animationName ) )
                        continue

                    # Disabled.  This would write the "center" parameter into the "frame" row.
                    # Frames may be shared between IFLs with different parameters, though.
                    # To avoid possible conflicts, we keep the data out of band, key'd to animation.
                    #centerParam = paramsDict.get( "center|-1|-1" )
                    #if centerParam != None:
                    #    frameList = jsonObj['animations'][animationName]['frames']
                    #    frameList[5] = centerParam.x
                    #    frameList[6] = centerParam.y
                    #    logging.debug( "centerParam for {}: {}, {}".format( animationName, centerParam.x, centerParam.y )

                    # A few more levels of indirection here.
                    # The type of values is Param, but that can have arbitrary fields:
                    # it requires name,
                    # optionally has frame/id/lastFrame,
                    # and requires a set of: value (int/bool/string/event); x,y (vector); or x,y,width,height (box)...
                    #
                    # Haxe doesn't like inconsitent dict types in array (for anonymous structures at least),
                    # so we want to emit these a few levels deeper.
                    # Nice side effect is easy lookups / sorting -- but we can also do that with:
                    #    for param in sorted( paramsDict.values, key=methodcaller('getKey') )
                    # Bad side effect is duplication of data for name, possibly frame, and possibly id.
                    #
                    # Note __dict__ will omit frame/id/lastFrame if not present...
                    # But we can rebuild those on the other side.
                    jsonObj['animations'][animationName][ 'params' ] = defaultdict( lambda: defaultdict( list ) ) # autovivify first two layers
                    outDict = jsonObj['animations'][animationName][ 'params' ]
                    for paramName in paramsDict:
                        inNameDict = paramsDict[ paramName ]
                        outNameDict = outDict[ paramName ]
                        for paramFrame in inNameDict:
                            inFrameList = inNameDict[ paramFrame ]
                            outFrameList = outNameDict[ paramFrame ]
                            for inParam in inFrameList:
                                outFrameList.append( inParam.__dict__ )

                except Exception as animE:
                    logging.warning( "failure to find/manipulate animation {} in sheet {} for params: {}".format( str( animationName ), str( jsonPath ), str( animE.message ) ) )
                    raise

            # Bonus: rid ourselves of 'texturepacker' key, it's useless for engine and is just bloat.
            if 'texturepacker' in jsonObj:
                del jsonObj['texturepacker']

            # Write out modified spritesheet, compactly.
            with open( jsonAbsPath, 'w' ) as jsonOutFile:
                json.dump( jsonObj, jsonOutFile, sort_keys=True, indent=None, separators=(',', ':') ) # compact representation

        except Exception as sheetE:
            logging.error( "failure to parse or rewrite sheet " + str( jsonPath ) + ": " + str( sheetE.message ) )
            raise

def addIFLsToSpritesheets( spritesheetsByID ):
    for key in spritesheetsByID.keys():
        sheet = spritesheetsByID[ key ]
        logging.debug( "    checking: '" + str( sheet.jsonFilePath ) + "'..."  )

        for assetname in sheet.assets:
            asset = sheet.assets[ assetname ]

            if isinstance( asset, IFL ):
                logging.debug( "        found IFL: '" + asset.relPath + "'"  )
                addIFL( asset, sheet ) # TODO: way too much work to reopen and close file each time


def addIFL( ifl, sheet ):
    jsonPath = os.path.abspath( sheet.jsonFilePath )
    jsonFile = open( jsonPath, 'r' )
    jsonStr = jsonFile.read()
    jsonFile.close()

    frames = []

    # Find line of the json corresponding to each frame image in the IFL
    for image in ifl.images:
        imgRelPath = image.relPath.replace( "./", "" ) # TODO only at start # TODO canonical (realpath?)
        imgRelPath = os.path.splitext( imgRelPath )[0]

        pathLocStart = jsonStr.find( imgRelPath ) # TODO multiple matches
        if pathLocStart == -1:
            sys.stderr.write( "WARNING: couldn't find frame: " + imgRelPath + "\n" )
            continue

        # Find the frame index for this frame image
        pattern = re.compile( imgRelPath + r'": ({ "frames": )?\[(?P<digits>\d+)\]' ) # TODO: quote imgRelPath (perl \Q$imgRelPath\E style)
        match = pattern.search( jsonStr, pathLocStart ) # TODO multiple matches
        if match != None:
            frames.append( [ match.group( "digits" ), ifl.frameCounts[ ifl.images.index( image ) ] ] )
        else:
            sys.stderr.write( "WARNING: could not find frame index for " + imgRelPath + "\n" )

    # Find location in file to add this IFL to
    animBlockLocation = jsonStr.find( ANIM_BLOCK_START_STR )
    if animBlockLocation == -1:
        sys.stderr.write( "WARNING: Could not find anim block in file to add this IFL to: " + ifl.relPath + "\n" )
        return

    animListStart = animBlockLocation + len( ANIM_BLOCK_START_STR )
    newStr = jsonStr[:animListStart]

    # Write ifl anim name
    iflPath = ifl.relPath.replace( "./", "" )
    iflPath = os.path.splitext( iflPath )[0]
    iflString = "    \"" + iflPath + "\": ["

    #logging.debug( "ifl at path: " + iflPath )

    # Write each frame index
    first = True
    for frame in frames:
        numFrames = int( frame[ 1 ] )

        for _ in range( 0, numFrames ):
            if not first:
                iflString += ", "
            first = False
            iflString += str( frame[ 0 ] )

    # Write eol chars
    iflString += "],"

    # Finish putting the file back together, and write out
    newStr += "\n" + iflString + jsonStr[animListStart:]
    jsonFile = open( jsonPath, 'w' )
    writeFile( jsonFile, newStr )
    jsonFile.close()

    logging.debug( "            adding the following line to the json: '" + iflString + "'"  )


