/*
 * DCCourseProficiency.j
 * Digital Culture Map
 *
 * 
 */

@import <Foundation/CPObject.j>


@implementation DCCourseProficiency : CPObject
{
	int courseProficiencyId @accessors;
	int proficiencyId @accessors;
	int courseId @accessors;
	int slot @accessors;
	CPString proficiencyDirection @accessors;
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
		[self setCourseProficiencyId:obj.course_proficiency.id];
		[self setProficiencyId:obj.course_proficiency.proficiency_id];
		[self setCourseId:obj.course_proficiency.course_id];
		[self setSlot:obj.course_proficiency.slot];
		[self setProficiencyDirection:obj.course_proficiency.proficiency_direction];
	}
	
	return self;
}

