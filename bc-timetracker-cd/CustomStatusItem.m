//
// From https://github.com/oscardelben
//

#import "CustomStatusItem.h"

@implementation CustomStatusItem

@synthesize delegate;
@synthesize freeMemory;
@synthesize menuBarImage;
@synthesize imageRect;

- (void)drawRect:(NSRect)dirtyRect
{
  NSLog(@" draw rect");
    NSRect destRect = NSZeroRect;
    destRect.size = dirtyRect.size;
  
    self.menuBarImage = [NSImage imageNamed:@"file_menu2.png"];
    imageRect = NSMakeRect(0, 3, menuBarImage.size.width, menuBarImage.size.height);
    [menuBarImage drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
    [self setFrameSize:NSMakeSize(menuBarImage.size.width + 2.0, self.frame.size.height)];
    
    NSLog(@" done draw rect");
}

#pragma mark --
#pragma mark toggleWindow

- (NSPoint)getAnchorPoint
{	
	NSRect frame = [[self window] frame];
	NSRect screen = [[NSScreen mainScreen] frame];
	NSPoint point = NSMakePoint(NSMidX(frame), screen.size.height - [[NSStatusBar systemStatusBar] thickness]);
    
	return point;
}

- (void)toggleShowWindow
{
    if ([(NSObject *)delegate respondsToSelector:@selector(toggleShowWindowFromPoint:)]) {
        [delegate toggleShowWindowFromPoint:[self getAnchorPoint]];
    }
}

#pragma mark --
#pragma mark Events

- (void)mouseDown:(NSEvent *)event {
    [self toggleShowWindow];
}

@end
