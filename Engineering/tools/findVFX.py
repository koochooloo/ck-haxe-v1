import os
import sys

def collectVFX( sourceDir, pathList ):
   for dirpath, dirs, files in os.walk( sourceDir ):
      dirs.sort()
      relPath = dirpath.replace(sourceDir, "")
      
      for fullname in sorted(files):
         filename, ext = os.path.splitext( fullname )

         if ext.lower() == ".pex" or ext.lower()==".json" or ext.lower()==".plist" or ext.lower()==".pixi":
            pathList.append(relPath + '\\' + fullname)

if __name__ == "__main__":
   argCount = len( sys.argv )
   if argCount < 3:
      print "ERROR: Usage: python findVFX.py <output path> <input path(s)>"
      exit(1)
   outputPath = sys.argv[ 1 ]
   inputPaths = []
   i = 2
   while i < argCount: 
      inputPaths.append(sys.argv[ i ])
      i = i + 1

   inFilenames = []
   for inPath in inputPaths:
      collectVFX(inPath, inFilenames)
   
   outstr = ""
   for inFile in inFilenames:
      outstr += inFile + "\n"

   # Write it all back out
   with open( outputPath, 'w' ) as vfxFile:
      vfxFile.write( outstr )


   
