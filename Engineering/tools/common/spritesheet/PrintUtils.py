#
# Copyright (C) 2013, 1st Playable Productions, LLC. All rights reserved.
#
# UNPUBLISHED -- Rights reserved under the copyright laws of the United
# States. Use of a copyright notice is precautionary only and does not
# imply publication or disclosure.
#
# THIS DOCUMENTATION CONTAINS CONFIDENTIAL AND PROPRIETARY INFORMATION
# OF 1ST PLAYABLE PRODUCTIONS, LLC. ANY DUPLICATION, MODIFICATION,
# DISTRIBUTION, OR DISCLOSURE IS STRICTLY PROHIBITED WITHOUT THE PRIOR
# EXPRESS WRITTEN PERMISSION OF 1ST PLAYABLE PRODUCTIONS, LLC.
##########################################################################
LOG_FILE_PTR = None

def printMsg( msg, printToConsole = False ):
    if LOG_FILE_PTR != None:
        LOG_FILE_PTR.write( str( msg ) + "\n" )
    if printToConsole:
        print msg
