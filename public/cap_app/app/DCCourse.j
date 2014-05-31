/*
 * DCCourse.j
 * Digital Culture Map
 *
 * 
 */

@import <Foundation/CPObject.j>


var courses,
    courseIdsByLevel;


@implementation DCCourse : CPObject
{
	int courseId @accessors;
	CPString prefix @accessors;
	CPString number @accessors;
	CPString title @accessors;
	CPString courseDescription @accessors;
	id delegate @accessors;
	id cell @accessors;
	BOOL isInPath @accessors;
	CPDictionary inPro;
	CPDictionary outPro;
	
	int proScore @accessors;
	BOOL hasSelectedProficiency @accessors;
}


+ (void)initialize
{
    if (self != DCCourse)
        return;

	courses = [[CPDictionary alloc] init];
	courseIdsByLevel = [[CPDictionary alloc] init];
	var courses4 = [[CPArray alloc] init];
	var courses3 = [[CPArray alloc] init];
	var courses2 = [[CPArray alloc] init];
	var courses1 = [[CPArray alloc] init];
	[courseIdsByLevel setObject:courses1 forKey:1];
	[courseIdsByLevel setObject:courses2 forKey:2];
	[courseIdsByLevel setObject:courses3 forKey:3];
	[courseIdsByLevel setObject:courses4 forKey:4];
}


+ (DCCourse)find:(int)anId
{
	return [courses objectForKey:anId];
}


+ (void)add:(DCCourse)aCourse level:(int)level
{
	[courses setObject:aCourse forKey:[aCourse courseId]];
	
	var levelArray = [courseIdsByLevel objectForKey:level];
	levelArray = [levelArray arrayByAddingObject:[aCourse courseId]];
	[courseIdsByLevel setObject:levelArray forKey:level];
}

+ (int)lastPageForLevel:(int)level
{
	var levelArray = [courseIdsByLevel objectForKey:level];
	return parseInt(([levelArray count] / 6));
}

+ (CPArray)coursesPage:(int)pageNumber level:(int)level
{
	var anArray = [[CPArray alloc] init];
	var levelArray = [courseIdsByLevel objectForKey:level];
	if ([levelArray count] == 0)
		return anArray;
	
	if ((pageNumber * 6) >= [levelArray count])
		pageNumber = 0;
	if (pageNumber < 0)
		pageNumber = [levelArray count] % 6;
	var firstIndex = pageNumber * 6;
	var lastIndex = firstIndex + 5;
	if (lastIndex >= [levelArray count])
		lastIndex = [levelArray count] - 1;
	var indexArray = [levelArray subarrayWithRange:CPMakeRange(firstIndex, lastIndex - firstIndex + 1)];
	for (var i = 0; i < [indexArray count]; i++) {
		var cid = [indexArray objectAtIndex:i];
		var aCourse = [courses objectForKey:cid]
		anArray = [anArray arrayByAddingObject:aCourse];
	}
	return anArray;
}

+ (void)sortLevel:(int)aLevel byProficiency:(DCProficiency)aProf
{
	var levelArray = [courseIdsByLevel objectForKey:aLevel];
	
	for (var key in levelArray) {
		var cid = levelArray[key];
		var aCourse = [courses objectForKey:cid]
		if ([aCourse hasOutgoingProficiency:aProf]) {
			[aCourse setProScore:100];
			[aCourse setHasSelectedProficiency:YES];
		}
		else {
			[aCourse setProScore:0];
			[aCourse setHasSelectedProficiency:NO];
		}
		
	}
	
	var sortedLevelArray = [levelArray sortedArrayUsingFunction:DCCourseProScoreCompare context:null];
	
	[courseIdsByLevel setObject:sortedLevelArray forKey:aLevel];
}

+ (void)clearHasSelectedProficiency
{
	var coursesList = [courses allValues];
	for (var key in coursesList) {
		if (key != "isa") {
			var c = coursesList[key];
			[c setHasSelectedProficiency:NO];
		}
	}
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
		[self setCourseId:obj.course.id];
		[self setPrefix:obj.course.prefix];
		[self setNumber:obj.course.number];
		[self setTitle:obj.course.title];
		[self setCourseDescription:obj.course.description];
		[self setIsInPath:NO];
		inPro = [[CPDictionary alloc] init];
		outPro = [[CPDictionary alloc] init];
	}
	
	return self;
}

- (void)selectAction:(id)sender
{
	console.log( "SELECTED: " + prefix + " " + number );
	[delegate handleSelection:self];
	//[cell setSelected:YES];
}

- (void)setAsSelected
{
	var cv = [cell superview];
	var items = [cv items];
	var i;
	for (i=0; i < [items count]; i++) {
		if ([[items objectAtIndex:i] representedObject] == self) {
			[cv setSelectionIndexes:[[CPIndexSet alloc] initWithIndex:i]];
		}
	}
}

- (CPString)short_name
{
	return [self prefix] + " " + [self number];
}

- (void)addCourseProficiency:(CPCourseProficiency)cp
{
	var p = [DCProficiency find:[cp proficiencyId]];
	if (p == null) {
		console.log("warning, null proficiency in addCourseProficiency");
		return;
	}
	if ([cp proficiencyDirection] == "Outgoing") {
		[outPro setObject:p forKey:[cp proficiencyId]];
	}
	else {
		var slotDict = [inPro objectForKey:[cp slot]];
		if (!slotDict) {
			slotDict = [[CPDictionary alloc] init];
			[inPro setObject:slotDict forKey:[cp slot]];
		}
		[slotDict setObject:p forKey:[cp proficiencyId]];
	}
}

- (CPArray)outgoingArray
{
	return [outPro allValues];
}

- (int)outgoingProficiencyCount
{
	return [outPro count];
}

- (int)incomingProficiencyCount
{
	if ([inPro count] == 0)
		return 0;
	var total = 0;
	slotList = [inPro allValues];
	for (var slotKey in slotList) {
		if (slotKey != "isa") {
			var slotDict = slotList[slotKey];
			total += [slotDict count];
		}
	}
	return total;
}

- (CPArray)incomingArrayForSlot:(int)num
{
	var slotDict = [inPro objectForKey:num];
	if (!slotDict)
		return null;
	return [slotDict allValues];
}

- (BOOL)hasOutgoingProficiency:(DCProficiency)prof
{
	var outList = [self outgoingArray];
	for (var key in outList) {
		if (key != "isa") {
			var p = outList[key];
			if ([p proficiencyId] == [prof proficiencyId])
				return YES;
		}
	}
	return NO;
}

- (int)compareProScore:(DCCourse)aCourse
{
	if ([self proScore] > [aCourse proScore])
		return CPOrderedAscending;
	else if ([self proScore] < [aCourse proScore])
		return CPOrderedDescending;
	return CPOrderedSame;
}

@end


var DCCourseProScoreCompare = function( lhs, rhs)
{
	var lhsCourse = [courses objectForKey:lhs]
	var rhsCourse = [courses objectForKey:rhs]
	
	return [lhsCourse compareProScore:rhsCourse];
}

