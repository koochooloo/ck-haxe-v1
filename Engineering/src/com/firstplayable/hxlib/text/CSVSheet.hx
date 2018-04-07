//
// Copyright (C) 2006-2016, 1st Playable Productions, LLC. All rights reserved.
//
// UNPUBLISHED -- Rights reserved under the copyright laws of the United
// States. Use of a copyright notice is precautionary only and does not
// imply publication or disclosure.
//
// THIS DOCUMENTATION CONTAINS CONFIDENTIAL AND PROPRIETARY INFORMATION
// OF 1ST PLAYABLE PRODUCTIONS, LLC. ANY DUPLICATION, MODIFICATION,
// DISTRIBUTION, OR DISCLOSURE IS STRICTLY PROHIBITED WITHOUT THE PRIOR
// EXPRESS WRITTEN PERMISSION OF 1ST PLAYABLE PRODUCTIONS, LLC.
///////////////////////////////////////////////////////////////////////////
package com.firstplayable.hxlib.text;
import com.firstplayable.hxlib.Debug.log;
import com.firstplayable.hxlib.Debug.warn;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
using Lambda;
using Std;

//TODO: update .getRange() to be more useful (see TODO there)
//TODO: .sort() to arrange information by specified column alphabetically, chain sorts for customization
/**
 * Create, load, export, and work with CSV formatted strings.
 */
class CSVSheet extends URLLoader
{
    /**
     * A name to represent your table. For your reference only.
     */
    public var tableName:String;
    
    /**
     * The string to use when encoding or decoding the table as a column (cell) separator. The default is "," (comma).
     */
    public var separator:String;
    
    /**
     * The string to use when a cell needs to be encapsulated. Default is "\"" (quotation).
     */
    public var encapsulator:String;
    
    /**
     * A default return value when your query fails. Possible values you may want to use; null, "", or "STRING_NOT_FOUND".
     * Default is "CELL_NOT_FOUND".
     */
    public var cellNotFoundReturn:String;
    
    /**
     * The width of the table / number of columns (headers).
     */
    public var width(get, never):Int;
    private function get_width():Int { return ( m_table.length > 0 ) ? m_table[ 0 ].length : 0; }
    
    /**
     * The height of the table / number of rows (entries).
     */
    public var height(get, never):Int;
    private function get_height():Int { return m_table.length; }
    
    private var m_table:Array<Array<String>>;    //the 2d array representing the csv
    private var m_isDataSet:Bool;    //true if decode() has been successfully called.
    
    /**
     * A representation of the table as an array. Note that modifications to the array will affect the table data.
     */
    public var array(get, never):Array<Array<String>>;
    private function get_array():Array<Array<String>> { return m_table.copy(); }
    
    /**
     * An array representing the header row only.
     */
    public var headers(get, never):Array<String>;
    private function get_headers():Array<String> { return getRowByIndex( 0 ); }
    
    /**
     * A regular expression denoting how to split rows when decoding. The default is split on carriage return and new line (\r\n).
     */
    private var rowDelim:EReg;
    
    /**
     * A regular expression denoting how to split columns (cells) when decoding. The default is to split on unencapsulated commas.
     */
    private var colDelim:EReg;
    
    /**
     * Creates a new CSVSheet. 
     * @param    url           CSV file location to automatically load. If nothing provided, you can either
     *                         load later or set 'data' manually before decoding.
     * @param    aTableName    An optional string name for your table to use as a reference identifier.
     */
    public function new( url:URLRequest = null, aTableName:String = "CSVTable" ) 
    {
        super( url );
        
        tableName = aTableName;
        
        separator = ",";
        encapsulator = "\"";
        cellNotFoundReturn = "CELL_NOT_FOUND";
        
        m_table = [];
        m_isDataSet = false;
    }
    
    /**
     * Inserts a row or appends the table.
     * @param    row            A string array.
     * @param    ?rowIndex    The index to insert the row at. If not provided, the row is appended to the end.
     */
    public function insertRow( row:Array<String>, ?rowIndex:Int ):Void
    {
        if ( Debug.exists( row ) )
        {
            if ( rowIndex != null )
            {
                m_table.insert( rowIndex, row );
            }
            else
            {
                m_table.push( row );
            }
        }
    }
    
