//
//  RCTUMShareModule.m
//  RCTUMShareModule
//
//  Created by zhangzy on 2017/3/12.
//  Copyright © 2017年 zzy. All rights reserved.
//

#import "RCTUMSocial.h"
#import <UShareUI/UShareUI.h>

@implementation RCTUMSocial {
    NSDictionary *_sharePlatforms;
}

RCT_EXPORT_MODULE();


RCT_REMAP_METHOD(share,
                 Title: (NSString *) title
                 Desc:(NSString *) desc
                 Thumb:(NSString *) thumb
                 Link:(NSString *) link
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        if(_sharePlatforms == nil) {
            
            reject(@"-1", @"请先在AppDelegate.m中初始化分享设置", nil);
            return;
        }
        // 设置顺序
        NSMutableArray *sort = [[NSMutableArray alloc] init];
    
        [_sharePlatforms enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if([key rangeOfString:@"weixin"].location != NSNotFound) {
                [sort addObject:@(UMSocialPlatformType_WechatSession)];
                [sort addObject:@(UMSocialPlatformType_WechatTimeLine)];
            } else if([key rangeOfString:@"qq"].location != NSNotFound) {
                [sort addObject:@(UMSocialPlatformType_QQ)];
                [sort addObject:@(UMSocialPlatformType_Qzone)];
            } else if([key rangeOfString:@"sina"].location != NSNotFound) {
                [sort addObject:@(UMSocialPlatformType_Sina)];
            }
        }];
        
        [UMSocialUIManager setPreDefinePlatforms:sort];
        
        
        [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
            
            //创建分享消息对象
            UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
            
            //创建网页内容对象
            NSString* thumbURL = thumb;
            UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:desc thumImage:thumbURL];
            
            //设置网页地址
            shareObject.webpageUrl = link;
            //分享消息对象设置分享内容对象
            messageObject.shareObject = shareObject;
            
            
            //调用分享接口
            [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:nil completion:^(id data, NSError *error) {
                if (error) {
                    reject(@"-1", @"分享失败", error);
                    UMSocialLogInfo(@"************Share fail with error %@*********",error);
                } else {
                    
                    resolve(@"分享成功");
                }
            }];
            
        }];
        
    });
    
}

RCT_REMAP_METHOD(shareWithPlatformType,
                 PlatformType: (int) platformType
                 Title: (NSString *) title
                 Desc:(NSString *) desc
                 Thumb:(NSString *) thumb
                 Link:(NSString *) link
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    
    if(link != nil) {
        
        [self shareWithLink:platformType Title:title Desc:desc Thumb:thumb Link:link resolver:resolve rejecter:reject];
    } else if(thumb != nil) {
        [self shareWithImage:platformType Thumb:thumb resolver:resolve rejecter:reject];
    } else {
        [self shareWithText:platformType Desc:desc resolver:resolve rejecter:reject];
    }
    
}

- (void) shareWithLink: (int) platformType
                 Title: (NSString *) title
                 Desc:(NSString *) desc
                 Thumb:(NSString *) thumb
                 Link:(NSString *) link
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(_sharePlatforms == nil) {
            
            reject(@"-1", @"请先在AppDelegate.m中初始化分享设置", nil);
            return;
        }
        
        UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
        
        NSString* thumbURL = thumb;
        UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:desc thumImage:thumbURL];
        shareObject.webpageUrl = link;
        
        messageObject.shareObject = shareObject;
        
        [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:nil completion:^(id data, NSError *error) {
            if (error) {
                reject(@"-1", @"分享失败", error);
                UMSocialLogInfo(@"************Share fail with error %@*********",error);
            } else {
                
                resolve(@"分享成功");
            }
        }];
        
    });
    
}

- (void) shareWithText: (int) platformType
                 Desc:(NSString *) desc
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(_sharePlatforms == nil) {
            
            reject(@"-1", @"请先在AppDelegate.m中初始化分享设置", nil);
            return;
        }
        
        UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
        //设置文本
        messageObject.text = desc;
        
        [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:nil completion:^(id data, NSError *error) {
            if (error) {
                reject(@"-1", @"分享失败", error);
                UMSocialLogInfo(@"************Share fail with error %@*********",error);
            } else {
                
                resolve(@"分享成功");
            }
        }];
        
    });
    
}

