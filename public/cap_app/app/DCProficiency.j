/*
 * DCProficiency.j
 * Digital Culture Map
 *
 * 
 */

@import <Foundation/CPObject.j>


var proficiencies;


@implementation DCProficiency : CPObject
{
	int proficiencyId @accessors;
	CPString name @accessors;
	int level @accessors;
}


+ (void)initialize
{
    if (self != DCProficiency)
        return;

	proficiencies = [[CPDictionary alloc] init];
}


+ (void)add:(DCProficiency)aProficiency
{
	[proficiencies setObject:aProficiency forKey:[aProficiency proficiencyId]];
}


+ (DCProficiency)find:(int)aKey
{
	return [proficiencies objectForKey:aKey];
}

+ (DCProficiency)findByTitle:(CPString)aTitle
{
	var profList = [proficiencies allValues];
	for (var key in profList) {
		var prof = profList[key];
		if ([prof title] == aTitle)
			return prof;
	}
	return null;
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
		[self setProficiencyId:obj.proficiency.id];
		[self setName:obj.proficiency.name];
		[self setLevel:obj.proficiency.level];
	}
	
	return self;
}

- (CPString)title
{
	return [self name] + " " + [self level];
}