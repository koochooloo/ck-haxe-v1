package lime.utils.compress;


import haxe.io.Bytes;
import lime._backend.native.NativeCFFI;

#if flash
import flash.utils.ByteArray;
#end

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

@:access(lime._backend.native.NativeCFFI)


class Deflate {
	
	
	public static function compress (bytes:Bytes):Bytes {
		
		#if (lime_cffi && !macro)
		
		#if !cs
		return NativeCFFI.lime_deflate_compress (bytes, Bytes.alloc (0));
		#else
		var data:Dynamic = NativeCFFI.lime_deflate_compress (bytes, null);
		if (data == null) return null;
		return @:privateAccess new Bytes (data.length, data.b);
		#end
		
		#elseif (js && html5)
		
		var data = untyped __js__ ("pako.deflateRaw") (bytes.getData ());
		return Bytes.ofData (data);
		
		#elseif flash
		
		var byteArray:ByteArray = cast bytes.getData ();
		
		var data = new ByteArray ();
		data.writeBytes (byteArray);
		data.deflate ();
		
		return Bytes.ofData (data);
		
		#else
		
		return null;
		
		#end
		
	}
	
	
	public static function decompress (bytes:Bytes):Bytes {
		
		#if (lime_cffi && !macro)
		
		#if !cs
		return NativeCFFI.lime_deflate_decompress (bytes, Bytes.alloc (0));
		#else
		var data:Dynamic = NativeCFFI.lime_deflate_decompress (bytes, null);
		if (data == null) return null;
		return @:privateAccess new Bytes (data.length, data.b);
		#end
		
		#elseif (js && html5)
		
		var data = untyped __js__ ("pako.inflateRaw") (bytes.getData ());
		return Bytes.ofData (data);
		
		#elseif flash
		
		var byteArray:ByteArray = cast bytes.getData ();
		
		var data = new ByteArray ();
		data.writeBytes (byteArray);
		data.inflate ();
		
		return Bytes.ofData (data);
		
		#else
		
		return null;
		
		#end
		
	}
	
	
}