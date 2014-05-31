/*
 * DCClass.j
 * Digital Culture Map
 *
 * 
 */

@import <Foundation/CPObject.j>


@implementation DCClass : CPObject
{
	int classId @accessors;
	int semesterId @accessors;
	int courseId @accessors;
}

- (id)init
{
	self = [super init];
	
	return self;
}

- (id)initWithData:(JSObject)obj
{
	self = [super init];
	
	if (self) {
		[self setClassId:obj.instance.id];
		[self setSemesterId:obj.instance.semester_id];
		[self setCourseId:obj.instance.course_id];
		
		console.log("class: courseId= " + courseId );
	}
	
	return self;
}


@end