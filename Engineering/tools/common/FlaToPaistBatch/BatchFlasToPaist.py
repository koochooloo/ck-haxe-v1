##
## Copyright (C) 2014, 1st Playable Productions, LLC. All rights reserved.
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
import sys
import os
import argparse
#import SVNUtils
import subprocess

MIN_ARGS = 2

def processFla( fla, exportPath ):
    # Fix paths
    fla = fla.replace( "\\", "/" )
    fla = "file:///" + fla
    exportPath = exportPath.replace( "\\", "/" )
    exportPath = "file:///" + exportPath
    
    pngDir = exportPath + "/2d/"
    jsonDir = exportPath + "/json/"
    
    print( "New paths to use: " + fla )
    print( "Export Paist project to: " + exportPath )
    # Write script:
    # Open file
    print( "Generating temporary JSFL file for flash..." )

    scriptPtr = open( "DoExport.jsfl", 'w' )
    scriptPtr.write( "var pngDir = \"" + pngDir + "\";\n" )
    scriptPtr.write( "var jsonDir = \"" + jsonDir + "\";\n" )
    scriptPtr.write( "xjsfl.init(this);\n" )
    scriptPtr.write( "fl.openDocument(\"" + fla + "\");\n" )

    # Copy the body of the jsfl script
    jsfFile = open( "JSFL/ExportToPaist.jsfl", 'r' );
    filestr = jsfFile.read()
    jsfFile.close();
    scriptPtr.write( filestr )


    # Ecexute the script
    scriptPtr.close()
    print( "Executing temporary JSFL file..." )
    try:
        subprocess.call( "DoExport.jsfl", shell=True )
    except:
        print( "    Error type: " + str( sys.exc_info()[0] ) )
        print( "    Error val : " + str( sys.exc_info()[1] ) )
    os.remove( "DoExport.jsfl" )
    

if __name__ == "__main__":
    parser = argparse.ArgumentParser( description='Runs a module on a directory of flas and re-exports them.' )
    parser.add_argument( 'args',nargs='*' )
    options = parser.parse_args()

    numArgs = len( options.args )

    if numArgs < MIN_ARGS:
        print( "Insufficient number of arguments. Expected: fla path, swf path." )
        print( "    Optionally: module to execute, args for that module" )
        exit

    flaPath = os.path.abspath( options.args.pop( 0 ) )
    assetPath = os.path.abspath( options.args.pop( 0 ) )

    print( "\nflaPath " + flaPath )
    print( "\nassetPath " + assetPath )

    if numArgs > MIN_ARGS:
        subprocess.call( options.args, shell=True )
    
    # Get names and lock all flas
    for root, dirs, files in os.walk( flaPath ):
        for filename in files:
            splitName = os.path.splitext( filename )
            if splitName[1] == ".fla":
                fullpath = os.path.join( root, splitName[0] )
                fullpath += ".fla"
                print( "\n\n\nProcessing " + fullpath )
                #SVNUtils.getLockOnFile( fullpath )
                processFla( fullpath, assetPath )
                print( "Done processing " + fullpath )

#    os.remove( "temp.txt" );

    
