##
## Copyright (C) 2016, 1st Playable Productions, LLC. All rights reserved.
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
import argparse






if __name__ == "__main__":
    parser = argparse.ArgumentParser( description='Script to fix PaistManifest.hx (data_make output) to support 4:3 and 16:9 assets' )
    parser.add_argument( 'imageSourceDir', action='store', help='Specify the directory containing the spritesheets' )
    parser.add_argument( 'manifestPath', action='store', help='Specify the PaistManifest file' )
    args = parser.parse_args()

    assetMap = {}

    # Find all of the 16:9 versions of the files, and map
    # to non-aspect-specified name (eg map BG1_16_9_BG_DEFAULT -> BG1_BG_DEFAULT).
    # The 4:3 files will be handled later...
    for dirpath, dirs, files in os.walk( args.imageSourceDir ):
        for fullname in files:
            filename, ext = os.path.splitext( fullname )

            # There is always a png-json pair; only need to process one per pair
            if ext.lower() == ".json":
                continue

            # Skip anything that's not a 16:9 file
            if filename.find( "_16_9" ) == -1:
                continue;

            genericName = filename.replace( "_16_9", "" )
            assetMap[ genericName ] = filename


    # Parse the manifest and update to use 16:9 assets
    manifest = open( os.path.abspath( args.manifestPath ), 'r' )
    outstr = ""
    for line in manifest:
        for assetName in assetMap:
            # Update addLib calls to use 16:9 versions
            if line.find( assetName ) != -1:
                line = line.replace( assetName, assetMap[ assetName ] )

            # Rename init to specify asset version to init
            if line.find( "init()" ) != -1:
                line = line.replace( "init()", "init169()" )

        outstr += line
    manifest.close()

    # Duplicate the 16:9 code, but substitute in 4:3
    startIdx = outstr.find( "public static function init169():Void" )
    endIdx = outstr.rfind( "}" )

    initstr = outstr[ startIdx : endIdx ]
    initstr = initstr.replace( "_16_9", "_4_3" )
    initstr = initstr.replace( "init169()", "init43()" )

    outstr = outstr[:endIdx] + "\t" + initstr + outstr[endIdx:]

    # Write it all back out
    manifest = open( os.path.abspath( args.manifestPath ), 'w' )
    manifest.write( outstr )

    
