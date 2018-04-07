import os
import sys
from shutil import copyfile

class ParseState:
   PRE_IMPORT = 1
   IMPORT = 2
   POST_IMPORT = 3
   ADD = 4
   POST_ADD = 5   

def collectTests( sourceDir, tests ):
   for dirpath, dirs, files in os.walk( sourceDir ):
      dirs.sort()
      for fullname in sorted(files):
         filename, ext = os.path.splitext( fullname )

         if ext.lower() == ".hx" and ("Test.hx" in fullname):
            tests.append(filename)

def modifyTestSuite( inputPath, outputPath, tests ):
   copyfile(inputPath, outputPath)

   importMarker = "@@IMPORT"
   addMarker = "@@ADD"
   endMarker = "@@END"
   
   outstr = ""
   readState = ParseState.PRE_IMPORT
   with open( outputPath, 'r' ) as suiteFile:
      for line in suiteFile:
         if readState == ParseState.PRE_IMPORT:
            outstr += line
            if line.find(importMarker) >= 0:
               readState = ParseState.IMPORT
               for t in tests:
                  outstr += "import " + t + ";\n"
         elif readState == ParseState.IMPORT:
            if line.find(endMarker) >= 0:
               readState = ParseState.POST_IMPORT
               outstr += line
         elif readState == ParseState.POST_IMPORT:
            outstr += line
            if line.find(addMarker) >= 0:
               readState = ParseState.ADD
               for t in tests:
                  outstr += "      add(" + t + ");\n"
         elif readState == ParseState.ADD:
            if line.find(endMarker) >= 0:
               readState = ParseState.POST_ADD
               outstr += line
         elif readState == ParseState.POST_ADD:
            outstr += line

   if readState != ParseState.POST_ADD:
      print "ERROR: failed to parse TestSuite.hx file markers correctly!"
      exit(1)
         
   # Write it all back out
   with open( outputPath, 'w' ) as suiteFile:
      suiteFile.write( outstr )

if __name__ == "__main__":
   argCount = len( sys.argv )
   if argCount < 4:
      print "ERROR: Usage: python FindAllTests.py <input path> <output path> <test paths>"
      exit(1)
   inputPath = sys.argv[ 1 ]
   outputPath = sys.argv[ 2 ]
   testPaths = []
   i = 3
   while i < argCount: 
      testPaths.append(sys.argv[ i ])
      i = i + 1

   testFilenames = []
   for testPath in testPaths:
      collectTests(testPath, testFilenames)
   
   if len(testFilenames) == 0:
      print "ERROR: no tests found!"
      exit(1)
   
   for t in testFilenames:
      print "Found test: " + t
      
   modifyTestSuite(inputPath, outputPath, testFilenames)   
   
   
