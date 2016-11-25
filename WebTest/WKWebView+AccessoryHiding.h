//
//  WKWebView+AccessoryHiding.h
//  TuyouTravel
//
//  Created by 王旭 on 16/9/30.
//  Copyright © 2016年 TuYouTravel. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WKWebView (AccessoryHiding)

@property (nonatomic, assign) BOOL hackishlyHidesInputAccessoryView;
//- (void) setHackishlyHidesInputAccessoryView:(BOOL)value;
@end
