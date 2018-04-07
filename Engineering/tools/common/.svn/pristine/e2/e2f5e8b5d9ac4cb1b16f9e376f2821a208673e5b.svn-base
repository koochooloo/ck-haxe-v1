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
import re
import sys
import logging
import xml.etree.ElementTree as ET

from PIL import Image as PILImage

from MappedData import Map, Image, IFL, Param


SUPPORTED_IMG_FORMATS = [ ".png", ".jpg" ]
IFL_FORMAT = ".ifl"

## Given a filename, possibly including leading path,
def is9Patch( fn ):
    return re.search( r'9patch', os.path.basename( fn ) )

# Recursively iterates through a directoy of images and creates mappings between images and IFLs
def mapSourceDir( imageSourceDir ):
    theMap = Map()

    rpjFiles = []

    # First, just gather all the images and IFLs
    for dirpath, _, files in os.walk( imageSourceDir ):

        for filename in files:
            fileExt = os.path.splitext( filename )[1].lower()

            filepath = os.path.join( dirpath, filename )
            filepath = filepath.replace( "\\", "/" ) # TODO canonical (realpath?)

            if fileExt == ".rpj":
                rpjFiles.append( ( filepath, dirpath ) )

            if not shouldMap( fileExt ):
                logging.debug( "    - skipping '" + filename + "'"  )
                continue


            if fileExt == IFL_FORMAT:
                theMap.addIfl( IFL( filepath ) )
            else:
                theMap.addImage( Image( filepath ) )

            logging.debug( "    + tracking '" + filepath + "'"  )

    # Now, map IFL <--> frame images
    for iflName in theMap.ifls:
        ifl = theMap.getIfl( iflName )
        if ifl is None:
            sys.stderr.write( "Couldn't find IFL instance for '" + iflName + "' for linking\n" )
            continue
        ifl.readAndLink( theMap )

    # Finally, parse the rpj files we saw (allowing us to use the rest of the map).
    for rpjTuple in rpjFiles:
        parseRpj( theMap, rpjTuple[0], rpjTuple[1] )

    return theMap

def parseRpj( theMap, filename, root ):
    logging.debug( "Parsing RPJ: " + filename )
    root = root.replace( "\\", "/" ) # normalize slashes (TODO canonpath)
    root = re.sub( r'^[.]/', '', root ) # strip off leading ./
    tree = ET.parse( filename )
    body = tree.find( "Body" )
    parseResources( theMap, body, root + "/", root )

def parseResources( theMap, element, namePrefix, root ):
    if element is None:
        return

    newNamePrefix = namePrefix + element.get( "name", "" )
    logging.debug( "Parsing 'resources': " + newNamePrefix )

    for resource in element.findall('resource'):
        parseResource( theMap, resource, newNamePrefix, root )

    for subdir in element.findall('resources'):
        # Shouldn't need a recurision depth limit here;
        # .rpj is fairly shallow.
        parseResources( theMap, subdir, newNamePrefix, root )

def parseResource( theMap, element, namePrefix, root ):
    name = element.get( "name", "" )
    path = element.get( "path", "" )
    fullName = namePrefix + name
    logging.debug( "Parsing 'resource': " + fullName )

    if name == "" or path == "":
        sys.stderr.write( "WARNING: skipping resource, missing name or path; at or under: " + fullName + "\n" )
        return

    imageLocalPath = os.path.join( '.', os.path.join( root, path ) )
    imageLocalPath = imageLocalPath.replace( "\\", "/" ) # TODO canonical (realpath?)

    params = element.find( "params" )
    if params is not None:
        for paramElement in params:
            paramDict = paramElement.attrib.copy()
            paramDict['type'] = paramElement.tag
            #logging.debug( "Param for " + fullName + ": " + repr( paramDict ) )
            theMap.addParam( fullName, Param( paramDict, imageLocalPath, theMap ) )

    # Check if we need to generate divs.  TODO: should be per-frame?
    # Start with "first frame only", warn if multiple frames and subsequent frames have 9patch?
    if is9Patch( path ):
        parse9Patch( theMap, fullName, imageLocalPath )

def parse9Patch( theMap, fullName, imageLocalPath ):
    # Take some care to avoid overwriting if we have divs coming in from the .rpj.
    hasXDivs = False
    hasYDivs = False
    params = theMap.getParams( fullName )
    if params is not None:
        hasXDivs = any( "xDivs|-1" in elem for elem in params.keys() )
        hasYDivs = any( "yDivs|-1" in elem for elem in params.keys() )

    image = None
    ifl = theMap.getIfl( imageLocalPath )
    if ifl is not None:
        if len( ifl.image ) > 0:
            image = ifl.image[0]

    if image is None:
        image = theMap.getImage( imageLocalPath )

    if image is None:
        sys.stderr.write( "WARNING: 9patch error, couldn't find image for: " + imageLocalPath + "\n" )
        return

    logging.debug( "INFO: 9patch: found: " + imageLocalPath + "\n" )

    # TODO: avoid conversion to RGBA, it's costly
    with PILImage.open( imageLocalPath ).convert( 'RGBA' ) as rawImage:
        imgSize = rawImage.size
        imgWidth = imgSize[0]
        imgHeight = imgSize[1]

        pix = rawImage.load()

        fixed = True
        if not hasXDivs:
            xDivs = []
            for x in range( 1, imgWidth ):
                r, g, b, a = pix[ x, 0 ]
                if   a == 255 and r == 255 and g == 255 and b == 255:
                    if fixed is False:
                        fixed = True
                        xDivs.append( x - 1 )
                elif a == 255 and r ==   0 and g ==   0 and b ==   0:
                    if fixed is True:
                        fixed = False
                        xDivs.append( x - 1 )
                else:
                    sys.stderr.write( 'WARNING: 9patch unexpected pixel at [{},{}]: rgba {},{},{},{} in: {}\n'.format( x, 0, r, g, b, a, imageLocalPath ) )

            for xIdx, xDiv in enumerate(xDivs):
                theMap.addParam( fullName, Param( { "name" : "xDivs", "frame" : -1, "id" : str(xIdx), "value" : xDiv, "type" : "int" }, imageLocalPath, theMap ) )

            logging.debug( "INFO: 9patch xDivs: " + ( ','.join(str(x) for x in xDivs) ) + " in: " + imageLocalPath + "\n" )

        fixed = True
        if not hasYDivs:
            yDivs = []
            for y in range( 1, imgHeight ):
                r, g, b, a = pix[ 0, y ]
                if   a == 255 and r == 255 and g == 255 and b == 255:
                    if fixed is False:
                        fixed = True
                        yDivs.append( y - 1 )
                elif a == 255 and r ==   0 and g ==   0 and b ==   0:
                    if fixed is True:
                        fixed = False
                        yDivs.append( y - 1 )
                else:
                    sys.stderr.write( 'WARNING: 9patch unexpected pixel at [{},{}]: rgba {},{},{},{} in: {}\n'.format( 0, y, r, g, b, a, imageLocalPath ) )

            for yIdx, yDiv in enumerate(yDivs):
                # TODO: need to modify params for off-by-one trim?
                theMap.addParam( fullName, Param( { "name" : "yDivs", "frame" : -1, "id" : str(yIdx), "value" : yDiv, "type" : "int" }, imageLocalPath, theMap ) )

            logging.debug( "INFO: 9patch yDivs: " + ( ','.join(str(y) for y in yDivs) ) + " in: " + imageLocalPath + "\n" )

def shouldMap( ext ):
    return ( ext in SUPPORTED_IMG_FORMATS ) or ( ext == IFL_FORMAT )