    /**
     * Removes a row from the table.
     * @param    rowIndex    The index to remove.
     */
    public function removeRow( rowIndex:Int ):Void
    {
        m_table.splice( rowIndex, 1 );
    }
    
    /**
     * Removes a column from the table.
     * @param    colIndex    The index to remove.
     */
    public function removeCol( colIndex:Int ):Void
    {
        for ( record in m_table )
        {
            if ( record.length > colIndex )
            {
                record.splice( colIndex, 1 );
            }
        }
    }
    
    /**
     * Encodes your CSV Sheet as a string. The resulting value is stored in the 'data' property.
     * @return    Encoded table as string
     */
    public function encode():String
    {
        var dataStr:String = "";
        
        for ( row in m_table )
        {
            var rowLen:Int = row.length;
            for ( j in 0...rowLen )
            {
                row[ j ] = encapsulator + row[ j ] + encapsulator;
            }
            
            dataStr += row.join( separator ) + "\r\n";
        }
        
        data = dataStr;
        m_isDataSet = true;
        
        return dataStr;
    }
    
    /**
     * Parses the data property of this class into a two dimensional array (the csv sheet in which to work with)
     * based on the delimeter pattern properties.
     */
    public function decode():Void
    {
        //make sure data is valid and loaded
        if ( !data.is( String ) )
        {
            warn( "Property 'data' is invalid or null. Cannot decode!" );
            return;
        }
        
        //finds a value if it is not surrounded by quotes
        //TODO: Change to support encapsulator variable instead of quotes.
        var unencapsulatedFind:String = "(?=([^\"\\\\]*(\\\\.|\"([^\"\\\\]*\\\\.)*[^\"\\\\]*\"))*[^\"]*$)";
        rowDelim = new EReg( "(\r?\n|\r^)" + unencapsulatedFind, "g" ); //any combo of newline chars
        colDelim = new EReg( separator + unencapsulatedFind, "g" );     //the separator string
        
        m_table.splice( 0, m_table.length );
        var rows:Array<String> = rowDelim.split( data );
        
        for ( row in rows )
        {
            var cells:Array<String> = colDelim.split( row );
            
            var colLen:Int = cells.length;
            //remove encapsulation for each cell
            for ( j in 0...colLen )
            {
                var cellStr:String = cells[ j ];
                var encapPattern:EReg = new EReg( "^" + encapsulator + "+|" + encapsulator + "+$", "g" );
                var quotePattern:EReg = new EReg( "\"\"", "g" );
                
                cellStr = encapPattern.replace( cellStr, "" );
                cellStr = quotePattern.replace( cellStr, "\"" );
				cellStr = StringTools.ltrim( cellStr );
				cellStr = StringTools.rtrim( cellStr );
                cells[ j ] = cellStr;
            }
            
            m_table.push( cells );
        }
        
        m_isDataSet = true;
    }
    
    /**
     * Searches the sheet for all cells matching criteria and creates a mini sheet (2d array) of results.
     * conditions    An array of strings, formatted as search queries to use as criteria:
     *               ie, [ "ColumnA=happy", "ColB=25", "ColC=joe" ]
     * exclusive     If true, multiple conditions will be evaluated using AND; otherwise they will be evaluated using OR.
     * @return       Mini sheet (2d array) representation of results. If no results found, returns an array containing cellNotFoundReturn.
	 * 
	 * //TODO: add matching searches with '?' replacing '='. (ie, a search for "happy" will catch [ "happy", "happy92", "iamhappy" ])
     * //TODO: add 'ANY' keyword for col header to signify search all cells for value
     */
    public function search( conditions:Array<String>, exclusive:Bool = false, includeHeaders:Bool = false ):Array<Array<String>>
    {
        //"Col=0" or "Col?0" or "ANY=0"
        var splitter:String = "=";
        var ar:Array<Array<String>> = [];
        
        for ( entry in m_table )
        {
            var shouldAdd:Int = 0;
            
            for ( eval in conditions )
            {
                var pair:Array<String> = eval.split( splitter );
                var col:Int = getColIndexByName( pair[ 0 ] );
                var val:String = pair[ 1 ];
                
                //check condition met
                if ( entry[ col ] == val )
                {
                    ++shouldAdd;
                    if ( !exclusive ) break;
                }
            }
            
            var allConditionsMet:Bool = exclusive && shouldAdd == conditions.length;
            var oneConditionMet:Bool = !exclusive && shouldAdd > 0;
            
            if ( allConditionsMet || oneConditionMet )
            {
                ar.push( entry );
            }
        }
        
        //no results found
        if ( ar.length == 0 )
        {
            log( "Search found no matches!" );
            
            var arNotFound:Array<String> = [];
            
            //fill out array with not found string
            for ( i in 0...headers.length )
            {
                arNotFound[ i ] = cellNotFoundReturn;
            }
            
            ar.push( arNotFound );
        }
        else
        {
            log( "Search found " + ar.length + " matches!" );
        }
        
		//do this after so we don't interfere with above checks
		if ( includeHeaders )
		{
			ar.unshift( headers );
		}
		
        return ar;
    }
    
