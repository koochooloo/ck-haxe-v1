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


package com.firstplayable.hxlib.display;

import com.firstplayable.hxlib.Debug.*;
import com.firstplayable.hxlib.display.anim.SpritesheetAnim;
import com.firstplayable.hxlib.loader.ResMan;
import com.firstplayable.hxlib.utils.json.GlobalTable.The;
import com.firstplayable.hxlib.utils.json.IJsonClient;
import com.firstplayable.hxlib.utils.json.JsonObjectFactory;
import lime.ui.MouseCursor;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.text.TextField;

@:enum abstract GetObjectFailResponse(Int)
{
	var WARN_ON_FAIL   = 0; //!< If the object isn't found simply warn about it (this is the same as the previous implementation)
	var ERROR_ON_FAIL  = 1; //!< If the object isn't found then error out if possible (ie DSDEBUG_ENABLED builds)
	var IGNORE_FAILURE = 2; //!< Don't acknowledge failure to find the object
}

/**
 * The in-game representation of a Paist menu.
 */
class GenericMenu extends Sprite implements IJsonClient
{
	public static inline var EMPTY_MENU_NAME:String = "";
	
	private var m_isInited:Bool = false;
	private var m_menuName:String;
	private var m_btnMap:Array<GraphicButton>;
	private var m_objectMap:Map<String, DisplayObject>;
	
	public var menuName(get, never):String;
	private function get_menuName():String { return m_menuName; }

	public function new( menuName:String ) 
	{
		super();
		m_menuName = menuName;
		
		var jsonFile:String = ResMan.instance.getPaistFileByName( m_menuName );
		
		if( m_isInited )
		{
			warn( "Menu (" + m_menuName + ") tied to JsonFile( " + jsonFile + " ) already inited!!!" );
			return;
		}
		
		m_btnMap = new Array();
		m_objectMap = new Map();

		if ( jsonFile == EMPTY_MENU_NAME )
		{
			return;
		}
		
		var jof:JsonObjectFactory = JsonObjectFactory.getInstance();
		if ( !jof.populate( jsonFile, this ) )
		{
			warn( "Menu (" + m_menuName + ") tied to JsonFile(" + jsonFile + ") failed to populate properly" );
			return;
		}
		
		m_isInited = true;
	}
	
	private function doGetChildByName( name:String ):DisplayObject
	{
		var obj:DisplayObject = null;
		
		if ( m_objectMap.exists( name ) )
		{
			obj = m_objectMap.get( name );
		}
		else
		{
			obj = super.getChildByName( name );
		}
		
		return obj;
	}
	
	override public function getChildByName( name:String ):DisplayObject 
	{
		var obj:DisplayObject = doGetChildByName( name );
		
		if ( obj == null )
		{
			var msg:String = "GenericMenu: could not get child named '" + name + "' on menu '" + m_menuName + "'"
				+ "(Check hasObject or use getChildAs(name, type, IGNORE_FAILURE) to suppress if you are handling errors.)";
			warn( msg );
		}
		
		return obj;
	}
	
	public function getChildAs<T>( name:String, type:Class<T>, failResponse:GetObjectFailResponse = WARN_ON_FAIL ):T
	{
		var obj:DisplayObject = doGetChildByName( name );
		
		if ( obj != null && Std.is( obj, type ) )
		{
			return cast obj;
		}
		else if ( failResponse != IGNORE_FAILURE )
		{
			var msg:String = "GenericMenu: could not get child named '" + name + "' as type '" + type + "' on menu '" + m_menuName + "'";
			
			if ( obj != null )
			{
				msg += "\n	Note: child by that name exists, but its type is '" + Type.getClassName( Type.getClass( obj ) ) + "'";
			}
			
			warn( msg );
		}
		
		return null;
	}
	
	/**
	 * Gets a button by its GraphicButton.id 
	 */
	public function getButtonById( id:Int ):GraphicButton
	{
		if ( warn_if( id >= m_btnMap.length, "Warning: '" + id + "' is not a valid button ID on menu '" + m_menuName + "'" ) )
		{
			return null;
		}
		
		return m_btnMap[ id ];
	}
	
	/**
	 * Checks if the menu has a display object with a specified name
	 * @param	name		The  name of the object to check
	 * @return				Returns true if the object exists, otherwise false
	 */
	public function hasObject( name:String ):Bool
	{
		var obj:DisplayObject = doGetChildByName( name );
		return obj != null;
	}
	
	public function showObject( name:String, failResponse:GetObjectFailResponse = WARN_ON_FAIL ):Void
	{
		var obj:DisplayObject = getChildAs( name, DisplayObject, failResponse );
		if ( obj != null )
		{
			obj.visible = true;
		}
	}
	
	public function hideObject( name:String, failResponse:GetObjectFailResponse = WARN_ON_FAIL ):Void
	{
		var obj:DisplayObject = getChildAs( name, DisplayObject, failResponse );
		if ( obj != null )
		{
			obj.visible = false;
		}
	}
	
