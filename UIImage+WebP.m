//
//  UIImage+WebP.m
//  TestWebP
//
//  Created by ziggear on 14-6-27.
//  Copyright (c) 2014年 Carson McDonald. All rights reserved.
//

#import "UIImage+WebP.h"
#import <WebP/decode.h>

@implementation UIImage (WebP)

static void free_image_data(void *info, const void *data, size_t size) {
    if(info != NULL) {
        WebPFreeDecBuffer(&(((WebPDecoderConfig *)info)->output));
    } else {
        free((void *)data);
    }
}

+ (instancetype)imageWithWebPPath:(NSString *)pathOfWebPImage {
    WebPDecoderConfig config;

    // Find the path of the selected WebP image in the bundle and read it into memory
    NSData *myData = [NSData dataWithContentsOfFile:pathOfWebPImage];

    // Get the current version of the WebP decoder
    // int rc = WebPGetDecoderVersion();

    // Get the width and height of the selected WebP image
    int width = 0;
    int height = 0;
    WebPGetInfo([myData bytes], [myData length], &width, &height);

    CGDataProviderRef provider;

    WebPInitDecoderConfig(&config);

    config.options.no_fancy_upsampling = 1;
    config.options.bypass_filtering = 1;
    config.options.use_threads = 0;
    config.output.colorspace = MODE_RGBA;

    // Decode the WebP image data into a RGBA value array
    WebPDecode([myData bytes], [myData length], &config);
    
    // Construct a UIImage from the decoded RGBA value array
    provider = CGDataProviderCreateWithData(&config, config.output.u.RGBA.rgba, width*height*4, free_image_data);
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(width, height, 8, 32, 4*width, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    return [[[UIImage class] alloc] initWithCGImage:imageRef];
}

@end