    /**
     * Gets a sequential collection of cells from the table.
     * @param    startRow    The index of the record to start from.
     * @param    endRow      The index of the last record (exclusive).
     * @param    col         The column to get the cells from.
     * @return        A list of cells, [ start, end )
	 * 
	 * //TODO: startRow & endRow to Dynamic (see getCell()), col as optional param -jm
     */
    public function getCellsInRange( startRow:Int, endRow:Int, col:Dynamic ):Array<String>
    {
        var rangeTable:Array<String> = [];
        
        for ( i in startRow...endRow )
        {
            rangeTable.push( getCell( i, col ) );
        }
        
        return rangeTable;
    }
    
    /**
     * Gets a sequential collection of entries from the table.
     * @param    startRow          The index of the record to start from.
     * @param    endRow            The index of the last record (exclusive).
     * @param    includeHeaders    Specify whether to include the header row in the results; defaulted to false.
     * @return        A list of entries, [ start, end )
	 * 
	 * //TODO: startRow & endRow to Dynamic (see getCell()), col as optional param -jm
     */
    public function getEntriesInRange( startRow:Int, endRow:Int, includeHeaders:Bool = false ):Array<Array<String>>
    {
        var rangeTable:Array<Array<String>> = [];
        
        if ( includeHeaders )
        {
            rangeTable.push( headers );
        }
        
        for ( i in startRow...endRow )
        {
            rangeTable.push( getRowByIndex( i ) );
        }
        
        return rangeTable;
    }
    
    /**
     * Get a table record.
     * @param    row        Either int row index or string row header.
     * @return        The record that is the specified row. Returns empty array if invalid query.
     */
    public function getRecord( row:Dynamic ):Array<String>
    {
        if ( !m_isDataSet )
        {
            warn( "Table has not been decoded. Please call decode() first." );
            return [];
        }
        
        if ( row.is( Int ) )
        {
            return getRowByIndex( row );
        }
        else if ( row.is( String ) )
        {
            return getRowByName( row );
        }
        
        warn( "Query information is not valid." );
        return [];
    }
    
    /**
     * Get a table record.
     * @param    row        Index of the row in the table.
     * @return        The record at the row index. Returns empty array if invalid query.
     */
    public function getRowByIndex( row:Int ):Array<String>
    {
        if ( row < m_table.length )
        {
            return m_table[ row ];
        }
        
        warn( "Row index out of bounds." );
        return [];
    }
    
    /**
     * Get a table record by the header.
     * @param    rowHeader    The name of the header.
	 * @param	 returnHeader Determines whether or not the "header" cell will be included in
	 * 							the return value. Defaults to "true" to preserve existing functionality.
     * @return        The record at the row index. Returns empty array if invalid query.
     */
    private function getRowByName( rowHeader:String, ?returnHeader:Bool = true ):Array<String>
    {
        for ( row in m_table )
        {
            //iterate through the first element in each row.
            var rowName:String = row[ 0 ];
            
            if ( rowName == rowHeader )
            {
                return returnHeader ? row : row.slice(1);
            }
        }
        
        warn( "Row does not exist: '" + rowHeader + "'." );
        return [];
    }
    
