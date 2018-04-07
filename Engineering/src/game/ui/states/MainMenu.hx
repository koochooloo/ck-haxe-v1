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

package game.ui.states;
import away3d.bounds.BoundingSphere;
import away3d.containers.View3D;
import away3d.core.math.MathConsts;
import away3d.core.pick.PickingColliderType;
import away3d.core.pick.PickingType;
import away3d.debug.AwayStats;
import away3d.entities.Mesh;
import away3d.entities.SegmentSet;
import away3d.events.Asset3DEvent;
import away3d.events.MouseEvent3D;
import away3d.library.assets.Asset3DType;
import away3d.lights.DirectionalLight;
import away3d.materials.ColorMaterial;
import away3d.materials.TextureMaterial;
import away3d.materials.lightpickers.StaticLightPicker;
import away3d.primitives.LineSegment;
import away3d.primitives.SphereGeometry;
import away3d.utils.Cast;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.app.Application;
import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.debug.tunables.Tunables;
import com.firstplayable.hxlib.display.OPSprite;
import com.firstplayable.hxlib.loader.ResMan;
import com.firstplayable.hxlib.utils.MathUtils;
import com.firstplayable.hxlib.utils.Utils;
import game.Country;
import game.controllers.FlowController;
import game.def.DemoDefs;
import game.events.ZoomEvent;
import game.ui.SpeckMenu;
import game.utils.GeoJsonUtils;
import haxe.Timer;
import motion.Actuate;
import openfl.display.BitmapData;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.geom.Vector3D;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
#if (debug || build_cheats) 
import com.firstplayable.hxlib.debug.DebugDefs;
import com.firstplayable.hxlib.debug.events.RefreshUIEvent;
#end

/**
 * The type of data we have for a country
 * as is relevant to the main menu.
 */
enum CountryType
{
	FULL;			//Have border data, name + fact, and curriculum.
	COMING_SOON;	//Have border data, and name + fact
	EMPTY;			//May have border data, nothing else.
}

typedef MenuCountryData =
{
	var code:String;
	@:optional var name:String;
	var type:CountryType;
	var borders:Array<SegmentSet>;
}

class MainMenu extends SpeckMenu
{
	private static inline var GLOBE_IDLE_TIMEOUT_SEC:Float = 5.0;
	private static inline var GLOBE_TWEEN_TO_TOUCH_SEC:Float = 1.0;
	private static inline var SPHERE_ROTATE_DEG_PER_SEC:Float = 360.0 / 60.0; // rotate every 60 seconds
	private static inline var GLOBE_POPUP_X:Float = 100;
	private static inline var GLOBE_CENTER_X:Float = 0;
	
	private static inline var START_GLOBE_AXIS_PITCH_DEGREES:Float = -15; // negative = north pole toward cam
	private static inline var GLOBE_MAX_AXIS_PITCH_DEGREES:Float = 75; // magnitude in degrees, stay below 90
	
	public static inline var GLOBE_MODEL:String = "3d/globe.3ds";
	public static inline var GLOBE_TEXTURE:String = "3d/globe.jpg";
	private static inline var GLOBE_TEXTURE_MAPPING:String = "EARTH.PNG";
	
	private static inline var GLOBE_RADIUS:Float = 1.0; // Don't change this without checking code, various trig might rely on it...

	//engine variables
	private var _view:View3D;
	
	//light objects
	private var _light:DirectionalLight;
	private var _lightPicker:StaticLightPicker;
	
	//scene objects
	private var _sphereMesh:Mesh;
	
	// Timeout period started when?  Non-null only when idle but not yet rotating.
	private var _sphereTimeoutStart:Null<Float> = null;
	// Last rotation update was when?  Non-null when rotating.
	private var _lastSphereRotateStamp:Null<Float> = null;
	
	private var _spherePitchDeg:Float = START_GLOBE_AXIS_PITCH_DEGREES;
	private var _sphereYawDeg:Float = 0;
	private var _sphereRotDirty:Bool = true;
	private var _idling:Bool = true;
	
	// Convenience methods for Actuate; enables .smartRotation
	public var rotationX(get, set):Float; // pitch
	public var rotationY(get, set):Float; // yaw
	
	private function get_rotationX():Float { return _spherePitchDeg; }
	private function set_rotationX(xDeg:Float):Float
	{
		if ( _spherePitchDeg != xDeg ) 
		{
			_spherePitchDeg = xDeg;
			_sphereRotDirty = true; 
		}
		return _spherePitchDeg;
	}
	
	private function get_rotationY():Float { return _sphereYawDeg; }
	private function set_rotationY(yDeg:Float):Float
	{
		if ( _sphereYawDeg != yDeg ) 
		{
			_sphereYawDeg = yDeg;
			_sphereRotDirty = true; 
		}
		return _sphereYawDeg;
	}
	
	private var m_cameraStartPos:Vector3D;
	private var m_curZoom:Float;
	
	//================================================
	// Country data
	//================================================
	private var m_countryMenuData:Map<String, MenuCountryData> = null;
	private var m_selectedCountryCode:String;
	private var m_highlightedBorders:Array<SegmentSet> = null;
	
	//================================================
	// Country Label
	//================================================
	private static inline var COUNTRY_LABEL_ASSET:String = "2d/UI/panel_small";
	
	private var m_countryLabelPanel:DisplayObjectContainer = null;
	private var m_countryLabel:OPSprite = null;
	private var m_countryText:TextField = null;
	
	//================================================
	// Used to track a drag gesture
	//================================================

	/**
	 * Stores the location of the begining of the touch.
	 * Compared against to determine follow yaw and pitch.
	 */
	private var startTouchPoint:Point;
	
	/**
	 * Used only to determine if gesture is a drag or click on the globe.
	 */
	private var startGlobeTouchPoint:Vector3D;
	
	/**
	 * Tracks the time when the gesture started
	 */
	private var startTouchTime:Float;
	
	/**
	 * The yaw rotation at the start of the touch.
	 */
	private var startYaw:Float;
	
	/**
	 * The pitch rotation at the start of the touch.
	 */
	private var startPitch:Float;
	
	/**
	 * The current touch position. Used to determine yaw and pitch.
	 */
	private var curTouchPoint:Point;
	
