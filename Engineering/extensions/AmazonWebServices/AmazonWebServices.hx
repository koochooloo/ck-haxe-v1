package;


import lime.system.CFFI;
import lime.system.JNI;


class AmazonWebServices {
	
	
	public static function sampleMethod (inputValue:Int):Int {
		
		#if android
		
		var resultJNI = amazonwebservices_sample_method_jni(inputValue);
		var resultNative = amazonwebservices_sample_method(inputValue);
		
		if (resultJNI != resultNative) {
			
			throw "Fuzzy math!";
			
		}
		
		return resultNative;
		
		#else
		
		return amazonwebservices_sample_method(inputValue);
		
		#end
		
	}

	public static function connect():Void
	{
#if ios
		amazonwebservices_connect();
#end
	}

	public static function loadTeacher(id:String, successCB:Dynamic->Void, errorCB:String->Void):Void
	{
#if ios
		amazonwebservices_load_teacher(id, successCB, errorCB);
#end
	}

	public static function loadStudent(id:String, successCB:Dynamic->Void, errorCB:String->Void):Void
	{
#if ios
		amazonwebservices_load_student(id, successCB, errorCB);
#end
	}

public static function saveStudent(id:String, teacherId:String, saveData:String, profileData:String):Void
	{
#if ios
		amazonwebservices_save_student(id, teacherId, saveData, profileData);
#end
	}
	
	
	private static var amazonwebservices_sample_method = CFFI.load ("amazonwebservices", "amazonwebservices_sample_method", 1);

#if ios
	private static var amazonwebservices_connect = CFFI.load ("amazonwebservices", "amazonwebservices_connect", 0);

	private static var amazonwebservices_load_teacher = CFFI.load ("amazonwebservices", "amazonwebservices_load_teacher", 3);

	private static var amazonwebservices_load_student = CFFI.load ("amazonwebservices", "amazonwebservices_load_student", 3);

	private static var amazonwebservices_save_student = CFFI.load ("amazonwebservices", "amazonwebservices_save_student", 4);
#end
	
	#if android
	private static var amazonwebservices_sample_method_jni = JNI.createStaticMethod ("org.haxe.extension.AmazonWebServices", "sampleMethod", "(I)I");
	#end
	
	
}
