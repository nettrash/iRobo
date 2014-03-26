/*
	svcArrayOfTerminal.h
	The implementation of properties and methods for the svcArrayOfTerminal array.
	Generated by SudzC.com
*/
#import "svcArrayOfTerminal.h"

#import "svcTerminal.h"
@implementation svcArrayOfTerminal

	+ (id) createWithNode: (CXMLNode*) node
	{
		return [[self alloc] initWithNode: node];
	}

	- (id) initWithNode: (CXMLNode*) node
	{
		if(self = [self init]) {
			for(CXMLElement* child in [node children])
			{
				svcTerminal* value = [[svcTerminal createWithNode: child] object];
				if(value != nil) {
					[self addObject: value];
				}
			}
		}
		return self;
	}
	
	+ (NSMutableString*) serialize: (NSArray*) array
	{
		NSMutableString* s = [NSMutableString string];
		for(id item in array) {
			[s appendString: [item serialize: @"Terminal"]];
		}
		return s;
	}
@end
