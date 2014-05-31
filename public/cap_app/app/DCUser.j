/*
 * DCUser.j
 * Digital Culture Map
 *
 * 
 */

@import <Foundation/CPObject.j>


@implementation DCUser : CPObject
{
	int userId @accessors;
	CPString first_name @accessors;
	CPString last_name @accessors;
	CPString user_type @accessors;
	CPString email @accessors;
	CPString degree @accessors;
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
		[self setUserId:obj.user.id];
		[self setFirst_name:obj.user.first_name];
		[self setLast_name:obj.user.last_name];
		[self setUser_type:obj.user.user_type];
		[self setEmail:obj.user.email];
		[self setDegree:obj.user.degree];
	}
	
	return self;
}

- (CPString)full_name
{
	return [self first_name] + " " + [self last_name];
}

@end