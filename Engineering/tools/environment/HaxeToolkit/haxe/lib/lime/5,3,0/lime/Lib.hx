package lime;


import haxe.PosInfos;
import lime.utils.Log;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
#end

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end


class Lib {
	
	
	@:noCompletion private static var __sentWarnings = new Map<String, Bool> ();
	
	
	#if macro
	public static function extraParams ():Void {
		
		if (!Context.defined ("tools")) {
			
			if (!Context.defined ("flash") && (!Context.defined ("js") || Context.defined ("nodejs"))) {
				
				Compiler.define ("lime-cffi");
				Compiler.define ("native");
				Compiler.define ("lime-curl");
				Compiler.define ("lime-vorbis");
				
			}
			
		}
		
	}
	#end
	
	
	public static function notImplemented (api:String, ?posInfo:PosInfos):Void {
		
		if (!__sentWarnings.exists (api)) {
			
			__sentWarnings.set (api, true);
			
			Log.warn (api + " is not implemented", posInfo);
			
		}
		
	}
	
	
}
