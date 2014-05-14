/*
	svcMessage.h
	The interface definition of properties and methods for the svcMessage object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface svcMessage : SoapObject
{
	int _Id;
	NSDate* _RegDate;
	NSString* _Title;
	NSString* _Body;
	NSString* _URL;
	NSString* _Mood;
	
}
		
	@property int Id;
	@property (retain, nonatomic) NSDate* RegDate;
	@property (retain, nonatomic) NSString* Title;
	@property (retain, nonatomic) NSString* Body;
	@property (retain, nonatomic) NSString* URL;
	@property (retain, nonatomic) NSString* Mood;

	+ (svcMessage*) createWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end