	/**
	 * How much spinning should occur after a swipe gesture is registered.
	 */
	private var swipeVelocity:Point;
	
	private var swipeVelocityX:Float = 0;
	private var swipeVelocityY:Float = 0;
	
	private var prevSwipeSpinTime:Null<Float> = null;
	

	public function new() 
	{
		super( "MainMenu" );
		startTouchPoint = null;
		startTouchTime = 0;
		curTouchPoint = null;
		swipeVelocity = null;
		
		m_selectedCountryCode = null;
		m_highlightedBorders = null;
		
//#if ENABLE_3D_TEST
		// See SplashState.loadMenu for addRes and load.
		startGlobeTouchPoint = null;
		load3D();
//#end // #if ENABLE_3D_TEST

		m_curZoom = 0.0;

		createAllCountryMenuData();
	}
	
	private function load3D():Void
	{
		// Away3D test		
		hideObject( "bg" ); // DO NOT CHECK IN (yet)
		var bg:OPSprite = getChildAs( "bg", OPSprite );
		var bgBMD:BitmapData = bg != null ? bg.getBitmapData() : null;
		
		//
		// Modified from Load3DS sample from away3d-samples 5,0,2:
		// https://github.com/openfl/away3d-samples/blob/5.0.2/basic/Load3DS/Source/Main.hx
		//
		
		//setup the view
		_view = new View3D();
		if ( bgBMD != null && MathUtils.isPow2( bgBMD.width ) && MathUtils.isPow2( bgBMD.height ) && bgBMD.width <= 2048 && bgBMD.height <= 2048 )
		{
			_view.background = Cast.bitmapTexture( bgBMD );
		}
		else
		{
			Debug.log( "WARNING: skipping bg set: bg not present, not pow2 dims, or >2048." );
		}
		_view.backgroundColor = 0xFF000000; // 0xFF73E0F6;
		_view.backgroundAlpha = 0xFF;
		
		_view.touchPicker = PickingType.RAYCAST_BEST_HIT;
		_view.mousePicker = PickingType.RAYCAST_BEST_HIT;
		
		//setup the lights for the scene
		_light = new DirectionalLight(-1, -1, 1);
		_lightPicker = new StaticLightPicker([_light]);
		_view.scene.addChild(_light);
		
		//setup the url map for textures in the 3ds fil
		var sphereGeo:SphereGeometry = new SphereGeometry( GLOBE_RADIUS, 16*2, 12*2 );
		var sphereMat:TextureMaterial = new TextureMaterial( Cast.bitmapTexture( ResMan.instance.getImageData( GLOBE_TEXTURE ) ) );
		sphereMat.ambient = 1;

		var sphereMesh:Mesh = new Mesh( sphereGeo, sphereMat );
		sphereMesh.scale(220);
		sphereMesh.z = -400;
		var boundingSphere:BoundingSphere = new BoundingSphere();
		boundingSphere.fromSphere( sphereMesh.getPosition(), sphereGeo.radius );
		sphereMesh.bounds = boundingSphere;
		sphereMesh.mouseEnabled = true;
		sphereMesh.pickingCollider = PickingColliderType.HAXE_BEST_HIT;
		sphereMesh.addEventListener( MouseEvent3D.MOUSE_DOWN, onGlobeMouseDown);
		sphereMesh.name = "Globe";
		
		_sphereMesh = sphereMesh;
		_view.scene.addChild(_sphereMesh);
			
		//=============================================
		// Setup camera
		//=============================================
		
		//setup the camera for optimal shadow rendering
		_view.camera.lens.far = 2100;
		//Debug.dump( sphereMesh.pivotPoint.toString() );
		//Debug.dump( sphereMesh.position );
		//Debug.dump( sphereMesh.scenePosition );
		_view.camera.lookAt( new Vector3D( 0, 0, 0 ) );
		
		m_cameraStartPos = _view.camera.position;
		
#if (debug || build_cheats) 
		//add stats panel
		addChild(new AwayStats(_view));
		//addDebugReferencePoints();
#end // #if ! shipping

		if ( stage != null )
		{
			add3DListeners();
		}
		else
		{
			// Defer until onAddedToStage.
		}
		
	}
	
	private function add3DListeners():Void
	{
		// (possibly deferred) add listeners		
		Utils.safeAddListener(this, Event.ENTER_FRAME, onEnterFrame);
		//Utils.safeAddListener(stage, MouseEvent.MOUSE_DOWN, onMouseDown);
		//Utils.safeAddListener(stage, MouseEvent.MOUSE_UP, onMouseUp);
		Utils.safeAddListener(stage, Event.RESIZE, onResize);
		onResize();	
		
		if ( _view != null )
		{
			stage.addChildAt(_view,0);
		}
	
	}
	
	private function onGlobeMouseDown( event:MouseEvent3D ):Void
	{
		cancelIdle();
		
		startGlobeTouchPoint = event.localPosition;
		startTouchTime = Timer.stamp();
		startYaw = this.rotationY;
		startPitch = this.rotationX;
		
		curTouchPoint = null;
		swipeVelocity = null;
		swipeVelocityX = 0;
		swipeVelocityY = 0;
		prevSwipeSpinTime = null;
	}
	
	private function cancelIdle():Void
	{
		_sphereTimeoutStart = null;
		_lastSphereRotateStamp = null;
	}
	
	// Start the globe idle timeout, if it's not already started or idling.
	private function startIdle():Void
	{
		if (!Tunables.GLOBE_IDLE || !_idling )
		{
			return;
		}
		
		if ( _lastSphereRotateStamp == null )
		{
			if ( _sphereTimeoutStart == null )
			{
				var now:Float = Timer.stamp();
				_sphereTimeoutStart = now;
				// Cancel all tweens (for now -- TODO revisit this)
				// Null-safe.
				Actuate.stop( _sphereMesh, null, false, false );
			}
		}
		else
		{
			//Debug.log( "Logic error: Sphere rotate, but also had started a timeout to rotate, resetting timeout..." );
			_sphereTimeoutStart = null;
		}
	}
	
