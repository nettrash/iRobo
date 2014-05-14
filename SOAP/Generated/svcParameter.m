/*
	svcParameter.h
	The implementation of properties and methods for the svcParameter object.
	Generated by SudzC.com
*/
#import "svcParameter.h"

#import "svcArrayOfParameter.h"
@implementation svcParameter
	@synthesize Name = _Name;
	@synthesize Label = _Label;
	@synthesize Type = _Type;
	@synthesize innerParameters = _innerParameters;
	@synthesize DefaultValue = _DefaultValue;
	@synthesize Format = _Format;

	- (id) init
	{
		if(self = [super init])
		{
			self.Name = nil;
			self.Label = nil;
			self.Type = nil;
			self.innerParameters = [[NSMutableArray alloc] init];
			self.DefaultValue = nil;
			self.Format = nil;

		}
		return self;
	}

	+ (svcParameter*) createWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return [[self alloc] initWithNode: node];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.Name = [Soap getNodeValue: node withName: @"Name"];
			self.Label = [Soap getNodeValue: node withName: @"Label"];
			self.Type = [Soap getNodeValue: node withName: @"Type"];
			self.innerParameters = [[svcArrayOfParameter createWithNode: [Soap getNode: node withName: @"innerParameters"]] object];
			self.DefaultValue = [Soap getNodeValue: node withName: @"DefaultValue"];
			self.Format = [Soap getNodeValue: node withName: @"Format"];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"Parameter"];
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
		if (self.Type != nil) [s appendFormat: @"<Type>%@</Type>", [[self.Type stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.innerParameters != nil && self.innerParameters.count > 0) {
			[s appendFormat: @"<innerParameters>%@</innerParameters>", [svcArrayOfParameter serialize: self.innerParameters]];
		} else {
			[s appendString: @"<innerParameters/>"];
		}
		if (self.DefaultValue != nil) [s appendFormat: @"<DefaultValue>%@</DefaultValue>", [[self.DefaultValue stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.Format != nil) [s appendFormat: @"<Format>%@</Format>", [[self.Format stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];

		return s;
	}
	
	- (NSMutableString*) serializeAttributes
	{
		NSMutableString* s = [super serializeAttributes];

		return s;
	}
	
	-(BOOL)isEqual:(id)object{
		if(object != nil && [object isKindOfClass:[svcParameter class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	-(NSUInteger)hash{
		return [Soap generateHash:self];

	}

@end