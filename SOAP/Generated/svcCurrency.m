/*
	svcCurrency.h
	The implementation of properties and methods for the svcCurrency object.
	Generated by SudzC.com
*/
#import "svcCurrency.h"

@implementation svcCurrency
	@synthesize Name = _Name;
	@synthesize Label = _Label;
	@synthesize PossibleValues = _PossibleValues;
	@synthesize OrderNum = _OrderNum;
	@synthesize Action = _Action;

	- (id) init
	{
		if(self = [super init])
		{
			self.Name = nil;
			self.Label = nil;
			self.PossibleValues = nil;
			self.Action = nil;

		}
		return self;
	}

	+ (svcCurrency*) createWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return [[self alloc] initWithNode: node];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.Name = [Soap getNodeValue: node withName: @"Name"];
			self.Label = [Soap getNodeValue: node withName: @"Label"];
			self.PossibleValues = [Soap getNodeValue: node withName: @"PossibleValues"];
			self.OrderNum = [[Soap getNodeValue: node withName: @"OrderNum"] intValue];
			self.Action = [Soap getNodeValue: node withName: @"Action"];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"Currency"];
	}
  
	- (NSMutableString*) serialize: (NSString*) nodeName
	{
		NSMutableString* s = [NSMutableString string];
		[s appendFormat: @"<%@", nodeName];
		[s appendString: [self serializeAttributes]];
		[s appendString: @">"];
		[s appendString: [self serializeElements]];
		[s appendFormat: @"</%@>", nodeName];
		return s;
	}
	
	- (NSMutableString*) serializeElements
	{
		NSMutableString* s = [super serializeElements];
		if (self.Name != nil) [s appendFormat: @"<Name>%@</Name>", [[self.Name stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.Label != nil) [s appendFormat: @"<Label>%@</Label>", [[self.Label stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.PossibleValues != nil) [s appendFormat: @"<PossibleValues>%@</PossibleValues>", [[self.PossibleValues stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		[s appendFormat: @"<OrderNum>%@</OrderNum>", [NSString stringWithFormat: @"%i", self.OrderNum]];
		if (self.Action != nil) [s appendFormat: @"<Action>%@</Action>", [[self.Action stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];

		return s;
	}
	
	- (NSMutableString*) serializeAttributes
	{
		NSMutableString* s = [super serializeAttributes];

		return s;
	}
	
	-(BOOL)isEqual:(id)object{
		if(object != nil && [object isKindOfClass:[svcCurrency class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	-(NSUInteger)hash{
		return [Soap generateHash:self];

	}

@end
