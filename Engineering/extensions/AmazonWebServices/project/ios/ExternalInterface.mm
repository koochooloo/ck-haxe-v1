#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#import "Utils.h"

#import "DBTeacher.h"
#import "DBStudent.h"

#import <hx/CFFI.h>
#import <UIKit/UIKit.h>


using namespace amazonwebservices;



static value amazonwebservices_sample_method (value inputValue) {
	
	int returnValue = SampleMethod(val_int(inputValue));
	return alloc_int(returnValue);

}
DEFINE_PRIM (amazonwebservices_sample_method, 1);

static void amazonwebservices_connect()
{
    connect();
}
DEFINE_PRIM(amazonwebservices_connect, 0);


// Callbacks into haxe space
AutoGCRoot *g_studentCallback;     // Dynamic->Void
AutoGCRoot *g_teacherCallback;     // Dynamic->Void
AutoGCRoot *g_errorCallback;       // String->Void

static void amazonwebservices_load_teacher(value teacherId, value successCB, value errorCB)
{
    g_teacherCallback = new AutoGCRoot(successCB);
    g_errorCallback = new AutoGCRoot(errorCB);

    const char *t = val_string(teacherId);
    loadTeacher(t);
}
DEFINE_PRIM(amazonwebservices_load_teacher, 3);

static void amazonwebservices_load_student(value studentId, value successCB, value errorCB)
{
    g_studentCallback = new AutoGCRoot(successCB);
    g_errorCallback = new AutoGCRoot(errorCB);

    const char *s = val_string(studentId);
    loadStudent(s);
}
DEFINE_PRIM(amazonwebservices_load_student, 3);

static void amazonwebservices_save_student(value studentId, value teacherId, value saveData, value profileData)
{
    const char *sId = val_string(studentId);
    const char *tId = val_string(teacherId);
    const char *sData = val_string(saveData);
    const char *pData = val_string(profileData);
    saveStudent(sId, tId, sData, pData);
}
DEFINE_PRIM(amazonwebservices_save_student, 4);


void onLoadTeacher(DBTeacher *teacher)
{
    if (teacher == nil)
    {
        // Just to keep myself sane, passing back the name of the error string
        value e = alloc_string("ACCOUNT_DOESNOTEXIST");

        val_call1(g_errorCallback->get(), e);
        return;
    }

    // Passing back a dynamic that mimics a Teacher from AccountManager.hx
    // except that it has the number of students, rather than an array of them
    value t = alloc_empty_object();
    alloc_field(t, val_id("id"), alloc_string([teacher.TeacherId UTF8String]));
    alloc_field(t, val_id("grade"), alloc_string([teacher.GradeLevel UTF8String]));
    alloc_field(t, val_id("nStudents"), alloc_int([teacher.Students intValue]));

    val_call1(g_teacherCallback->get(), t);
}

void onLoadStudent(DBStudent *student)
{
    if (student == nil)
    {
        // Just to keep myself sane, passing back the name of the error string
        value e = alloc_string("ACCOUNT_DOESNOTEXIST");

        val_call1(g_errorCallback->get(), e);
        return;
    }

    if ( student.Profile == nil )
    {
        student.Profile = @"";
    }
    if ( student.SaveData == nil )
    {
        student.saveData = @"";
    }
    
    // Passing back a dynamic that mimics a Student from AccountManager.hx
    value s = alloc_empty_object();
    alloc_field(s, val_id("id"), alloc_string([student.StudentId UTF8String]));
    alloc_field(s, val_id("teacherId"), alloc_string([student.TeacherId UTF8String]));
    alloc_field(s, val_id("saveData"), alloc_string([student.SaveData UTF8String]));
    alloc_field(s, val_id("profile"), alloc_string([student.Profile UTF8String]));

    val_call1(g_studentCallback->get(), s);
}

void onLoadError(const char *msg)
{
    value e = alloc_string(msg);

    val_call1(g_errorCallback->get(), e);
}



extern "C" void amazonwebservices_main () {
	
	val_int(0); // Fix Neko init
	
}
DEFINE_ENTRY_POINT (amazonwebservices_main);



extern "C" int amazonwebservices_register_prims () { return 0; }