	override private function onAddedToStage(e:Event):Void
	{
		super.onAddedToStage(e);
		add3DListeners();
		
		cancelIdle();
		_sphereTimeoutStart = Timer.stamp() - GLOBE_IDLE_TIMEOUT_SEC; // start timed out
		
		startTouchPoint = null;
		m_selectedCountryCode = null;
		m_highlightedBorders = null;
		startYaw = this.rotationY;
		
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		stage.addEventListener(MouseEvent.MOUSE_OUT,  onMouseOut);
		stage.addEventListener(MouseEvent.MOUSE_UP,   onMouseUp);
		
		SpeckGlobals.event.addEventListener(ZoomEvent.ZOOM_EVENT, onZoomUpdate);
		#if (debug || build_cheats) 
		DebugDefs.debugEventTarget.addEventListener(RefreshUIEvent.REFRESH_UI_EVENT, onUIUpdated);
		#end
	}
	
	private function onMouseDown(e:MouseEvent):Void
	{
		startTouchPoint = new Point(e.stageX, e.stageY);
	}
	
	private function onMouseMove(e:MouseEvent):Void
	{
		if ((startGlobeTouchPoint == null) || (startTouchPoint == null))
		{
			return;
		}
		var mousePos:Point = new Point(e.stageX, e.stageY);		
		curTouchPoint = mousePos;
		swipeVelocity = curTouchPoint.subtract(startTouchPoint);
		
		//Yaw
		//Allows dragging to the edge of the screen to rotate ~180 degrees
		var xDiff:Float = -(e.stageX - startTouchPoint.x) / ( lime.app.Application.current.window.width * Tunables.GLOBE_ROTATION_RATIO) ;
		var yawRads:Float = (Math.PI * xDiff) / GLOBE_RADIUS;
		var yawDegrees:Float = yawRads * MathConsts.RADIANS_TO_DEGREES;
		
		this.rotationY = startYaw + yawDegrees;

		
		//Pitch
		//Allows dragging to the edge of the screen to rotate ~180 degrees
		var yDiff:Float = -(e.stageY - startTouchPoint.y) / ( lime.app.Application.current.window.height * Tunables.GLOBE_ROTATION_RATIO);
		var pitchRads:Float = (Math.PI * yDiff) / GLOBE_RADIUS;
		var pitchDegrees:Float = pitchRads * MathConsts.RADIANS_TO_DEGREES;
		
		this.rotationX = startPitch + pitchDegrees;
	}
	
	private function onMouseUp(e:MouseEvent):Void
	{
		if (!handleSpinGlobeToTouch(e)
		 && !handleSwipeSpinMomentum(e))
		{
			startIdle();
		}
		
		onMouseDone(e);
	}
	
	private function onMouseOut(e:MouseEvent):Void
	{
		if (!handleSwipeSpinMomentum(e))
		{
			startIdle();
		}
		
		onMouseDone(e);
	}
	
	/**
	 * Returns whether or not a swipe gesture was registered,
	 * and sets values to begin swiping
	 * @param	e
	 * @return
	 */
	private function handleSwipeSpinMomentum(e:MouseEvent):Bool
	{
		if (prevSwipeSpinTime != null)
		{
			return true;
		}
		
		if (swipeVelocity == null)
		{
			return false;
		}
		
		var curTime:Float = Timer.stamp();
		var deltaTime = curTime - startTouchTime;
		
		//Swiped to long, not a swipe
		if (deltaTime > Tunables.GLOBE_SWIPE_TIME_EPSILON)
		{
			return false;
		}
		
		var swipeSpeed:Float = swipeVelocity.length / deltaTime * Tunables.SWIPE_SPEED_RATIO;
		//Didn't swipe fast enough
		if (swipeSpeed < Tunables.GLOBE_SWIPE_SPEED_EPSILON)
		{
			return false;
		}
		
		swipeVelocity.normalize(swipeSpeed);
		swipeVelocityX = swipeVelocity.x * Tunables.GLOBE_ROTATION_RATIO;
		swipeVelocityY = swipeVelocity.y * Tunables.GLOBE_ROTATION_RATIO;
		prevSwipeSpinTime = curTime;
		
		return true;
	}
	
	/**
	 * Returns whether or not the player triggered a spin to location
	 * @param	e
	 * @return
	 */
	private function handleSpinGlobeToTouch(e:MouseEvent):Bool
	{
		//==========================================
		// First determine if this is an actual click
		// or a drag in disguise.
		//==========================================
		
		//If this wasn't a "globe touch" then no need to handle globe.
		if (startGlobeTouchPoint == null)
		{
			return false;
		}
		
		if (startTouchPoint == null)
		{
			return false;
		}
		
		var pos:Vector3D = startGlobeTouchPoint;
		
		var upPoint:Point = new Point(e.stageX, e.stageY);
		var dragDiff:Point = upPoint.subtract(startTouchPoint);
		//Won't need this now.
		startGlobeTouchPoint = null;
		startTouchPoint = null;
		
		var delta:Float = dragDiff.length;
		if (delta >= Tunables.GLOBE_ROTATION_EPSILON)
		{
			//This is a drag, do not start "rotate to point"
			return false;
		}
		
		//==========================================
		// This is an actual click! Rotate the globe
		// so that the clicked location is facing the
		// screen.
		//==========================================
		
		cancelIdle();
		
		var posX:Float = pos.x;
		var posY:Float = pos.y;
		var posZ:Float = pos.z;
		
		// Clear any existing tween.
		Actuate.stop( this, null, false, false );

		// 90 degrees CCW from click pos (front) to object facing (right).
		// x,y -> -y,x is a 90 degree rot.
		var yawX = -posZ; // would ordinarily be posX
		var yawY =  posX; // would ordinarily be posZ
		var yawRadians:Float = Math.atan2( yawY, yawX ); // range (-pi,pi]
		if ( yawRadians < 0 ) yawRadians += 2 * Math.PI; // range [0, 2pi)
		var yawDegrees:Float = yawRadians * MathConsts.RADIANS_TO_DEGREES; // range [0,360) - shouldn't need % 360
		Actuate.tween( this, GLOBE_TWEEN_TO_TOUCH_SEC, { rotationY: yawDegrees } ).smartRotation().onComplete( startIdle );
		
		var pitchDegrees:Float = posY * -GLOBE_MAX_AXIS_PITCH_DEGREES; // low on globe = +N degrees pitch (away), high on globe = -N degrees pitch (toward)
		Actuate.tween( this, GLOBE_TWEEN_TO_TOUCH_SEC, { rotationX: pitchDegrees } ).smartRotation();
		
		#if GLOBE_DEBUG
		Debug.dump( _sphereYawDeg );
		Debug.dump( _spherePitchDeg );
		Debug.dump( event.uv );
		Debug.dump( event.localPosition );
		Debug.dump( yawDegrees );
		Debug.dump( pitchDegrees );
		Debug.dump( event.localNormal );
		Debug.dump( event.scenePosition );
		Debug.dump( event.sceneNormal );
		Debug.dump( event.screenX );
		Debug.dump( event.screenY );
		#end
		
		var longitude:Float = longitudeDegreesFromLocalPosition( pos );
		var latitude:Float = latitudeDegreesFromLocalPosition( pos );
		Debug.dump( longitude );
		Debug.dump( latitude );
		if ( GeoJsonUtils.isJsonLoaded() )
		{
			var searchStart:Float = Timer.stamp();
			var cc3s:Array<String> = GeoJsonUtils.getCountryCodes();
			for ( cc3 in cc3s )
			{
				// TO DISABLE (costly) COUNTRY SEARCH,
				// COMMENT OUT THIS BLOCK.
				if ( GeoJsonUtils.isPointInCountry( longitude, latitude, cc3 ) )
				{
					Debug.log( "Point in country: " + Std.string( cc3 ) );
					goToCountry( cc3 );
				}
			}
			var searchTime:Float = Timer.stamp() - searchStart;
			Debug.log( "Country search, ms: " + Std.string( searchTime * 1000 ) );
		}
		
		//==========================================
		// Adds a debug mesh at point
		//==========================================
		/*
		var debugPos:Vector3D = localPositionFromLatLong(latitude, longitude);
		addDebugPoint(debugPos, 0x8080FF);
		*/
		
		return true;
	}
	
