/*
	svcTerminal.h
	The interface definition of properties and methods for the svcTerminal object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface svcTerminal : SoapObject
{
	int _terminal_Id;
	BOOL _terminal_Active;
	NSDecimalNumber* _terminal_Latitude;
	NSDecimalNumber* _terminal_Longtitude;
	NSString* _terminal_Address;
	NSString* _terminal_City;
	NSString* _terminal_Type;
	
}
		
	@property int terminal_Id;
	@property BOOL terminal_Active;
	@property (retain, nonatomic) NSDecimalNumber* terminal_Latitude;
	@property (retain, nonatomic) NSDecimalNumber* terminal_Longtitude;
	@property (retain, nonatomic) NSString* terminal_Address;
	@property (retain, nonatomic) NSString* terminal_City;
	@property (retain, nonatomic) NSString* terminal_Type;

	+ (svcTerminal*) createWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end
