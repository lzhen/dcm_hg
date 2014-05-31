/*
 * AppController.j
 * dcm
 *
 * Created by Loren Olson.
 * Copyright 2008 Arizona State University. All rights reserved.
 */

@import <Foundation/CPObject.j>
@import <Foundation/CPURLRequest.j>
@import <Foundation/CPURLConnection.j>

@import "app/DCCourse.j"
@import "app/DCUser.j"
@import "app/DCPath.j"
@import "app/DCSemester.j"
@import "app/DCClass.j"
@import "app/DCProficiency.j"
@import "app/DCCourseProficiency.j"
@import "app/DCCourseLevelView.j"
@import "app/DCCourseCell.j"





@implementation AppController : CPObject
{
	CPTextField label;
	CPView contentView;
	CPWindow theWindow;
	CPView headerView;
	
	CPView userView;
	CPTextView userText;
	
	CPView cartView;
	CPTextView pathNameText;
	CPView classesView;
	
	CPView detailView;
	CPTextView detailPrefixAndNumber;
	CPTextView detailTitle;
	CPTextView detailDescription;
	CPScrollView detailScrollView;
	CPScrollView detailProfView;
	CPButton removeButton;
	
	CPDictionary classesForCourse;
	CPDictionary buttonDictionary;
	
	CPView mapView;
	CPView mapInfo;
	CourseLevelView level4View;
	CourseLevelView level3View;
	CourseLevelView level2View;
	CourseLevelView level1View;
	CPTextView showProfTextView;
	CPButton clearShowProfButton;
	
	CPURLConnection connection4;
	CPURLConnection connection3;
	CPURLConnection connection2;
	CPURLConnection connection1;
	
	CPURLConnection userConnection;
	CPURLConnection pathConnection;
	CPURLConnection classesConnection;
	CPURLConnection semestersConnection;
	CPURLConnection profConnection;
	CPURLConnection courseProjConnection;
	
	CPURLConnection classQuery;
	CPURLConnection addClassQuery;
	
	DCUser user;
	DCCourse selectedCourse;
	DCProficiency selectedProficiency;
	
	BOOL initialDataLoad;
	
	var aButtonImage;
	var bButtonImage;
	
	CPColor genericBackgroundColor;
	CPColor headerColor;
	CPColor headerTextColor;
	CPColor cartHeadBackgroundColor;
	CPColor background90;
	CPColor background93;
	CPColor background98;
	CPColor missingColor;
	
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
	aButtonImage = [[CPImage alloc] initWithContentsOfFile:"http://localhost:3000/images/a_button.png"];
	bButtonImage = [[CPImage alloc] initWithContentsOfFile:"http://localhost:3000/images/c_button.png"];
	
	genericBackgroundColor = [CPColor colorWithCalibratedRed:0.88 green:0.88 blue:0.88 alpha:1.0];
	headerColor = [CPColor colorWithCalibratedRed:0.0 green:0.2 blue:0.4 alpha:1.0];
	headerTextColor = [CPColor colorWithCalibratedRed:0.9412 green:0.7529 blue:0.0 alpha:1.0];
	cartHeadBackgroundColor = [CPColor colorWithCalibratedRed:0.1019 green:0.3098 blue:0.5215 alpha:1.0];
	background85 = [CPColor colorWithCalibratedRed:0.85 green:0.85 blue:0.85 alpha:1.0];
	background93 = [CPColor colorWithCalibratedRed:0.93 green:0.93 blue:0.93 alpha:1.0];
	background98 = [CPColor colorWithCalibratedRed:0.98 green:0.98 blue:0.98 alpha:1.0];
	missingColor = [CPColor colorWithCalibratedRed:0.5 green:0.05 blue:0.05 alpha:1.0];
	
	user = null;
	selectedCourse = null;
	selectedProficiency = null;
	
    theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
    contentView = [theWindow contentView];

    [self createHeaderView];
	[self createUserView];
	[self createCartView];
	[self createMapView];
	[self createDetailView];
	
    [theWindow orderFront:self];

	// make the first request to rails for data
	initialDataLoad = YES;
	var userrequest = [CPURLRequest requestWithURL:"/map/get_user"];
    userConnection = [CPURLConnection connectionWithRequest:userrequest delegate:self];
	
    // Uncomment the following line to turn on the standard menu bar.
    //[CPMenu setMenuBarVisible:YES];
}


