/*
	svcDeviceStatItem.h
	The interface definition of properties and methods for the svcDeviceStatItem object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface svcDeviceStatItem : SoapObject
{
	NSString* _provider;
	int _currentMonthCount;
	NSDecimalNumber* _currentMonthSum;
	int _prevMonthCount;
	NSDecimalNumber* _prevMonthSum;
	int _avgMonthCount;
	NSDecimalNumber* _avgMonthSum;
	
}
		
	@property (retain, nonatomic) NSString* provider;
	@property int currentMonthCount;
	@property (retain, nonatomic) NSDecimalNumber* currentMonthSum;
	@property int prevMonthCount;
	@property (retain, nonatomic) NSDecimalNumber* prevMonthSum;
	@property int avgMonthCount;
	@property (retain, nonatomic) NSDecimalNumber* avgMonthSum;

	+ (svcDeviceStatItem*) createWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end