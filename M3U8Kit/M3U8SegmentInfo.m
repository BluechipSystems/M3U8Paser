//
//  M3U8SegmentInfo.m
//  M3U8Kit
//
//  Created by Oneday on 13-1-11.
//  Copyright (c) 2013年 0day. All rights reserved.
//

#import "M3U8SegmentInfo.h"

@interface M3U8SegmentInfo()
@property (nonatomic, strong) NSDictionary *dictionary;
@end

@implementation M3U8SegmentInfo

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.dictionary = dictionary;
        
        //parse length and offset
        NSString * range = self.dictionary[M3U8_EXT_X_BYTERANGE];
        if(range) {
            range = [range stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSArray * components = [range componentsSeparatedByString:@"@"];
            if(components.count > 0) {
                _byteRangeLength = [components[0] longLongValue];
            }
            if(components.count > 1) {
                _byteRangeOffset = [components[1] longLongValue];
            }
                     
        }

        
    }
    return self;
}

- (NSString *)baseURL {
    return self.dictionary[M3U8_BASE_URL];
}

- (NSString *)mediaURL {
    NSURL *baseURL = [NSURL URLWithString:self.baseURL];
    return [[NSURL URLWithString:self.URI relativeToURL:baseURL] absoluteString];
}

- (NSString *)title {
    return self.dictionary[M3U8_EXTINF_TITLE];
}

- (NSString *)tvgLogo {
    return self.dictionary[M3U8_EXTINF_TITLE];
}

- (NSString *)groupTitle {
    return self.dictionary[M3U8_EXTINF_TITLE];
}


- (NSTimeInterval)duration {
    return [self.dictionary[M3U8_EXTINF_DURATION] doubleValue];
}

- (NSString *)URI {
    return self.dictionary[M3U8_EXTINF_URI];
}

-(BOOL)hasByteRange
{
    return self.dictionary[M3U8_EXT_X_BYTERANGE] != nil;
}


- (NSString *)description {
    return [NSString stringWithString:self.dictionary.description];
}

@end
