/*
 * DCCourseLevelView.j
 * Digital Culture Map
 *
 * 
 */

var buttonImage,
    buttonImageAlt,
	buttonImageSelected,
	buttonImageInPath;
	
@implementation CourseLevelView : CPView
{
    CPCollectionView listView;
	CPButton leftButton;
	CPButton rightButton;
	int pageNumber;
	int level;
	var controller;
}

- (id)initWithFrame:(CGRect)aFrame controller:(CPObject)ctrl level:(int)aLevel
{
	self = [super initWithFrame:aFrame];
	
	if (self) {
		controller = ctrl;
		
		var leftbuttonimage = [[CPImage alloc] initWithContentsOfFile:"http://localhost:3000/images/left_arrow2.png"];
		//leftButton = [[CPButton alloc] initWithFrame:CGRectMake( (CGRectGetWidth([self bounds]) - 30)/2, (CGRectGetHeight([self bounds]) - 30)/2, 30, 30)];
		leftButton = [[CPButton alloc] initWithFrame:CGRectMake( 5, 25, 30, 30)];
		[leftButton setImage:leftbuttonimage];
		//[leftButton setAlternateImage:buttonaltimage];
		[leftButton setBordered:NO];
		[leftButton setAction:@selector(nextPage:)];
		[leftButton setTarget:self];
		[leftButton setImagePosition:CPImageLeft | CPImageAbove]
        [self addSubview:leftButton];
	
		[self createCollectionView];
		
		
		var rightbuttonimage = [[CPImage alloc] initWithContentsOfFile:"http://localhost:3000/images/right_arrow2.png"];
		rightButton = [[CPButton alloc] initWithFrame:CGRectMake( CGRectGetWidth(aFrame) - 35, 25, 30, 30)];
		[rightButton setImage:rightbuttonimage];
		//[rightButton setAlternateImage:buttonaltimage];
		[rightButton setBordered:NO];
		[rightButton setAction:@selector(nextPage:)];
		[rightButton setTarget:self];
		[rightButton setImagePosition:CPImageLeft | CPImageAbove]
        [self addSubview:rightButton];
		
		[self setBackgroundColor:[CPColor colorWithCalibratedRed:0.90 green:0.90 blue:0.90 alpha:1.0]] ;
		
		pageNumber = 0;
		level = aLevel;
	}
	
	return self;
}

- (void)createCollectionView
{
	var courseItem = [[CPCollectionViewItem alloc] init] ;
    [courseItem setView:[[CourseCell alloc] initWithFrame:CGRectMakeZero()]] ;

	if (listView)
		[listView removeFromSuperview];
	listView = [[CPCollectionView alloc] initWithFrame:CGRectMake(40, 5, CGRectGetWidth([self bounds]) - 80, CGRectGetHeight([self bounds]) - 10)];
	[listView setDelegate:controller] ;
    [listView setItemPrototype:courseItem] ;
	[listView setSelectable:YES];
	[listView setAllowsMultipleSelection:NO];

    [listView setMinItemSize:CGSizeMake(140.0, 60.0)] ;
    [listView setMaxItemSize:CGSizeMake(140.0, 60.0)] ;
    //[listView setAutoresizingMask:CPViewWidthSizable] ;
	[listView setMaxNumberOfRows:1];
	[listView setMaxNumberOfColumns:6];
	[listView setBackgroundColor:[CPColor colorWithCalibratedRed:0.85 green:0.85 blue:0.85 alpha:1.0]] ;
	[self addSubview:listView];
}

- (void)setContent:(CPArray)values
{
	[listView setContent:values];
}

- (void)clearSelection
{
	//console.log( "clearSelection" );
	var indexSet = [listView selectionIndexes];
	if ([indexSet count] > 0) {
		//console.log( "something is selected" );
	}
	[listView setSelectionIndexes:[[CPIndexSet alloc] init]];
}

- (void)nextPage:(id)sender
{
	console.log( "nextPage, pageNumber currently is " + pageNumber );
	if (sender == rightButton) {
		console.log( "rightButton");
		pageNumber = pageNumber + 1;
		if (pageNumber > [DCCourse lastPageForLevel:level])
			pageNumber = 0;
		[self setContent:[DCCourse coursesPage:pageNumber level:level]];
	}
	else {
		console.log( "leftButton" );
		pageNumber = pageNumber - 1;
		console.log( "1 pageNumber is " + pageNumber );
		if (pageNumber < 0)
			pageNumber = [DCCourse lastPageForLevel:level];
		console.log( "2 pageNumber is " + pageNumber );
		[self setContent:[DCCourse coursesPage:pageNumber level:level]];
	}
	console.log( "exit pageNumber is " + pageNumber );
}

- (void)gotoPage:(int)aPageNumber
{
	if (aPageNumber < 0)
		pageNumber = 0;
	else if (aPageNumber > [DCCourse lastPageForLevel:level])
		pageNumber = [DCCourse lastPageForLevel:level];
	else
		pageNumber = aPageNumber;
	[self setContent:[DCCourse coursesPage:pageNumber level:level]];
}

- (void)resetView
{
	console.log("resetView");
	//[listView reloadContent];
	//[self setContent:[[CPArray alloc] init]];
	//
	
	itemsList = [listView items];
	for (var key in itemsList) {
		if (key != "isa") {
			var anItem = itemsList[key];
			var c = [anItem representedObject];
			console.log( ">>> " + [c short_name] );
			[c setCell:null];
		}
	}
	
	[self createCollectionView];
	[self setContent:[DCCourse coursesPage:pageNumber level:level]];
}



@end