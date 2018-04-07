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


def writeResourceMap( resMapPath, spritesheets ):
    writer = ResourceMapWriter( resMapPath )
    writer.writeClassBegin()

    for key in spritesheets.keys():
        sheet = spritesheets[ key ]

        sheetpath = sheet.relPath.replace( "..\\assets\\", "" ) # TODO: no hard-coding "assets"...
        sheetpath = sheetpath.replace( "\\", "/" ) + ".json"

        for asset in sorted(sheet.assets):
            assetpath = asset.replace( "\\", "/" )
            assetpath = assetpath.replace( "./", "" )
            writer.writeEntry( assetpath, sheetpath )

            shortname = os.path.splitext( assetpath )[ 0 ]
            if shortname != assetpath:
                writer.writeEntry( shortname, sheetpath )

    writer.writeClassEnd()
    writer.closeOutputFile()


class ResourceMapWriter(object):
    def __init__( self, resMapPath ):
        self.outputFile = open( resMapPath, 'w' )

    def writeClassBegin( self ):
        self.outputFile.write( "package assets;\n\n" )

        self.outputFile.write( "import haxe.ds.StringMap;\n" )
        self.outputFile.write( "import com.firstplayable.hxlib.loader.IResourceMap;\n" )

        self.outputFile.write( "\n//WARNING! THIS CLASS IS AUTO-GENERATED BY TOOLS. YOUR CHANGES WILL BE OVERWRITTEN." )
        self.outputFile.write( "\nclass ResourceMap implements IResourceMap\n{\n" )

        self.outputFile.write( "	public var INVALID:String = \"invalid\";\n" )
        self.outputFile.write( "	private var m_map:StringMap<String>; \n\n" )

        self.outputFile.write( "	public function new()\n" )
        self.outputFile.write( "	{\n" )
        self.outputFile.write( "		m_map = new StringMap<String>();\n" )
        self.outputFile.write( "		init();\n" )
        self.outputFile.write( "	}\n\n" )

        self.outputFile.write( "	public function getSheetPath( assetName:String ):String\n" )
        self.outputFile.write( "	{\n" )
        self.outputFile.write( "		if ( !m_map.exists( assetName ) ) { return INVALID; }\n" )
        self.outputFile.write( "		else { return m_map.get( assetName ); }\n" )
        self.outputFile.write( "	}\n\n" )

        self.outputFile.write( "	public function init():Void\n" )
        self.outputFile.write( "	{\n" )

    def writeEntry( self, assetPath, sheetPath ):
        #assetPath = assetPath[assetPath.find("2d\\"):]
        #assetPath = assetPath.replace( "\\", "/" )
        #assetName = os.path.splitext( assetName )[0]
        self.outputFile.write( "		m_map.set( \"" + assetPath + "\", \"" + sheetPath + "\" );\n" )

    def writeClassEnd( self ):
        self.outputFile.write( "	}\n" )
        self.outputFile.write( '}' )

    def closeOutputFile( self ):
        self.outputFile.close()

