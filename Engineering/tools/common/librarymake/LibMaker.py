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
import os

class LibMaker( object ):
    
    def __init__( self ):
        self.sourceDir = os.path.abspath( "../../../assets/" )
        self.srcDirLen = len( self.sourceDir ) + 1
        self.init()
    
    def init( self ):
        self.output = ""
        self.numLibs = -1
        self.TAB = "  "
        self.LINE = "\n"
    
    def createModel( self ):
        self.init()
        outSrc = self.sourceDir + "/manifest.def"
        print( "creating model file: " + outSrc )
        self.walkModel()
        outFile = open( outSrc, 'w' )
        outFile.write( self.output )
        outFile.close()
    
    def createJSON( self ):
        self.init()
        outSrc = self.sourceDir + "/manifest.json"
        print( "creating json file: " + outSrc )
        self.walkJSON()
        outFile = open( outSrc, 'w' )
        outFile.write( self.output )
        outFile.close()
    
    def walkModel( self ):
        for root, dirs, files in os.walk( self.sourceDir ):
            dirs.sort(); # traverse subdirs in alpha order
            self.numLibs += 1
            self.output += "libs[" + str( self.numLibs ) + "]" + self.LINE
            
            if self.numLibs == 0:
                self.output += self.TAB + "src = assets" + self.LINE
            else:
                self.output += self.TAB + "src = " + root[self.srcDirLen:].replace( "\\", "/" ) + self.LINE
            
            self.output += self.TAB + "children[] = "
            
            temp = ""
            for curDir in dirs:
                temp += curDir + ", "
            
            temp = temp[:-2] #remove trailing ", "
            self.output += temp + self.LINE
            self.output += self.TAB + "sources[] = "
            
            temp = ""
            for curFile in sorted(files):
                temp += curFile + ", "
            
            temp = temp[:-2] #remove trailing ", "
            self.output += temp + self.LINE
    
    def walkJSON( self ):
        self.output += "{" + self.LINE + self.TAB + "\"libs\":[" + self.LINE
        for root, dirs, files in os.walk( self.sourceDir ):
            dirs.sort(); # traverse subdirs in alpha order

            self.numLibs += 1
            
            if self.numLibs == 0:
                self.output += self.TAB * 2 + "{" + self.LINE + self.TAB * 3 + "\"src\":\"assets\"," + self.LINE
            else:
                self.output += self.TAB * 2 + "{" + self.LINE + self.TAB * 3 + "\"src\":\"" + root[self.srcDirLen:].replace( "\\", "/" ) + "\"," + self.LINE
            
            self.output += self.TAB * 3 + "\"children\":["
            
            temp = self.LINE
            for curDir in dirs:
                temp += self.TAB * 4 + "\"" + curDir + "\"," + self.LINE
            
            if temp == self.LINE:
                temp = "],"
            else:
                temp = temp[:-2] + self.LINE + self.TAB * 3 + "]," #replace trailing ",\n"
            
            self.output += temp + self.LINE
            self.output += self.TAB * 3 + "\"sources\":["
            
            temp = self.LINE
            for curFile in sorted(files):
                temp += self.TAB * 4 + "\"" + curFile + "\"," + self.LINE
            
            if temp == self.LINE:
                temp = "]"
            else:
                temp = temp[:-2] + self.LINE + self.TAB * 3 + "]" #replace trailing ",\n"
            
            self.output += temp + self.LINE
            self.output += self.TAB * 2 + "}," + self.LINE
            
        self.output = self.output[:-2] + self.LINE + self.TAB + "]" + self.LINE + "}" #replace trailing ",\n"

if __name__ == "__main__":
    gen = LibMaker()
    gen.createModel()
    #print( gen.output )
    gen.createJSON()
    #print( gen.output )
