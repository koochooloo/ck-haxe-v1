#ifndef AMAZONWEBSERVICES_H
#define AMAZONWEBSERVICES_H

namespace amazonwebservices 
{
	int SampleMethod(int inputValue);
	
	void connect();

	void loadTeacher(const char *teacherId);
	void loadStudent(const char *studentId);

	void saveStudent(const char *studentId, const char *teacherId, const char *saveData, const char *profileData);
}

#endif
