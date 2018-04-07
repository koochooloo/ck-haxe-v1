//
// Copyright (C) 2017, 1st Playable Productions, LLC. All rights reserved.
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

package game.utils;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.debug.tunables.Tunables;
import com.firstplayable.hxlib.loader.ResMan;
import haxe.Timer;
import openfl.geom.Point;
import openfl.geom.Vector3D;

/**
 * Collection of utilities for working with Geo Json data
 */
class GeoJsonUtils
{
	private static var GEOJSON_PATH:String = "3d/geojson/combined/countries_min.json";
	private static var COUNTRIES_GEOJSON:Dynamic = null;
	
	//======================================================
	// Utility Calls
	//======================================================
	
	public static function getCountryCodes():Array<String>
	{
		var cc3s:Array<String> = Reflect.fields( COUNTRIES_GEOJSON );
		return cc3s;
	}
	
	public static function isPointInCountry( longitude:Float, latitude:Float, cc3:String ):Bool
	{		
		var features:Array<Dynamic> = getFeaturesForCountry(cc3);
		if ((features == null) || (features.length == 0))
		{
			return false;
		}
		
		var inCountry:Bool = false;
		
		for ( featureIdx in 0...features.length )
		{
			var feature:Dynamic = features[featureIdx];
			if ( feature == null )
			{
				Debug.warn( 'Country feature was null: $cc3 feature idx $featureIdx' );
				continue;
			}
			
			var geometry:Dynamic = feature.geometry;
			if ( geometry == null )
			{
				Debug.warn( 'Country geometry was null: $cc3 feature idx $featureIdx' );
				continue;
			}
			
			var coordinates:Dynamic = feature.geometry.coordinates;
			if ( coordinates == null || coordinates.length == null || coordinates.length <= 0 )
			{
				Debug.warn( 'Country coordinates array not found or had no entries: $cc3 feature idx $featureIdx' );
				continue;
			}
			
			var geometryType:String = geometry.type;
			if ( geometryType == "Polygon" )
			{
				// Multiple distinct bodies.
				var polygon:Dynamic = coordinates;
				inCountry = isPointInGeoJsonPolygon( longitude, latitude, polygon, '$cc3 feature idx $featureIdx' );
				if ( inCountry ) break;
			}
			else if ( geometryType == "MultiPolygon" )
			{
				for ( polygonIdx in 0...coordinates.length )
				{
					var polygon:Dynamic = coordinates[polygonIdx];
					inCountry = isPointInGeoJsonPolygon( longitude, latitude, polygon, '$cc3 feature idx $featureIdx poly idx $polygonIdx' );
					if ( inCountry ) break;
				}
				if ( inCountry ) break;
			}
		}
		
		return inCountry;
	}
	
	// "isLeft" is actually a cross product, checking the rotation direction.
	// Original docs (see isPointInGeoJsonRing for source):
	//
	// isLeft(): tests if a point is Left|On|Right of an infinite line.
	//    Input:  three points P0, P1, and P2
	//    Return: >0 for P2 left of the line through P0 and P1
	//            =0 for P2  on the line
	//            <0 for P2  right of the line
	//    See: Algorithm 1 "Area of Triangles and Polygons"
	private static inline function isLeft( px:Float, py:Float, v0:Array<Float>, v1:Array<Float> ):Float
	{
		var v0x:Float = v0[0];
		var v0y:Float = v0[1];
		var v1x:Float = v1[0];
		var v1y:Float = v1[1];
		return ( (v1x - v0x) * (py - v0y)
				- (px - v0x) * (v1y - v0y) );
	}
	
	private static function isPointInGeoJsonRing( px:Float, py:Float, ring:Dynamic, debugContext:String = null ):Bool
	{
		if ( ring == null || ring.length == null || ring.length <= 4 )
		{
			Debug.log( "Country polygon ring was null or too small: " + Std.string( debugContext ) );
			return false;			
		}

		// From this point on, we assume types are correct and catch if not.
		try
		{
			// Based loosely on wn_PnPoly and isLeft from http://www.geomalgorithms.com/a03-_inclusion.html :
			// Original license:
			// Copyright 2000 softSurfer, 2012 Dan Sunday
			// This code may be freely used and modified for any purpose
			// providing that this copyright notice is included with it.
			// SoftSurfer makes no warranty for this code, and cannot be held
			// liable for any real or imagined damage resulting from its use.
			// Users of this code must verify correctness for their application.

			// Find how many times the poly winds around 
			
			var wn:Int = 0;
			var v0:Array<Float> = cast ring[0];
			for ( coordIdx in 1...ring.length )
			{
				var v1:Array<Float> = cast ring[coordIdx];
				
				// Explicitly disabled search for likely antimeridian crossings.
				// We have none in current dataset.
				#if GLOBE_SEARCH_FOR_ANTIMERIDIAN_CROSSINGS
				var xDiff:Float = v0[0] - v1[0];
				if ( Math.abs( xDiff ) >= 180.0 ) {
					Debug.log( "Likely antimeridian traversal in: "  + Std.string( debugContext ) );
				}
				#end // #if GLOBE_SEARCH_FOR_ANTIMERIDIAN_CROSSINGS
				
				var v0y:Float = v0[1];
				var v1y:Float = v1[1];
				if ( v0y <= py )
				{
					// Start y <= py
					if ( v1y > py )
					{
						// End y > py
						// v0 to v1 crosses horizontal ray upward
						if ( isLeft( px, py, v0, v1 ) > 0 )
						{
							// px,py left of edge v0->v1
							// Add to winding number;
							// valid "up intersect" of x ray.
							++wn; 
						}
					}
				}
				else
				{
					// Start y >= py
					if ( v1y <= py )
					{
						// End y <= py
						// v0 to v1 crosses horizontal ray downward
						if ( isLeft( px, py, v0, v1 ) < 0 )
						{
							// px,py right of edge v0->v1
							// Subtract from winding number;
							// valid "down intersect" of x ray.
							--wn;
						}
					}
				}
				
				v0 = v1;
			}
			
			// If the poly winds around us more than 0 times,
			// we're inside.
			return wn != 0;
		}
		catch (e:Dynamic)
		{
			Debug.warn( "Country polygon ring iteration error: " + Std.string( debugContext ) );
			return false;
		}
	}