	private function onMouseDone(e:MouseEvent):Void
	{
		startTouchPoint = null;
		startYaw = 0;
		startPitch = 0;

		startGlobeTouchPoint = null;
	}
	
	override private function onRemovedFromStage(e:Event):Void
	{
		// Remove all tweens and reset timers.
		Actuate.stop( this, null, false, false );
		cancelIdle();
		
		unhighlightSelectedCountry();
		
		super.onRemovedFromStage(e);
		stage.removeChild(_view);
		
		if (m_countryLabelPanel != null)
		{
			if (m_countryText != null)
			{
				m_countryLabelPanel.removeChild(m_countryText);
			}
			
			if (m_countryLabel != null)
			{				
				m_countryLabelPanel.removeChild(m_countryLabel);
			}
			
			removeChild(m_countryLabelPanel);
		}

		m_countryLabelPanel = null;
		m_countryText = null;
		m_countryLabel = null;
		
		// remove listeners
		Utils.safeRemoveListener(SpeckGlobals.event, ZoomEvent.ZOOM_EVENT, onZoomUpdate);
		
		#if (debug || build_cheats) 
		Utils.safeRemoveListener(DebugDefs.debugEventTarget, RefreshUIEvent.REFRESH_UI_EVENT, onUIUpdated);
		#end
		
		Utils.safeRemoveListener(this, Event.ENTER_FRAME, onEnterFrame);
		Utils.safeRemoveListener(stage, MouseEvent.MOUSE_DOWN, 	onMouseDown);
		Utils.safeRemoveListener(stage, MouseEvent.MOUSE_MOVE, 	onMouseMove);
		Utils.safeRemoveListener(stage, MouseEvent.MOUSE_UP,  	onMouseUp);
		Utils.safeRemoveListener(stage, MouseEvent.MOUSE_OUT, 	onMouseOut);
		Utils.safeRemoveListener(stage, Event.RESIZE, onResize);
	}	
	
	/**
	 * Navigation and render loop
	 */
	private function onEnterFrame(event:Event):Void
	{
		var now:Float = Timer.stamp();

		if ( _sphereMesh != null )
		{
			if ( _sphereTimeoutStart != null )
			{
				// Starting to timeout.
				var toElapsedSec:Float = now - _sphereTimeoutStart;
				if ( toElapsedSec >= GLOBE_IDLE_TIMEOUT_SEC ) {
					// Begin idle.
					_sphereTimeoutStart = null;
					_lastSphereRotateStamp = now;
				}
			}
			if ( _lastSphereRotateStamp != null )
			{
				// Timed out, rotating.
				var deltaTimeSec:Float = now - _lastSphereRotateStamp;
				var degToRotate:Float = SPHERE_ROTATE_DEG_PER_SEC * deltaTimeSec;
				_sphereYawDeg -= degToRotate; // ccw looking down
				_sphereRotDirty = true;
				_lastSphereRotateStamp = now;
			}
			if (prevSwipeSpinTime != null)
			{
				var deltaTimeSec:Float = now - prevSwipeSpinTime;
				prevSwipeSpinTime = now;
				
				//===================================
				//Handle yaw
				//===================================
				var degToRotate:Float = swipeVelocityX * deltaTimeSec;
				
				if (swipeVelocityX != 0)
				{
					_sphereYawDeg -= degToRotate;
					_sphereRotDirty = true;
				}
				
				swipeVelocityX = swipeVelocityX * Tunables.SWIPE_DECAY_RATIO;
				if (swipeVelocityX < 0)
				{
					swipeVelocityX += Tunables.GLOBE_SWIPE_DECAY;
					if (swipeVelocityX > 0)
					{
						swipeVelocityX = 0;
					}
				}
				else if (swipeVelocityX > 0)
				{
					swipeVelocityX -= Tunables.GLOBE_SWIPE_DECAY;
					if (swipeVelocityX < 0)
					{
						swipeVelocityX = 0;
					}
				}
			
				//===================================
				//Handle Pitch
				//===================================
				degToRotate = swipeVelocityY * deltaTimeSec;
				
				if (swipeVelocityY != 0)
				{
					_spherePitchDeg -= degToRotate;
					_sphereRotDirty = true;
				}
				
				swipeVelocityY = swipeVelocityY * Tunables.SWIPE_DECAY_RATIO;
				
				if (swipeVelocityY < 0)
				{
					swipeVelocityY += Tunables.GLOBE_SWIPE_DECAY;
					if (swipeVelocityY > 0)
					{
						swipeVelocityY = 0;
					}
				}
				else if (swipeVelocityY > 0)
				{
					swipeVelocityY -= Tunables.GLOBE_SWIPE_DECAY;
					if (swipeVelocityY < 0)
					{
						swipeVelocityY = 0;
					}
				}
				
				//===================================
				//Check if we're done spinning
				//===================================
				if((swipeVelocityX == 0) && (swipeVelocityY == 0))
				{
					//Done spinning
					prevSwipeSpinTime = null;
				}
			}
			if ( _sphereRotDirty )
			{
				// TODO: there's probably a faster way of doing this all at once;
				// see Object3D.rotate impl
				_sphereMesh.rotateTo( _spherePitchDeg, 0, 0 );
				_sphereMesh.rotate( _sphereMesh.upVector, _sphereYawDeg );
			}
		}
		
		if (m_selectedCountryCode != null)
		{
			showLabelForCountry(m_selectedCountryCode);
		}
		
		if ( _view != null )
		{
			_view.render();
		}
	}
	
