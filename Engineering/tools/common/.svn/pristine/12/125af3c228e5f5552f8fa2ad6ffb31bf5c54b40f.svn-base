// var pngDir = "file:///C:/projects/ourobros/branches/caduceus/Experiments/HaxeRocketHagglePrototype/assets/2d/"
// var jsonDir = "file:///C:/projects/ourobros/branches/caduceus/Experiments/HaxeRocketHagglePrototype/assets/json/"
// Init xJFSL object
// xjsfl.init( this );
// fl.openDocument("file:///C:/projects/ourobros/branches/caduceus/Experiments/HaxeRocketHagglePrototype/lib/fla/");

//-----------------------------------
var jsonBegin = "{ \n\
    \"fileProperties\" : { \n\
        \"contentType\" : \"menu\", \n\
        \"version\" : 3, \n\
        \"platform\" : [ \"iPad\" ], \n\
        \"screenOrientation\" : \"Landscape\" \n\
    }, \n\
    \"topMenu\" : { \n\
        \"menuProperties\" : { \n\
            \"inheritable\" : { \n\
                \"loadParams\" : false \n\
            } \n\
        }, \n\
"
var jsonEnd = "    } \n\
}"

var jsonControlTemplate = "	{ \n\
            \"name\" : \"REPLACE_NAME\", \n\
            \"priority\" : REPLACE_PRIORITY, \n\
            \"inheritable\" : { \n\
                \"resource\" : \"REPLACE_RESOURCE\", \n\
                \"position\" : [ REPLACE_X, REPLACE_Y ], \n\
                \"loadParams\" : true \n\
            } \n\
        },"

// Template for the rpj file
// Default value for reference point is Origin
var rpjTemplate = "<ResourceProject version=\"3.0\"> \n\
  <Head> \n\
  </Head> \n\
  <Body> \n\
    <resources name=\"REPLACE_FOLDERNAME/\"> \n\
      <paramDefaults> \n\
        <paramDefault name=\"bounds\" value=\"Automatic;Bounds\" /> \n\
        <paramDefault name=\"center\" value=\"Automatic;(Origin,Origin)\" /> \n\
      </paramDefaults> \n\
    </resources> \n\
  </Body> \n\
</ResourceProject>"

//-----------------------------------
const IFL_FILE_EXT = ".ifl";
var iflFrameDelay = 5;

var exportedItemArray = new Array();
//-----------------------------------

var doc = fl.getDocumentDOM();
fl.outputPanel.clear();

var doc_name = doc.name.substring(0, doc.name.indexOf(".", 0));

//-------------------------------------------
// Write RPJ
var rpjFileURI = pngDir + doc_name + ".rpj";
var rpjContents = rpjTemplate.replace("REPLACE_FOLDERNAME", doc_name);
FLfile.write( rpjFileURI, rpjContents );
//-------------------------------------------

// Write JSON
FLfile.createFolder(jsonDir);
var jsonFileURI = jsonDir + doc_name + ".json";

var tl = doc.getTimeline();

FLfile.write(jsonFileURI, jsonBegin);

// movie clip => spriteObject
FLfile.write(jsonFileURI, "\t\"button\" : [ ", "append"); // write the type of control in paist
printControlsByItemType( "button" );
FLfile.write(jsonFileURI, "\t], \n", "append");

// button => button
FLfile.write(jsonFileURI, "\t\"spriteObject\" : [ ", "append"); // write the type of control in paist
printControlsByItemType( "movie clip" );
FLfile.write(jsonFileURI, "\t], \n", "append");

// TODO:
// export shapes

FLfile.write(jsonFileURI, jsonEnd, "append");


function printControlsByItemType( libraryItemType )
{
    for ( var layerId = 0; layerId < tl.layerCount; ++layerId )
    {
	var priority = 1000 - layerId * 10; // layer 0 is closest to the player
        for ( var frameId = 0; frameId < tl.layers[layerId].frameCount; ++frameId)
	{
	    var elts = tl.layers[layerId].frames[frameId].elements;
	    printControls(elts, libraryItemType, priority);
	}
    }
    
}

function printControls( elements, libraryItemType, priority )
{
    for (var x = 0; x < elements.length; x++) { 
          var elt = elements[x]; 
          var type = elements.instanceType;
	  if ( elt.libraryItem != undefined
	      && elt.libraryItem.itemType == libraryItemType )
          {
	    var jsonCurControl = jsonControlTemplate

	    const resourceName = elt.libraryItem.name;
	    // Use the last part of resource name as control name.
	    // There might be duplicates... should there be a warning for duplicates?
	    const indexOfLastSlash = resourceName.lastIndexOf("/");
	    const controlName = resourceName.substring(indexOfLastSlash + 1, resourceName.length);

	    jsonCurControl = jsonCurControl.replace("REPLACE_NAME", controlName)
	    jsonCurControl = jsonCurControl.replace("REPLACE_PRIORITY", priority)
	    jsonCurControl = jsonCurControl.replace("REPLACE_RESOURCE", doc_name + "/" + resourceName)
	    jsonCurControl = jsonCurControl.replace("REPLACE_X", Math.round(elt.left))
	    jsonCurControl = jsonCurControl.replace("REPLACE_Y", Math.round(elt.top))
	    FLfile.write(jsonFileURI, jsonCurControl, "append");
	    
	    if ( exportedItemArray.indexOf(elt.libraryItem) < 0 ) // if the library item has not been exported yet
	    {
	        // export libraryItem
	        exportItemAsPng(elt.libraryItem)
	        exportedItemArray.push(elt.libraryItem)
	    }
          }
	  
     }
    
}

