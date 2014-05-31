/*
 * DCPath.j
 * Digital Culture Map
 *
 * 
 */

@import <Foundation/CPObject.j>

var path;
var pathDictionary;
var proficinciesInPath;


@implementation DCPath : CPObject
{
	int pathId @accessors;
	int studentId @accessors;
	CPString title @accessors;
}

+ (void)initialize
{
    if (self != DCPath)
        return;

	pathDictionary = [[CPDictionary alloc] init];
	proficinciesInPath = [[CPDictionary alloc] init];
}

+ (void)setCurrentPath:(DCPath)aPath
{
	path = aPath;
}

+ (DCPath)currentPath
{
	return path;
}

+ (void)addSemester:(CPDictionary)dict withId:(int)aKey
{
	[pathDictionary setObject:dict forKey:aKey];
}

+ (void)removeSemesterWithId:(int)aKey
{
	[pathDictionary removeObjectForKey:aKey];
}

+ (CPDictionary)semesterForKey:(int)aKey
{
	return [pathDictionary objectForKey:aKey];
}

+ (CPArray)semesterKeys
{
	return [pathDictionary allKeys];
}

+ (int)semesterCount
{
	return [pathDictionary count];
}

+ (void)calculateProficienciesInPath
{
	[proficinciesInPath removeAllObjects];
	
	if ([self semesterCount] == 0)
		return;
	
	var listOfKeys = [self semesterKeys];
	for (var key in listOfKeys) {
		if (key != "isa") {
			var semester = [DCSemester semesterForKey:listOfKeys[key]];
			var semesterClassDictionary = [self semesterForKey:listOfKeys[key]];
			var semesterClassList = [semesterClassDictionary allValues];
			for (var i = 0; i < [semesterClassList count]; i++) {
				var aClass = [semesterClassList objectAtIndex:i];
				var aCourse = [DCCourse find:[aClass courseId]];
				var outgoingProficiencies = [aCourse outgoingArray];
				for (var outKey in outgoingProficiencies) {
					if (outKey != "isa") {
						var p = outgoingProficiencies[outKey];
						var profInList = [proficinciesInPath objectForKey:[p proficiencyId]];
						if (!profInList) {
							console.log( "add prof to list in path: " + [p title] );
							[proficinciesInPath setObject:p forKey:[p proficiencyId]];
						}
					}
				}
			}			
		}
	}
}

+ (BOOL)isProficiencyInPath:(DCProficiency)aProf
{
	var profInList = [proficinciesInPath objectForKey:[aProf proficiencyId]];
	if (profInList)
		return YES;
	return NO;
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
		[self setPathId:obj.id];
		[self setStudentId:obj.student_id];
		[self setTitle:obj.title];
	}
	
	return self;
}



@end