	/**
	 * Listener function for asset complete event on loader
	 */
	private function onAssetComplete(e:Event):Void
	{
		var event:Asset3DEvent = cast(e, Asset3DEvent);
		if (event.asset.assetType == Asset3DType.MESH) {
			var mesh:Mesh = cast(event.asset, Mesh);
			mesh.castsShadows = true;
		} else if (event.asset.assetType == Asset3DType.MATERIAL) {
			var material:TextureMaterial = cast(event.asset, TextureMaterial);
			//DISABLED//material.shadowMethod = new FilteredShadowMapMethod(_light);
			material.lightPicker = _lightPicker;
			material.gloss = 30;
			material.specular = 1;
			material.ambientColor = 0x303040;
			material.ambient = 1;
		}
	}
	
	/**
	 * stage listener for resize events
	 */
	private function onResize(event:Event = null):Void
	{
		if ( _view != null )
		{
			// Cribbed from Display.makeGameLayer,
			// with alterations for max res in 3d
			var scale:Float = Application.app.calculateScale( ScaleMode.FIT );
		
			var appWidth:Float = Application.app.appSize.x;
			var appHeight:Float = Application.app.appSize.y;
		
			var assetWidth:Float = Application.app.targetSize.x;
			var assetHeight:Float = Application.app.targetSize.y;
		
			// Center the layer on the screen
			// (Already done by parent layer)
			_view.x = ( appWidth / 2 ) - ( assetWidth * scale / 2 );
			_view.y = ( appHeight / 2 ) - ( assetHeight * scale / 2 );
		
			
			_view.width = appWidth - ( _view.x * 2 );
			_view.height = appHeight - ( _view.y * 2 );
		}
	}
	
	// 
	// Menu transition 
	// 
	
	private function goToCountry( code:String )
	{
		WebAudio.instance.play( "SFX/country1_click" );	
		
		//=============================================
		// Country data
		//=============================================
		for ( country in SpeckGlobals.dataManager.allCountries )
		{
			if ( code == country.code /*&& ( DemoDefs.DEMOCOUNTRIES.indexOf(country.name) >= 0 )*/ )
			{
				// Set flow params and display countryMenu popup description
				FlowController.data.selectedCountry = country;
				SpeckGlobals.hud.showChefPopup();
	
				// Move globe over for popup and stop rotation on the selected country
				shiftGlobeForPopup();
				
				cancelIdle();
			}
		}
		
		onSelectedCountry(code);
	}
	
	public function focusInCountry( code ):Void
	{
		// Rotate globe to country pos
		rotateToCountry( code );
		
		// Move globe over for popup and stop rotation on the selected country
		shiftGlobeForPopup();
		
		onSelectedCountry(code);
		
		cancelIdle();
	}
	
	private function shiftGlobeForPopup():Void
	{
		// Disable hud 
		SpeckGlobals.hud.toggleButtonVisibility( 4, false );
		SpeckGlobals.hud.toggleButtonVisibility( 1, false );
		
		// Move globe over for character popup
		_sphereMesh.x = GLOBE_POPUP_X;
		
		// Stop rotation & idle timeout 
		Actuate.stop( _sphereMesh );
		//_idling = false;
		
		updateZoom();
	}
	
	public function resetGlobe():Void
	{
		// Enable hud
		SpeckGlobals.hud.toggleButtonVisibility( 4, true );
		SpeckGlobals.hud.toggleButtonVisibility( 1, true );
		
		// Recenter globe
		_sphereMesh.x = GLOBE_CENTER_X;
		
		// Reset zoom
		m_curZoom = 0;
		SpeckGlobals.hud.resetZoomButton();
		
		// Restart idle
		//_idling = true;
		updateZoom();
	}
	
	// Using logic from handleSpinGlobeToTouch
	private function rotateToCountry( code ):Void
	{
		// Grab country coordinates from GeoJSON ( returns long/lat, relative to globe sphere )
		var features:Array<Dynamic> = GeoJsonUtils.getFeaturesForCountry( code );
		var geometry:Dynamic = features[0].geometry;
		var coords:Array<Dynamic> = geometry.coordinates; 
		
		var point:Array<Dynamic> = null;
		if ( geometry.type == "MultiPolygon" )
		{
			point = coords[0][0][0];
		}
		else
		{
			point = coords[0][0];
		}
		var latCountry:Float = point[1] ;
		var longCountry:Float = point[0];
		
		// Translate country lat/long coordinates to local scene coordinates
		var countryPos:Vector3D = localPositionFromLatLong( latCountry, longCountry );
		var posX:Float = countryPos.x;
		var posY:Float = countryPos.y;
		var posZ:Float = countryPos.z;
		
		// Clear any existing tween.
		Actuate.stop( this, null, false, false );

		// Rotate logic from handleSpinGlobeToTouch:
		// 		90 degrees CCW from click pos (front) to object facing (right).
		// 		x,y -> -y,x is a 90 degree rot.
		var yawX = -posZ; // would ordinarily be posX
		var yawY =  posX; // would ordinarily be posZ
		var yawRadians:Float = Math.atan2( yawY, yawX ); // range (-pi,pi]
		if ( yawRadians < 0 ) yawRadians += 2 * Math.PI; // range [0, 2pi)
		var yawDegrees:Float = yawRadians * MathConsts.RADIANS_TO_DEGREES; // range [0,360) - shouldn't need % 360
		Actuate.tween( this, GLOBE_TWEEN_TO_TOUCH_SEC, { rotationY: yawDegrees } ).smartRotation().onComplete( startIdle );
		
		var pitchDegrees:Float = posY * -GLOBE_MAX_AXIS_PITCH_DEGREES; // low on globe = +N degrees pitch (away), high on globe = -N degrees pitch (toward)
		Actuate.tween( this, GLOBE_TWEEN_TO_TOUCH_SEC, { rotationX: pitchDegrees } ).smartRotation();
	}
	