- (void)createHeaderView
{
	headerView = [[CPView alloc] initWithFrame:CGRectMake(0, 0, 1200, 40)];
	[contentView addSubview:headerView];
	[contentView setBackgroundColor:[CPColor colorWithCalibratedRed:0.0 green:0.0 blue:0.21 alpha:1.0]] ;
	
	var headerText = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
    [headerText setStringValue:@"Digital Culture Map"];
    [headerText setFont:[CPFont systemFontOfSize:24.0]];
    [headerText sizeToFit];
	[headerText setTextColor:headerTextColor];
    [headerText setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
    //[headerText setFrameOrigin:CGPointMake((CGRectGetWidth([headerView bounds]) - CGRectGetWidth([headerText frame])) / 2.0, (CGRectGetHeight([headerView bounds]) - CGRectGetHeight([headerText frame])) / 2.0)];
	[headerText setFrameOrigin:CGPointMake( 30, (CGRectGetHeight([headerView bounds]) - CGRectGetHeight([headerText frame])) / 2.0)];
	[headerView addSubview:headerText];
	[headerView setBackgroundColor:headerColor] ;
}

- (void)createUserView
{
	userView = [[CPView alloc] initWithFrame:CGRectMake(0, 40, 1200, 25)];
	[userView setBackgroundColor:headerColor];
	[contentView addSubview:userView];
	
	userText = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
    [self setUserName:@"Name"];
	[userView addSubview:userText];
}

- (void)setUserName:(CPString)newString
{
	[userText setStringValue:newString];
    [userText setFont:[CPFont systemFontOfSize:16.0]];
	[userText setTextColor:headerTextColor];
    [userText sizeToFit];
    [userText setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
    [userText setFrameOrigin:CGPointMake(CGRectGetWidth([userView bounds]) - CGRectGetWidth([userText bounds]) - 10, (25 - CGRectGetHeight([userText bounds]))/2) ];
}

- (void)createCartView
{
	if (cartView)
		[cartView removeFromSuperview];
	//var h = CGRectGetHeight([contentView bounds]) - 65;
	var h = 685;
	cartView = [[CPScrollView alloc] initWithFrame:CGRectMake(0, 65, 200, h)];
	[cartView setBackgroundColor:genericBackgroundColor];
	[cartView setAutohidesScrollers:YES];
	[contentView addSubview:cartView];
	
	var cartHeadView = [[CPView alloc] initWithFrame:CGRectMake(5, 5, 190, 30)];
	[cartHeadView setBackgroundColor:cartHeadBackgroundColor];
	[cartView addSubview:cartHeadView];
	
	pathNameText = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
	var path = [DCPath currentPath];
	if (path)
    	[self setPathName:[path title]];
	[cartView addSubview:pathNameText];
	
	var classesView = [[CPView alloc] initWithFrame:CGRectMake(5, 35, 190, 645)];
	[classesView setBackgroundColor:background93];
	[cartView addSubview:classesView];
}

- (void)setPathName:(CPString)newString
{
	[pathNameText setStringValue:newString];
    [pathNameText setFont:[CPFont systemFontOfSize:16.0]];
	[pathNameText setTextColor:headerTextColor];
    [pathNameText sizeToFit];
    [pathNameText setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
    //[pathNameText setFrameOrigin:CGPointMake((CGRectGetWidth([cartView bounds]) - CGRectGetWidth([pathNameText bounds]))/2, 5) ];
	[pathNameText setFrameOrigin:CGPointMake(10, 10) ];
}

- (void)createClassesInCart
{
	if ([DCPath semesterCount] == 0)
		return;
	
	var y = 5 + CGRectGetHeight([pathNameText bounds]) + 10;
	var listOfKeys = [DCPath semesterKeys];
	for (var key in listOfKeys) {
		if (key != "isa") {
			var semesterHeadView = [[CPView alloc] initWithFrame:CGRectMake(5, y, 190, 24)];
			[semesterHeadView setBackgroundColor:background85];
			[cartView addSubview:semesterHeadView];
			
			var semesterNameText = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
			var semester = [DCSemester semesterForKey:listOfKeys[key]];
			//console.log( key + " : " + [semester title] );
			[semesterNameText setStringValue:[semester title]];
		    [semesterNameText setFont:[CPFont boldSystemFontOfSize:14.0]];
		    [semesterNameText sizeToFit];
		    [semesterNameText setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
			[semesterNameText setFrameOrigin:CGPointMake(10, y+2) ];
			[cartView addSubview:semesterNameText];
		
			y = y + 2 + CGRectGetHeight([semesterNameText bounds]) + 5;
			
			var semesterClassDictionary = [DCPath semesterForKey:listOfKeys[key]];
			var semesterClassList = [semesterClassDictionary allValues];
			for (var i = 0; i < [semesterClassList count]; i++) {
				var aClass = [semesterClassList objectAtIndex:i];
				var aCourse = [DCCourse find:[aClass courseId]];
				
				var courseNameText = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
				[courseNameText setStringValue:[aCourse prefix] + " " + [aCourse number]];
			    [courseNameText setFont:[CPFont systemFontOfSize:12.0]];
			    [courseNameText sizeToFit];
			    [courseNameText setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
				[courseNameText setFrameOrigin:CGPointMake(20, y) ];
				[cartView addSubview:courseNameText];
				
				y = y + CGRectGetHeight([semesterNameText bounds]) + 5;
			}
			
			y = y + 5;
		}
	}
}

- (void)createMapView
{
	mapView = [[CPView alloc] initWithFrame:CGRectMake(200, 65, 1000, 359)];
	[contentView addSubview:mapView];
	
	mapInfo = [[CPView alloc] initWithFrame:CGRectMake(0, 0, 1000, 30)];
	[mapInfo setBackgroundColor:background85];
	[mapView addSubview:mapInfo];
	
	showProfTextView = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
    [self setShowProfTextView:@" "];
	[mapInfo addSubview:showProfTextView];
	[showProfTextView setHidden:YES];
	
	clearShowProfButton = [[CPButton alloc] initWithFrame:CGRectMake( 5, 1, 120, 28)];
	[clearShowProfButton setEnabled:YES];
	[clearShowProfButton setFrameSize:CGSizeMake(120, 28)];
	[clearShowProfButton setImage:aButtonImage];
	[clearShowProfButton setBordered:NO];
	[clearShowProfButton setAction:@selector(clearAction:)];
	[clearShowProfButton setTitle:@"Clear Proficiency"];
	[clearShowProfButton setTarget:self];
	[clearShowProfButton setImagePosition:CPImageLeft | CPImageAbove]
    [mapInfo addSubview:clearShowProfButton];
	[clearShowProfButton setHidden:YES];
	
	level4View = [[CourseLevelView alloc] initWithFrame:CGRectMake(0, 30, 1000, 80.0) controller:self level:4];
	[mapView addSubview:level4View];
	
	level3View = [[CourseLevelView alloc] initWithFrame:CGRectMake(0, 113, 1000, 80.0) controller:self level:3];
	[mapView addSubview:level3View];
	
	level2View = [[CourseLevelView alloc] initWithFrame:CGRectMake(0, 196, 1000, 80.0) controller:self level:2];
	[mapView addSubview:level2View];
	
	level1View = [[CourseLevelView alloc] initWithFrame:CGRectMake(0, 279, 1000, 80.0) controller:self level:1];
	[mapView addSubview:level1View];
}

- (void)setShowProfTextView:(CPString)newString
{
	[showProfTextView setStringValue:newString];
    [showProfTextView setFont:[CPFont systemFontOfSize:14.0]];
	[showProfTextView setTextColor:missingColor];
    [showProfTextView sizeToFit];
    [showProfTextView setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
	[showProfTextView setFrameOrigin:CGPointMake(140, 5) ];
}

- (void)createDetailView
{
	//var h = CGRectGetHeight([contentView bounds]) - 439;
	var h = 326;
	detailView = [[CPView alloc] initWithFrame:CGRectMake(200, 424, 1000, h )];
	[detailView setBackgroundColor:[CPColor colorWithCalibratedRed:0.85 green:0.85 blue:0.85 alpha:1.0]];
	[contentView addSubview:detailView];
	
	detailPrefixAndNumber = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
	[self setPrefixAndNumber:@" "];
	[detailView addSubview:detailPrefixAndNumber];
	
	detailTitle = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
	[self setDetailTitle:@" "];
	[detailView addSubview:detailTitle];
	
	detailDescription = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
	[self setDetailDescription:null];
	[detailView addSubview:detailDescription];	
}

- (void)setPrefixAndNumber:(CPString)newString
{
    [detailPrefixAndNumber setStringValue:newString];
    [detailPrefixAndNumber setFont:[CPFont boldSystemFontOfSize:24.0]];
    [detailPrefixAndNumber sizeToFit];
    [detailPrefixAndNumber setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
    [detailPrefixAndNumber setFrameOrigin:CGPointMake(5, 5)];
}

- (void)setDetailTitle:(CPString)newString
{
    [detailTitle setStringValue:newString];
    [detailTitle setFont:[CPFont boldSystemFontOfSize:18.0]];
    [detailTitle sizeToFit];
    [detailTitle setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
	var y = CGRectGetMaxY([detailPrefixAndNumber frame]) - CGRectGetHeight([detailTitle frame]) - 1;
    [detailTitle setFrameOrigin:CGPointMake(CGRectGetMaxX([detailPrefixAndNumber frame]) + 5, y)];
}

- (void)removeAction:(id)semder
{
	console.log("removeAction");
	if ([DCPath semesterCount] == 0)
		return;
	
	var listOfKeys = [DCPath semesterKeys];
	for (var key in listOfKeys) {
		if (key != "isa") {
		
			var semesterClassDictionary = [DCPath semesterForKey:listOfKeys[key]];
			var semesterClassList = [semesterClassDictionary allValues];
			for (var i = 0; i < [semesterClassList count]; i++) {
				var aClass = [semesterClassList objectAtIndex:i];
				var aCourse = [DCCourse find:[aClass courseId]];
				
				if (aCourse.courseId == selectedCourse.courseId) {
					console.log( "found class to remove" );
					var request = [CPURLRequest requestWithURL:"/map/delete_class_from_path?path_id="+[[DCPath currentPath] pathId]+"&class_id="+[aClass classId]];
				    connection = [CPURLConnection connectionWithRequest:request delegate:self];
					[semesterClassDictionary removeObjectForKey:[aClass classId]];
					if ([semesterClassDictionary count] == 0) {
						[DCPath removeSemesterWithId:[aClass semesterId]];
					}
					[aCourse setIsInPath:NO];
					if ([aCourse cell] != undefined) {
						[[aCourse cell] setSelected:NO];
					}
					[DCPath calculateProficienciesInPath];
					[self createCartView];
					[self createClassesInCart];
					return;
				}
			}			
		}
	}
}

- (void)addAction:(id)sender
{
	classList = [classesForCourse allValues];
	for (var key in classList) {
		if (key != "isa") {
			var aClass = classList[key];
			var aSemester = [DCSemester semesterForKey:[aClass semesterId]];
			if ([sender title] == [aSemester title]) {
				console.log( "found class to add" );
				var request = [CPURLRequest requestWithURL:"/map/add_class_to_path?path_id="+[[DCPath currentPath] pathId]+"&instance_id="+[aClass classId]];
			    connection = [CPURLConnection connectionWithRequest:request delegate:self];
				
				var semesterClassDictionary = [DCPath semesterForKey:[aSemester semesterId]];
				if (!semesterClassDictionary) {
					semesterClassDictionary = [[CPDictionary alloc] init];
					[DCPath addSemester:semesterClassDictionary withId:[aSemester semesterId]];
				}
				[semesterClassDictionary setObject:aClass forKey:[aClass classId]];
				
				var aCourse = [DCCourse find:[aClass courseId]];
				[aCourse setIsInPath:YES];
				if ([aCourse cell] != undefined) {
					[[aCourse cell] setSelected:NO];
				}
				[DCPath calculateProficienciesInPath];
				[self createCartView];
				[self createClassesInCart];
				console.log("add done")
				return;
			}
		}
	}
}

- (void)setDetailDescription:(DCCourse)currentCourse
{
	if (!currentCourse)
		return;

	if (removeButton)  {
		[removeButton removeFromSuperview];
		removeButton = null;
	}
	if (buttonDictionary) {
		buttonList = [buttonDictionary allValues];
		for (var key in buttonList) {
			if (key != "isa") {
				[buttonList[key] removeFromSuperview];
			}
		}
		[buttonDictionary removeAllObjects];
		buttonDictionary = null;
	}
		
	var y = CGRectGetMaxY([detailPrefixAndNumber frame]) + 5;
	if ([currentCourse isInPath]) {
		removeButton = [[CPButton alloc] initWithFrame:CGRectMake( 5, y, 120, 28)];
		[removeButton setEnabled:YES];
		[removeButton setFrameSize:CGSizeMake(120, 28)];
		[removeButton setImage:aButtonImage];
		[removeButton setBordered:NO];
		[removeButton setAction:@selector(removeAction:)];
		[removeButton setTitle:@"Remove From Path"];
		[removeButton setTarget:self];
		[removeButton setImagePosition:CPImageLeft | CPImageAbove]
        [detailView addSubview:removeButton];
		y = y + 38;
	}
	else {
		var x = 5;
		buttonDictionary = [[CPDictionary alloc] init];
		classList = [classesForCourse allValues];
		for (var key in classList) {
			if (key != "isa") {
				var aClass = classList[key];
				var aSemester = [DCSemester semesterForKey:[aClass semesterId]];
				var button = [[CPButton alloc] initWithFrame:CGRectMake( x, y, 120, 28)];
				[button setEnabled:YES];
				[button setFrameSize:CGSizeMake(120, 28)];
				[button setImage:aButtonImage];
				[button setBordered:NO];
				[button setAction:@selector(addAction:)];
				[button setTitle:[aSemester title]];
				[button setTarget:self];
				[button setImagePosition:CPImageLeft | CPImageAbove]
		        [detailView addSubview:button];
				[buttonDictionary setObject:button forKey:[aClass classId]];
				x += 125;
			}
		}
		y = y + 38;
	}
	
	var newString = [currentCourse courseDescription]
	[detailDescription setLineBreakMode:CPLineBreakByWordWrapping];
    [detailDescription setStringValue:newString];
	var aFont = [CPFont systemFontOfSize:12.0];
    [detailDescription setFont:aFont];

    //[detailDescription sizeToFit];
    //[detailDescription setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];

	var aSize = [newString sizeWithFont:aFont inWidth:CGRectGetWidth([detailView frame])];
	console.log( "aSize: " +  aSize.width + " " + aSize.height );
	aSize.height = aSize.height + 10;
	[detailDescription setFrameSize:aSize];
	var frame = [detailDescription frame];
	console.log( "frame: " + frame.origin.x + " " + frame.origin.y + " " + frame.size.width + " " + frame.size.height );

    [detailDescription setFrameOrigin:CGPointMake(5, y)];
}

- (void)proficiencyAction:(id)sender
{
	console.log( "action for " + [sender title] );
	var prof = [DCProficiency findByTitle:[sender title]];
	if (prof) {
		//console.log( "found proficiency, its id: " + [prof proficiencyId] );
		
		var level = parseInt( parseInt([selectedCourse number]) / 100 );
		//console.log( "selected course is level " + level );
		
		if (level == 1)
			return;
		var sortLevel = level - 1;
		
		selectedProficiency = prof;
		[self setShowProfTextView:[prof title]];
		[clearShowProfButton setHidden:NO];
		[showProfTextView setHidden:NO];
		
		[DCCourse sortLevel:sortLevel byProficiency:prof];
		
		if (sortLevel == 2)
			[level2View gotoPage:0];
		else if (sortLevel == 3)
			[level3View gotoPage:0];
		else if (sortLevel == 4)
			[level4View gotoPage:0];
		
		
	}
	else {
		console.log( "didn't find it??" );
	}
}

- (void)clearAction:(id)sender
{
	[DCCourse clearHasSelectedProficiency];
	[level1View resetView];
	[level2View resetView];
	[level3View resetView];
	[showProfTextView setHidden:YES];
	[clearShowProfButton setHidden:YES];
}

- (void)setProfView:(DCCourse)currentCourse
{
	if (!currentCourse)
		return;
		
	if (detailScrollView) {
		[detailScrollView removeFromSuperview];
	}
	
	
	
	var w = CGRectGetWidth([detailView frame]);
	var h = CGRectGetHeight([detailView frame]) - CGRectGetMaxY([detailDescription frame]) - 10;
	//console.log( CGRectGetHeight([detailView frame]) + " - " +  CGRectGetMaxY([detailDescription frame]) + " makes h= " + h );
	
	detailScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY([detailDescription frame]) + 5, w, h)];
	//[detailScrollView setAutohidesScrollers:NO];
	
	[detailScrollView setHasHorizontalScroller:NO];
	[detailView addSubview:detailScrollView];
	
	//detailProfView = [[CPView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY([detailDescription frame]) + 5, w - 20, 300)];
	detailProfView = [[CPView alloc] initWithFrame:CGRectMake(0, 0, w - 20, 300)];
	[detailProfView setBackgroundColor:[CPColor colorWithCalibratedRed:0.80 green:0.80 blue:0.80 alpha:1.0]];
	[detailScrollView setDocumentView:detailProfView];
	
	var y = 5;
	var max_y = y;
	
	if ([currentCourse incomingProficiencyCount] > 0)
		max_y = [self showIncomingProficiencies:currentCourse atY:y];
	
	//console.log( "max_y finished at " + max_y );
	y = max_y + 10;
	//console.log( "y== " + y );
	
	if ([currentCourse outgoingProficiencyCount] > 0)
		max_y = [self showOutgoingProficiencies:currentCourse atY:y];
	
	//[detailProfView setFrameSize:CGSizeMake(w - 20, max_y + 10)];
	
}

- (float)showOutgoingProficiencies:(DCCourse)currentCourse atY:(float)y
{
	var outText = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
	[outText setStringValue:"Outgoing Proficiencies"];
    [outText setFont:[CPFont systemFontOfSize:16.0]];
    [outText sizeToFit];
    [outText setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
	[outText setFrameOrigin:CGPointMake(5, y) ];
	[detailProfView addSubview:outText];

	y = y + CGRectGetHeight([outText bounds]) + 5;
	
	var outList = [currentCourse outgoingArray];
	for (var key in outList) {
		if (key != "isa") {
			outText = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
			var p = outList[key];
			[outText setStringValue:[p title]];
		    [outText setFont:[CPFont systemFontOfSize:12.0]];
		    [outText sizeToFit];
		    [outText setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
			[outText setFrameOrigin:CGPointMake(15, y) ];
			[detailProfView addSubview:outText];
			y = y + CGRectGetHeight([outText bounds]) + 2;
		}
	}
	
	return y + 10;
}

- (float)showIncomingProficiencies:(DCCourse)currentCourse atY:(float)y
{
	var inText = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
	[inText setStringValue:"Incoming Proficiencies"];
    [inText setFont:[CPFont systemFontOfSize:16.0]];
    [inText sizeToFit];
    [inText setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
	[inText setFrameOrigin:CGPointMake(5, y) ];
	[detailProfView addSubview:inText];
	
	y = y + CGRectGetHeight([inText bounds]) + 5;
	
	var start_y = y;
	var start_x = 5;
	var max_x = start_x;
	var max_y = start_y;
	for (var i = 0; i < 5; i++) {
		start_y = y;
		start_x = max_x + 10;
		var inList = [currentCourse incomingArrayForSlot:i];
		if (inList) {
		
			inText = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
			[inText setStringValue:"Slot " + i];
		    [inText setFont:[CPFont boldSystemFontOfSize:12.0]];
		    [inText sizeToFit];
		    [inText setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
			[inText setFrameOrigin:CGPointMake(start_x, start_y) ];
			[detailProfView addSubview:inText];

			start_y = start_y + CGRectGetHeight([inText bounds]) + 5;
			max_x = CGRectGetMaxX([inText frame]);
			console.log("max_y starts at " + max_y );
			
			for (var key in inList) {
				//console.log( ">> " + key );
				if (key != "isa") {
					var p = inList[key];
					if ([DCPath isProficiencyInPath:p]) {
						inText = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
						[inText setStringValue:[p title]];
					    [inText setFont:[CPFont systemFontOfSize:12.0]];
						[inText setTextColor:[CPColor colorWithCalibratedRed:0.0 green:0.7 blue:0.1 alpha:1.0]];
					    [inText sizeToFit];
						var offset = (28 - CGRectGetHeight([inText bounds])) / 2;
						start_y = start_y + offset;
					    [inText setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
						[inText setFrameOrigin:CGPointMake(start_x, start_y) ];
						[detailProfView addSubview:inText];
						
						var x1 = start_x + CGRectGetWidth([inText bounds]);
						var y1 = start_y + CGRectGetHeight([inText bounds]);
						start_y = start_y + CGRectGetHeight([inText bounds]) + 2;
						if (x1 > max_x)
							max_x = x1;
						if (y1 > max_y)
							max_y = y1;
					}
					else {
						
						
						var pname = [p title];
						var font = [CPFont systemFontOfSize:10.0];
						var namesize = [name sizeWithFont:font];
						var button = [[CPButton alloc] initWithFrame:CGRectMake( start_x, start_y, 180, 28)];
						[button setEnabled:YES];
						[button setBordered:NO];
						[button setAction:@selector(proficiencyAction:)];
						[button setTitle:pname];
						[button setFont:font];
						[button setTextColor:[CPColor colorWithCalibratedRed:0.6 green:0.1 blue:0.1 alpha:1.0]];
						[button setTarget:self];
						[button setImage:bButtonImage];
						[button setImagePosition:CPImageLeft | CPImageAbove]
				        [detailProfView addSubview:button];
						var x1 = start_x + CGRectGetWidth([button bounds]);
						var y1 = start_y + CGRectGetHeight([button bounds]);
						start_y = start_y + CGRectGetHeight([button bounds]) + 2;
						if (x1 > max_x)
							max_x = x1;
						if (y1 > max_y)
							max_y = y1;
					}
					console.log( "max_y is now " + max_y );
				}
			}
		}
	}
	
	return max_y;
}

- (void)queryForClasses:(DCCourse)aCourse
{
	var request = [CPURLRequest requestWithURL:"/map/classes_for_course?course_id=" + [aCourse courseId]];
    classQuery = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)connectionDidFinishLoading:(CPURLConnection)aConnection
{
	console.log("connectionDidFinishLoading:");
	
	if (initialDataLoad) {
		if (userConnection == aConnection) {
			var request = [CPURLRequest requestWithURL:"/map/proficiencies"];
		    profConnection = [CPURLConnection connectionWithRequest:request delegate:self];
		}
		else if (profConnection == aConnection) {
			var request = [CPURLRequest requestWithURL:"/map/courses?level=400"];
		    connection4 = [CPURLConnection connectionWithRequest:request delegate:self];
		}
		else if (connection4 == aConnection) {
			request = [CPURLRequest requestWithURL:"/map/courses?level=300"];
		    connection3 = [CPURLConnection connectionWithRequest:request delegate:self];
		}
		else if (connection3 == aConnection) {
			request = [CPURLRequest requestWithURL:"/map/courses?level=200"];
		    connection2 = [CPURLConnection connectionWithRequest:request delegate:self];
		}
		else if (connection2 == aConnection) {
			request = [CPURLRequest requestWithURL:"/map/courses?level=100"];
		    connection1 = [CPURLConnection connectionWithRequest:request delegate:self];
		}
		else if (connection1 == aConnection) {
			var request = [CPURLRequest requestWithURL:"/map/course_proficiencies"];
		    courseProfConnection = [CPURLConnection connectionWithRequest:request delegate:self];
		}
		else if (courseProfConnection == aConnection) {
			var pathrequest = [CPURLRequest requestWithURL:"/map/get_current_path"];
		    pathConnection = [CPURLConnection connectionWithRequest:pathrequest delegate:self];
		}
		else if (pathConnection == aConnection) {
			var semestersrequest = [CPURLRequest requestWithURL:"/map/semesters"];
		    semestersConnection = [CPURLConnection connectionWithRequest:semestersrequest delegate:self];
		}
		else if (semestersConnection == aConnection) {
			var classesrequest = [CPURLRequest requestWithURL:"/map/get_classes_in_current_path"];
		    classesConnection = [CPURLConnection connectionWithRequest:classesrequest delegate:self];
			
			// this statement should be in the final request block.
			initialDataLoad = NO;
		}
	}

	//[contentView setNeedsDisplay:YES];
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)data
{
	console.log("connection:didReceiveData:");
	//console.log(data);
	var results = CPJSObjectCreateWithJSON(data);
	
	if (aConnection == connection4) {
		[self createCourses:results level:4];
		[level4View setContent:[DCCourse coursesPage:0 level:4]];
	}
	else if (aConnection == connection3) {
		[self createCourses:results level:3];
		[level3View setContent:[DCCourse coursesPage:0 level:3]];
	}
	else if (aConnection == connection2) {
		[self createCourses:results level:2];
		[level2View setContent:[DCCourse coursesPage:0 level:2]];
	}
	else if (aConnection == connection1) {
		[self createCourses:results level:1];
		[level1View setContent:[DCCourse coursesPage:0 level:1]];
	}
	else if (aConnection == userConnection) {
		for (var key in results) {
			var obj = results[key];
			if (obj["user"]) {
				user = [[DCUser alloc] initWithData:obj];
				[self setUserName:[user full_name]];
			}
		}
	}
	else if (aConnection == pathConnection) {
		for (var key in results) {
			var obj = results[key];
			if (obj["title"]) {
				var path = [[DCPath alloc] initWithData:obj];
				[DCPath setCurrentPath:path];
				[self setPathName:[path title]];
			}
		}
	}
	else if (aConnection == classesConnection) {
		//console.log(data)
		[self handleClassData:results]
	}
	else if (aConnection == semestersConnection) {
		for (var key in results) {
			var obj = results[key];
			if (obj["semester"]) {
				var aSemester = [[DCSemester alloc] initWithData:obj];
				[DCSemester addSemester:aSemester];
			}
		}
	}
	else if (aConnection == profConnection) {
		for (var key in results) {
			var obj = results[key];
			if (obj["proficiency"]) {
				var p = [[DCProficiency alloc] initWithData:obj];
				[DCProficiency add:p];
			}
		}
	}
	else if (aConnection == courseProfConnection) {
		for (var key in results) {
			var obj = results[key];
			if (obj["course_proficiency"]) {
				var cp = [[DCCourseProficiency alloc] initWithData:obj];
				var aCourse = [DCCourse find:[cp courseId]];
				[aCourse addCourseProficiency:cp];
			}
		}
	}
	else if (aConnection == classQuery) {
		if (classesForCourse) 
			[classesForCourse removeAllObjects];
		classesForCourse = [[CPDictionary alloc] init];
		console.log(data);
		for (var key in results) {
			var obj = results[key];
			if (obj["instance"]) {
				var aClass = [[DCClass alloc] initWithData:obj];
				[classesForCourse setObject:aClass forKey:[aClass classId]];
			}
		}
		[self setDetailDescription:selectedCourse];
		[self setProfView:selectedCourse];
	}
}

- (void)handleClassData:(JSObject)results
{
	for (var key in results) {
		if (key != "isa") {
			var semesterId;
			var semesterDictionary = [[CPDictionary alloc] init];
			var obj = results[key];
			//console.log(key);
			for (var key2 in obj) {
				var obj2 = obj[key2];
				if (key2 == 0) {
					//console.log("semester: " + obj2);
					semesterId = parseInt(obj2);
				}
				else {
					for (var key3 in obj2) {
						var obj3 = obj2[key3];
						if (obj3["instance"]) {
							var aClass = [[DCClass alloc] initWithData:obj3];
							//console.log( "course: " + aClass.courseId );
							[semesterDictionary setObject:aClass forKey:[aClass classId]];
						}
					}
				}
			}
			[DCPath addSemester:semesterDictionary withId:semesterId];
		}
	}
	[self processClassesInPath];
	[DCPath calculateProficienciesInPath];
	[self createClassesInCart];
}



- (void)processClassesInPath
{
	if ([DCPath semesterCount] == 0)
		return;
	
	var listOfKeys = [DCPath semesterKeys];
	for (var key in listOfKeys) {
		if (key != "isa") {
		
			var semesterClassDictionary = [DCPath semesterForKey:listOfKeys[key]];
			var semesterClassList = [semesterClassDictionary allValues];
			for (var i = 0; i < [semesterClassList count]; i++) {
				var aClass = [semesterClassList objectAtIndex:i];
				var aCourse = [DCCourse find:[aClass courseId]];
				[aCourse setIsInPath:YES];
				if ([aCourse cell] != undefined) {
					[[aCourse cell] setSelected:NO];
				}
			}			
		}
	}
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPString)error
{
	console.log( "connection didFailWithError" );
    alert(error) ;
}

- (void)collectionViewDidChangeSelection:(CPCollectionView)collectionView
{
	console.log("collectionViewDidChangeSelection")
}

- (void)createCourses:(CPArray)results level:(int)level
{
	for (var key in results) {
		var obj = results[key];
		if (obj["course"]) {
			var aCourse = [[DCCourse alloc] initWithData:obj];
			[aCourse setDelegate:self];
			//console.log( obj.course.prefix + " " + obj.course.number )
			[DCCourse add:aCourse level:level];
		}
		
	}
}

- (void)handleSelection:(DCCourse)sender
{
	[self queryForClasses:sender];
	
	[level4View clearSelection];
	[level3View clearSelection];
	[level2View clearSelection];
	[level1View clearSelection];
	[sender setAsSelected];
	selectedCourse = sender;
	
	// update the detail view
	[self setPrefixAndNumber:[sender short_name]];
	[self setDetailTitle:sender.title];
	[self setDetailDescription:sender];
	[self setProfView:sender];
	
	[level4View setNeedsDisplay:YES];
}


@end

