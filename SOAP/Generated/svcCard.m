/*
	svcCard.h
	The implementation of properties and methods for the svcCard object.
	Generated by SudzC.com
*/
#import "svcCard.h"

@implementation svcCard
	@synthesize card_Id = _card_Id;
	@synthesize card_RegDate = _card_RegDate;
	@synthesize UNIQUE = _UNIQUE;
	@synthesize card_Name = _card_Name;
	@synthesize card_Holder = _card_Holder;
	@synthesize card_Type = _card_Type;
	@synthesize card_Month = _card_Month;
	@synthesize card_Year = _card_Year;
	@synthesize card_Removed = _card_Removed;
	@synthesize card_Number = _card_Number;
	@synthesize card_Approved = _card_Approved;
	@synthesize card_InAuthorize = _card_InAuthorize;
	@synthesize ErrorText = _ErrorText;
	@synthesize card_Balance = _card_Balance;
	@synthesize card_IsOCEAN = _card_IsOCEAN;
    @synthesize card_NativeNumber = _card_NativeNumber;

	- (id) init
	{
		if(self = [super init])
		{
			self.card_RegDate = nil;
			self.UNIQUE = nil;
			self.card_Name = nil;
			self.card_Holder = nil;
			self.card_Type = nil;
			self.card_Number = nil;
			self.ErrorText = nil;
			self.card_Balance = nil;
            self.card_NativeNumber = nil;
		}
		return self;
	}

	+ (svcCard*) createWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return [[self alloc] initWithNode: node];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.card_Id = [[Soap getNodeValue: node withName: @"card_Id"] intValue];
			self.card_RegDate = [Soap dateFromString: [Soap getNodeValue: node withName: @"card_RegDate"]];
			self.UNIQUE = [Soap getNodeValue: node withName: @"UNIQUE"];
			self.card_Name = [Soap getNodeValue: node withName: @"card_Name"];
			self.card_Holder = [Soap getNodeValue: node withName: @"card_Holder"];
			self.card_Type = [Soap getNodeValue: node withName: @"card_Type"];
			self.card_Month = [[Soap getNodeValue: node withName: @"card_Month"] intValue];
			self.card_Year = [[Soap getNodeValue: node withName: @"card_Year"] intValue];
			self.card_Removed = [[Soap getNodeValue: node withName: @"card_Removed"] boolValue];
			self.card_Number = [Soap getNodeValue: node withName: @"card_Number"];
			self.card_Approved = [[Soap getNodeValue: node withName: @"card_Approved"] boolValue];
			self.card_InAuthorize = [[Soap getNodeValue: node withName: @"card_InAuthorize"] boolValue];
			self.ErrorText = [Soap getNodeValue: node withName: @"ErrorText"];
			self.card_Balance = [NSDecimalNumber decimalNumberWithString: [Soap getNodeValue: node withName: @"card_Balance"]];
			self.card_IsOCEAN = [[Soap getNodeValue: node withName: @"card_IsOCEAN"] boolValue];
            self.card_NativeNumber = [Soap getNodeValue: node withName: @"card_NativeNumber"];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"Card"];
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
		[s appendFormat: @"<card_Id>%@</card_Id>", [NSString stringWithFormat: @"%i", self.card_Id]];
		if (self.card_RegDate != nil) [s appendFormat: @"<card_RegDate>%@</card_RegDate>", [Soap getDateString: self.card_RegDate]];
		if (self.UNIQUE != nil) [s appendFormat: @"<UNIQUE>%@</UNIQUE>", [[self.UNIQUE stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.card_Name != nil) [s appendFormat: @"<card_Name>%@</card_Name>", [[self.card_Name stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.card_Holder != nil) [s appendFormat: @"<card_Holder>%@</card_Holder>", [[self.card_Holder stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.card_Type != nil) [s appendFormat: @"<card_Type>%@</card_Type>", [[self.card_Type stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		[s appendFormat: @"<card_Month>%@</card_Month>", [NSString stringWithFormat: @"%i", self.card_Month]];
		[s appendFormat: @"<card_Year>%@</card_Year>", [NSString stringWithFormat: @"%i", self.card_Year]];
		[s appendFormat: @"<card_Removed>%@</card_Removed>", (self.card_Removed)?@"true":@"false"];
		if (self.card_Number != nil) [s appendFormat: @"<card_Number>%@</card_Number>", [[self.card_Number stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		[s appendFormat: @"<card_Approved>%@</card_Approved>", (self.card_Approved)?@"true":@"false"];
		[s appendFormat: @"<card_InAuthorize>%@</card_InAuthorize>", (self.card_InAuthorize)?@"true":@"false"];
		if (self.ErrorText != nil) [s appendFormat: @"<ErrorText>%@</ErrorText>", [[self.ErrorText stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.card_Balance != nil) [s appendFormat: @"<card_Balance>%@</card_Balance>", [NSString stringWithFormat: @"%@", self.card_Balance]];
		[s appendFormat: @"<card_IsOCEAN>%@</card_IsOCEAN>", (self.card_IsOCEAN)?@"true":@"false"];
        if (self.card_NativeNumber != nil) [s appendFormat: @"<card_NativeNumber>%@</card_NativeNumber>", [[self.card_NativeNumber stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];

		return s;
	}
	
	- (NSMutableString*) serializeAttributes
	{
		NSMutableString* s = [super serializeAttributes];

		return s;
	}
	
	-(BOOL)isEqual:(id)object{
		if(object != nil && [object isKindOfClass:[svcCard class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	-(NSUInteger)hash{
		return [Soap generateHash:self];

	}

@end
