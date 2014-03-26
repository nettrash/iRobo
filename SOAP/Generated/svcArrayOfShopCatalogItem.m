/*
	svcArrayOfShopCatalogItem.h
	The implementation of properties and methods for the svcArrayOfShopCatalogItem array.
	Generated by SudzC.com
*/
#import "svcArrayOfShopCatalogItem.h"

#import "svcShopCatalogItem.h"
@implementation svcArrayOfShopCatalogItem

	+ (id) createWithNode: (CXMLNode*) node
	{
		return [[self alloc] initWithNode: node];
	}

	- (id) initWithNode: (CXMLNode*) node
	{
		if(self = [self init]) {
			for(CXMLElement* child in [node children])
			{
				svcShopCatalogItem* value = [[svcShopCatalogItem createWithNode: child] object];
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
			[s appendString: [item serialize: @"ShopCatalogItem"]];
		}
		return s;
	}
@end
