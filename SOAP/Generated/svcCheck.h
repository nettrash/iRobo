/*
	svcCheck.h
	The interface definition of properties and methods for the svcCheck object.
	Generated by SudzC.com
*/

#import "Soap.h"
	
@class svcCard;
@class svcArrayOfCurrency;

@interface svcCheck : SoapObject
{
	NSString* _UNIQUE;
	int _checkId;
	svcCard* _card;
	NSString* _CVC;
	NSString* _OpKey;
	NSDecimalNumber* _Summa;
	NSString* _MerchantName;
	NSString* _MerchantOrder;
	NSDate* _RegDate;
	NSString* _State;
	int _MerchantID;
	BOOL _IsYandexEnabled;
	NSMutableArray* _AdditionalCurrencies;
	
}
		
	@property (retain, nonatomic) NSString* UNIQUE;
	@property int checkId;
	@property (retain, nonatomic) svcCard* card;
	@property (retain, nonatomic) NSString* CVC;
	@property (retain, nonatomic) NSString* OpKey;
	@property (retain, nonatomic) NSDecimalNumber* Summa;
	@property (retain, nonatomic) NSString* MerchantName;
	@property (retain, nonatomic) NSString* MerchantOrder;
	@property (retain, nonatomic) NSDate* RegDate;
	@property (retain, nonatomic) NSString* State;
	@property int MerchantID;
	@property BOOL IsYandexEnabled;
	@property (retain, nonatomic) NSMutableArray* AdditionalCurrencies;

	+ (svcCheck*) createWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end