	// Used to disable globe interaction (eg during the Tutorial)
	public function toggleMouseEnabled( enabled:Bool ):Bool
	{
		_sphereMesh.mouseEnabled = enabled;
		return _sphereMesh.mouseEnabled;
	}
	
	//===============================================
	// Geography Graphics
	//===============================================
	
	/**
	 * Creates the MainMenu specific data struct for all
	 * countries in our data set.
	 */
	private function createAllCountryMenuData()
	{
		if (m_countryMenuData != null)
		{
			return;
		}
		
		m_countryMenuData = new Map<String, MenuCountryData>();
		
		var numCountry:Int = 0;
		for ( country in SpeckGlobals.dataManager.allCountries )
		{
			var type:CountryType = getCountryDataType(country);
			var nextCountry:String = country.code;
			var name:String = country.name;
			var nextBorders:Array<SegmentSet> = null;
			if (type == FULL || type == COMING_SOON )
			{
				// nextBorders = createBordersForCountry(nextCountry);
			}
			
			var nextData:MenuCountryData = 
			{
				code:country.code,
				name:name,
				type:type,
				borders:nextBorders
			};
			
			m_countryMenuData[nextCountry] = nextData;
			
			++numCountry;
		}
	}
	
	/**
	 * Gets the enum value representing the type of data we
	 * have for the provided country.
	 * @param	country
	 * @return
	 */
	private function getCountryDataType(country:Country):CountryType
	{
		//=============================================
		// Country data
		//=============================================
		if ((country.name == null) || (country.facts == null) || (country.facts.length == 0))
		{
			return EMPTY;
		}
		else if ( DemoDefs.DEMOCOUNTRIES.indexOf(country.name) >= 0 )
		{
			return FULL;
		}
		else
		{
			return COMING_SOON;
		}
	}
	
	/**
	 * Draws the borders for the provided country
	 * @param	code
	 */
	private function createBordersForCountry(code:String, ?radius:Float, 
		?color:Int = null, ?thickness:Float = null):Array<SegmentSet>
	{
		if (radius == null)
		{
			radius = Tunables.BORDER_RADIUS;
		}
		
		if (color == null)
		{
			color = Tunables.BORDER_COLOR;
		}
		
		if (thickness == null)
		{
			thickness = Tunables.BORDER_THICKNESS;
		}
		
		//=============================================
		// Borders
		//=============================================
		var borders:Array<SegmentSet> = [];
		
		var rawBorderPolygons:Array<Dynamic> = GeoJsonUtils.getBorderPolygonsForCountry(code);
		var borderPolygons:Array<Dynamic> = GeoJsonUtils.getSmoothedBorders(rawBorderPolygons, Tunables.BORDER_SMOOTHING);
		var polyIdx:Int = 0;
		for (polygon in borderPolygons)
		{
			var borderSegments:SegmentSet = new SegmentSet();
			borderSegments.name = code + polyIdx;
			
			var borderPoly:Array<Array<Float>> = cast polygon;
			var prevPoint:Vector3D = null;
			for (vertex in borderPoly)
			{
				var nextPoint:Vector3D = localPositionFromLatLong(vertex[1], vertex[0], radius);
				if (prevPoint != null)
				{
					var nextSegment:LineSegment = new LineSegment(prevPoint, nextPoint, 
						color, color, thickness);
					borderSegments.addSegment(nextSegment);
				}
				prevPoint = nextPoint;
			}
			
			_sphereMesh.addChild(borderSegments);
			borders.push(borderSegments);
			
			++polyIdx;
		}
		
		return borders;
	}
	
	/**
	 * Handles shared behavior for when a country becomes selected.
	 * @param	code
	 */
	private function onSelectedCountry(code:String):Void
	{
		if (code == m_selectedCountryCode)
		{
			return;
		}
		
		unhighlightSelectedCountry();
		
		m_selectedCountryCode = code;
		
		highlightCountry(m_selectedCountryCode);
		showLabelForCountry(m_selectedCountryCode);
	}
	
	/**
	 * Highlights the provided country,
	 * and de-highlights the currently highlighted one,
	 * if any.
	 */
	private function highlightCountry(code:String):Void
	{		

		
		m_highlightedBorders = createBordersForCountry(m_selectedCountryCode, 
		 Tunables.BORDER_HIGHLIGHT_RADIUS, Tunables.BORDER_HIGHLIGHT_COLOR, Tunables.BORDER_HIGHLIGHT_THICKNESS);
	}
	
	/**
	 * Unhighlights the provided country.
	 */
	private function unhighlightSelectedCountry():Void
	{
		if (m_highlightedBorders != null)
		{
			for (border in m_highlightedBorders)
			{
				_sphereMesh.removeChild(border);
				border = null;
			}
			
			m_highlightedBorders = null;
		}
	}
	
