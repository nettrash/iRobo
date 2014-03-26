/*
	svcArrayOfShopItem.h
	The implementation of properties and methods for the svcArrayOfShopItem array.
	Generated by SudzC.com
*/
#import "svcArrayOfShopItem.h"

#import "svcShopItem.h"
@implementation svcArrayOfShopItem

	+ (id) createWithNode: (CXMLNode*) node
	{
		return [[self alloc] initWithNode: node];
	}

	- (id) initWithNode: (CXMLNode*) node
	{
		if(self = [self init]) {
			for(CXMLElement* child in [node children])
			{
				svcShopItem* value = [[svcShopItem createWithNode: child] object];
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
			[s appendString: [item serialize: @"ShopItem"]];
		}
		return s;
	}
@end
