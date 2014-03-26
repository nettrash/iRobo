/*
	svcSudzc.h
	Creates a list of the services available with the svc prefix.
	Generated by SudzC.com
*/
#import "svcWSMobileBANK.h"

@interface svcSudzC : NSObject {
	BOOL logging;
	NSString* server;
	NSString* defaultServer;
svcWSMobileBANK* wSMobileBANK;

}

-(id)initWithServer:(NSString*)serverName;
-(void)updateService:(SoapService*)service;
-(void)updateServices;
+(svcSudzC*)sudzc;
+(svcSudzC*)sudzcWithServer:(NSString*)serverName;

@property (nonatomic) BOOL logging;
@property (nonatomic, retain) NSString* server;
@property (nonatomic, retain) NSString* defaultServer;

@property (nonatomic, retain, readonly) svcWSMobileBANK* wSMobileBANK;

@end
			