	/**
	 * Shows a label for the selected country.
	 * @param	code
	 */
	private function showLabelForCountry(code:String):Void
	{	
		var countryName:String = capitalize( m_countryMenuData[code].name );
		
		if (countryName == null)
		{
			if (m_countryLabel != null)
			{
				m_countryLabel.visible = false;
			}
			return;
		}
		
		//=======================================
		// Get position used to place label
		//=======================================
		var centerPos:Vector3D = getMiddleOfCountry(code);
		centerPos = _sphereMesh.sceneTransform.transformVector(centerPos);
		var screenPos:Point = calcScreenPosition(centerPos);
		
		//=======================================
		// Construct Label if we don't have one
		//=======================================
		if (m_countryLabelPanel == null)
		{
			m_countryLabelPanel = new DisplayObjectContainer();
			m_countryLabelPanel.mouseEnabled = false;
			m_countryLabelPanel.mouseChildren = false;

			m_countryLabel = new OPSprite(ResMan.instance.getImage(COUNTRY_LABEL_ASSET));
			m_countryLabel.setScale(Tunables.LABEL_SCALE);
			m_countryLabel.alpha = Tunables.LABEL_BACKING_ALPHA;
			m_countryLabelPanel.addChild(m_countryLabel);
			
			m_countryText = new TextField();
			var textWidth = m_countryLabel.width;
			var textHeight = m_countryLabel.height;
			
			m_countryText.width = textWidth;
			m_countryText.height = textHeight;
			m_countryText.textColor = Tunables.LABEL_FONT_COLOR;
			
			var format:TextFormat = new TextFormat(Tunables.LABEL_FONT, 12, true);
			format.align = TextFormatAlign.CENTER;
			m_countryText.setTextFormat(format);
			
			m_countryLabelPanel.addChild(m_countryText);
			
			addChild(m_countryLabelPanel);
		}
		
		//============================================
		// If the country name has changed, update font.
		//============================================
		if (m_countryText.text != countryName)
		{			
			var maxWidth:Float = m_countryLabel.width - ((Tunables.LABEL_H_BORDER * 2));
			var maxHeight:Float = m_countryLabel.height - ((Tunables.LABEL_V_BORDER * 2));
			
			m_countryText.width = maxWidth;
			m_countryText.height = maxHeight;
			
			m_countryText.text = countryName;
			
			//If text is too small, expand until it fits.
			if (m_countryText.textHeight < maxHeight)
			{
				while ((m_countryText.textHeight < maxHeight))
				{
					var format:TextFormat = m_countryText.getTextFormat();
					
					var curSize:Int = m_countryText.getTextFormat().size;
					var newSize:Int = curSize + 1;
					var format:TextFormat = m_countryText.getTextFormat();
					format.size = newSize;
					m_countryText.setTextFormat(format);
				}
			}
			
			//If text is too wide, shrink until it fits.
			if (m_countryText.textWidth > maxWidth)
			{
				var format:TextFormat = m_countryText.getTextFormat();
				while ((m_countryText.textWidth > maxWidth) && (format.size > 1))
				{					
					var curSize:Int = m_countryText.getTextFormat().size;
					var newSize:Int = curSize - 1;
					var format:TextFormat = m_countryText.getTextFormat();
					format.size = newSize;
					m_countryText.setTextFormat(format);
					
					format = m_countryText.getTextFormat();
				}
			}
			
			var format:TextFormat = m_countryText.getTextFormat();
			
			//1.2 is to allow space for fonts with letters that drop below the base
			//line. eg. q or j.
			m_countryText.height = Math.ceil(m_countryText.textHeight * 1.2);
			m_countryText.x = - m_countryText.width / 2;
			m_countryText.y = -Math.ceil((m_countryText.height / 2) + 1);
		}
		
		//===============================================
		// Place the Label
		//===============================================
		m_countryLabelPanel.x = screenPos.x + Tunables.LABEL_H_OFFSET;
		m_countryLabelPanel.y = screenPos.y + Tunables.LABEL_V_OFFSET;
		
		//===============================================
		// Determine Label Visibility
		//===============================================
		m_countryLabelPanel.visible = (centerPos.z < Tunables.LABEL_Z_CUTOFF);
		
		m_countryLabel.visible = Tunables.LABEL_BACKING_VISIBLE;
	}
	
	private function calcScreenPosition(scenePos:Vector3D):Point
	{
		var screenPos3D:Vector3D = _view.project(scenePos);
		
		//==========================================
		// The projection doesn't appear to take scaling
		// into account when mapping the scene position
		// to scene coordiantes. 
		//
		// This division by scale here provides an offset
		// that ensures the label appears in the correct
		// position regardless of scale.
		//==========================================
		var screenScaleX:Float = 1.0;
		var screenScaleX:Float = 1.0;
		if (parent != null)
		{
			screenScaleX = parent.scaleX;
			screenScaleX = parent.scaleY;
		}
		
		var screenX:Float = screenPos3D.x / screenScaleX;
		var screenY:Float = screenPos3D.y / screenScaleX;
		
		return new Point(screenX, screenY);
	}
	
	private function onZoomUpdate(e:ZoomEvent):Void
	{
		updateZoom(e.zoomPercent);
	}
	
	/**
	 * Handles the changing zoom level.
	 * @param	newZoom
	 */
	private function updateZoom(?zoom:Null<Float>):Void
	{
		var newZoom:Float = m_curZoom;
		if (zoom != null)
		{
			newZoom = zoom;
		}
		
		if (newZoom < 0)
		{
			newZoom = 0;
		}
		if (newZoom > 1)
		{
			newZoom = 1.0;
		}
		
		var effectiveZoom:Float = newZoom * (Tunables.MAX_ZOOM / 100);
		
		var zoomDelta:Vector3D = _sphereMesh.position.subtract(m_cameraStartPos);
		zoomDelta.scaleBy(effectiveZoom);
		var newPosition:Vector3D = m_cameraStartPos.add(zoomDelta);
		
		_view.camera.position = newPosition;
		
		m_curZoom = newZoom;
	}
	
	#if (debug || build_cheats) 
	private function onUIUpdated(e:RefreshUIEvent):Void
	{
		updateZoom(Tunables.ZOOM / 100);
		
		//=============================================
		// Recreate the label to reflect new parameters
		//=============================================
		if (m_countryLabelPanel != null)
		{
			if (m_countryLabel != null)
			{
				m_countryLabelPanel.removeChild(m_countryLabel);
				m_countryLabel = null;
			}
			if (m_countryText != null)
			{
				m_countryLabelPanel.removeChild(m_countryText);
				m_countryText = null;
			}
			
			removeChild(m_countryLabelPanel);
			m_countryLabelPanel = null;
		}

		
		if (m_selectedCountryCode != null)
		{
			showLabelForCountry(m_selectedCountryCode);
		}
	}
	#end
	