	public static function isPointInGeoJsonPolygon( px:Float, py:Float, polygon:Dynamic, debugContext:String = null ):Bool
	{
		if ( polygon == null || polygon.length == null || polygon.length <= 0 )
		{
			Debug.log( "Country polygon was null or empty: " + Std.string( debugContext ) );
			return false;			
		}
		
		// Inside first (exterior) ring?
		var isInPoly:Bool = isPointInGeoJsonRing( px, py, polygon[0], debugContext );
		if ( ! isInPoly ) 
		{
			// Not in this poly.
			return false;
		}
		
		// Okay, inside exterior ring.
		// Outside any holes? (TODO)
		/*
		for ( ringIdx in 1...polygon.length )
		{
			var isInHole:Bool = isPointInGeoJsonRing( px, py, polygon[ringIdx], debugContext );
			if ( isInHole )
			{
				// Inside a hole.
				isInPoly = false;
				break;
			}			
		}
		*/
		
		return isInPoly;
	}
	
	/**
	 * Gets the polygon data for the provided country
	 * @param	cc3
	 * @return
	 */
	public static function getPolygonsForCountry(cc3:String):Array<Dynamic>
	{
		var polygons:Array<Dynamic> = [];
		
		var features:Array<Dynamic> = getFeaturesForCountry(cc3);
		if ((features == null) || (features.length == 0))
		{
			return polygons;
		}
		
		for ( featureIdx in 0...features.length )
		{
			var feature:Dynamic = features[featureIdx];
			var polygons:Array<Dynamic> = getPolygonsForFeature(feature);
			polygons = polygons.concat(polygons);
		}
		
		return polygons;
	}
	
	/**
	 * Gets the polygon data for the provided feature
	 * @param	cc3
	 * @return
	 */
	public static function getPolygonsForFeature(feature:Dynamic):Array<Dynamic>
	{
		var polygons:Array<Dynamic> = [];
		
		if ( feature == null )
		{
			Debug.warn( 'Country feature was null ');
			return polygons;
		}
		
		var geometry:Dynamic = feature.geometry;
		if ( geometry == null )
		{
			Debug.warn( 'Feature geometry was null' );
			return polygons;
		}
		
		var coordinates:Dynamic = feature.geometry.coordinates;
		if ( coordinates == null || coordinates.length == null || coordinates.length <= 0 )
		{
			Debug.warn( 'Feature coordinates array not found or had no entries');
			return polygons;
		}
		
		var geometryType:String = geometry.type;
		if ( geometryType == "Polygon" )
		{
			var polygon:Dynamic = coordinates;
			polygons.push(polygon);
		}
		else if ( geometryType == "MultiPolygon" )
		{
			for ( polygonIdx in 0...coordinates.length )
			{
				var polygon:Dynamic = coordinates[polygonIdx];
				polygons.push(polygon);
			}
		}
		
		return polygons;
	}
	
	/**
	 * Gets the outermost "ring" polygons for the provided country. Null on error
	 * @param	cc3
	 * @return
	 */
	public static function getBorderPolygonsForCountry(cc3:String):Array<Dynamic>
	{
		var polygons:Array<Dynamic> = [];
		
		var features:Array<Dynamic> = getFeaturesForCountry(cc3);
		if ((features == null) || (features.length == 0))
		{
			return polygons;
		}
		
		for ( featureIdx in 0...features.length )
		{
			var feature:Dynamic = features[featureIdx];
			var featurePolygons:Array<Array<Dynamic>> = cast getPolygonsForFeature(feature);
			var featureOuterRings:Array<Dynamic> = [];
			for (featurePoly in featurePolygons)
			{
				featureOuterRings.push(featurePoly[0]);
			}
			polygons = polygons.concat(featureOuterRings);
		}
		
		return polygons;
	}
	
