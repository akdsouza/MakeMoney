//
//  IIController.h
//  MakeMoney
//
#import "IITransender.h"
#import "IINotControls.h"

@class IITransender;
@class IINotControls;

@interface IIController : UIViewController {
	IINotControls* notControls;
	IITransender* transender; //where all the content is transended from
	NSDictionary* options;
	NSDictionary* behavior;
}
@property (readwrite, copy) NSDictionary* behavior;
@property (readwrite, copy) NSDictionary* options;
@property (readwrite, assign) IITransender* transender;
@property (readwrite, assign) IINotControls* notControls;

- (void)startFunctioning;
- (void)stopFunctioning;
@end
