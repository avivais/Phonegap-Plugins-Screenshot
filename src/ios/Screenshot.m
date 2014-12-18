//
//  Screenshot.h
//
//  Created by Simon Madine on 29/04/2010.
//  Copyright 2010 The Angry Robot Zombie Factory.
//   - Converted to Cordova 1.6.1 by Josemando Sobral.
//  MIT licensed
//
//  Modifications to support orientation change by @ffd8
//

#import <Cordova/CDV.h>
#import "Screenshot.h"
#import "AssetsLibrary/AssetsLibrary.h"

@implementation Screenshot

@synthesize webView;

//- (void)saveScreenshot:(NSArray*)arguments withDict:(NSDictionary*)options
- (void)saveScreenshot:(CDVInvokedUrlCommand*)command
{
	CGRect imageRect;
	CGRect screenRect = [[UIScreen mainScreen] bounds];

	// statusBarOrientation is more reliable than UIDevice.orientation
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

	if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) { 
		// landscape check
		imageRect = CGRectMake(0, 0, CGRectGetHeight(screenRect), CGRectGetWidth(screenRect));
	} else {
		// portrait check
		imageRect = CGRectMake(0, 0, CGRectGetWidth(screenRect), CGRectGetHeight(screenRect));
	}

	// Adds support for Retina Display. Code reverts back to original if iOs 4 not detected.
	if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, 0.0f);
    else
        UIGraphicsBeginImageContext(imageRect.size);


	CGContextRef ctx = UIGraphicsGetCurrentContext();
	[[UIColor blackColor] set];
	CGContextTranslateCTM(ctx, 0, 0);
	CGContextFillRect(ctx, imageRect);

    if ([self.webView respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [self.webView drawViewHierarchyInRect:self.webView.bounds afterScreenUpdates:YES];
    } else {
        //Fail gracefully
        [self.webView.layer renderInContext:ctx];
    }
    
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];

	// Request to save the image to camera roll
	[library writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
		if (error) {
			// The callback should receive the error
            NSString* failureReason = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:failureReason];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		} else {
            NSString* base64encoded;
            
            if ([UIImageJPEGRepresentation(image, 1.0) respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
                base64encoded = [UIImageJPEGRepresentation(image, 1.0) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];   // iOS 7+
            } else {
                base64encoded = [UIImageJPEGRepresentation(image, 1.0) base64Encoding]; // pre iOS7
            }
            
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:base64encoded];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
	UIGraphicsEndImageContext();
}

@end
