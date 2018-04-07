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
package;

import massive.munit.Assert;
import com.firstplayable.hxlib.utils.MathUtils;
import openfl.geom.Point;

class MathUtilsTest 
{
	@Test
	public function testAbsInt():Void
	{
	   Assert.areEqual(0, MathUtils.absInt(0));
	   Assert.areEqual(-0, MathUtils.absInt(0));
	   Assert.areEqual(2, MathUtils.absInt(2));
	   Assert.areEqual(2, MathUtils.absInt(-2));
	   Assert.areEqual(-2, -MathUtils.absInt(2));
	   Assert.areEqual(-2, -MathUtils.absInt(-2));
   }
   
   @Test
   public function testGetLinearPoint():Void
   {
      var p:Point = MathUtils.getLinearPoint(new Point(0,0), new Point(100,0), 50);
      Assert.isTrue(MathUtils.floatEqual(p.x, 50));
      Assert.isTrue(MathUtils.floatEqual(p.y, 0));
           
      p = MathUtils.getLinearPoint(new Point(-40,1000), new Point(-40,0), 2000);
      Assert.isTrue(MathUtils.floatEqual(p.x, -40));
      Assert.isTrue(MathUtils.floatEqual(p.y, -1000));
   }
   
   @Test
   public function testPointAt():Void
   {
      var theta:Float = MathUtils.pointAt(new Point(0,0), new Point(10,10));
      Assert.isTrue(MathUtils.floatEqual(theta, 45));

      theta = MathUtils.pointAt(new Point(0,-100), new Point(0,0));
      Assert.isTrue(MathUtils.floatEqual(theta, 90));

      theta = MathUtils.pointAt(new Point(0,100), new Point(0,0));
      Assert.isTrue(MathUtils.floatEqual(theta, -90));

      theta = MathUtils.pointAt(new Point(10,100), new Point(5,95));
      Assert.isTrue(MathUtils.floatEqual(theta, -135));
   }
   
   @Test
   public function testFloatEqual():Void
   {
      Assert.isTrue(MathUtils.floatEqual(0.0, 0.000001));
      Assert.isTrue(MathUtils.floatEqual(0.0, -0.000001));
      Assert.isTrue(MathUtils.floatEqual(10000.0, 10000.00001));
      Assert.isTrue(MathUtils.floatEqual(-10000.0, -10000.00001));
      Assert.isFalse(MathUtils.floatEqual(10000.0, -10000.00001));
      Assert.isFalse(MathUtils.floatEqual(-10000.0, 10000.00001));
      Assert.isFalse(MathUtils.floatEqual(1000000.0, 1.01));
      Assert.isFalse(MathUtils.floatEqual(100000.0, 0.0001));
      Assert.isFalse(MathUtils.floatEqual(10000000.0, 0.0001));
      Assert.isFalse(MathUtils.floatEqual(1000000000.0, 0.0001));

      Assert.isFalse(MathUtils.floatEqual(1.0e4000, 1.0e-4000));
      Assert.isFalse(MathUtils.floatEqual(1.0e4000, -1.0e-4000));
      Assert.isFalse(MathUtils.floatEqual(-1.0e4000, 1.0e-4000));
      Assert.isFalse(MathUtils.floatEqual(-1.0e4000, -1.0e-4000));
      Assert.isFalse(MathUtils.floatEqual(1.0e-4000, 1.0e4000));
      Assert.isFalse(MathUtils.floatEqual(1.0e-4000, -1.0e4000));
      Assert.isFalse(MathUtils.floatEqual(-1.0e-4000, 1.0e4000));
      Assert.isFalse(MathUtils.floatEqual(-1.0e-4000, -1.0e4000));
   }

   @Test
   public function testLerp():Void
   {
      var p:Point = MathUtils.lerp(new Point(0,0), new Point(100,0), 0.5);
      Assert.isTrue(MathUtils.floatEqual(p.x, 50));
      Assert.isTrue(MathUtils.floatEqual(p.y, 0));

      p = MathUtils.lerp(new Point(100,100), new Point(50,50), 0.5);
      Assert.isTrue(MathUtils.floatEqual(p.x, 75));
      Assert.isTrue(MathUtils.floatEqual(p.y, 75));

      p = MathUtils.lerp(new Point(100,-100), new Point(50,50), 0.0);
      Assert.isTrue(MathUtils.floatEqual(p.x, 100));
      Assert.isTrue(MathUtils.floatEqual(p.y, -100));

      p = MathUtils.lerp(new Point(100,-100), new Point(50,50), 1.0);
      Assert.isTrue(MathUtils.floatEqual(p.x, 50));
      Assert.isTrue(MathUtils.floatEqual(p.y, 50));
   }
   
   @Test
   public function testProject():Void
   {
      var p:Point = MathUtils.project(new Point(50,50), new Point(0,100));
      Assert.isTrue(MathUtils.floatEqual(p.x, 0));
      Assert.isTrue(MathUtils.floatEqual(p.y, 50));

      p = MathUtils.project(new Point(50,50), new Point(50,50));
      Assert.isTrue(MathUtils.floatEqual(p.x, 50));
      Assert.isTrue(MathUtils.floatEqual(p.y, 50));

      p = MathUtils.project(new Point(50,50), new Point(-50,50));
      Assert.isTrue(MathUtils.floatEqual(p.x, 0));
      Assert.isTrue(MathUtils.floatEqual(p.y, 0));
   }

   @Test
   public function testReflect():Void
   {
      var p:Point = MathUtils.reflect(new Point(50,50), new Point(0,100));
      Assert.isTrue(MathUtils.floatEqual(p.x, -50));
      Assert.isTrue(MathUtils.floatEqual(p.y, 50));

      p = MathUtils.reflect(new Point(50,50), new Point(50,50));
      Assert.isTrue(MathUtils.floatEqual(p.x, 50));
      Assert.isTrue(MathUtils.floatEqual(p.y, 50));

      p = MathUtils.reflect(new Point(50,50), new Point(-50,50));
      Assert.isTrue(MathUtils.floatEqual(p.x, -50));
      Assert.isTrue(MathUtils.floatEqual(p.y, -50));
      
      p = MathUtils.reflect(new Point(-50,0), new Point(1,1));
      Assert.isTrue(MathUtils.floatEqual(p.x, 0));
      Assert.isTrue(MathUtils.floatEqual(p.y, -50));
   }
}