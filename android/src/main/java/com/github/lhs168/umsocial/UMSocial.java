package com.github.lhs168.umsocial;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.facebook.react.bridge.*;
import com.umeng.socialize.*;
import com.umeng.socialize.bean.SHARE_MEDIA;
import com.umeng.socialize.media.UMImage;
import com.umeng.socialize.media.UMWeb;
import com.umeng.socialize.shareboard.SnsPlatform;
import com.umeng.socialize.utils.ShareBoardlistener;

import java.util.*;

/**
 * Created by zzy on 2017/3/9.
 * Date : 2017/3/9 17:10
 */
public class UMSocial extends ReactContextBaseJavaModule implements ActivityEventListener {

    private Context mContext;
    private ArrayList<SHARE_MEDIA> mDisplayList;

    public UMSocial(ReactApplicationContext reactContext) {
        super(reactContext);
        mContext = reactContext;
    }

    @Override
    public String getName() {
        return "UMSocial";
    }

    @ReactMethod
    public void share(final String title, final String desc, final String thumb, final String link, final Promise promise) {

        new ShareAction(getCurrentActivity()).setDisplayList(
                (SHARE_MEDIA[]) mDisplayList.toArray(new SHARE_MEDIA[mDisplayList.size()]))
                .setShareboardclickCallback(new ShareBoardlistener() {
                    @Override
                    public void onclick(SnsPlatform snsPlatform, SHARE_MEDIA share_media) {

                        UMImage image = new UMImage(getCurrentActivity(), thumb);
                        UMWeb web = new UMWeb(link);
                        web.setTitle(title);//标题
                        web.setThumb(image);  //缩略图
                        web.setDescription(desc);//描述
                        new ShareAction(getCurrentActivity()).withMedia(web)
                                .setPlatform(share_media)
                                .setCallback(new UMShareListener() {
                                    @Override
                                    public void onStart(SHARE_MEDIA share_media) {

                                    }

                                    @Override
                                    public void onResult(SHARE_MEDIA share_media) {
                                        promise.resolve("分享成功");
                                    }

                                    @Override
                                    public void onError(SHARE_MEDIA share_media, Throwable throwable) {
                                        promise.reject(throwable);
                                    }

                                    @Override
                                    public void onCancel(SHARE_MEDIA share_media) {
                                    }
                                })
                                .share();
                    }
                }).open();
    }

    @ReactMethod
    public void shareWithPlatformType(int platform, String title, String desc, String thumb, String link, final Promise promise) {

        SHARE_MEDIA plat = SHARE_MEDIA.WEIXIN;
        switch (platform) {
            case 1:
                plat = SHARE_MEDIA.WEIXIN;
                break;
            case 2:
                plat = SHARE_MEDIA.WEIXIN_CIRCLE;
                break;
            case 4:
                plat = SHARE_MEDIA.QQ;
                break;
            case 5:
                plat = SHARE_MEDIA.QZONE;
                break;
            case 0:
                plat = SHARE_MEDIA.SINA;
                break;
        }

        if (link != null) {
            this.shareWithLink(plat, title, desc, thumb, link, promise);
        } else if (thumb != null) {
            this.shareWithImage(plat, thumb, promise);
        } else {
            this.shareWithText(plat, desc, promise);
        }
    }

    public void shareWithText(SHARE_MEDIA platform, String desc, final Promise promise) {

        new ShareAction(getCurrentActivity()).setPlatform(platform)
                .withText(desc)
                .setCallback(new UMShareListener() {
                    @Override
                    public void onStart(SHARE_MEDIA share_media) {

                    }

                    @Override
                    public void onResult(SHARE_MEDIA share_media) {
                        promise.resolve("分享成功");
                    }

                    @Override
                    public void onError(SHARE_MEDIA share_media, Throwable throwable) {
                        promise.reject(throwable);
                    }

                    @Override
                    public void onCancel(SHARE_MEDIA share_media) {
                    }
                }).share();
    }

    public void shareWithLink(SHARE_MEDIA platform, String title, String desc, String thumb, String link, final Promise promise) {

        UMImage image = new UMImage(getCurrentActivity(), thumb);
        UMWeb web = new UMWeb(link);
        web.setTitle(title);//标题
        web.setThumb(image);  //缩略图
        web.setDescription(desc);//描述
        new ShareAction(getCurrentActivity()).setPlatform(platform)
                .withMedia(web)
                .setCallback(new UMShareListener() {
                    @Override
                    public void onStart(SHARE_MEDIA share_media) {

                    }

                    @Override
                    public void onResult(SHARE_MEDIA share_media) {
                        promise.resolve("分享成功");
                    }

                    @Override
                    public void onError(SHARE_MEDIA share_media, Throwable throwable) {
                        promise.reject(throwable);
                    }

                    @Override
                    public void onCancel(SHARE_MEDIA share_media) {
                    }
                }).share();
    }

    public void shareWithImage(SHARE_MEDIA platform, String thumb, final Promise promise) {

        UMImage image = new UMImage(getCurrentActivity(), thumb);
        new ShareAction(getCurrentActivity()).setPlatform(platform)
                .withMedia(image)
                .setCallback(new UMShareListener() {
                    @Override
                    public void onStart(SHARE_MEDIA share_media) {

                    }

                    @Override
                    public void onResult(SHARE_MEDIA share_media) {
                        promise.resolve("分享成功");
                    }

                    @Override
                    public void onError(SHARE_MEDIA share_media, Throwable throwable) {
                        promise.reject(throwable);
                    }

                    @Override
                    public void onCancel(SHARE_MEDIA share_media) {
                    }
                }).share();
    }

