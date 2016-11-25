//
//  baseWkWebVC.h
//  TuyouTravel
//
//  Created by 王旭 on 16/9/20.
//  Copyright © 2016年 TuYouTravel. All rights reserved.
//


#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "WKWebView+AccessoryHiding.h"



@interface baseWkWebVC : UIViewController<UIGestureRecognizerDelegate,UIAlertViewDelegate,WKNavigationDelegate,WKScriptMessageHandler,WKUIDelegate>


@property (nonatomic, strong) WKWebView* webView;

@property (nonatomic,strong)NSString *titleStr;
@property(nonatomic,strong)NSURL *URL;

@property (nonatomic,strong)JSContext *contex;


-(void)setUrl:(NSString*)urlString;
-(void)openRequest;
@end
