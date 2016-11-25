//
//  baseWkWebVC.m
//  TuyouTravel
//
//  Created by 王旭 on 16/9/20.
//  Copyright © 2016年 TuYouTravel. All rights reserved.
//

#import "baseWkWebVC.h"


#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height


@interface baseWkWebVC ()
//几个显示的LB
@property (nonatomic,strong)UILabel *firstNBLB;
@property (nonatomic,strong)UILabel *operationLB;
@property (nonatomic,strong)UILabel *secondNBLB;
@property (nonatomic,strong)UILabel *resultLB;

@end

#define kAlertOnlyRefresh 1990
#define kAlertBackAndRefresh 1991

@implementation baseWkWebVC
- (void)dealloc
{
    self.webView.navigationDelegate = nil;
}
-(id)init
{
    self=[super init];
    if (self) {
        
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        
        // 设置偏好设置
        config.preferences = [[WKPreferences alloc] init];
        // 默认为0
        config.preferences.minimumFontSize = 10;
        // 默认认为YES
        config.preferences.javaScriptEnabled = YES;
        // 在iOS上默认为NO，表示不能自动通过窗口打开
        config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
        
        // web内容处理池
        config.processPool = [[WKProcessPool alloc] init];
        
        // 通过JS与webview内容交互
        config.userContentController = [[WKUserContentController alloc] init];
        // 注入JS对象名称AppModel，当JS通过AppModel来调用时，
        // 我们可以在WKScriptMessageHandler代理中接收到
        [config.userContentController addScriptMessageHandler:self name:@"AppModel"];
        

        self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        self.webView.navigationDelegate = self;
       [self.webView setHackishlyHidesInputAccessoryView:YES];
        self.URL=[[NSURL alloc]init];
        
        self.firstNBLB=[[UILabel alloc]init];
        self.firstNBLB.font=[UIFont systemFontOfSize:15];
        self.firstNBLB.textColor=[UIColor blueColor];
        
        self.operationLB=[[UILabel alloc]init];
        self.operationLB.font=[UIFont systemFontOfSize:15];
        self.operationLB.textColor=[UIColor redColor];
        
        
        self.secondNBLB=[[UILabel alloc]init];
        self.secondNBLB.font=[UIFont systemFontOfSize:15];
        self.secondNBLB.textColor=[UIColor yellowColor];
        
        self.resultLB=[[UILabel alloc]init];
        self.resultLB.font=[UIFont systemFontOfSize:15];
        self.resultLB.textColor=[UIColor greenColor];
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    [self setUI];
    
  //键盘监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
   
}
-(void)setUI
{
    NSArray *titlrArr=[NSArray arrayWithObjects:@"因子",@"运算",@"因子",@"结果", nil];
    NSArray *valueArr=[NSArray arrayWithObjects:self.firstNBLB,self.operationLB,self.secondNBLB,self.resultLB ,nil];
    for (int i=0; i<titlrArr.count; i++) {
        UILabel *lb=[[UILabel alloc]initWithFrame:CGRectMake(20, 20+50*i, 50, 40)];
        lb.font=[UIFont systemFontOfSize:15];
        lb.text=titlrArr[i];
        [self.view addSubview:lb];
        
        UILabel *LB=valueArr[i];
        LB.textAlignment=NSTextAlignmentRight;
        LB.frame=CGRectMake(30,20+50*i , 200, 40);
        [self.view addSubview:LB];
    }
    self.webView.frame = CGRectMake(0, self.resultLB.frame.origin.y+50, ScreenWidth, ScreenHeight-self.resultLB.frame.origin.y-50-50);
    [self.view addSubview:self.webView];
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.opaque = NO;
    [self.view setUserInteractionEnabled:YES];
    [self.webView setUserInteractionEnabled:YES];

    
    UIButton *clearBT=[UIButton buttonWithType:UIButtonTypeCustom];
    [clearBT setTitle:@"清除" forState:UIControlStateNormal];
    clearBT.frame=CGRectMake((ScreenWidth-100)/2, ScreenHeight-40, 100, 40);
    [self.view addSubview:clearBT];
    [clearBT addTarget:self action:@selector(clearJsFunction) forControlEvents:UIControlEventTouchUpInside];
}

-(void)clearJsFunction
{
    //javaScriptString是JS方法名，completionHandler是异步回调block
    [self.webView evaluateJavaScript:@"clearAllData()" completionHandler:^(id  result,NSError *error){
        NSLog(@"%@",error);
        
    }];
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
  
    [self.webView setUserInteractionEnabled:YES];
    
}

-(void)setUrl:(NSString*)urlString
{
    if(![[urlString lowercaseString] hasPrefix:@"http"]){
        urlString=[NSString stringWithFormat:@"http://%@",urlString];
    }
    urlString=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self.URL=[NSURL URLWithString:urlString];
    [self openRequest];
}

//刷新页面
-(void)reloadWebView
{
    if(self.webView.isLoading){
        [self.webView stopLoading];
    }
    [self openRequest];
}

-(void)openRequest{
    
   
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:self.URL];
    request.cachePolicy=NSURLRequestReloadIgnoringLocalCacheData;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     [self.webView loadRequest:request];
    });
    // [self.webView loadRequest:[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
}

