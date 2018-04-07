package lime.graphics.utils;


import haxe.ds.Vector;
import haxe.Int32;
import haxe.io.Bytes;
import lime._backend.native.NativeCFFI;
import lime.graphics.Image;
import lime.graphics.ImageBuffer;
import lime.graphics.PixelFormat;
import lime.math.color.ARGB;
import lime.math.color.BGRA;
import lime.math.color.RGBA;
import lime.math.ColorMatrix;
import lime.math.Rectangle;
import lime.math.Vector2;
import lime.system.CFFI;
import lime.system.Endian;
import lime.utils.BytePointer;
import lime.utils.UInt8Array;

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

@:access(lime._backend.native.NativeCFFI)
@:access(lime.graphics.ImageBuffer)
@:access(lime.math.color.RGBA)


class ImageDataUtil {
	
	
	public static function colorTransform (image:Image, rect:Rectangle, colorMatrix:ColorMatrix):Void {
		
		var data = image.buffer.data;
		if (data == null) return;
		
		#if (lime_cffi && !disable_cffi && !macro)
		if (CFFI.enabled) NativeCFFI.lime_image_data_util_color_transform (image, rect, colorMatrix); else
		#end
		{
			
			var format = image.buffer.format;
			var premultiplied = image.buffer.premultiplied;
			
			var dataView = new ImageDataView (image, rect);
			
			var alphaTable = colorMatrix.getAlphaTable ();
			var redTable = colorMatrix.getRedTable ();
			var greenTable = colorMatrix.getGreenTable ();
			var blueTable = colorMatrix.getBlueTable ();
			
			var row, offset, pixel:RGBA;
			
			for (y in 0...dataView.height) {
				
				row = dataView.row (y);
				
				for (x in 0...dataView.width) {
					
					offset = row + (x * 4);
					
					pixel.readUInt8 (data, offset, format, premultiplied);
					pixel.set (redTable[pixel.r], greenTable[pixel.g], blueTable[pixel.b], alphaTable[pixel.a]);
					pixel.writeUInt8 (data, offset, format, premultiplied);
					
				}
				
			}
			
		}
		
		image.dirty = true;
		image.version++;
		
	}
	
	
	public static function copyChannel (image:Image, sourceImage:Image, sourceRect:Rectangle, destPoint:Vector2, sourceChannel:ImageChannel, destChannel:ImageChannel):Void {
		
		var destIdx = switch (destChannel) {
			
			case RED: 0;
			case GREEN: 1;
			case BLUE: 2;
			case ALPHA: 3;
			
		}
		
		var srcIdx = switch (sourceChannel) {
			
			case RED: 0;
			case GREEN: 1;
			case BLUE: 2;
			case ALPHA: 3;
			
		}
		
		var srcData = sourceImage.buffer.data;
		var destData = image.buffer.data;
		
		if (srcData == null || destData == null) return;
		
		#if (lime_cffi && !disable_cffi && !macro)
		if (CFFI.enabled) NativeCFFI.lime_image_data_util_copy_channel (image, sourceImage, sourceRect, destPoint, srcIdx, destIdx); else
		#end
		{
			
			var srcView = new ImageDataView (sourceImage, sourceRect);
			var destView = new ImageDataView (image, new Rectangle (destPoint.x, destPoint.y, srcView.width, srcView.height));
			
			var srcFormat = sourceImage.buffer.format;
			var destFormat = image.buffer.format;
			var srcPremultiplied = sourceImage.buffer.premultiplied;
			var destPremultiplied = image.buffer.premultiplied;
			
			var srcPosition, destPosition, srcPixel:RGBA, destPixel:RGBA, value = 0;
			
			for (y in 0...destView.height) {
				
				srcPosition = srcView.row (y);
				destPosition = destView.row (y);
				
				for (x in 0...destView.width) {
					
					srcPixel.readUInt8 (srcData, srcPosition, srcFormat, srcPremultiplied);
					destPixel.readUInt8 (destData, destPosition, destFormat, destPremultiplied);
					
					switch (srcIdx) {
						
						case 0: value = srcPixel.r;
						case 1: value = srcPixel.g;
						case 2: value = srcPixel.b;
						case 3: value = srcPixel.a;
						
					}
					
					switch (destIdx) {
						
						case 0: destPixel.r = value;
						case 1: destPixel.g = value;
						case 2: destPixel.b = value;
						case 3: destPixel.a = value;
						
					}
					
					destPixel.writeUInt8 (destData, destPosition, destFormat, destPremultiplied);
					
					srcPosition += 4;
					destPosition += 4;
					
				}
				
			}
			
		}
		
		image.dirty = true;
		image.version++;
		
	}
	
	
	public static function copyPixels (image:Image, sourceImage:Image, sourceRect:Rectangle, destPoint:Vector2, alphaImage:Image = null, alphaPoint:Vector2 = null, mergeAlpha:Bool = false):Void {
		
		if (image.width == sourceImage.width && image.height == sourceImage.height && sourceRect.width == sourceImage.width && sourceRect.height == sourceImage.height && sourceRect.x == 0 && sourceRect.y == 0 && destPoint.x == 0 && destPoint.y == 0 && alphaImage == null && alphaPoint == null && mergeAlpha == false && image.format == sourceImage.format) {
			
			image.buffer.data.set (sourceImage.buffer.data);
			
		} else {
			
			#if (lime_cffi && !disable_cffi && !macro)
			if (CFFI.enabled) NativeCFFI.lime_image_data_util_copy_pixels (image, sourceImage, sourceRect, destPoint, alphaImage, alphaPoint, mergeAlpha); else
			#end
			{
				
				var sourceData = sourceImage.buffer.data;
				var destData = image.buffer.data;
				
				if (sourceData == null || destData == null) return;
				
				var sourceView = new ImageDataView (sourceImage, sourceRect);
				var destRect = new Rectangle (destPoint.x, destPoint.y, sourceView.width, sourceView.height);
				var destView = new ImageDataView (image, destRect);
				
				var sourceFormat = sourceImage.buffer.format;
				var destFormat = image.buffer.format;
				
				var sourcePosition, destPosition;
				var sourceAlpha, destAlpha, oneMinusSourceAlpha, blendAlpha;
				var sourcePixel:RGBA, destPixel:RGBA;
				
				var sourcePremultiplied = sourceImage.buffer.premultiplied;
				var destPremultiplied = image.buffer.premultiplied;
				var sourceBytesPerPixel = Std.int (sourceImage.buffer.bitsPerPixel / 8);
				var destBytesPerPixel = Std.int (image.buffer.bitsPerPixel / 8);
				
				var useAlphaImage = (alphaImage != null && alphaImage.transparent);
				var blend = (mergeAlpha || (useAlphaImage && !image.transparent));
				
				if (!useAlphaImage) {
					
					if (blend) {
						
						for (y in 0...destView.height) {
							
							sourcePosition = sourceView.row (y);
							destPosition = destView.row (y);
							
							for (x in 0...destView.width) {
								
								sourcePixel.readUInt8 (sourceData, sourcePosition, sourceFormat, sourcePremultiplied);
								destPixel.readUInt8 (destData, destPosition, destFormat, destPremultiplied);
								
								sourceAlpha = sourcePixel.a / 255.0;
								destAlpha = destPixel.a / 255.0;
								oneMinusSourceAlpha = 1 - sourceAlpha;
								blendAlpha = sourceAlpha + (destAlpha * oneMinusSourceAlpha);
								
								if (blendAlpha == 0) {
									
									destPixel = 0;
									
								} else {
									
									destPixel.r = RGBA.__clamp[Math.round ((sourcePixel.r * sourceAlpha + destPixel.r * destAlpha * oneMinusSourceAlpha) / blendAlpha)];
									destPixel.g = RGBA.__clamp[Math.round ((sourcePixel.g * sourceAlpha + destPixel.g * destAlpha * oneMinusSourceAlpha) / blendAlpha)];
									destPixel.b = RGBA.__clamp[Math.round ((sourcePixel.b * sourceAlpha + destPixel.b * destAlpha * oneMinusSourceAlpha) / blendAlpha)];
									destPixel.a = RGBA.__clamp[Math.round (blendAlpha * 255.0)];
									
								}
								
								destPixel.writeUInt8 (destData, destPosition, destFormat, destPremultiplied);
								
								sourcePosition += 4;
								destPosition += 4;
								
							}
							
						}
						
					} else if (sourceFormat == destFormat && sourcePremultiplied == destPremultiplied && sourceBytesPerPixel == destBytesPerPixel) {
						
						for (y in 0...destView.height) {
							
							sourcePosition = sourceView.row (y);
							destPosition = destView.row (y);
							
							#if js
							// TODO: Is this faster on HTML5 than the normal copy method?
							destData.set (sourceData.subarray (sourcePosition, sourcePosition + destView.width * destBytesPerPixel), destPosition);
							#else
							destData.buffer.blit (destPosition, sourceData.buffer, sourcePosition, destView.width * destBytesPerPixel);
							#end
							
						}
						
					} else {
						
						for (y in 0...destView.height) {
							
							sourcePosition = sourceView.row (y);
							destPosition = destView.row (y);
							
							for (x in 0...destView.width) {
								
								sourcePixel.readUInt8 (sourceData, sourcePosition, sourceFormat, sourcePremultiplied);
								sourcePixel.writeUInt8 (destData, destPosition, destFormat, destPremultiplied);
								
								sourcePosition += 4;
								destPosition += 4;
								
							}
							
						}
						
					}
					
				} else {
					
					if (alphaPoint == null) alphaPoint = new Vector2 ();
					
					var alphaData = alphaImage.buffer.data;
					var alphaFormat = alphaImage.buffer.format;
					var alphaPosition, alphaPixel:RGBA;
					
					var alphaView = new ImageDataView (alphaImage, new Rectangle (alphaPoint.x, alphaPoint.y, alphaImage.width, alphaImage.height));
					alphaView.offset (sourceView.x, sourceView.y);
					
					destView.clip (Std.int (destPoint.x), Std.int (destPoint.y), alphaView.width, alphaView.height);
					
					if (blend) {
						
						for (y in 0...destView.height) {
							
							sourcePosition = sourceView.row (y);
							destPosition = destView.row (y);
							alphaPosition = alphaView.row (y);
							
							for (x in 0...destView.width) {
								
								sourcePixel.readUInt8 (sourceData, sourcePosition, sourceFormat, sourcePremultiplied);
								destPixel.readUInt8 (destData, destPosition, destFormat, destPremultiplied);
								alphaPixel.readUInt8 (alphaData, alphaPosition, alphaFormat, false);
								
								sourceAlpha = (alphaPixel.a / 255.0) * (sourcePixel.a / 255.0);
								
								if (sourceAlpha > 0) {
									
									destAlpha = destPixel.a / 255.0;
									oneMinusSourceAlpha = 1 - sourceAlpha;
									blendAlpha = sourceAlpha + (destAlpha * oneMinusSourceAlpha);
									
									destPixel.r = RGBA.__clamp[Math.round ((sourcePixel.r * sourceAlpha + destPixel.r * destAlpha * oneMinusSourceAlpha) / blendAlpha)];
									destPixel.g = RGBA.__clamp[Math.round ((sourcePixel.g * sourceAlpha + destPixel.g * destAlpha * oneMinusSourceAlpha) / blendAlpha)];
									destPixel.b = RGBA.__clamp[Math.round ((sourcePixel.b * sourceAlpha + destPixel.b * destAlpha * oneMinusSourceAlpha) / blendAlpha)];
									destPixel.a = RGBA.__clamp[Math.round (blendAlpha * 255.0)];
									
									destPixel.writeUInt8 (destData, destPosition, destFormat, destPremultiplied);
									
								}
								
								sourcePosition += 4;
								destPosition += 4;
								alphaPosition += 4;
								
							}
							
						}
						
					} else {
						
						for (y in 0...destView.height) {
							
							sourcePosition = sourceView.row (y);
							destPosition = destView.row (y);
							alphaPosition = alphaView.row (y);
							
							for (x in 0...destView.width) {
								
								sourcePixel.readUInt8 (sourceData, sourcePosition, sourceFormat, sourcePremultiplied);
								alphaPixel.readUInt8 (alphaData, alphaPosition, alphaFormat, false);
								
								sourcePixel.a = Math.round (sourcePixel.a * (alphaPixel.a / 0xFF));
								sourcePixel.writeUInt8 (destData, destPosition, destFormat, destPremultiplied);
								
								sourcePosition += 4;
								destPosition += 4;
								alphaPosition += 4;
								
							}
							
						}
						
					}
					
				}
				
			}
			
		}
		
		image.dirty = true;
		image.version++;
		
	}
	
	
	public static function fillRect (image:Image, rect:Rectangle, color:Int, format:PixelFormat):Void {
		
		var fillColor:RGBA;
		
		switch (format) {
			
			case ARGB32: fillColor = (color:ARGB);
			case BGRA32: fillColor = (color:BGRA);
			default: fillColor = color;
			
		}
		
		if (!image.transparent) {
			
			fillColor.a = 0xFF;
			
		}
		
		var data = image.buffer.data;
		if (data == null) return;
		
		#if (lime_cffi && !disable_cffi && !macro)
		if (CFFI.enabled) NativeCFFI.lime_image_data_util_fill_rect (image, rect, (fillColor >> 16) & 0xFFFF, (fillColor) & 0xFFFF); else // TODO: Better Int32 solution
		#end
		{
			
			var format = image.buffer.format;
			var premultiplied = image.buffer.premultiplied;
			if (premultiplied) fillColor.multiplyAlpha ();
			
			var dataView = new ImageDataView (image, rect);
			var row;
			
			for (y in 0...dataView.height) {
				
				row = dataView.row (y);
				
				for (x in 0...dataView.width) {
					
					fillColor.writeUInt8 (data, row + (x * 4), format, false);
					
				}
				
			}
			
		}
		
		image.dirty = true;
		image.version++;
		
	}
	
	
	public static function floodFill (image:Image, x:Int, y:Int, color:Int, format:PixelFormat):Void {
		
		var data = image.buffer.data;
		if (data == null) return;
		
		if (format == ARGB32) color = ((color & 0xFFFFFF) << 8) | ((color >> 24) & 0xFF);
		
		#if (lime_cffi && !disable_cffi && !macro)
		if (CFFI.enabled) NativeCFFI.lime_image_data_util_flood_fill (image, x, y, (color >> 16) & 0xFFFF, (color) & 0xFFFF); else // TODO: Better Int32 solution
		#end
		{
			
			var format = image.buffer.format;
			var premultiplied = image.buffer.premultiplied;
			
			var fillColor:RGBA = color;
			
			var hitColor:RGBA;
			hitColor.readUInt8 (data, ((y + image.offsetY) * (image.buffer.width * 4)) + ((x + image.offsetX) * 4), format, premultiplied);
			
			if (!image.transparent) {
				
				fillColor.a = 0xFF;
				hitColor.a = 0xFF;
				
			}
			
			if (fillColor == hitColor) return;
			
			if (premultiplied) fillColor.multiplyAlpha();
			
			var dx = [ 0, -1, 1, 0 ];
			var dy = [ -1, 0, 0, 1 ];
			
			var minX = -image.offsetX;
			var minY = -image.offsetY;
			var maxX = minX + image.width;
			var maxY = minY + image.height;
			
			var queue = new Array<Int> ();
			queue.push (x);
			queue.push (y);
			
			var curPointX, curPointY, nextPointX, nextPointY, nextPointOffset, readColor:RGBA;
			
			while (queue.length > 0) {
				
				curPointY = queue.pop ();
				curPointX = queue.pop ();
				
				for (i in 0...4) {
					
					nextPointX = curPointX + dx[i];
					nextPointY = curPointY + dy[i];
					
					if (nextPointX < minX || nextPointY < minY || nextPointX >= maxX || nextPointY >= maxY) {
						
						continue;
						
					}
					
					nextPointOffset = (nextPointY * image.width + nextPointX) * 4;
					readColor.readUInt8 (data, nextPointOffset, format, premultiplied);
					
					if (readColor == hitColor) {
						
						fillColor.writeUInt8 (data, nextPointOffset, format, false);
						
						queue.push (nextPointX);
						queue.push (nextPointY);
						
					}
					
				}
				
			}
			
		}
		
		image.dirty = true;
		image.version++;
		
	}
	
	
	public static function gaussianBlur (image:Image, sourceImage:Image, sourceRect:Rectangle, destPoint:Vector2, blurX:Float = 4, blurY:Float = 4, quality:Int = 1, strength:Float = 1):Image {
		
		// TODO: Support sourceRect better, do not modify sourceImage, create C++ implementation for native
		
		// TODO: Better handling of premultiplied alpha
		var fromPreMult;
		
		if (image.buffer.premultiplied || sourceImage.buffer.premultiplied) {
			
			fromPreMult = function (col:Float, alpha:Float):Int {
				var col = Std.int (col);
				return col < 0 ? 0 : (col > 255 ? 255 : col);
			}
			
		} else {
			
			fromPreMult = function (col:Float, alpha:Float):Int {
				var col = Std.int (col / alpha * 255) ;
				return col < 0 ? 0 : (col > 255 ? 255 : col);
			}
			
		}
		
		var boxesForGauss = function (sigma:Float, n:Int):Array<Float> {
			var wIdeal = Math.sqrt((12*sigma*sigma/n)+1);  // Ideal averaging filter width
			var wl = Math.floor(wIdeal);
			if (wl % 2 == 0) wl--;
			var wu = wl+2;
			
			var mIdeal = (12*sigma*sigma - n*wl*wl - 4*n*wl - 3*n)/(-4*wl - 4);
			var m = Math.round(mIdeal);
			var sizes:Array<Float> = [];
			for (i in 0...n)
				sizes.push( i < m ? wl : wu);
			
			return sizes;
		}
		
		var boxBlurH = function (imgA:UInt8Array, imgB:UInt8Array, w:Int, h:Int, r:Int, off:Int):Void {
			var iarr = 1 / (r+r+1);
			for (i in 0...h) {
				var ti = i*w, li = ti, ri = ti+r;
				var fv = imgA[ti * 4 + off], lv = imgA[(ti+w-1) * 4 + off], val = (r+1)*fv;
				
				for (j in 0...r)
					val += imgA[(ti+j) * 4 + off];
				
				for (j in 0...r+1) {
					val += imgA[ri * 4 + off] - fv;
					imgB[ti * 4 + off] = Math.round(val*iarr);
					ri++;
					ti++;
				}
				
				for (j in r+1...w-r) {
					val += imgA[ri * 4 + off] - imgA[li * 4 + off];
					imgB[ti * 4 + off] = Math.round(val*iarr);
					ri++;
					li++;
					ti++;
				}
				
				for (j in w-r...w) {
					val += lv - imgA[li * 4 + off];
					imgB[ti * 4 + off] = Math.round(val*iarr);
					li++;
					ti++;
				}
			}
		}
		
		var boxBlurT = function (imgA:UInt8Array, imgB:UInt8Array, w:Int, h:Int, r:Int, off:Int):Void {
			var iarr = 1 / (r+r+1);
			var ws = w * 4;
			for (i in 0...w) {
				var ti = i * 4 + off, li = ti, ri = ti+(r*ws);
				var fv = imgA[ti], lv = imgA[ti+(ws*(h-1))], val = (r+1)*fv;
				for (j in 0...r)
					val += imgA[ti+j*ws];
				
				for (j in 0...r+1) {
					val += imgA[ri] - fv;
					imgB[ti] = Math.round(val*iarr);
					ri+=ws; ti+=ws;
				}
				
				for (j in r+1...h-r) {
					val += imgA[ri] - imgA[li];
					imgB[ti] = Math.round(val*iarr);
					li+=ws;
					ri+=ws;
					ti+=ws;
				}
				
				for (j in h-r...h) {
					val += lv - imgA[li];
					imgB[ti] = Math.round(val*iarr);
					li+=ws;
					ti+=ws;
				}
			}
		}
		
		var boxBlur = function (imgA:UInt8Array, imgB:UInt8Array, w:Int, h:Int, bx:Float, by:Float):Void {
			for(i in 0...imgA.length)
				imgB[i] = imgA[i];
			
			boxBlurH(imgB, imgA, w, h, Std.int(bx), 0);
			boxBlurH(imgB, imgA, w, h, Std.int(bx), 1);
			boxBlurH(imgB, imgA, w, h, Std.int(bx), 2);
			boxBlurH(imgB, imgA, w, h, Std.int(bx), 3);
			
			boxBlurT(imgA, imgB, w, h, Std.int(by), 0);
			boxBlurT(imgA, imgB, w, h, Std.int(by), 1);
			boxBlurT(imgA, imgB, w, h, Std.int(by), 2);
			boxBlurT(imgA, imgB, w, h, Std.int(by), 3);
		}
		
		var imgB = image.data;
		var imgA = sourceImage.data;
		var w = Std.int (sourceRect.width);
		var h = Std.int (sourceRect.height);
		var bx = Std.int (blurX);
		var by = Std.int (blurY);
		var oX = Std.int (destPoint.x);
		var oY = Std.int (destPoint.y);
		
		var n = (quality * 2) - 1;
		var rng = Math.pow(2, quality) * 0.125;
		
		var bxs = boxesForGauss(bx * rng, n);
		var bys = boxesForGauss(by * rng, n);
		var offset:Int = Std.int( (w * oY + oX) * 4 );
		
		boxBlur (imgA, imgB, w, h, (bxs[0]-1)/2, (bys[0]-1)/2);
		var bIndex:Int = 1;
		for (i in 0...Std.int(n / 2)) {
			boxBlur (imgB, imgA, w, h, (bxs[bIndex]-1)/2, (bys[bIndex]-1)/2);
			boxBlur (imgA, imgB, w, h, (bxs[bIndex+1]-1)/2, (bys[bIndex+1]-1)/2);
			
			bIndex += 2;
		}
		
		var i:Int = 0;
		var a:Int;
		if (offset < 0) {
			while (i < imgA.length) {
				a = Std.int(imgB[ i + 3 ] * strength );
				a = a < 0 ? 0 : (a > 255 ? 255 : a);
				imgB[ i ] = fromPreMult( imgB[ i ], a );
				imgB[ i + 1 ] = fromPreMult( imgB[ i + 1 ], a );
				imgB[ i + 2 ] = fromPreMult( imgB[ i + 2 ], a );
				imgB[ i + 3 ] = a;
				i += 4;
			}
			for (i in imgA.length - offset...imgA.length)
				imgB[ i ] = 0;
		} else {
			i = imgA.length - 4;
			while (i >= 0) {
				a = Std.int(imgB[ i + 3 ] * strength );
				a = a < 0 ? 0 : (a > 255 ? 255 : a);
				imgB[ i + offset] = fromPreMult( imgB[ i ], a );
				imgB[ i + 1 + offset] = fromPreMult( imgB[ i + 1 ], a );
				imgB[ i + 2 + offset] = fromPreMult( imgB[ i + 2 ], a );
				imgB[ i + 3 + offset] = a;
				i -= 4;
			}
			for (i in 0...offset)
				imgB[ i ] = 0;
		}
		
		image.dirty = true;
		image.version++;
		sourceImage.dirty = true;
		sourceImage.version++;
		
		if (imgB == image.data) return image;
		return sourceImage;
		
	}
	
	
	public static function getColorBoundsRect (image:Image, mask:Int, color:Int, findColor:Bool = true, format:PixelFormat):Rectangle {
		
		var left = image.width + 1;
		var right = 0;
		var top = image.height + 1;
		var bottom = 0;
		
		var _color:RGBA, _mask:RGBA;
		
		switch (format) {
			
			case ARGB32:
				
				_color = (color:ARGB);
				_mask = (mask:ARGB);
			
			case BGRA32:
				
				_color = (color:BGRA);
				_mask = (mask:BGRA);
			
			default:
				
				_color = color;
				_mask = mask;
			
		}
		
		if (!image.transparent) {
			
			_color.a = 0xFF;
			_mask.a = 0xFF;
			
		}
		
		var pixel, hit;
		
		for (x in 0...image.width) {
			
			hit = false;
			
			for (y in 0...image.height) {
				
				pixel = image.getPixel32 (x, y, RGBA32);
				hit = findColor ? (pixel & _mask) == _color : (pixel & _mask) != _color;
				
				if (hit) {
					
					if (x < left) left = x;
					break;
					
				}
				
			}
			
			if (hit) {
				
				break;
				
			}
			
		}
		
		var ix;
		
		for (x in 0...image.width) {
			
			ix = (image.width - 1) - x;
			hit = false;
			
			for (y in 0...image.height) {
				
				pixel = image.getPixel32 (ix, y, RGBA32);
				hit = findColor ? (pixel & _mask) == _color : (pixel & _mask) != _color;
				
				if (hit) {
					
					if (ix > right) right = ix;
					break;
					
				}
				
			}
			
			if (hit) {
				
				break;
				
			}
			
		}
		
		for (y in 0...image.height) {
			
			hit = false;
			
			for (x in 0...image.width) {
				
				pixel = image.getPixel32 (x, y, RGBA32);
				hit = findColor ? (pixel & _mask) == _color : (pixel & _mask) != _color;
				
				if (hit) {
					
					if (y < top) top = y;
					break;
					
				}
				
			}
			
			if (hit) {
				
				break;
				
			}
			
		}
		
		var iy;
		
		for (y in 0...image.height) {
			
			iy = (image.height - 1) - y;
			hit = false;
			
			for (x in 0...image.width) {
				
				pixel = image.getPixel32 (x, iy, RGBA32);
				hit = findColor ? (pixel & _mask) == _color : (pixel & _mask) != _color;
				
				if (hit) {
					
					if (iy > bottom) bottom = iy;
					break;
					
				}
				
			}
			
			if (hit) {
				
				break;
				
			}
			
		}
		
		var w = right - left;
		var h = bottom - top;
		
		if (w > 0) w++;
		if (h > 0) h++;
		
		if (w < 0) w = 0;
		if (h < 0) h = 0;
		
		if (left == right) w = 1;
		if (top == bottom) h = 1;
		
		if (left > image.width) left = 0;
		if (top > image.height) top = 0;
		
		return new Rectangle (left, top, w, h);
		
	}
	
	
	public static function getPixel (image:Image, x:Int, y:Int, format:PixelFormat):Int {
		
		var pixel:RGBA;
		
		pixel.readUInt8 (image.buffer.data, (4 * (y + image.offsetY) * image.buffer.width + (x + image.offsetX) * 4), image.buffer.format, image.buffer.premultiplied);
		pixel.a = 0;
		
		switch (format) {
			
			case ARGB32: return (pixel:ARGB);
			case BGRA32: return (pixel:BGRA);
			default: return pixel;
			
		}
		
	}
	
	
	public static function getPixel32 (image:Image, x:Int, y:Int, format:PixelFormat):Int {
		
		var pixel:RGBA;
		
		pixel.readUInt8 (image.buffer.data, (4 * (y + image.offsetY) * image.buffer.width + (x + image.offsetX) * 4), image.buffer.format, image.buffer.premultiplied);
		
		switch (format) {
			
			case ARGB32: return (pixel:ARGB);
			case BGRA32: return (pixel:BGRA);
			default: return pixel;
			
		}
		
	}
	
	
	public static function getPixels (image:Image, rect:Rectangle, format:PixelFormat):Bytes {
		
		if (image.buffer.data == null) return null;
		
		var length = Std.int (rect.width * rect.height);
		var bytes = Bytes.alloc (length * 4);
		
		#if (lime_cffi && !disable_cffi && !macro)
		if (CFFI.enabled) NativeCFFI.lime_image_data_util_get_pixels (image, rect, format, bytes); else
		#end
		{
			
			var data = image.buffer.data;
			var sourceFormat = image.buffer.format;
			var premultiplied = image.buffer.premultiplied;
			
			var dataView = new ImageDataView (image, rect);
			var position, argb:ARGB, bgra:BGRA, pixel:RGBA;
			var destPosition = 0;
			
			for (y in 0...dataView.height) {
				
				position = dataView.row (y);
				
				for (x in 0...dataView.width) {
					
					pixel.readUInt8 (data, position, sourceFormat, premultiplied);
					
					switch (format) {
						
						case ARGB32: argb = pixel; pixel = cast argb;
						case BGRA32: bgra = pixel; pixel = cast bgra;
						default:
						
					}
					
					bytes.set (destPosition++, pixel.r);
					bytes.set (destPosition++, pixel.g);
					bytes.set (destPosition++, pixel.b);
					bytes.set (destPosition++, pixel.a);
					
					position += 4;
					
				}
				
			}
			
		}
		
		return bytes;
		
	}
	
	
	public static function merge (image:Image, sourceImage:Image, sourceRect:Rectangle, destPoint:Vector2, redMultiplier:Int, greenMultiplier:Int, blueMultiplier:Int, alphaMultiplier:Int):Void {
		
		if (image.buffer.data == null || sourceImage.buffer.data == null) return;
		
		#if (lime_cffi && !disable_cffi && !macro)
		if (CFFI.enabled) NativeCFFI.lime_image_data_util_merge (image, sourceImage, sourceRect, destPoint, redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier); else
		#end
		{
			
			var sourceView = new ImageDataView (sourceImage, sourceRect);
			var destView = new ImageDataView (image, new Rectangle (destPoint.x, destPoint.y, sourceView.width, sourceView.height));
			
			var sourceData = sourceImage.buffer.data;
			var destData = image.buffer.data;
			var sourceFormat = sourceImage.buffer.format;
			var destFormat = image.buffer.format;
			var sourcePremultiplied = sourceImage.buffer.premultiplied;
			var destPremultiplied = image.buffer.premultiplied;
			
			var sourcePosition, destPosition, sourcePixel:RGBA, destPixel:RGBA;
			
			for (y in 0...destView.height) {
				
				sourcePosition = sourceView.row (y);
				destPosition = destView.row (y);
				
				for (x in 0...destView.width) {
					
					sourcePixel.readUInt8 (sourceData, sourcePosition, sourceFormat, sourcePremultiplied);
					destPixel.readUInt8 (destData, destPosition, destFormat, destPremultiplied);
					
					destPixel.r = Std.int (((sourcePixel.r * redMultiplier) + (destPixel.r * (256 - redMultiplier))) / 256);
					destPixel.g = Std.int (((sourcePixel.g * greenMultiplier) + (destPixel.g * (256 - greenMultiplier))) / 256);
					destPixel.b = Std.int (((sourcePixel.b * blueMultiplier) + (destPixel.b * (256 - blueMultiplier))) / 256);
					destPixel.a = Std.int (((sourcePixel.a * alphaMultiplier) + (destPixel.a * (256 - alphaMultiplier))) / 256);
					
					destPixel.writeUInt8 (destData, destPosition, destFormat, destPremultiplied);
					
					sourcePosition += 4;
					destPosition += 4;
					
				}
				
			}
			
		}
		
		image.dirty = true;
		image.version++;
		
	}
	
	
	public static function multiplyAlpha (image:Image):Void {
		
		var data = image.buffer.data;
		if (data == null || !image.buffer.transparent) return;
		
		#if (lime_cffi && !disable_cffi && !macro)
		if (CFFI.enabled) NativeCFFI.lime_image_data_util_multiply_alpha (image); else
		#end
		{
			
			var format = image.buffer.format;
			var length = Std.int (data.length / 4);
			var pixel:RGBA;
			
			for (i in 0...length) {
				
				pixel.readUInt8 (data, i * 4, format, false);
				pixel.writeUInt8 (data, i * 4, format, true);
				
			}
			
		}
		
		image.buffer.premultiplied = true;
		image.dirty = true;
		image.version++;
		
	}
	
	
	public static function resize (image:Image, newWidth:Int, newHeight:Int):Void {
		
		var buffer = image.buffer;
		if (buffer.width == newWidth && buffer.height == newHeight) return;
		var newBuffer = new ImageBuffer (new UInt8Array (newWidth * newHeight * 4), newWidth, newHeight);
		
		#if (lime_cffi && !disable_cffi && !macro)
		if (CFFI.enabled) NativeCFFI.lime_image_data_util_resize (image, newBuffer, newWidth, newHeight); else
		#end
		{
			
			var imageWidth = image.width;
			var imageHeight = image.height;
			
			var data = image.data;
			var newData = newBuffer.data;
			var sourceIndex:Int, sourceIndexX:Int, sourceIndexY:Int, sourceIndexXY:Int, index:Int;
			var sourceX:Int, sourceY:Int;
			var u:Float, v:Float, uRatio:Float, vRatio:Float, uOpposite:Float, vOpposite:Float;
			
			for (y in 0...newHeight) {
				
				for (x in 0...newWidth) {
					
					// TODO: Handle more color formats
					
					u = ((x + 0.5) / newWidth) * imageWidth - 0.5;
					v = ((y + 0.5) / newHeight) * imageHeight - 0.5;
					
					sourceX = Std.int (u);
					sourceY = Std.int (v);
					
					sourceIndex = (sourceY * imageWidth + sourceX) * 4;
					sourceIndexX = (sourceX < imageWidth - 1) ? sourceIndex + 4 : sourceIndex;
					sourceIndexY = (sourceY < imageHeight - 1) ? sourceIndex + (imageWidth * 4) : sourceIndex;
					sourceIndexXY = (sourceIndexX != sourceIndex) ? sourceIndexY + 4 : sourceIndexY;
					
					index = (y * newWidth + x) * 4;
					
					uRatio = u - sourceX;
					vRatio = v - sourceY;
					uOpposite = 1 - uRatio;
					vOpposite = 1 - vRatio;
					
					newData[index] = Std.int ((data[sourceIndex] * uOpposite + data[sourceIndexX] * uRatio) * vOpposite + (data[sourceIndexY] * uOpposite + data[sourceIndexXY] * uRatio) * vRatio);
					newData[index + 1] = Std.int ((data[sourceIndex + 1] * uOpposite + data[sourceIndexX + 1] * uRatio) * vOpposite + (data[sourceIndexY + 1] * uOpposite + data[sourceIndexXY + 1] * uRatio) * vRatio);
					newData[index + 2] = Std.int ((data[sourceIndex + 2] * uOpposite + data[sourceIndexX + 2] * uRatio) * vOpposite + (data[sourceIndexY + 2] * uOpposite + data[sourceIndexXY + 2] * uRatio) * vRatio);
					
					// Maybe it would be better to not weigh colors with an alpha of zero, but the below should help prevent black fringes caused by transparent pixels made visible
					
					if (data[sourceIndexX + 3] == 0 || data[sourceIndexY + 3] == 0 || data[sourceIndexXY + 3] == 0) {
						
						newData[index + 3] = 0;
						
					} else {
						
						newData[index + 3] = data[sourceIndex + 3];
						
					}
					
				}
				
			}
			
		}
		
		buffer.data = newBuffer.data;
		buffer.width = newWidth;
		buffer.height = newHeight;
		
		#if (js && html5)
		buffer.__srcImage = null;
		buffer.__srcImageData = null;
		buffer.__srcCanvas = null;
		buffer.__srcContext = null;
		#end
		
		image.dirty = true;
		image.version++;
		
	}
	
	
	public static function resizeBuffer (image:Image, newWidth:Int, newHeight:Int):Void {
		
		var buffer = image.buffer;
		var data = image.data;
		var newData = new UInt8Array (newWidth * newHeight * 4);
		var sourceIndex:Int, index:Int;
		
		for (y in 0...buffer.height) {
			
			for (x in 0...buffer.width) {
				
				sourceIndex = (y * buffer.width + x) * 4;
				index = (y * newWidth + x) * 4;
				
				newData[index] = data[sourceIndex];
				newData[index + 1] = data[sourceIndex + 1];
				newData[index + 2] = data[sourceIndex + 2];
				newData[index + 3] = data[sourceIndex + 3];
				
			}
			
		}
		
		buffer.data = newData;
		buffer.width = newWidth;
		buffer.height = newHeight;
		
	}
	
	
	public static function setFormat (image:Image, format:PixelFormat):Void {
		
		var data = image.buffer.data;
		if (data == null) return;
		
		#if (lime_cffi && !disable_cffi && !macro)
		if (CFFI.enabled) NativeCFFI.lime_image_data_util_set_format (image, format); else
		#end
		{
			
			var index, a16;
			var length = Std.int (data.length / 4);
			var r1, g1, b1, a1, r2, g2, b2, a2;
			var r, g, b, a;
			
			switch (image.format) {
				
				case RGBA32:
					
					r1 = 0;
					g1 = 1;
					b1 = 2;
					a1 = 3;
				
				case ARGB32:
					
					r1 = 1;
					g1 = 2;
					b1 = 3;
					a1 = 0;
				
				case BGRA32:
					
					r1 = 2;
					g1 = 1;
					b1 = 0;
					a1 = 3;
				
			}
			
			switch (format) {
				
				case RGBA32:
					
					r2 = 0;
					g2 = 1;
					b2 = 2;
					a2 = 3;
				
				case ARGB32:
					
					r2 = 1;
					g2 = 2;
					b2 = 3;
					a2 = 0;
				
				case BGRA32:
					
					r2 = 2;
					g2 = 1;
					b2 = 0;
					a2 = 3;
				
			}
			
			for (i in 0...length) {
				
				index = i * 4;
				
				r = data[index + r1];
				g = data[index + g1];
				b = data[index + b1];
				a = data[index + a1];
				
				data[index + r2] = r;
				data[index + g2] = g;
				data[index + b2] = b;
				data[index + a2] = a;
				
			}
			
		}
		
		image.buffer.format = format;
		image.dirty = true;
		image.version++;
		
	}
	
	
	public static function setPixel (image:Image, x:Int, y:Int, color:Int, format:PixelFormat):Void {
		
		var pixel:RGBA;
		
		switch (format) {
			
			case ARGB32: pixel = (color:ARGB);
			case BGRA32: pixel = (color:BGRA);
			default: pixel = color;
			
		}
		
		// TODO: Write only RGB instead?
		
		var source = new RGBA ();
		source.readUInt8 (image.buffer.data, (4 * (y + image.offsetY) * image.buffer.width + (x + image.offsetX) * 4), image.buffer.format, image.buffer.premultiplied);
		
		pixel.a = source.a;
		pixel.writeUInt8 (image.buffer.data, (4 * (y + image.offsetY) * image.buffer.width + (x + image.offsetX) * 4), image.buffer.format, image.buffer.premultiplied);
		
		image.dirty = true;
		image.version++;
		
	}
	
	
	public static function setPixel32 (image:Image, x:Int, y:Int, color:Int, format:PixelFormat):Void {
		
		var pixel:RGBA;
		
		switch (format) {
			
			case ARGB32: pixel = (color:ARGB);
			case BGRA32: pixel = (color:BGRA);
			default: pixel = color;
			
		}
		
		if (!image.transparent) pixel.a = 0xFF;
		pixel.writeUInt8 (image.buffer.data, (4 * (y + image.offsetY) * image.buffer.width + (x + image.offsetX) * 4), image.buffer.format, image.buffer.premultiplied);
		
		image.dirty = true;
		image.version++;
		
	}
	
	
	public static function setPixels (image:Image, rect:Rectangle, bytePointer:BytePointer, format:PixelFormat, endian:Endian):Void {
		
		if (image.buffer.data == null) return;
		
		#if (lime_cffi && !disable_cffi && !macro)
		if (CFFI.enabled) NativeCFFI.lime_image_data_util_set_pixels (image, rect, bytePointer.bytes, bytePointer.offset, format, endian == BIG_ENDIAN ? 1 : 0); else
		#end
		{
			
			var data = image.buffer.data;
			var sourceFormat = image.buffer.format;
			var premultiplied = image.buffer.premultiplied;
			var dataView = new ImageDataView (image, rect);
			var row, color, pixel:RGBA;
			var transparent = image.transparent;
			var bytes = bytePointer.bytes;
			var dataPosition = bytePointer.offset;
			var littleEndian = (endian != BIG_ENDIAN);
			
			for (y in 0...dataView.height) {
				
				row = dataView.row (y);
				
				for (x in 0...dataView.width) {
					
					if (littleEndian) {
						
						color = bytes.getInt32 (dataPosition); // can this be trusted on big endian systems?
						
					} else {
						
						color = bytes.get (dataPosition + 3) | (bytes.get (dataPosition + 2) << 8) | (bytes.get (dataPosition + 1) << 16) | (bytes.get (dataPosition) << 24);
						
					}
					
					dataPosition += 4;
					
					switch (format) {
						
						case ARGB32: pixel = (color:ARGB);
						case BGRA32: pixel = (color:BGRA);
						default: pixel = color;
						
					}
					
					if (!transparent) pixel.a = 0xFF;
					pixel.writeUInt8 (data, row + (x * 4), sourceFormat, premultiplied);
					
				}
				
			}
			
		}
		
		image.dirty = true;
		image.version++;
		
	}
	
	
	public static function threshold (image:Image, sourceImage:Image, sourceRect:Rectangle, destPoint:Vector2, operation:String, threshold:Int, color:Int, mask:Int, copySource:Bool, format:PixelFormat):Int {
		
		var _color:RGBA, _mask:RGBA, _threshold:RGBA;
		
		switch (format) {
			
			case ARGB32:
				
				_color = (color:ARGB);
				_mask = (mask:ARGB);
				_threshold = (threshold:ARGB);
			
			case BGRA32:
				
				_color = (color:BGRA);
				_mask = (mask:BGRA);
				_threshold = (threshold:BGRA);
			
			default:
				
				_color = color;
				_mask = mask;
				_threshold = threshold;
			
		}
		
		var _operation = switch (operation) {
			
			case "!=": NOT_EQUALS;
			case "==": EQUALS;
			case "<" : LESS_THAN;
			case "<=": LESS_THAN_OR_EQUAL_TO;
			case ">" : GREATER_THAN;
			case ">=": GREATER_THAN_OR_EQUAL_TO;
			default: -1;
			
		}
		
		if (_operation == -1) return 0;
		
		var srcData = sourceImage.buffer.data;
		var destData = image.buffer.data;
		
		if (srcData == null || destData == null) return 0;
		
		var hits = 0;
		
		#if (lime_cffi && !disable_cffi && !macro)
		if (CFFI.enabled) hits = NativeCFFI.lime_image_data_util_threshold (image, sourceImage, sourceRect, destPoint, _operation, (_threshold >> 16) & 0xFFFF, (_threshold) & 0xFFFF, (_color >> 16) & 0xFFFF, (_color) & 0xFFFF, (_mask >> 16) & 0xFFFF, (_mask) & 0xFFFF, copySource); else
		#end
		{
			
			var srcView = new ImageDataView (sourceImage, sourceRect);
			var destView = new ImageDataView (image, new Rectangle (destPoint.x, destPoint.y, srcView.width, srcView.height));
			
			var srcFormat = sourceImage.buffer.format;
			var destFormat = image.buffer.format;
			var srcPremultiplied = sourceImage.buffer.premultiplied;
			var destPremultiplied = image.buffer.premultiplied;
			
			var srcPosition, destPosition, srcPixel:RGBA, destPixel:RGBA, pixelMask:UInt, test:Bool, value:Int;
			
			for (y in 0...destView.height) {
				
				srcPosition = srcView.row (y);
				destPosition = destView.row (y);
				
				for (x in 0...destView.width) {
					
					srcPixel.readUInt8 (srcData, srcPosition, srcFormat, srcPremultiplied);
					
					pixelMask = srcPixel & _mask;
					
					value = __pixelCompare (pixelMask, _threshold);
					
					test = switch (_operation) {
						
						case NOT_EQUALS: (value != 0);
						case EQUALS: (value == 0);
						case LESS_THAN: (value == -1);
						case LESS_THAN_OR_EQUAL_TO: (value == 0 || value == -1);
						case GREATER_THAN: (value == 1);
						case GREATER_THAN_OR_EQUAL_TO: (value == 0 || value == 1);
						default: false;
						
					}
					
					if (test) {
						
						_color.writeUInt8 (destData, destPosition, destFormat, destPremultiplied);
						hits++;
						
					} else if (copySource) {
						
						srcPixel.writeUInt8 (destData, destPosition, destFormat, destPremultiplied);
						
					}
					
					srcPosition += 4;
					destPosition += 4;
					
				}
				
			}
			
		}
		
		if (hits > 0) {
			
			image.dirty = true;
			image.version++;
			
		}
		
		return hits;
		
	}
	
	
	public static function unmultiplyAlpha (image:Image):Void {
		
		var data = image.buffer.data;
		if (data == null) return;
		
		#if (lime_cffi && !disable_cffi && !macro)
		if (CFFI.enabled) NativeCFFI.lime_image_data_util_unmultiply_alpha (image); else
		#end
		{
			
			var format = image.buffer.format;
			var length = Std.int (data.length / 4);
			var pixel:RGBA;
			
			for (i in 0...length) {
				
				pixel.readUInt8 (data, i * 4, format, true);
				pixel.writeUInt8 (data, i * 4, format, false);
				
			}
			
		}
		
		image.buffer.premultiplied = false;
		image.dirty = true;
		image.version++;
		
	}
	
	
	private static inline function __pixelCompare (n1:UInt, n2:UInt):Int {
		
		var tmp1:UInt;
		var tmp2:UInt;
		
		tmp1 = (n1 >> 24) & 0xFF;
		tmp2 = (n2 >> 24) & 0xFF;
		
		if (tmp1 != tmp2) {
			
			return (tmp1 > tmp2 ? 1 : -1);
			
		} else {
			
			tmp1 = (n1 >> 16) & 0xFF;
			tmp2 = (n2 >> 16) & 0xFF;
			
			if (tmp1 != tmp2) {
				
				return (tmp1 > tmp2 ? 1 : -1);
				
			} else {
				
				tmp1 = (n1 >> 8) & 0xFF;
				tmp2 = (n2 >> 8) & 0xFF;
				
				if (tmp1 != tmp2) {
					
					return (tmp1 > tmp2 ? 1 : -1);
					
				} else {
					
					tmp1 = n1 & 0xFF;
					tmp2 = n2 & 0xFF;
					
					if (tmp1 != tmp2) {
						
						return (tmp1 > tmp2 ? 1 : -1);
						
					} else {
						
						return 0;
						
					}
					
				}
				
			}
			
		}
		
	}
	
	
}


