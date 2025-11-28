#import "FastOrientationLocker.h"
@implementation FastOrientationLocker {
    UIInterfaceOrientationMask currentOrientationMask;
}
-(instancetype) init {
  self = [super init];
  return self;
}
RCT_EXPORT_MODULE()

- (void) forceRotation:(UIInterfaceOrientation)orientation {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIInterfaceOrientationMask lockMask;
        switch(orientation) {
            case UIInterfaceOrientationPortrait:
                lockMask = UIInterfaceOrientationMaskPortrait;
                break;
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
                lockMask = UIInterfaceOrientationMaskLandscape;
                break;
            default:
                lockMask = UIInterfaceOrientationMaskAll;

        }
        self->currentOrientationMask = lockMask;
        
        if (@available(iOS 16.0, *)) {
            UIWindowScene *windowScene = nil;
            for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    if ([scene isKindOfClass:[UIWindowScene class]]) {
                        windowScene = (UIWindowScene *)scene;
                        break; // Found the active foreground scene, no need to continue
                    }
                }
            }
            if (windowScene != nil){
                UIWindowSceneGeometryPreferencesIOS *preferences = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:lockMask];
                [windowScene requestGeometryUpdateWithPreferences:preferences errorHandler:^(NSError * _Nonnull error) {
                    NSLog(@"❌ Orientation update failed: %@", error.localizedDescription);
                }];
            }

        } else {
            [UIDevice.currentDevice setValue:[NSNumber numberWithInteger: orientation] forKey:@"orientation"];
            [UIViewController attemptRotationToDeviceOrientation];

        }

    });
}

- (void)lockToLandscape {
    [self forceRotation:UIInterfaceOrientationLandscapeLeft];
}

- (void)lockToPortrait {
    [self forceRotation:UIInterfaceOrientationPortrait];
}

- (void)unlockAllOrientations {
    dispatch_async(dispatch_get_main_queue(), ^{
        self->currentOrientationMask = UIInterfaceOrientationMaskAll;
        [UIDevice.currentDevice setValue:[NSNumber numberWithInteger: UIInterfaceOrientationUnknown] forKey:@"orientation"];
        [UIViewController attemptRotationToDeviceOrientation];
    });
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeFastOrientationLockerSpecJSI>(params);
}

@end