	public function toggleObjectVisibility( name:String, visible:Bool ):Void
	{
		visible ? showObject( name ) : hideObject( name );
	}
	
	public function positionObjectByRef( obj:DisplayObject, refName:String ):Void
	{
		var ref:DisplayObject = doGetChildByName( refName );
		if ( ref == null || obj == null )
		{
			var msg:String = "Cannot position obj by refName '" + refName + "' on menu '" + m_menuName + "';";
			msg += "ref exists? " + ( ref != null ) + "; obj exists? " + ( obj != null );
			warn( msg );
			// EARLY RETURN
			return;
		}
		
		obj.x = ref.x;
		obj.y = ref.y;
		
		addChildAt( obj, getChildIndex( ref ) );
		
		ref.visible = false;
	}
	
	public function replaceRefWithObject( obj:DisplayObject, refName:String, ?props:Array<String> ):Void
	{
		var ref:DisplayObject = doGetChildByName( refName );
		if ( ref == null || obj == null )
		{
			var msg:String = "Cannot position obj by refName '" + refName + "' on menu '" + m_menuName + "';";
			msg += "ref exists? " + ( ref != null ) + "; obj exists? " + ( obj != null );
			warn( msg );
			// EARLY RETURN
			return;
		}
		
		addChildAt( obj, getChildIndex( ref ) );
		ref.visible = false;
		
		if ( props != null )
		{
			for ( prop in props )
			{
				if ( Reflect.hasField( ref, prop ) && Reflect.hasField( ref, prop ) )
				{
					var propValue:Dynamic = Reflect.getProperty( ref, prop );
					Reflect.setField( obj, prop, propValue );
				}
			}
		}
	}
	
	/**
	 * Attempts to assign the text defined in Gamestrings by strID to the child TextField named tfName
	 * @param	tfName		- name of the TextField to set text in
	 * @param	strID		- the string ID of the text in Gamestrings
	 * @param	forceText	- if false (default), the text will only be set if a string is found in Gamestrings;
	 *				if true, the text will be set no matter what (if you pass a string ID that does
	 *				not exist in Gamestrings, then strID will be used in the TextField)
	 */
	public function setTextInField( tfName:String, strID:String, forceText:Bool = false ):Void
	{
		var tf:TextField = getChildAs( tfName, TextField );
		if ( log_if( (tf == null), "Cannot setTextInField; specified field was null" ) ) // getChildAs will have already warned, just log
		{
			// EARLY RETURN
			return;
		}
		
		var text:String = The.gamestrings.get( strID );
		if ( text == strID && !forceText )
		{
			log( "No string found for strID '" + strID + "'; not displaying this (use forceText=true to display)" );
			// EARLY RETURN
			return;
		}
		
		// if html5 and null, js will crash
		if ( text == null )
		{
			log( "String found but was null for strID '" + strID + "'" );
			text = "";
		}
		
		tf.text = text;
	}

	/**
	  * Changes the mouse cursor when hovering over the target object.
	  * @param name - Name of the object in paist.
	  * @param cursor - The lime.ui.MouseCursor style to use.
	  */
	public function setCursorForObject(name:String, cursor:MouseCursor):Void
	{
		var obj = getChildByName(name);
		if (obj != null)
		{
			if (Std.is(obj, OPSprite))
			{
				var spriteObj:OPSprite = cast obj;
				spriteObj.cursor = cursor;
			}
			else if (Std.is(obj, SpritesheetAnim))
			{
				var spriteObj:SpritesheetAnim = cast obj;
				spriteObj.cursor = cursor;
			}
			else
			{
				warn("Can't set cursor for objects of this type!");
			}
		}
	}
	
	public function getType():ClientType
	{
		return ClientType.GENERIC_MENU;
	}
	
	public function onButtonHit( ?caller:GraphicButton ):Void
	{
	}
	
	public function onButtonDown( ?caller:GraphicButton ):Void
	{
	}
	
	public function onButtonUp( ?caller:GraphicButton ):Void
	{
	}
	
	public function onButtonOver( ?caller:GraphicButton ):Void
	{
	}
	
	public function onButtonOut( ?caller:GraphicButton ):Void
	{
	}
	
	public function addButton( button:GraphicButton ):Void
	{
		// button will have been validated before this point
		var id:Int = button.id;
		
		if ( m_btnMap[ id ] != null )
		{
			var msg = "Button with ID " + id + " already exists on menu '"
				+ m_menuName + "'; old name: '" + m_btnMap[id].name
				+ "', new name: '" + button.name + "'";
			if ( id != 0 )
			{
				warn( msg );
			}
			else
			{
				log( msg );
			}
			// EARLY RETURN
			return;
		}
		
		m_btnMap[ id ] = button;
	}
	
	@:allow( com.firstplayable.hxlib.utils.json.JsonMenuPlugIn )
	private function addObjectByName( obj:DisplayObject, name:String ):Void
	{
		if ( m_objectMap.exists( name ) )
		{
			warn( "Object with name " + name + " already exists on menu '" + m_menuName + "'; overwriting." );
		}
		
		m_objectMap.set( name, obj );
	}
}