// reference:
// http://abitofcode.com/2011/11/export-flash-library-items-as-pngs-with-jsfl/
// http://abitofcode.com/wp-content/plugins/download-monitor/download.php?id=7
function exportItemAsPng(item) {   
    var indexOfLastSlash = item.name.lastIndexOf("/");
    var pngFolderURI = pngDir + doc_name + "/" + item.name.substring(0, indexOfLastSlash);
    //fl.trace(pngFolderURI);
    
    var fileName = item.name.substring(indexOfLastSlash + 1, item.name.length) // file name without extension
    
    //fl.trace(pngFolderURI + " " + FLfile);
    FLfile.createFolder(pngFolderURI);
    var pngFileURIBase = pngFolderURI + "/" + fileName;
    //fl.trace(pngFileURIBase);
    
    // selects the specified library item (true = replace current selection)
    doc.library.selectItem(item.name, true);
    
    // Add the current library item to the stage
    doc.library.addItemToDocument({x:0, y:0});

    // cuts the current selection from the document and writes it to the Clipboard.
    doc.clipCut();

    // Create a new temporary document to paste the clip held in the clipboard 
    fl.createDocument();    
        
    // get a handle on the currently focused document (the temporary one)
    exportdoc = fl.getDocumentDOM();
        
    // pastes the contents of the Clipboard into the document, defaults to 
    // adding it at the center of the document    
    exportdoc.clipPaste();
    
    exportdoc.exportInstanceToPNGSequence(pngFileURIBase);
    
    if ( item.itemType == "button" ) // for buttons
    {
        // rename exported PNG sequence so they end with _up/_down
        renameFile( pngFileURIBase + "0001.png", pngFileURIBase + "_up.png", true);
        renameFile( pngFileURIBase + "0003.png", pngFileURIBase + "_down.png", true);
	FLfile.remove(pngFileURIBase + "0002.png");
    }
    else if ( item.itemType == "movie clip" )
    {
        if ( !FLfile.exists( pngFileURIBase + ".png" ) )
        {
            // Assume PNGSequence was exported and
            // write IFL
            createIFL( pngFileURIBase );
        }
    }


    // access the document that is currently focused (the temporary one) and
    // close it. Do not promt the user to save changes
    exportdoc.close(false);    
        
    // trace its name in the output panel
    fl.trace('saving:' + pngFileURIBase);
}

function renameFile(srcFileURI, dstFileURI, overwrite)
{
    if ( overwrite == true )
    {
	if ( FLfile.exists(srcFileURI) )
	{
	    FLfile.remove(dstFileURI);
	}
    }

    if ( FLfile.exists(srcFileURI) )
    {
	if ( FLfile.copy(srcFileURI, dstFileURI) )
	{
	    FLfile.remove(srcFileURI);
	}
	else
	{
	    fl.trace("Failed to rename " + srcFileURI);
	}
    }
    else
    {
	fl.trace("File does not exist: " + srcFileURI);
    }
}

function createIFL( pngFileURIBase )
{
    const iflFileURI = pngFileURIBase + IFL_FILE_EXT;
    //Open an ifl file, overwriting any previous contents
    var iflFile = new File();
    iflFile.init( iflFileURI, true );

    var pngNumber = 1;
    
    while( true )
    {
        // pad the number with 0's at the beginning so there are at least 4 digits
	var pngNumberString = Utils.pad(pngNumber, 4, "0")
	
        // write a line to ifl file for the current png file
        const indexOfLastSlash = pngFileURIBase.lastIndexOf("/");
        const pngFileNameBase = pngFileURIBase.substring(indexOfLastSlash + 1, pngFileURIBase.length);
        const pngFileName = pngFileNameBase + pngNumberString + ".png";
        var pngFileURI = pngFileURIBase + pngNumberString + ".png";
        if ( FLfile.exists(pngFileURI) )
        {
            iflFile.append(pngFileName + " " + iflFrameDelay + "\n");
        }
        else
        {
            // if the png for the frame DOES NOT exist
            // escape the loop
            // ( Tried getting number of frames via item.timeline.layers[#].frameCount,
            //   but not sure which layer's frameCount should be used )
            break;
        }
        ++pngNumber;
    }
}