    /**
     * Get a cell in the table by index or name.
     * @param    row        Either int row index or string row header.
     * @param    col        Either int column index or string column header.
     * @return        Value of the cell, or 'cellNotFoundReturn' if bad query.
     */
    public function getCell( row:Dynamic, col:Dynamic ):String
    {
        if ( !m_isDataSet )
        {
            warn( "Table has not been decoded. Please call decode() first." );
            return cellNotFoundReturn + "[NO_TABLE]";
        }
        
        var cell:String = null;
        
        if ( row.is( Int ) && col.is( Int ) )
        {
            cell = getCellByIndex( row, col );
        }
        else if ( row.is( String ) && col.is( String ) )
        {
            cell = getCellByName( row, col );
        }
        else if ( row.is( Int ) && col.is( String ) )
        {
            cell = getRowByIndex( row )[ getColIndexByName( col ) ];
        }
        else if ( row.is( String ) && col.is( Int ) )
        {
            cell = getRowByName( row )[ col ];
        }
        else
        {
            warn( "Query information is not valid." );
        }
        
        return ( cell != null ) ? cell : cellNotFoundReturn + "[" + row + ", " + col + "]";
    }
    
    /**
     * Get a cell in the table.
     * @param    row        Index of the row.
     * @param    col        Index of the column.
     * @return        Value of the cell.
     */
    private function getCellByIndex( row:Int, col:Int ):String
    {
        //check that cell x,y are valid
        if ( row < m_table.length && col < m_table[ 0 ].length )
        {
            return m_table[ row ][ col ];
        }
        
        warn( "Row and/or column index out of bounds." );
        return cellNotFoundReturn;
    }
    
    /**
     * Get a cell in the table by headers.
     * @param    rowHeader    Name of the row header.
     * @param    colHeader    Name of the column header.
     * @return        Value of the cell.
     */
    private function getCellByName( rowHeader:String, colHeader:String ):String
    {
        var row:Array<String> = getRowByName( rowHeader );
        var colIndex:Int = getColIndexByName( colHeader );
        
        //check that row and column are valid
        if ( Debug.exists( row ) && colIndex < row.length )
        {
            return row[ colIndex ];
        }
        
        warn( "Row and/or column does not exist." );
        return cellNotFoundReturn;
    }
    
    /**
     * Gets a column index by its header.
     * @param    colHeader    Name of the column header.
     * @return        Index of the column.
     */
    public function getColIndexByName( colHeader:String ):Int
    {
        var headerRow:Array<String> = m_table[ 0 ];
        return headerRow.indexOf( colHeader );
    }
    
    /**
     * Gets a row index by its header.
     * @param    colHeader    Name of the row header.
     * @return        Index of the row.
     */
    public function getRowIndexByName( rowHeader:String ):Int
    {
        var h:Int = height;
        
        for ( i in 0...h )
        {
            if ( m_table[ i ][ 0 ] == rowHeader )
                return i;
        }
        
        return -1;
    }
    
    /**
     * Empties the table and marks the csv as un-decoded and un-encoded. The 'data' property will remain unmodified.
     */
    public function clear():Void
    {
        m_table.splice( 0, m_table.length );
        m_isDataSet = false;
    }
    
    /**
     * Overrides the toString() function to return a formatted string representing the contents of the table. If the table was not decoded, calls super.toString().
     * @return
     */
    override public function toString():String
    {
        var output:String = "(tableName= " + tableName + "):\n";
        
        for ( record in m_table )
        {
            output += ( record.join( "|" ) + "\n" );
        }
        
        return super.toString() + output;
    }
	
	/**
	 * Creates a CSVSheet instance from a 2D array
	 * @param	ar
	 * @return
	 */
	public static function from2dArray( ar:Array<Array<String>> ):CSVSheet
	{
		var sheet:CSVSheet = new CSVSheet();
		var rows:Int = ar.length;
		var csvStr:String = ar[ 0 ].join( "," ); //header row
		
		//starting at 1 so we don't end up with a \n on either side of the string
		for ( i in 1...rows )
		{
			csvStr += "\n" + ar[ i ].join( "," );
		}
		
		sheet.data = csvStr;
		return sheet;
	}
}