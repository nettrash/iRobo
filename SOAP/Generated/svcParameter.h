/*
	svcParameter.h
	The interface definition of properties and methods for the svcParameter object.
	Generated by SudzC.com
*/

#import "Soap.h"
	
@class svcArrayOfParameter;

@interface svcParameter : SoapObject
{
	NSString* _Name;
	NSString* _Label;
	NSString* _Type;
	NSMutableArray* _innerParameters;
	NSString* _DefaultValue;
	NSString* _Format;
	
}
		
	@property (retain, nonatomic) NSString* Name;
	@property (retain, nonatomic) NSString* Label;
	@property (retain, nonatomic) NSString* Type;
	@property (retain, nonatomic) NSMutableArray* innerParameters;
	@property (retain, nonatomic) NSString* DefaultValue;
	@property (retain, nonatomic) NSString* Format;

	+ (svcParameter*) createWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end