	/**
	 * Returns a collection of borders that are a smoothed version of the borders passed in.
	 * All adjacent segments of length smaller than threshold are combined together.
	 * @param	borders
	 * @param	threshold
	 * @return
	 */
	public static function getSmoothedBorders(borders:Array<Dynamic>, threshold:Float):Array<Dynamic>
	{
		var returnBorders:Array<Dynamic> = borders.copy();
		
		//=====================================
		// Repeat until the smoothing algorithm
		// makes no changes.
		//=====================================
		var bordersSmoothed = true;
		var iterations:Int = 0;
		while (bordersSmoothed)
		{
			bordersSmoothed = false;
			
			var smoothedBorders:Array<Dynamic> = [];
			
			if (Tunables.DEBUG_SMOOTHING)
			{
				++iterations;
				Debug.log("==========================================");
				Debug.log("==========================================");
				Debug.log("borders at iteration " + iterations + ": ");
				Debug.log("" +returnBorders);
			}
			
			//Smooth each poly and add to smoothedBorders
			for (polygon in returnBorders)
			{
				var smoothedPoly:Array<Array<Float>> = [];
				
				var borderPoly:Array<Array<Float>> = cast polygon;
				var vertexIdx:Int = 0;
				
				while (vertexIdx < borderPoly.length)
				{					
					var vertex0:Array<Float> = borderPoly[vertexIdx];
					var curPoint:Point = new Point(vertex0[0], vertex0[1]);
					
					smoothedPoly.push(vertex0);
					if (vertexIdx < borderPoly.length - 2)
					{
						var vertex1:Array<Float> = borderPoly[vertexIdx + 1];
						var nextPoint1:Point = new Point(vertex1[0], vertex1[1]);
						
						var vertex2:Array<Float> = borderPoly[vertexIdx + 2];
						var nextPoint2:Point = new Point(vertex2[0], vertex2[1]);
						
						var delta1:Float = (nextPoint1.subtract(curPoint)).length;
						var delta2:Float = (nextPoint2.subtract(nextPoint1)).length;
						
						
						if ((delta1 < threshold) && (delta2 < threshold))
						{
							bordersSmoothed = true;
							
							vertexIdx += 2;
						}
						else
						{						
							vertexIdx += 1;
						}
					}
					else
					{
						vertexIdx += 1;
					}
				}
				
				smoothedBorders.push(smoothedPoly);
			}
			
			returnBorders = smoothedBorders;
		}

		return returnBorders;
	}
	
	/**
	 * Gets all of the "feature" data for the provided country
	 * @param	cc3
	 * @return
	 */
	public static function getFeaturesForCountry(cc3:String):Array<Dynamic>
	{
		var features:Array<Dynamic> = [];
		
		// TODO: reduce checks in here (and callees) with try/catch around deref chains
		if ( cc3 == null )
		{
			Debug.warn( "Null cc3 passed to getFeaturesForCountry." );
			return features;
		}

		if ( COUNTRIES_GEOJSON == null )
		{
			Debug.warn( "Countries not loaded before isPointInCountry." );
			return features;
		}
		
		// First, see if we know this country.
		var geojson:Null<Dynamic> = Reflect.field( COUNTRIES_GEOJSON, cc3 );
		if ( geojson == null )
		{
			Debug.warn( "Country not found: " + Std.string(cc3) );
			return features;
		}
		
		// Check geojson type.
		if ( geojson.type != "FeatureCollection" || geojson.features == null || geojson.features.length == null || geojson.features.length <= 0 )
		{
			// Common in our dataset.  Empty countries are:
			// ALA, BES, BVT, CCK, CXR,
			// ESH, GIB, GLP, GUF, MTQ,
			// MYT, PSE, REU, SJM, SSD,
			// TKL, TUV, UMI
			//DISABLED//Debug.log( 'Country geojson was not FeatureCollection or had no features: $cc3' );
			return features;
		}
		
		return geojson.features;
	}
	
	//======================================================
	// Code for loading geo json data
	//======================================================
	
	public static function loadGeoJson():Void
	{
		if (!isJsonLoaded())
		{
			ResMan.instance.addRes( "GeoJson", { src : GEOJSON_PATH } );
			ResMan.instance.load( "GeoJson", onAllGeoJsonComplete );
		}
	}
	
	public static function isJsonLoaded():Bool
	{
		return COUNTRIES_GEOJSON != null;
	}
	
	private static function onAllGeoJsonComplete()
	{
		var startParseTime:Float = Timer.stamp();
		COUNTRIES_GEOJSON = ResMan.instance.getJson( GEOJSON_PATH );
		if ( COUNTRIES_GEOJSON == null )
		{
			Debug.error( GEOJSON_PATH + " unable to load." );
		}
		var endParseTime:Float = Timer.stamp();
		Debug.log( "GeoJson parse, ms: " + Std.string( ( endParseTime - startParseTime ) * 1000 ) );
		var startUnloadTime:Float = Timer.stamp();
		ResMan.instance.unload( "GeoJson", false );
		var endUnloadTime:Float = Timer.stamp();
		Debug.log( "GeoJson raw unload, ms: " + Std.string( ( endUnloadTime - startUnloadTime ) * 1000 ) );
	}
	
}