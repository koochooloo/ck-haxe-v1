package lime.text.harfbuzz;


import lime._backend.native.NativeCFFI;

@:access(lime._backend.native.NativeCFFI)


class HB {
	
	
	public static function shape (font:HBFont, buffer:HBBuffer, features:Array<HBFeature> = null):Void {
		
		#if (lime_cffi && lime_harfbuzz && !macro)
		NativeCFFI.lime_hb_shape (font, buffer, features);
		#end
		
	}
	
	
}