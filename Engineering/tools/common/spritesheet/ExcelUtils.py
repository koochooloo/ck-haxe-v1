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

#import win32com.client as win32
import math
#import time
import sys

from xlrd import open_workbook

import PrintUtils

SAFE_COL_END_VAL = 1
SAFE_ROW_END_VAL = 3

WHITESPACE_CHARS = [ " ", "\n", "\t", "\r" ]

class SpreadsheetInfo(object):
    def __init__( self ):
        self.numRows = 0
        self.numCols = 0
        self.sheetData = []
        self.columnInfo = {}

# Can probably use empty_cell in xlrd
def isValidEntry( rawExcelEntry ):
    if rawExcelEntry is None:
        return False

    if type( rawExcelEntry ) == int or type( rawExcelEntry ) == float:
        return True

    cleanEntry = rawExcelEntry
    if hasattr( cleanEntry, "replace" ):
        for char in WHITESPACE_CHARS:
            cleanEntry = cleanEntry.replace( char, "" )

    return len( cleanEntry ) > 0

def getFileInfo( spreadsheetLoc, sheetID, startRow ):
    currentWorkbook = open_workbook( spreadsheetLoc )

    sheets = []
    if sheetID == "ALL":
        for curSheetID in range( 0, currentWorkbook.nsheets ):
            sheets.append( currentWorkbook.sheet_by_index( curSheetID ) )
    else:
        sheets.append( currentWorkbook.sheet_by_index( int( sheetID ) ) )

    numCols = sheets[ 0 ].ncols
    numRows = 0

    PrintUtils.printMsg( "Sheet: " + str( sheetID ) )
    PrintUtils.printMsg( "Total rows: " + str( numRows ) + " (when Sheet = ALL, this is total of all rows)" )
    PrintUtils.printMsg( "Total cols: " + str( numCols ) )

    sheetData = []

    for curSheet in sheets:
        PrintUtils.printMsg( "Processing a sheet..." )
        if curSheet.ncols != numCols:
            # TODO: this isn't always an error condition (only bad if merging multiple sheets; ok if sheets are distinct)
            PrintUtils.printMsg( "WARNING: a sheet has incorrect number of columns; skipping", True )
            PrintUtils.printMsg( "Expected: " + str( numCols ), True )
            PrintUtils.printMsg( "Found   : " + str( curSheet.ncols ), True )
            continue

        curNumRows = curSheet.nrows
        numRows += curNumRows

        for curRow in range( 0, curNumRows ):
            newRowData = []
            rowID = curRow
            for curCol in range( 0, numCols ):
                colID = curCol
                curValue = curSheet.cell( rowID, colID ).value
                cellType = type( curValue )
                if cellType == int or ( cellType == float and math.floor( curValue ) == curValue ):
                    curValue = int( curValue )
                # See if its a valid entry
                if not isValidEntry( curValue ):
                    curValue = unicode( "" )
                newRowData.append( curValue )
            sheetData.append( newRowData )

    colData = {}
    for curCol in range( 0, numCols ):
        startRowName = unicode( sheetData[ startRow ][ curCol ] ).encode('utf-8')
        row1Name = unicode( sheetData[ 0 ][ curCol ] ).encode('utf-8')
        row2Name = unicode( sheetData[ 1 ][ curCol ] ).encode('utf-8')
        if startRowName != "":
            colData[ curCol ] = startRowName
        elif row1Name != "":
            colData[ curCol ] = row1Name
        elif row2Name != "":
            colData[ curCol ] = row2Name


    fileInfo = SpreadsheetInfo()
    fileInfo.numRows = numRows
    fileInfo.numCols = numCols
    fileInfo.sheetData = sheetData
    fileInfo.columnInfo = colData

    return fileInfo

def gatherSpreadsheetInfo( spreadsheetLoc, sheetID, startRow ):
    spreadsheetInfo = None

    try:
        PrintUtils.printMsg( "Examining " + str( spreadsheetLoc ) )
        spreadsheetInfo = getFileInfo( spreadsheetLoc, sheetID, startRow )
        PrintUtils.printMsg( "Spreadsheet examined!" )
        PrintUtils.printMsg( "" )
    except Exception:
        PrintUtils.printMsg( "WARNING: something went wrong while gathering spreadsheet info from " + spreadsheetLoc, True )
        PrintUtils.printMsg( "    Error type: " + str( sys.exc_info()[0] ), True )
        PrintUtils.printMsg( "    Error val : " + str( sys.exc_info()[1] ), True )
        PrintUtils.printMsg( "Check for macros and add-ons and try removing MySQL Excel COM add-on." )
    return spreadsheetInfo

