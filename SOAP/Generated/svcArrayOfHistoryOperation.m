/*
	svcArrayOfHistoryOperation.h
	The implementation of properties and methods for the svcArrayOfHistoryOperation array.
	Generated by SudzC.com
*/
#import "svcArrayOfHistoryOperation.h"

#import "svcHistoryOperation.h"
@implementation svcArrayOfHistoryOperation

	+ (id) createWithNode: (CXMLNode*) node
	{
		return [[self alloc] initWithNode: node];
	}

	- (id) initWithNode: (CXMLNode*) node
	{
		if(self = [self init]) {
			for(CXMLElement* child in [node children])
			{
				svcHistoryOperation* value = [[svcHistoryOperation createWithNode: child] object];
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
			[s appendString: [item serialize: @"HistoryOperation"]];
		}
		return s;
	}
@end