	//===============================================
	// Geography Math
	//===============================================
	
	/**
	 * Return the center of the largest border zone in the country.
	 * @param	code
	 * @return
	 */
	private static function getMiddleOfCountry(code:String):Vector3D
	{
		var borderPolygons:Array<Dynamic> = GeoJsonUtils.getBorderPolygonsForCountry(code);
		var largestBorderPoly:Array<Array<Float>> = null;
		
		/**
		 * Find the largest border zone
		 */
		for (polygon in borderPolygons)
		{			
			var borderPoly:Array<Array<Float>> = cast polygon;
			if (largestBorderPoly == null)
			{
				largestBorderPoly = borderPoly;
			}
			else if (borderPoly.length > largestBorderPoly.length)
			{
				largestBorderPoly = borderPoly;
			}
		}
		
		/**
		 * Calculate the center of that border
		 */
		var long:Float = 0;
		var lat:Float = 0;
		
		for (coord in largestBorderPoly)
		{
			long 	+= coord[0];
			lat 	+= coord[1];
		}
		
		long 	/= largestBorderPoly.length;
		lat 	/= largestBorderPoly.length;
		
		return localPositionFromLatLong(lat, long);
	}
	
	private static function latitudeDegreesFromLocalPosition( localPos:Vector3D ):Float
	{
		var hypotenuse:Float = GLOBE_RADIUS;
		var opposite:Float = localPos.y;
		var rad:Float = Math.asin( opposite / hypotenuse );
		return rad * MathConsts.RADIANS_TO_DEGREES;
	}

	private static function longitudeDegreesFromLocalPosition( localPos:Vector3D ):Float
	{
		var rad:Float = Math.atan2( localPos.z, localPos.x ); // range roughly (-pi,pi) = (-180,180)
		rad += Math.PI; // texture starts near meridian = +180/-180, phase shift up to (0,2pi) = (0,360) roughly
		if ( rad > Math.PI )
		{
			// Shift anything > 180 down by 360
			rad -= 2 * Math.PI; // return to (-pi,pi] = (-180,180]
		}
		return rad * MathConsts.RADIANS_TO_DEGREES;
	}
	
	private static function localPositionFromLatLong(latitude:Float, longitude:Float, radiusRatio:Float = 1.0):Vector3D
	{
		var radius:Float = GLOBE_RADIUS * radiusRatio;
		
		//==============================
		// Y
		//==============================
		var latRadians:Float = latitude / MathConsts.RADIANS_TO_DEGREES;
		var y:Float = Math.sin(latRadians) * radius;
		
		//==============================
		// X and Z
		//==============================
		var longRadians:Float = longitude / MathConsts.RADIANS_TO_DEGREES;
		longRadians -= Math.PI;
		var x:Float = Math.cos(latRadians) * Math.cos(longRadians);
		var z:Float = Math.cos(latRadians) * Math.sin(longRadians);
		
		return new Vector3D(x, y, z);
	}
	
	//===============================================
	// Geography Math Debugging
	//===============================================
	
	private static var ms_nextDebugPointID:Int = 0;
	
	private static var DEBUG_RADIUS:Float = GLOBE_RADIUS * 0.05;
	private static var DEBUG_INTERVAL:Float = Math.PI / 8;
	
	private static var ms_DebugInterval:Array<Float> = null;
	private static var DEBUG_INTERVALS(get, never):Array<Float>;
	
	private static function get_DEBUG_INTERVALS():Array<Float>
	{
		if (ms_DebugInterval == null)
		{
			ms_DebugInterval = [];
			var numIntervals:Int = Math.floor((Math.PI * 2) / DEBUG_INTERVAL);
			for (i in 0...numIntervals)
			{
				ms_DebugInterval.push(i * DEBUG_INTERVAL);
			}
		}
		
		return ms_DebugInterval;
	}
	
	/**
	 * Adds reference points at 1, and -1 for each of the dimmensions.
	 */
	private function addDebugReferencePoints():Void
	{
		//Add one at X = 1
		var xRef:Vector3D = new Vector3D(GLOBE_RADIUS, 0, 0);
		addDebugPoint(xRef, 0xFF0000);
		
		//Add one at Y = 1
		var yRef:Vector3D = new Vector3D(0, GLOBE_RADIUS, 0);
		addDebugPoint(yRef, 0x00FF00);
		
		//Add one at Z = 1
		var zRef:Vector3D = new Vector3D(0, 0, GLOBE_RADIUS);
		addDebugPoint(zRef, 0x00FFFF);
		
		//Add points at -1
		
		var nxRef:Vector3D = new Vector3D(-GLOBE_RADIUS, 0, 0);
		addDebugPoint(nxRef, 0x000000);
		
		//Add one at Y = 1
		var nyRef:Vector3D = new Vector3D(0, -GLOBE_RADIUS, 0);
		addDebugPoint(nyRef, 0xC0C0C0);
		
		//Add one at Z = 1
		var nzRef:Vector3D = new Vector3D(0, 0, -GLOBE_RADIUS);
		addDebugPoint(nzRef, 0xFFFFFF);
	}
	
	/**
	 * Adds a debug point to the sphere
	 * @param	localPosition
	 */
	private function addDebugPoint(localPosition:Vector3D, color:Int = 0xFF0000):Mesh
	{
		var debugGeo:SphereGeometry = new SphereGeometry( DEBUG_RADIUS, 16*2, 12*2 );
		var debugMat:ColorMaterial = new ColorMaterial(color);
		debugMat.ambient = 1;

		var debugMesh:Mesh = new Mesh( debugGeo, debugMat );
		
		debugMesh.x = localPosition.x;
		debugMesh.y = localPosition.y;
		debugMesh.z = localPosition.z;

		debugMesh.name = "DebugPoint" + ms_nextDebugPointID;
		++ms_nextDebugPointID;
		
		_sphereMesh.addChild(debugMesh);
		
		return debugMesh;
	}
}