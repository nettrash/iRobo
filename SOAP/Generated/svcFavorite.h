/*
	svcFavorite.h
	The interface definition of properties and methods for the svcFavorite object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface svcFavorite : SoapObject
{
	int _favoriteId;
	NSString* _favoriteName;
	int _cardId;
	NSString* _currency;
	NSString* _currencyName;
	NSString* _parameters;
	NSDecimalNumber* _summa;
	NSString* _UNIQUE;
	int _sortOrder;
    NSString* _OutPossibleValues;
    BOOL _zeroComission;
}
		
	@property int favoriteId;
	@property (retain, nonatomic) NSString* favoriteName;
	@property int cardId;
	@property (retain, nonatomic) NSString* currency;
	@property (retain, nonatomic) NSString* currencyName;
	@property (retain, nonatomic) NSString* parameters;
	@property (retain, nonatomic) NSDecimalNumber* summa;
	@property (retain, nonatomic) NSString* UNIQUE;
	@property int sortOrder;
    @property (retain, nonatomic) NSString* OutPossibleValues;
    @property (nonatomic) BOOL zeroComission;

	+ (svcFavorite*) createWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end
