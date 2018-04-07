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

#!/usr/bin/python

import sys
import os
import os.path

from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive

import PrintUtils

QUERY_PARAMETER="q"

# Downloads files from GoogleDive using OAuth2.0 authentication.
# Documentation for pydrive lives here: http://pythonhosted.org/PyDrive/
class GoogleUtils(object):
    def __init__(self):
        self.drive = None

    # Handles authentication. User will be prompted via web browser to authenticate.
    def authenticate(self):
        try:
            gauth = GoogleAuth()
            gauth.LocalWebserverAuth()

            self.drive = GoogleDrive( gauth )
        except BaseException as err:
            PrintUtils.print_to_file("WARNING: Failed to authenticate.", True)
            PrintUtils.print_to_file("\tError: {0}".format(err), True)
            sys.exit(1)

    # Download the file to the indicated directory
    def download_file_to_folder(self, file_metadata, target_directory):
        drive_file = self.drive.CreateFile(metadata=file_metadata)

        filename = os.path.join(target_directory, file_metadata['title'])

        try:
            drive_file.GetContentFile(filename=filename, mimetype=file_metadata["mimeType"])
        except BaseException as err:
            PrintUtils.print_to_file("WARNING: Failed to download file.", True)
            PrintUtils.print_to_file("\tError: {0}".format(err), True)
            sys.exit(1)

    # Returns a list of files in the folder with provided ID
    def get_files_in_folder(self, folder_id):
        return self.get_files_matching_query('"{0}" in parents'.format(folder_id))

    # Returns a list of files which match the provided query
    def get_files_matching_query(self, query):
        parameters = {
            QUERY_PARAMETER: query
        }

        files_in_folder = []

        try:
            files_in_folder = self.drive.ListFile(param=parameters).GetList()
        except BaseException as err:
            PrintUtils.print_to_file("WARNING: Failed to list files.", True)
            PrintUtils.print_to_file("\tError: {0}".format(err), True)
            sys.exit(1)

        return files_in_folder
