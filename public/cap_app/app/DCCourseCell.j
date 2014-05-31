/*
 * DCCourseCell.j
 * Digital Culture Map
 *
 * 
 */


@implementation CourseCell : CPView
{
    CPTextField button;
	id obj;
}


+ (void)initialize
{
	if (self != CourseCell)
        return;

	buttonImage = [[CPImage alloc] initWithContentsOfFile:"http://localhost:3000/images/button3.png"];
	buttonImageAlt = [[CPImage alloc] initWithContentsOfFile:"http://localhost:3000/images/button_test_alt.png"];
	buttonImageSelected = [[CPImage alloc] initWithContentsOfFile:"http://localhost:3000/images/button3_selected.png"];
	buttonImageHasProf = [[CPImage alloc] initWithContentsOfFile:"http://localhost:3000/images/button3_prof.png"];
	buttonImageInPath = [[CPImage alloc] initWithContentsOfFile:"http://localhost:3000/images/button3_inpath.png"];
	buttonImageInPathSelected = [[CPImage alloc] initWithContentsOfFile:"http://localhost:3000/images/button3_selected_inpath.png"];
}

- (void)setRepresentedObject:(JSObject)anObject
{
	console.log("setRepresentedObject " + [anObject short_name] );
	obj = anObject;
    if (!button) {
		button = [[CPButton alloc] initWithFrame:CGRectMake( 10, 10, 120, 40)];
		[button setEnabled:YES];
		[button setFrameSize:CGSizeMake(120, 40)];
		[button setBordered:NO];
		[button setAction:@selector(selectAction:)];
		[button setImagePosition:CPImageLeft | CPImageAbove]
        [self addSubview:button];
    }

	[self setButtonAppearance];
	[button setTitle:[anObject short_name]];
	[anObject setCell:self];
	[button setTarget:anObject];
	

}

- (void)setButtonAppearance
{
	console.log("setButtonAppearance " + [obj short_name] );
	if ([obj isInPath]) {
		[button setImage:buttonImageInPath];
	}
	else {
		if ([obj hasSelectedProficiency])
			[button setImage:buttonImageHasProf];
		else
			[button setImage:buttonImage];
	}
	
	[button setAlternateImage:buttonImageAlt];
}

- (void)setSelected:(BOOL)isSelected
{
	if (isSelected) {
		if ([obj isInPath]) {
			[button setImage:buttonImageInPathSelected];
		}
		else {
			[button setImage:buttonImageSelected];
		}
	}
	else {
		[self setButtonAppearance];
	}
	[button setNeedsDisplay:YES];
}

@end