    @ReactMethod
    public void initShare(String appkey, ReadableMap sharePlatforms, boolean debug) {
        //Log.i("react", "react um initShare");
        UMShareAPI.init(mContext, appkey);

        UMShareConfig config = new UMShareConfig();
        config.isOpenShareEditActivity(true);
        UMShareAPI.get(mContext).setShareConfig(config);

        ReadableMapKeySetIterator readableMapKeySetIterator = sharePlatforms.keySetIterator();
        String[] keys = new String[3];
        int i = 0;
        while (readableMapKeySetIterator.hasNextKey()) {
            String key = readableMapKeySetIterator.nextKey();
            keys[i] = key;
            ReadableMap obj = sharePlatforms.getMap(key);
            if (key.endsWith("weixin")) {
                PlatformConfig.setWeixin(obj.getString("appKey"), obj.getString("appSecret"));
            } else if (key.endsWith("qq")) {
                PlatformConfig.setQQZone(obj.getString("appKey"), obj.getString("appSecret"));
            } else if (key.endsWith("sina") || key.endsWith("weibo")) {
                PlatformConfig.setSinaWeibo(obj.getString("appKey"), obj.getString("appSecret"), obj.getString("redirectURL"));
            }
            i++;
        }

        Arrays.sort(keys);
        mDisplayList = new ArrayList<SHARE_MEDIA>();
        for (i = 0; i < keys.length; i++) {
            if (keys[i].endsWith("weixin")) {
                mDisplayList.add(SHARE_MEDIA.WEIXIN);
                mDisplayList.add(SHARE_MEDIA.WEIXIN_CIRCLE);
            } else if (keys[i].endsWith("qq")) {
                mDisplayList.add(SHARE_MEDIA.QQ);
            } else if (keys[i].endsWith("sina") || keys[i].endsWith("weibo") ) {
                mDisplayList.add(SHARE_MEDIA.SINA);
            }
        }

        Config.DEBUG = debug;
        UMShareAPI.get(mContext);
    }

    @ReactMethod
    public void login(String platform, final Promise promise) {

        SHARE_MEDIA sharePlatform = SHARE_MEDIA.QQ;
        if (platform.equals("weixin")) {
            sharePlatform = SHARE_MEDIA.WEIXIN;
        } else if (platform.equals("weibo")) {
            sharePlatform = SHARE_MEDIA.SINA;
        }
        UMShareAPI.get(getCurrentActivity()).getPlatformInfo(getCurrentActivity(), sharePlatform, new UMAuthListener() {
            @Override
            public void onStart(SHARE_MEDIA share_media) {

            }

            @Override
            public void onComplete(SHARE_MEDIA share_media, int i, Map<String, String> map) {

                WritableMap writableMap = Arguments.createMap();

                Set<String> keySet = map.keySet();
                Iterator<String> iter = keySet.iterator();
                while (iter.hasNext()) {
                    String key = iter.next();
                    writableMap.putString(key, map.get(key));
                }

                promise.resolve(writableMap);

            }

            @Override
            public void onError(SHARE_MEDIA share_media, int i, Throwable throwable) {
                promise.reject(throwable);

            }

            @Override
            public void onCancel(SHARE_MEDIA share_media, int i) {
                promise.reject("-1", "user cancel");
            }
        });
    }

    @ReactMethod
    public void auth(String platform, final Promise promise) {

        SHARE_MEDIA sharePlatform = SHARE_MEDIA.QQ;
        if (platform.equals("weixin")) {
            sharePlatform = SHARE_MEDIA.WEIXIN;
        } else if (platform.equals("weibo")) {
            sharePlatform = SHARE_MEDIA.SINA;
        }
        UMShareAPI.get(getCurrentActivity()).doOauthVerify(getCurrentActivity(), sharePlatform, new UMAuthListener() {
            @Override
            public void onStart(SHARE_MEDIA share_media) {

            }

            @Override
            public void onComplete(SHARE_MEDIA share_media, int i, Map<String, String> map) {
                Log.v("react", "react um auth complete:" + map.toString());
                WritableMap writableMap = Arguments.createMap();
                String openId = map.get("openid");
                if (openId == null || openId.equals("")) {
                    openId = map.get("uid");
                }
                String token = map.get("accessToken") != null ? map.get("accessToken") : map.get("access_token");
                String expiration = map.get("expiration") != null ? map.get("expiration") : map.get("expires_in");
                writableMap.putString("openid", openId);
                writableMap.putString("token", token);
                writableMap.putString("expiration", expiration);
                //writableMap.putString("originalResponse", map.get("originalResponse"));
                promise.resolve(writableMap);
            }

            @Override
            public void onError(SHARE_MEDIA share_media, int i, Throwable throwable) {
                promise.reject(throwable);

            }

            @Override
            public void onCancel(SHARE_MEDIA share_media, int i) {
                promise.reject("-1", "user cancel");
            }
        });
    }

    @ReactMethod
    public void checkInstall(String platform, final Promise promise) {
        SHARE_MEDIA sharePlatform = SHARE_MEDIA.QQ;
        if (platform.equals("weixin")) {
            sharePlatform = SHARE_MEDIA.WEIXIN;
        } else if (platform.equals("weibo")) {
            sharePlatform = SHARE_MEDIA.SINA;
        }
        Boolean isInstall = UMShareAPI.get(getCurrentActivity()).isInstall(getCurrentActivity(), sharePlatform);
        //Log.i("react", "react um isInstall > "+platform+":"+isInstall);
        promise.resolve(isInstall);
    }

    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        UMShareAPI.get(getCurrentActivity()).onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onNewIntent(Intent intent) {

    }
}
