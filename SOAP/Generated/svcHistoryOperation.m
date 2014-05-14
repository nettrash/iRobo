/*
	svcHistoryOperation.h
	The implementation of properties and methods for the svcHistoryOperation object.
	Generated by SudzC.com
*/
#import "svcHistoryOperation.h"

@implementation svcHistoryOperation
	@synthesize op_RegDate = _op_RegDate;
	@synthesize op_Key = _op_Key;
	@synthesize out_curr = _out_curr;
	@synthesize op_Parameters = _op_Parameters;
	@synthesize card_Id = _card_Id;
	@synthesize op_Sum = _op_Sum;
	@synthesize process = _process;
	@synthesize state = _state;
	@synthesize fin = _fin;
	@synthesize currName = _currName;
	@synthesize errorMessage = _errorMessage;
	@synthesize inFavorites = _inFavorites;
	@synthesize check_Id = _check_Id;
	@synthesize check_MerchantName = _check_MerchantName;
	@synthesize check_MerchantOrder = _check_MerchantOrder;
	@synthesize charity_Id = _charity_Id;
	@synthesize charity_Name = _charity_Name;

	- (id) init
	{
		if(self = [super init])
		{
			self.op_RegDate = nil;
			self.op_Key = nil;
			self.out_curr = nil;
			self.op_Parameters = nil;
			self.op_Sum = nil;
			self.process = nil;
			self.state = nil;
			self.currName = nil;
			self.errorMessage = nil;
			self.check_MerchantName = nil;
			self.check_MerchantOrder = nil;
			self.charity_Name = nil;

		}
		return self;
	}

	+ (svcHistoryOperation*) createWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return [[self alloc] initWithNode: node];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.op_RegDate = [Soap dateFromString: [Soap getNodeValue: node withName: @"op_RegDate"]];
			self.op_Key = [Soap getNodeValue: node withName: @"op_Key"];
			self.out_curr = [Soap getNodeValue: node withName: @"out_curr"];
			self.op_Parameters = [Soap getNodeValue: node withName: @"op_Parameters"];
			self.card_Id = [[Soap getNodeValue: node withName: @"card_Id"] intValue];
			self.op_Sum = [NSDecimalNumber decimalNumberWithString: [Soap getNodeValue: node withName: @"op_Sum"]];
			self.process = [Soap getNodeValue: node withName: @"process"];
			self.state = [Soap getNodeValue: node withName: @"state"];
			self.fin = [[Soap getNodeValue: node withName: @"fin"] boolValue];
			self.currName = [Soap getNodeValue: node withName: @"currName"];
			self.errorMessage = [Soap getNodeValue: node withName: @"errorMessage"];
			self.inFavorites = [[Soap getNodeValue: node withName: @"inFavorites"] boolValue];
			self.check_Id = [[Soap getNodeValue: node withName: @"check_Id"] intValue];
			self.check_MerchantName = [Soap getNodeValue: node withName: @"check_MerchantName"];
			self.check_MerchantOrder = [Soap getNodeValue: node withName: @"check_MerchantOrder"];
			self.charity_Id = [[Soap getNodeValue: node withName: @"charity_Id"] intValue];
			self.charity_Name = [Soap getNodeValue: node withName: @"charity_Name"];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"HistoryOperation"];
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
		if (self.op_RegDate != nil) [s appendFormat: @"<op_RegDate>%@</op_RegDate>", [Soap getDateString: self.op_RegDate]];
		if (self.op_Key != nil) [s appendFormat: @"<op_Key>%@</op_Key>", [[self.op_Key stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.out_curr != nil) [s appendFormat: @"<out_curr>%@</out_curr>", [[self.out_curr stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.op_Parameters != nil) [s appendFormat: @"<op_Parameters>%@</op_Parameters>", [[self.op_Parameters stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		[s appendFormat: @"<card_Id>%@</card_Id>", [NSString stringWithFormat: @"%i", self.card_Id]];
		if (self.op_Sum != nil) [s appendFormat: @"<op_Sum>%@</op_Sum>", [NSString stringWithFormat: @"%@", self.op_Sum]];
		if (self.process != nil) [s appendFormat: @"<process>%@</process>", [[self.process stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.state != nil) [s appendFormat: @"<state>%@</state>", [[self.state stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		[s appendFormat: @"<fin>%@</fin>", (self.fin)?@"true":@"false"];
		if (self.currName != nil) [s appendFormat: @"<currName>%@</currName>", [[self.currName stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.errorMessage != nil) [s appendFormat: @"<errorMessage>%@</errorMessage>", [[self.errorMessage stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		[s appendFormat: @"<inFavorites>%@</inFavorites>", (self.inFavorites)?@"true":@"false"];
		[s appendFormat: @"<check_Id>%@</check_Id>", [NSString stringWithFormat: @"%i", self.check_Id]];
		if (self.check_MerchantName != nil) [s appendFormat: @"<check_MerchantName>%@</check_MerchantName>", [[self.check_MerchantName stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.check_MerchantOrder != nil) [s appendFormat: @"<check_MerchantOrder>%@</check_MerchantOrder>", [[self.check_MerchantOrder stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		[s appendFormat: @"<charity_Id>%@</charity_Id>", [NSString stringWithFormat: @"%i", self.charity_Id]];
		if (self.charity_Name != nil) [s appendFormat: @"<charity_Name>%@</charity_Name>", [[self.charity_Name stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];

		return s;
	}
	
	- (NSMutableString*) serializeAttributes
	{
		NSMutableString* s = [super serializeAttributes];

		return s;
	}
	
	-(BOOL)isEqual:(id)object{
		if(object != nil && [object isKindOfClass:[svcHistoryOperation class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	-(NSUInteger)hash{
		return [Soap generateHash:self];

	}

@end