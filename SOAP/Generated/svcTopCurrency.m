/*
	svcTopCurrency.h
	The implementation of properties and methods for the svcTopCurrency object.
	Generated by SudzC.com
*/
#import "svcTopCurrency.h"

@implementation svcTopCurrency
	@synthesize Label = _Label;
    @synthesize Name = _Name;
	@synthesize Count = _Count;
	@synthesize Parameters = _Parameters;
    @synthesize zeroComission = _zeroComission;

	- (id) init
	{
		if(self = [super init])
		{
			self.Label = nil;
            self.Name = nil;
			self.Parameters = nil;
            self.OutPossibleValues = nil;
		}
		return self;
	}

	+ (svcTopCurrency*) createWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return [[self alloc] initWithNode: node];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.Label = [Soap getNodeValue: node withName: @"Label"];
			self.Name = [Soap getNodeValue: node withName: @"Name"];
			self.Count = [[Soap getNodeValue: node withName: @"Count"] intValue];
			self.Parameters = [Soap getNodeValue: node withName: @"Parameters"];
			self.OutPossibleValues = [Soap getNodeValue: node withName: @"OutPossibleValues"];
			self.zeroComission = [[Soap getNodeValue: node withName: @"zeroComission"] boolValue];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"TopCurrency"];
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
		if (self.Label != nil) [s appendFormat: @"<Label>%@</Label>", [[self.Label stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.Name != nil) [s appendFormat: @"<Name>%@</Name>", [[self.Name stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		[s appendFormat: @"<Count>%@</Count>", [NSString stringWithFormat: @"%i", self.Count]];
		if (self.Parameters != nil) [s appendFormat: @"<Parameters>%@</Parameters>", [[self.Parameters stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.OutPossibleValues != nil) [s appendFormat: @"<OutPossibleValues>%@</OutPossibleValues>", [[self.OutPossibleValues stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		[s appendFormat: @"<zeroComission>%@</zeroComission>", (self.zeroComission)?@"true":@"false"];

		return s;
	}
	
	- (NSMutableString*) serializeAttributes
	{
		NSMutableString* s = [super serializeAttributes];

		return s;
	}
	
	-(BOOL)isEqual:(id)object{
		if(object != nil && [object isKindOfClass:[svcTopCurrency class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	-(NSUInteger)hash{
		return [Soap generateHash:self];

	}

@end
