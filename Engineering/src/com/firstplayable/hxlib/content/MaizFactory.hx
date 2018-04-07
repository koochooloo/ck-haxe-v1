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
package com.firstplayable.hxlib.content;
import com.firstplayable.hxlib.utils.PropUtils;
import haxe.xml.Fast;
import openfl.events.Event;
import openfl.geom.Point;
import openfl.net.URLLoader;
import openfl.net.URLRequest;

//WARNING: CLASS NOT READY YET! SEE Jon for details!
class MaizFactory extends URLLoader
{
	//TODO: implement background layer nodes
	private var m_objects:Array<Dynamic>;
	//TODO: implement vector nodes
	
	public function new( url:URLRequest = null ) 
	{
		super( url );
		m_objects = [];
	}
	
	public function decode():Void
    {
		var layout:Xml = Xml.parse( data );
		var map:Fast = new Fast( layout.firstElement() );
		
		//BackgroundLayer node
		var backLayer:Fast = map.node.Background.node.BackgroundLayer;
		//m_background
		
		var Objects:Fast = map.node.Objects;
		
		//iterate over all Object nodes
		for ( Object in Objects.nodes.Object )
		{
			var group:String = Object.att.objectTypeGroupName;
			var type:String = Object.att.objectTypeName;
			var refPos:Fast = Object.node.ReferencePointLocation;
			var p:Point = new Point( Std.parseFloat( refPos.att.x ), Std.parseFloat( refPos.att.y ) );
			
			var obj:Dynamic = {};
			obj.group = group;
			obj.type = type;
			obj.referencePos = p;
			
			var Properties:Fast = Object.node.Properties;
			
			//iterate over all Property nodes
			for ( Property in Properties.nodes.Property )
			{
				var name:String = Property.att.name;
				var value:String = Property.att.value;
				
				//detect bool
				if ( value == "True" || value == "False" )
				{
					var val:Bool = value == "True" ? true : false;
					Reflect.setProperty( obj, name, val );
				}
				//detect number
				else if ( !Math.isNaN( Std.parseFloat( value ) ) )
				{
					var val:Float = Std.parseFloat( value );
					Reflect.setProperty( obj, name, val );
				}
				//set as string
				else
				{
					Reflect.setProperty( obj, name, value );
				}
			}
			
			m_objects.push( obj );
		}
	}
	
	public function construct():Void
	{
		//construct backgrounds
		
		//construct objects
		for ( obj in m_objects )
		{
			var cl:Class<Dynamic> = Type.resolveClass( obj.definition );
			if ( cl == null )
			{
				Debug.log( "Class not found: " + obj.definition );
				continue;
			}
			
			//intentionally not setting var type so it's set during runtime
			var classObj = Type.createInstance( cl, [] );
			PropUtils.copyProperties( obj, classObj );
		}
		
		//construct vectors
		
		onConstructionComplete();
	}
	
	private function onConstructionComplete():Void
	{
		//handle on done
		dispatchEvent( new Event( "maizConstructionComplete" ) );
	}
}