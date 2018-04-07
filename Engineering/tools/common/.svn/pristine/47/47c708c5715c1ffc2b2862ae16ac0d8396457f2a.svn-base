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

import argparse
import logging
import os

import AssetManifestParser
import PaistParser
import VFXParser
import ResourceMapWriter
import SourceMapper
import SpritesheetGenerator

import SpritesheetMapper
import SpritesheetModifier


# TODO: desctiption of tool


class DataMaker(object):
    def __init__( self ):
        self.theMap = {} # auditSourceDir will make this a Map (as defined in MappedData.py)
        self.groups = {} # "loadGroup_tpSetting" -> AssetGroup
        self.paistFileToSpritesheetsMap = {}

    def auditSourceDir( self, imageSourceDir ):
        print "Mapping source dir  '" + imageSourceDir + "'..."
        self.theMap = SourceMapper.mapSourceDir( imageSourceDir )
        logging.info( "...done mapping source dir!\n\n"  )

    def makeSheetGroups( self, manifestPath ):
        print "Parsing asset manifest  '" + manifestPath + "'..."
        self.groups = AssetManifestParser.parseAssetManifest( manifestPath ) # returns Dict mapping "loadGroup_tpSetting" -> AssetGroup
        logging.info( "...done parsing asset manifest!\n\n"  )

    def initSpritesheetData( self, sheetDestDir ):
        print "Initializing spritesheet data..."
        SpritesheetMapper.initSpriteseets( self.theMap, self.groups, sheetDestDir )
        logging.info( "...done initializing spritesheet data!\n\n"  )

        logging.info( "Mapping spritesheet data..."  )
        SpritesheetMapper.mapAssetsToSpritesheets( self.theMap.images, self.theMap.spritesheetsByAssetPath )
        SpritesheetMapper.mapAssetsToSpritesheets( self.theMap.ifls, self.theMap.spritesheetsByAssetPath )
        logging.info( "...done mapping spritesheet data!\n\n"  )

    def generateSpritesheets( self, sourceDir, tempDir, sheetDestDir, logPath ):
        print "Creating spritesheets..."
        SpritesheetGenerator.generateSpritesheets( sourceDir, tempDir, sheetDestDir, self.theMap.spritesheetsByID, logPath, TP_IMAGE_NAME_MOD )
        logging.info( "...done creating spritesheets!\n\n"  )

    def modifySpritesheets( self ):
        print "Fixing some image names in the spritesheet jsons..."
        SpritesheetModifier.fixImageNames( self.theMap.spritesheetsByID, TP_IMAGE_NAME_MOD )
        logging.info( "...done fixing some image names in the spritesheet jsons!\n\n"  )

        print "Adding IFLs to spritesheets..."
        SpritesheetModifier.addIFLsToSpritesheets( self.theMap.spritesheetsByID )
        logging.info( "...done adding IFLs to spritesheets!\n\n"  )

    def modifySpriteshetsForParams( self ):
        # call after modifySpritesheets
        print "Adding params to spritesheets..."
        SpritesheetModifier.addParamsToSpritesheets( self.theMap )
        logging.info( "...done adding params to spritesheets!\n\n"  )

    def parsePaistFiles( self, paistFilesSrcDir, paistFilesDestDir ):
        print "Copying Paist json files (with fixed res paths)..."
        self.paistFileToSpritesheetsMap = PaistParser.fixResPathsAndCopy( paistFilesSrcDir, paistFilesDestDir, self.theMap )
        logging.info( "...done fixing and copying Paist json files!\n\n"  )
        # paistFileToSpritesheetsMap will be used to write PaistManifest.hx

    def writePaistManifest( self, manifestDest, paistDest ):
        print "Writing Paist Manifest..."
        PaistParser.writePaistManifest( manifestDest, self.paistFileToSpritesheetsMap, paistDest )
        logging.info( "...done writing Paist Manifest!\n\n"  )

    def writeVFXManifest( self, manifestDest, vfxSrc ):
        print "Writing VFX Manifest..."
        VFXParser.writeVFXManifest( manifestDest, vfxSrc )
        logging.info( "...done writing VFX Manifest!\n\n"  )

    def writeResourceMap( self, resMapPath ):
        print "Writing Resource Map..."
        ResourceMapWriter.writeResourceMap( resMapPath, self.theMap.spritesheetsByID )
        logging.info( "...done writing Resource Map!\n\n"  )



if __name__ == "__main__":
    parser = argparse.ArgumentParser( description='Data make script for haxe projects.' )

    parser.add_argument( 'assetManifestPath', action='store', help='Specify the path to the Asset Manifest, which specifies what TP settings and load groups to use' )
    parser.add_argument( 'imageSourceDir', action='store', help='Specify the directory containing images that should be turned into spritesheets' )
    parser.add_argument( 'spritesheetDestDir', action='store', help='Specify the path to the directory where spritesheets should be created' )
    parser.add_argument( 'imgTempDir', action='store', help='Specify the path to temporarily copy images to when creating spritesheets' )
    parser.add_argument( 'tpTempLogPath', action='store', help='Specify the path to a temporary file that will be used to buffer TP output' )
    parser.add_argument( 'paistSrcDir', action='store', help='Specify the path where this project\'s Paist json files live' )
    parser.add_argument( 'paistDestDir', action='store', help='Specify a temporary directory to place modified Paist files' )
    parser.add_argument( 'paistManifestDest', action='store', help='Specify the file that will be used to write out the Paist Manifest to' )
    parser.add_argument( 'resourceMapDest', action='store', help='Specify the file that will be used to write out the Resource Map to' )
    parser.add_argument( 'vfxManifestDest', action='store', help='Specify the file that will be used to write out the VFX Manifest to' )
    parser.add_argument( 'vfxSrcDir', action='store', help='Specify the path where this project\'s VFX json files live' )
    parser.add_argument( '-makeSpritesheets', action='store', default="0", help='(Optional) Specify this to generate spritesheets; leave this off to process existing sheets' )
    parser.add_argument( '-v', '--verbose', action='count', default=0, help='increase verbosity' )

    args = parser.parse_args()

    # from http://stackoverflow.com/a/34065768
    loglevels = [logging.WARNING, logging.INFO, logging.DEBUG]
    loglevel = loglevels[min(len(loglevels)-1,args.verbose)]  # capped to number of levels
    logging.basicConfig( level=loglevel, format='%(levelname)s: %(message)s' )

    TP_IMAGE_NAME_MOD = "TP_NO_ANIM_NAME_MOD"

    startDir = os.path.abspath( "./" )

    maker = DataMaker()

    maker.auditSourceDir( args.imageSourceDir )
    maker.makeSheetGroups( args.assetManifestPath )
    maker.initSpritesheetData( args.spritesheetDestDir )

    if args.makeSpritesheets != "0":
        maker.generateSpritesheets( args.imageSourceDir, args.imgTempDir, args.spritesheetDestDir, args.tpTempLogPath )
        maker.modifySpritesheets()
        maker.modifySpriteshetsForParams()
        # Spritesheet generation jumps between a few dirs; ensure we're back where we started
        os.chdir( startDir )



    maker.parsePaistFiles( args.paistSrcDir, args.paistDestDir )
    maker.writePaistManifest( args.paistManifestDest, args.paistDestDir )
    maker.writeVFXManifest( args.vfxManifestDest, args.vfxSrcDir )
    maker.writeResourceMap( args.resourceMapDest )


