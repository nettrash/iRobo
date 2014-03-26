/*
	svcCharity.h
	The implementation of properties and methods for the svcCharity object.
	Generated by SudzC.com
*/
#import "svcCharity.h"

#import "svcArrayOfCurrency.h"
@implementation svcCharity
	@synthesize charity_Id = _charity_Id;
	@synthesize charity_RegDate = _charity_RegDate;
	@synthesize charity_Name = _charity_Name;
	@synthesize charity_StartDate = _charity_StartDate;
	@synthesize charity_EndDate = _charity_EndDate;
	@synthesize charity_Description = _charity_Description;
	@synthesize charity_URL = _charity_URL;
	@synthesize charity_DefaultSum = _charity_DefaultSum;
	@synthesize charity_StaticSum = _charity_StaticSum;
	@synthesize charity_Active = _charity_Active;
	@synthesize charity_UseRequisites = _charity_UseRequisites;
	@synthesize charity_Person = _charity_Person;
	@synthesize charity_INN = _charity_INN;
	@synthesize charity_KPP = _charity_KPP;
	@synthesize charity_RS = _charity_RS;
	@synthesize charity_BANK = _charity_BANK;
	@synthesize charity_KS = _charity_KS;
	@synthesize charity_BIK = _charity_BIK;
	@synthesize charity_Designation = _charity_Designation;
	@synthesize charity_NDS = _charity_NDS;
	@synthesize AdditionalCurrencies = _AdditionalCurrencies;

	- (id) init
	{
		if(self = [super init])
		{
			self.charity_RegDate = nil;
			self.charity_Name = nil;
			self.charity_StartDate = nil;
			self.charity_EndDate = nil;
			self.charity_Description = nil;
			self.charity_URL = nil;
			self.charity_DefaultSum = nil;
			self.charity_Person = nil;
			self.charity_INN = nil;
			self.charity_KPP = nil;
			self.charity_RS = nil;
			self.charity_BANK = nil;
			self.charity_KS = nil;
			self.charity_BIK = nil;
			self.charity_Designation = nil;
			self.AdditionalCurrencies = [[NSMutableArray alloc] init];

		}
		return self;
	}

	+ (svcCharity*) createWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return [[self alloc] initWithNode: node];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.charity_Id = [[Soap getNodeValue: node withName: @"charity_Id"] intValue];
			self.charity_RegDate = [Soap dateFromString: [Soap getNodeValue: node withName: @"charity_RegDate"]];
			self.charity_Name = [Soap getNodeValue: node withName: @"charity_Name"];
			self.charity_StartDate = [Soap dateFromString: [Soap getNodeValue: node withName: @"charity_StartDate"]];
			self.charity_EndDate = [Soap dateFromString: [Soap getNodeValue: node withName: @"charity_EndDate"]];
			self.charity_Description = [Soap getNodeValue: node withName: @"charity_Description"];
			self.charity_URL = [Soap getNodeValue: node withName: @"charity_URL"];
			self.charity_DefaultSum = [NSDecimalNumber decimalNumberWithString: [Soap getNodeValue: node withName: @"charity_DefaultSum"]];
			self.charity_StaticSum = [[Soap getNodeValue: node withName: @"charity_StaticSum"] boolValue];
			self.charity_Active = [[Soap getNodeValue: node withName: @"charity_Active"] boolValue];
			self.charity_UseRequisites = [[Soap getNodeValue: node withName: @"charity_UseRequisites"] boolValue];
			self.charity_Person = [Soap getNodeValue: node withName: @"charity_Person"];
			self.charity_INN = [Soap getNodeValue: node withName: @"charity_INN"];
			self.charity_KPP = [Soap getNodeValue: node withName: @"charity_KPP"];
			self.charity_RS = [Soap getNodeValue: node withName: @"charity_RS"];
			self.charity_BANK = [Soap getNodeValue: node withName: @"charity_BANK"];
			self.charity_KS = [Soap getNodeValue: node withName: @"charity_KS"];
			self.charity_BIK = [Soap getNodeValue: node withName: @"charity_BIK"];
			self.charity_Designation = [Soap getNodeValue: node withName: @"charity_Designation"];
			self.charity_NDS = [[Soap getNodeValue: node withName: @"charity_NDS"] boolValue];
			self.AdditionalCurrencies = [[svcArrayOfCurrency createWithNode: [Soap getNode: node withName: @"AdditionalCurrencies"]] object];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"Charity"];
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
		[s appendFormat: @"<charity_Id>%@</charity_Id>", [NSString stringWithFormat: @"%i", self.charity_Id]];
		if (self.charity_RegDate != nil) [s appendFormat: @"<charity_RegDate>%@</charity_RegDate>", [Soap getDateString: self.charity_RegDate]];
		if (self.charity_Name != nil) [s appendFormat: @"<charity_Name>%@</charity_Name>", [[self.charity_Name stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.charity_StartDate != nil) [s appendFormat: @"<charity_StartDate>%@</charity_StartDate>", [Soap getDateString: self.charity_StartDate]];
		if (self.charity_EndDate != nil) [s appendFormat: @"<charity_EndDate>%@</charity_EndDate>", [Soap getDateString: self.charity_EndDate]];
		if (self.charity_Description != nil) [s appendFormat: @"<charity_Description>%@</charity_Description>", [[self.charity_Description stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.charity_URL != nil) [s appendFormat: @"<charity_URL>%@</charity_URL>", [[self.charity_URL stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.charity_DefaultSum != nil) [s appendFormat: @"<charity_DefaultSum>%@</charity_DefaultSum>", [NSString stringWithFormat: @"%@", self.charity_DefaultSum]];
		[s appendFormat: @"<charity_StaticSum>%@</charity_StaticSum>", (self.charity_StaticSum)?@"true":@"false"];
		[s appendFormat: @"<charity_Active>%@</charity_Active>", (self.charity_Active)?@"true":@"false"];
		[s appendFormat: @"<charity_UseRequisites>%@</charity_UseRequisites>", (self.charity_UseRequisites)?@"true":@"false"];
		if (self.charity_Person != nil) [s appendFormat: @"<charity_Person>%@</charity_Person>", [[self.charity_Person stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.charity_INN != nil) [s appendFormat: @"<charity_INN>%@</charity_INN>", [[self.charity_INN stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.charity_KPP != nil) [s appendFormat: @"<charity_KPP>%@</charity_KPP>", [[self.charity_KPP stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.charity_RS != nil) [s appendFormat: @"<charity_RS>%@</charity_RS>", [[self.charity_RS stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.charity_BANK != nil) [s appendFormat: @"<charity_BANK>%@</charity_BANK>", [[self.charity_BANK stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.charity_KS != nil) [s appendFormat: @"<charity_KS>%@</charity_KS>", [[self.charity_KS stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.charity_BIK != nil) [s appendFormat: @"<charity_BIK>%@</charity_BIK>", [[self.charity_BIK stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		if (self.charity_Designation != nil) [s appendFormat: @"<charity_Designation>%@</charity_Designation>", [[self.charity_Designation stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		[s appendFormat: @"<charity_NDS>%@</charity_NDS>", (self.charity_NDS)?@"true":@"false"];
		if (self.AdditionalCurrencies != nil && self.AdditionalCurrencies.count > 0) {
			[s appendFormat: @"<AdditionalCurrencies>%@</AdditionalCurrencies>", [svcArrayOfCurrency serialize: self.AdditionalCurrencies]];
		} else {
			[s appendString: @"<AdditionalCurrencies/>"];
		}

		return s;
	}
	
	- (NSMutableString*) serializeAttributes
	{
		NSMutableString* s = [super serializeAttributes];

		return s;
	}
	
	-(BOOL)isEqual:(id)object{
		if(object != nil && [object isKindOfClass:[svcCharity class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	-(NSUInteger)hash{
		return [Soap generateHash:self];

	}

@end
