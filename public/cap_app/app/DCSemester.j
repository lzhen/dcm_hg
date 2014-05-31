/*
 * DCSemester.j
 * Digital Culture Map
 *
 * 
 */

@import <Foundation/CPObject.j>


var semesters;


@implementation DCSemester : CPObject
{
	int semesterId @accessors;
	CPString name @accessors;
	CPString year @accessors;
}

+ (void)initialize
{
    if (self != DCSemester)
        return;

	semesters = [[CPDictionary alloc] init];
}

+ (void)addSemester:(DCSemester)aSemester
{
	[semesters setObject:aSemester forKey:[aSemester semesterId]];
}

+ (DCSemester)semesterForKey:aKey
{
	return [semesters objectForKey:aKey];
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
		[self setSemesterId:obj.semester.id];
		[self setName:obj.semester.name];
		[self setYear:obj.semester.year];
	}
	
	return self;
}

- (CPString)title
{
	return [self name] + " " + [self year];
}



@end