#pragma mark - WKNavigationDelegate 页面跳转
#pragma mark 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
   // NSLog(@"%s",__FUNCTION__);
    /**
     *typedef NS_ENUM(NSInteger, WKNavigationActionPolicy) {
     WKNavigationActionPolicyCancel, // 取消
     WKNavigationActionPolicyAllow,  // 继续
     }
     */
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark 身份验证
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler {
   // NSLog(@"%s",__FUNCTION__);
    // 不要证书验证
    completionHandler(NSURLSessionAuthChallengeUseCredential, nil);
}

#pragma mark 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
   // NSLog(@"%s",__FUNCTION__);
    
    
    NSString *paramStr = [webView.URL query];
    NSString *URLAbsoluteString=[webView.URL absoluteString];
    //需要登录的公共热点会弹出一个about:blank空白页 这里屏蔽一下
    if ([URLAbsoluteString isEqualToString:@"about:blank"]) {
        
       decisionHandler(WKNavigationResponsePolicyCancel);
        return;
    }
    if (!paramStr) {
        decisionHandler(WKNavigationResponsePolicyAllow);
        return;
        
    }
    
    
    
   // decisionHandler(WKNavigationResponsePolicyAllow);
}

#pragma mark 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
   // NSLog(@"%s",__FUNCTION__);
}

#pragma mark WKNavigation导航错误
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
  //  NSLog(@"%s",__FUNCTION__);
}

#pragma mark WKWebView终止
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
   // NSLog(@"%s",__FUNCTION__);
}

#pragma mark - WKNavigationDelegate 页面加载
#pragma mark 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
  //  NSLog(@"%s",__FUNCTION__);
}

#pragma mark 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
   // NSLog(@"%s",__FUNCTION__);
}

#pragma mark 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
 //   NSLog(@"%s",__FUNCTION__);
   
    if (webView.title.length > 0) {
        //self.viewNaviBar. = webView.title;
        if (!self.titleStr) {
            //如果没有指定特殊的标题 就抓取页面的标题
        }
    }
}

#pragma mark 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
   // NSLog(@"%s",__FUNCTION__);
   // NSLog(@"%@", error.localizedDescription);
   
    if (error.code==-1009) {
        UIAlertView *alt=[[UIAlertView alloc]initWithTitle:@"提示" message: [NSString stringWithFormat:@"%@稍后回来刷新",@"网络好像有点问题"] delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
       
        alt.tag=kAlertOnlyRefresh;
        [alt show];
    }
   else if (error.code!=102) {
        
        [self.webView stopLoading];
    
        if (self.navigationController.viewControllers.count==1) {
            UIAlertView *alt=[[UIAlertView alloc]initWithTitle:@"提示" message:@"数据加载失败了,刷新试试" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
            
             alt.tag=kAlertOnlyRefresh;
            [alt show];
           
        }
        else
        {
            UIAlertView *alt=[[UIAlertView alloc]initWithTitle:@"提示" message:@"数据加载失败了,刷新试试" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好的",nil];
            alt.tag=kAlertBackAndRefresh;
            [alt show];

        }
    }
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==kAlertOnlyRefresh) {
        [self reloadWebView];
    }
    else
    {
        if (buttonIndex==1) {
            [self reloadWebView];
        }
    }
}

#pragma mark WKScriptMessageHandler

-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    //
    NSLog(@"JS 调用了 %@ 方法，传回参数 %@",message.name,message.body);
    UserElement *Ele=[[SharedUserDefault sharedInstance] getUserInfo];
    NSString *memberId=Ele.memberId;
    memberId= (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)memberId, NULL, NULL,  kCFStringEncodingUTF8 ));
    NSMutableString *str=[NSMutableString stringWithString:memberId];
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"getMemberid(%@)",Ele.memberId ] completionHandler:^(id  result,NSError *error){
        
        NSLog(@"re");
        
    }];

}
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler
{
    NSLog(@"JSmessage--->%@",javaScriptString);
}

#pragma mark WkUIDelegate


/// 确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(YES);
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action){
                                                          completionHandler(NO);
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:^{}];
}
/// 警告框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:^{}];
}
/// 输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler
{
     NSLog(@"%s",__FUNCTION__);
    completionHandler(@"Client Not handler");
}



- (void)keyboardWillShow:(NSNotification*)notification //键盘出现
{
   NSDictionary* info = [notification userInfo];
    NSLog(@"keyboardWillShow%@",info);
    
}

- (void)keyboardWillHide:(NSNotification*)notification //键盘下落
{
   NSDictionary* info = [notification userInfo];
     NSLog(@"keyboardWillHide%@",info);
}

@end
