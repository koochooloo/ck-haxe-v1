#
# Copyright (C) 2017, 1st Playable Productions, LLC. All rights reserved.
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

log_file_ptr = None

def print_to_file(msg, print_to_console=False):
    if log_file_ptr is not None:
        log_file_ptr.write("{0}\n".format(msg))
    if print_to_console:
        print msg
