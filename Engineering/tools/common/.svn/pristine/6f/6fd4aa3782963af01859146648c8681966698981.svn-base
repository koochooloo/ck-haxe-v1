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
import pickle
import re
import sys
import logging
import distutils.util
import operator

from collections import defaultdict

#################################################################################
class Map(object):
    def __init__( self ):
        self.images = {}        # map image.relPath -> Image
        self.ifls = {}          # map ifl.relPath -> IFL
        # map relPath -> paramName -> paramFrame -> [ Param ... ] (autovivifying)
        self.params = defaultdict( lambda: defaultdict( lambda: defaultdict( list ) ) )
        self.spritesheetsByID = {}
        self.spritesheetsByAssetPath = {}

    def save( self, dest ):
        output = open( dest, 'wb' )
        pickle.dump( self, output, pickle.HIGHEST_PROTOCOL )
        output.close()

    def load( self, source ):
        pklFile = open( source, 'rb' )
        data = pickle.load( pklFile )
        pklFile.close()

        self.images = data.images
        self.ifls = data.ifls
        self.spritesheetsByID = data.spritesheetsByID
        self.spritesheetsByAssetPath = data.spritesheetsByAssetPath

    def addParam( self, relPath, param ):
        paramName = param.name;
        paramFrame = param.frame;

        logging.debug( "adding param: {} with name/frame: {}/{}".format( relPath, paramName, paramFrame ) )
        self.params[ relPath ][ paramName ][ paramFrame ].append( param )

    def addImage( self, image ):
        if image.relPath in self.images:
            sys.stderr.write( "WARNING: we're already tracking image '" + image.relPath + "'\n" )
            return
        self.images[ image.relPath ] = image

    def addIfl( self, ifl ):
        if ifl.relPath in self.ifls:
            sys.stderr.write( "WARNING: we're already tracking IFL '" + ifl.relPath + "'\n" )
            return
        self.ifls[ ifl.relPath ] = ifl


    def addSpritesheet( self, sheet ):
        if sheet.ID in self.spritesheetsByID:
            sys.stderr.write( "WARNING: we're already tracking spritesheet '" + sheet.ID + "'\n" )
        else:
            self.spritesheetsByID[ sheet.ID ] = sheet
            logging.debug( "        its ID: " + sheet.ID  )

        logging.debug( "        its paths: "  )
        for path in sheet.manifestData.paths:
            if path in self.spritesheetsByAssetPath:
                sys.stderr.write( "WARNING: we're already tracking spritesheet '" + sheet.ID + "'\n" )
                continue
            self.spritesheetsByAssetPath[ path ] = sheet
            logging.debug( "            : " + path  )

    def getParams( self, relPath ):
        # avoid autovivifying on get
        if relPath in self.params:
            return self.params[ relPath ]
        else:
            return None

    def getIfl( self, iflName ):
        if iflName in self.ifls:
            return self.ifls[ iflName ]
        else:
            return None

    def getImage( self, imageName ):
        if imageName in self.images:
            return self.images[ imageName ]
        else:
            return None

    def findSheetByResource( self, resourceName ):
        for key in self.ifls.keys():
            if self.isMatch( resourceName, key ):
                return self.ifls[ key ].spritesheet

        for key in self.images.keys():
            if self.isMatch( resourceName, key ):
                return self.images[ key ].spritesheet

        return None

    def findResourceRelPath( self, resourceName ):
        for key in self.ifls.keys():
            if self.isMatch( resourceName, key ):
                return self.ifls[ key ].relPath

        for key in self.images.keys():
            if self.isMatch( resourceName, key ):
                return self.images[ key ].relPath

        return resourceName

    @staticmethod
    def isMatch( resourceName, toCheck ):
        findPos = toCheck.find( resourceName )

        # First, eliminate any obvious non-matches
        if findPos == -1:
            return False

        # If basic match is found, rule out false positives
        # (eg if we're looking for "2d/results/defense", don't match "2d/results/defenseSmall")
        namelen = len( resourceName )
        postfix = toCheck[findPos + namelen:]
        ext = os.path.splitext( toCheck )[1]

        # Exact match: everything after resourceName in toCheck is the extension
        # (eg "2d/results/defense" should match "2d/results/defense.png")
        if postfix == ext:
            return True

        # Button match: only match against the _up state
        # (eg "2d/results/defense" should match "2d/results/defense_up.png"
        #  but not "2d/results/defense_down.png"; this is because Paist defaults
        #  to using the _up state for displaying buttons)
        if postfix.lower() == "_up.png":
            return True

        # No match found
        return False


