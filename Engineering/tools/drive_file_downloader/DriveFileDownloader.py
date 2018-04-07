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

import argparse
import json
import sys

import PrintUtils
import GoogleUtils

def validate_key(dictionary, key):
    if key not in dictionary:
        PrintUtils.print_to_file('Config file is missing "{0}"'.format(key), True)
        sys.exit(1)

if __name__ == "__main__":
    argument_parser = argparse.ArgumentParser(description="Download files from Google Drive")
    argument_parser.add_argument("log_file", type=argparse.FileType(mode='w'), help="File containing log statements")
    argument_parser.add_argument("config_file", type=argparse.FileType(mode='r'), help="File containing configuration settings")
    args = argument_parser.parse_args()

    PrintUtils.log_file_ptr = args.log_file

    google = GoogleUtils.GoogleUtils()

    google.authenticate()

    try:
        json_obj = json.load(fp=args.config_file)
    except BaseException:
        PrintUtils.print_to_file("Error parsing config file!", True)
        sys.exit(1)

    validate_key(json_obj, 'key')
    validate_key(json_obj, 'target_directory')
    validate_key(json_obj, 'valid_mime_types')

    files_in_folder = google.get_files_in_folder(json_obj['key'])

    valid_mime_types = set(json_obj['valid_mime_types'])

    files_with_valid_mime_types = [metadata for metadata in files_in_folder if metadata['mimeType'] in valid_mime_types]

    for metadata in files_with_valid_mime_types:
        google.download_file_to_folder(file_metadata=metadata, target_directory=json_obj['target_directory'])