- (void) shareWithImage: (int) platformType
                 Thumb:(NSString *) thumb
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(_sharePlatforms == nil) {
            
            reject(@"-1", @"请先在AppDelegate.m中初始化分享设置", nil);
            return;
        }
        
        //创建分享消息对象
        UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
        //创建图片内容对象
        UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
        [shareObject setShareImage:thumb];
        
        //分享消息对象设置分享内容对象
        messageObject.shareObject = shareObject;
        
        [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:nil completion:^(id data, NSError *error) {
            if (error) {
                reject(@"-1", @"分享失败", error);
                UMSocialLogInfo(@"************Share fail with error %@*********",error);
            } else {
                
                resolve(@"分享成功");
            }
        }];
        
    });
    
}


RCT_EXPORT_METHOD(initShare:(NSString *)umAppKey SharePlatforms:(NSDictionary *) sharePlatforms OpenLog:(BOOL)openLog)
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[UMSocialManager defaultManager] openLog:openLog];
        
        /* 设置友盟appkey */
        [[UMSocialManager defaultManager] setUmSocialAppkey:umAppKey];
        
        [sharePlatforms enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

            if([key rangeOfString:@"weixin"].location != NSNotFound) {
                
                [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:[obj objectForKey:@"appKey"] appSecret:[obj objectForKey:@"appSecret"] redirectURL:[obj objectForKey:@"redirectURL"]];
            } else if([key rangeOfString:@"qq"].location != NSNotFound) {
                [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:[obj objectForKey:@"appKey"] appSecret:[obj objectForKey:@"appSecret"] redirectURL:[obj objectForKey:@"redirectURL"]];
            } else if([key rangeOfString:@"sina"].location != NSNotFound) {
                [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:[obj objectForKey:@"appKey"] appSecret:[obj objectForKey:@"appSecret"] redirectURL:[obj objectForKey:@"redirectURL"]];
            }
        }];
        _sharePlatforms = sharePlatforms;
    });
    
}


RCT_REMAP_METHOD(login,
                 Platform:(NSString *)platform
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UMSocialPlatformType socialPlatformType = UMSocialPlatformType_QQ;
        if ([platform isEqualToString:@"weixin"]) {
            socialPlatformType = UMSocialPlatformType_WechatSession;
        } else if ([platform isEqualToString:@"weibo"]) {
            socialPlatformType = UMSocialPlatformType_Sina;
        }
        
        [[UMSocialManager defaultManager] getUserInfoWithPlatform:socialPlatformType currentViewController:nil completion:^(id result, NSError *error) {
            if (error) {
                reject(@"-1", @"登录失败", error);
            } else {
                UMSocialUserInfoResponse *resp = result;
                
                NSDictionary *data = @{@"uid": resp.uid, @"openid": resp.openid, @"accessToken": resp.accessToken, @"expiration": resp.expiration, @"name": resp.name, @"iconurl": resp.iconurl, @"gender": resp.gender, @"originalResponse": resp.originalResponse};
                
                resolve(data);
            }
        }];
    });
}

RCT_REMAP_METHOD(auth,
                 authPlatform:(NSString *)platform
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UMSocialPlatformType socialPlatformType = UMSocialPlatformType_QQ;
        if ([platform isEqualToString:@"weixin"]) {
            socialPlatformType = UMSocialPlatformType_WechatSession;
        } else if ([platform isEqualToString:@"weibo"]) {
            socialPlatformType = UMSocialPlatformType_Sina;
        }
        
        [[UMSocialManager defaultManager] authWithPlatform:socialPlatformType currentViewController:nil completion:^(id result, NSError *error) {
            if (error) {
                reject(@"-1", @"登录失败", error);
            } else {
                UMSocialAuthResponse *resp = result;
                if (!resp.openid) {
                    resp.openid = resp.uid ? resp.uid : @"";
                }
                NSDictionary *data = @{@"openid": resp.openid, @"token": resp.accessToken,  @"expiration": resp.expiration, @"originalResponse": resp.originalResponse};
                resolve(data);
            }
            
        }];
    });
}

RCT_REMAP_METHOD(checkInstall,
                 checkPlatform:(NSString *)platform
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UMSocialPlatformType socialPlatformType = UMSocialPlatformType_QQ;
        if ([platform isEqualToString:@"weixin"]) {
            socialPlatformType = UMSocialPlatformType_WechatSession;
        } else if ([platform isEqualToString:@"weibo"]) {
            socialPlatformType = UMSocialPlatformType_Sina;
        }
        BOOL isInstall = [[UMSocialManager defaultManager] isInstall:socialPlatformType];
        resolve(isInstall ? @YES : @NO);
    });
    
}

@end
