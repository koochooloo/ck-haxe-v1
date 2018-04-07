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



#------------------------------------------------------------------------------

# Sort keys by length (shortest first)
def sortAssetKeys( k1, k2 ):
    len1 = len( k1 )
    len2 = len( k2 )

    if len1 < len2:
        return -1
    elif len1 == len2:
        return 0
    else:
        return 1


#------------------------------------------------------------------------------
# Given a target path and a list of paths, finds the longest path that is
# a substring of the target path.
# Used to inherit parent settings.
def find( targetPath, paths, allowTargetAsReturnVal ):
    longestSubStr = targetPath
    longestLen = 0

    # Find the path that is the longest substring of the specified path
    for currPath in paths:
        if ( allowTargetAsReturnVal or currPath != targetPath ) and targetPath.find( currPath ) != -1:
            currLen = len( currPath )
            if currLen > longestLen:
                longestLen = currLen
                longestSubStr = currPath

    return longestSubStr