private class ImageDataView {
	
	
	public var x (default, null):Int;
	public var y (default, null):Int;
	public var height (default, null):Int;
	public var width (default, null):Int;
	
	private var byteOffset:Int;
	private var image:Image;
	private var rect:Rectangle;
	private var stride:Int;
	
	
	public function new (image:Image, rect:Rectangle = null) {
		
		this.image = image;
		
		if (rect == null) {
			
			this.rect = image.rect;
			
		} else {
			
			if (rect.x < 0) rect.x = 0;
			if (rect.y < 0) rect.y = 0;
			if (rect.x + rect.width > image.width) rect.width = image.width - rect.x;
			if (rect.y + rect.height > image.height) rect.height = image.height - rect.y;
			if (rect.width < 0) rect.width = 0;
			if (rect.height < 0) rect.height = 0;
			this.rect = rect;
			
		}
		
		stride = image.buffer.stride;
		
		__update ();
		
	}
	
	
	public function clip (x:Int, y:Int, width:Int, height:Int):Void {
		
		rect.__contract (x, y, width, height);
		__update ();
		
	}
	
	
	public inline function hasRow (y:Int):Bool {
		
		return (y >= 0 && y < height);
		
	}
	
	
	public function offset (x:Int, y:Int):Void {
		
		if (x < 0) {
			
			rect.x += x;
			if (rect.x < 0) rect.x = 0;
			
		} else {
			
			rect.x += x;
			rect.width -= x;
			
		}
		
		if (y < 0) {
			
			rect.y += y;
			if (rect.y < 0) rect.y = 0;
			
		} else {
			
			rect.y += y;
			rect.height -= y;
			
		}
		
		__update ();
		
	}
	
	
	public inline function row (y:Int):Int {
		
		return byteOffset + stride * y;
		
	}
	
	
	private function __update ():Void {
		
		this.x = Math.ceil (rect.x);
		this.y = Math.ceil (rect.y);
		this.width = Math.floor (rect.width);
		this.height = Math.floor (rect.height);
		byteOffset = (stride * (this.y + image.offsetY)) + ((this.x + image.offsetX) * 4);
		
	}
	
	
}


@:noCompletion @:dox(hide) @:enum private abstract ThresholdOperation(Int) from Int to Int {
	
	var NOT_EQUALS = 0;
	var EQUALS = 1;
	var LESS_THAN = 2;
	var LESS_THAN_OR_EQUAL_TO = 3;
	var GREATER_THAN = 4;
	var GREATER_THAN_OR_EQUAL_TO = 5;
	
}