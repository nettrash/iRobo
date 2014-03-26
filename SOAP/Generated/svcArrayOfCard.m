/*
	svcArrayOfCard.h
	The implementation of properties and methods for the svcArrayOfCard array.
	Generated by SudzC.com
*/
#import "svcArrayOfCard.h"

#import "svcCard.h"
@implementation svcArrayOfCard

	+ (id) createWithNode: (CXMLNode*) node
	{
		return [[self alloc] initWithNode: node];
	}

	- (id) initWithNode: (CXMLNode*) node
	{
		if(self = [self init]) {
			for(CXMLElement* child in [node children])
			{
				svcCard* value = [[svcCard createWithNode: child] object];
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
			[s appendString: [item serialize: @"Card"]];
		}
		return s;
	}
@end