#################################################################################
# Represents the meta-data corresponding to a single parameter (name + frame + id)
# See https://wiki.1stplayable.com/index.php/Web/Haxe/Reference_Points_and_Boxes_RFC
class Param(object):
    def __init__( self, paramDict, imageLocalPath, theMap ):
        ifl = theMap.getIfl( imageLocalPath )

        for key in paramDict:
            if key == 'paramType':
                # Skip "paramType", it's purely for Oriolo at the moment.
                continue
            val = paramDict[key]
            if key == 'id' or key == 'frame' or key == 'lastFrame':
                val = int( val ) # s16
            if ifl is not None and key == 'frame':
                val = ifl.translateImageIdxToAnimIdx( val, False )
            if ifl is not None and key == 'lastFrame':
                val = ifl.translateImageIdxToAnimIdx( val, True )
            setattr( self, key, val )

        # Clean up value types for more compact storage.
        if self.type == 'bool':
            self.value = distutils.util.strtobool( str( self.value ).lower() ) # bool
        elif self.type == 'int':
            self.value = int( self.value ) # int
        elif self.type == 'vector':
            self.x = int( self.x ) # s32
            self.y = int( self.y ) # s32
        elif self.type == 'box':
            self.x = int( self.x ) # s32
            self.y = int( self.y ) # s32
            self.width = int( self.width ) # s32
            self.height = int( self.height ) # s32

    def __getattr__( self, name ):
        try:
            return object.__getattribute__( self, name )
        except AttributeError:
            if re.match( r"id|frame|lastFrame", name ) != None:
                # optional parameters return -1 when not found
                return -1
            else:
                raise


#################################################################################
# Represents the meta-data corresponding to a single spritesheet
class Spritesheet(object):
    def __init__( self, ID, manifestData, filepath ):
        self.ID = ID
        self.relPath = filepath
        self.jsonFilePath = "not set"
        self.manifestData = manifestData # AssetGroup object; contains TP settings and paths of items that will be included in this sheet
        self.assets = {} # IFLs and Images

    def addAsset( self, asset ):
        self.assets[ asset.relPath ] = asset


#################################################################################
# Represents an individual .png or .jpg, as well as its associated meta-data
class Image(object):
    def __init__( self, filepath ):
        self.relPath = filepath
        self.fullOsPath = os.path.abspath( filepath )
        self.spritesheet = None
        self.iflOwner = None  #not all images will have this



#################################################################################
# Represents an individual IFL animation, as well as its associated meta-data
class IFL(object):
    def __init__( self, filepath ):
        self.relPath = filepath
        self.fullOsPath = os.path.abspath( filepath )
        self.images = []
        self.frameCounts = []
        self.spritesheet = None

    def readAndLink( self, theMap ):
        iflParentDir = os.path.split( self.relPath )[ 0 ]
        iflFile = open( self.fullOsPath, 'r' )

        logging.debug( "\n    IFL '" + self.relPath + "', which lives in '" + iflParentDir + "', contains: "  )

        for lineNum, line in enumerate( iflFile, 1 ):
            line = line.strip() # trim whitespaces, including the new line at the end
            if not line:
                continue

            # Parse each line; split path and frame hold
            lineParts = re.split(r'\s+(?=[\S]*$)', line)
            numLineParts = len( lineParts )
            if numLineParts > 2 or numLineParts <= 0:
                raise ValueError(
                    self.relPath + os.linesep
                    + "Error in Line " + str( lineNum ) + ": " + line + os.linesep
                    + "ifl line may include a file name followed by an optional number that specifies the number of frames" )

            framePath = iflParentDir + "/" + lineParts[0]
            frameDelay = lineParts[1] if numLineParts > 1 else 1

            logging.debug( "        " + framePath  )

            frameImg = theMap.getImage( framePath )
            if frameImg is None:
                sys.stderr.write( "WARNING: cannot find IFL frame image '" + framePath + "'\n" )
                continue

            self.images.append( frameImg )
            self.frameCounts.append( frameDelay )
            frameImg.iflOwner = self


        iflFile.close()

    # Sum all the delays leading up to (and possibly including) the given image index.
    # Useful for converting from an image index into a hxlib-internal frame count index for SpritesheetAnim.
    def translateImageIdxToAnimIdx( self, imageIdx, atEndOfDelay ):
        if atEndOfDelay:
            # Add one to the slice index to include this frame's delays, but
            # subtract one from the final result because we want to return
            # the last frame (inclusive) that will display with this image.
            # This corresponds to the inclusive nature of the 'lastFrame' param.
            return reduce( operator.add, [int( x ) for x in self.frameCounts[:imageIdx+1] ], 0 ) - 1
        else:
            return reduce( operator.add, [int( x ) for x in self.frameCounts[:imageIdx] ], 0 )
