//
//  M3U8MediaPlaylist.m
//  M3U8Kit
//
//  Created by Sun Jin on 3/26/14.
//  Copyright (c) 2014 Jin Sun. All rights reserved.
//

#import "M3U8MediaPlaylist.h"

@interface M3U8MediaPlaylist()

@property (nonatomic, copy) NSString *originalText;
@property (nonatomic, strong) NSString *baseURL;

@property (nonatomic, strong) NSString *version;

@property (nonatomic, strong) M3U8SegmentInfoList *segmentList;

@end

@implementation M3U8MediaPlaylist

- (instancetype)initWithContent:(NSString *)string type:(M3U8MediaPlaylistType)type baseURL:(NSString *)baseURL {
    if (NO == [string isMediaPlaylist]) {
        return nil;
    }
    if (self = [super init]) {
        self.originalText = string;
        self.baseURL = baseURL;
        self.type = type;
        [self parseMediaPlaylist];
    }
    return self;
}

- (instancetype)initWithContentOfURL:(NSURL *)URL type:(M3U8MediaPlaylistType)type error:(NSError **)error {
    if (nil == URL) {
        return nil;
    }
    NSString *string = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:error];
    return [self initWithContent:string type:type baseURL:URL.absoluteString];
}

- (NSArray *)allSegmentURLs {
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < self.segmentList.count; i ++) {
        M3U8SegmentInfo *info = [self.segmentList segmentInfoAtIndex:i];
        if (info.mediaURL.length > 0) {
            if (NO == [array containsObject:info.mediaURL]) {
                [array addObject:info.mediaURL];
            }
        }
    }
    return [array copy];
}

- (void)parseMediaPlaylist {
    
    self.segmentList = [[M3U8SegmentInfoList alloc] init];
    
    NSRange segmentRange = [self.originalText rangeOfString:M3U8_EXTINF];
    NSString *remainingSegments = self.originalText;
    
    
    while (NSNotFound != segmentRange.location) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        if (self.baseURL) {
            [params setObject:self.baseURL forKey:M3U8_BASE_URL];
        }
        
        NSRange nextSegmentRange = NSMakeRange(segmentRange.location +1, remainingSegments.length - segmentRange.location -1);
        nextSegmentRange = [remainingSegments rangeOfString:M3U8_EXTINF options:0 range:nextSegmentRange];
        if(nextSegmentRange.location != NSNotFound) {
            segmentRange.length = nextSegmentRange.location - segmentRange.location;
        }
        else {
            segmentRange.length = remainingSegments.length - segmentRange.location;
        }
        
        NSString *segmentString = [remainingSegments substringWithRange:segmentRange];
        NSArray * lines = [[segmentString stringByReplacingOccurrencesOfString:@"\r" withString:@""] componentsSeparatedByString:@"\n"];
        
        //parse segment parts
        for (NSString * line in lines) {
            
            NSString * trimmedLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            //tag
            if([trimmedLine hasPrefix:@"#"]) {
                //#EXTINF:<duration>,[<title>]
                if([line hasPrefix:M3U8_EXTINF]) {
                    NSArray * parts = [trimmedLine componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":,"]];
                    if(parts.count<2) {
                        continue;
                    }
                    [params setValue:parts[1] forKey:M3U8_EXTINF_DURATION];
                    
                    if(params.count>2) {
                        [params setValue:parts[2] forKey:M3U8_EXTINF_URI];
                    }
                }
                //#EXT-X-BYTERANGE: length[@offset]
                else if([line hasPrefix:M3U8_EXT_X_BYTERANGE]) {
                    NSString * dataLine = [line substringFromIndex:M3U8_EXT_X_BYTERANGE.length];
                    [params setValue:dataLine forKey:M3U8_EXT_X_BYTERANGE];
                }
            }
            //URI
            else if(trimmedLine.length > 0) {
                [params setValue:trimmedLine forKey:M3U8_EXTINF_URI];
            }
        }
        
        M3U8SegmentInfo *segment = [[M3U8SegmentInfo alloc] initWithDictionary:params];
        if (segment) {
            [self.segmentList addSegementInfo:segment];
        }
        
        segmentRange = nextSegmentRange;
    }
    
    //fix byteranges, if we have them
    if(self.segmentList.count) {
        M3U8SegmentInfo * seg = [self.segmentList segmentInfoAtIndex:0];
        unsigned long long lastPosition = seg.byteRangeLength;
        if(lastPosition>0) {
            for (NSUInteger idx = 1; idx < self.segmentList.count; idx++) {
                seg = [self.segmentList segmentInfoAtIndex:idx];
                if(seg.byteRangeLength>0 && seg.byteRangeOffset == 0) {
                    seg.byteRangeOffset = lastPosition;
                    lastPosition += seg.byteRangeLength;
                }
            }
        }
    }
    
//    while (NSNotFound != segmentRange.location) {
//        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//        if (self.baseURL) {
//            [params setObject:self.baseURL forKey:M3U8_BASE_URL];
//        }
//
//		// Read the EXTINF number between #EXTINF: and the comma
//		NSRange commaRange = [remainingSegments rangeOfString:@","];
//        NSRange valueRange = NSMakeRange(segmentRange.location + segmentRange.length, commaRange.location - (segmentRange.location + segmentRange.length));
//        if (commaRange.location == NSNotFound || valueRange.location > remainingSegments.length -1)
//            break;
//		NSString *value = [remainingSegments substringWithRange:valueRange];
//        NSRange spaceRange = [value rangeOfString:@" "];
//		[params setValue:[value substringToIndex:spaceRange.location] forKey:M3U8_EXTINF_DURATION];
//        
//        NSRange tvgLogoRange = [value rangeOfString:M3U8_EXTINF_TVG_LOGO];
//        NSRange groupTitleRange = [value rangeOfString:M3U8_EXTINF_GROUP_TITLE];
//        [params setValue:[value substringWithRange:NSMakeRange(tvgLogoRange.location+tvgLogoRange.length + 2,groupTitleRange.location - (tvgLogoRange.location+tvgLogoRange.length+4))] forKey:M3U8_EXTINF_TVG_LOGO];
//        [params setValue:[value substringWithRange:NSMakeRange(groupTitleRange.location+groupTitleRange.length+2,value.length-(groupTitleRange.location+groupTitleRange.length+3))] forKey:M3U8_EXTINF_GROUP_TITLE];
//        
//        remainingSegments = [remainingSegments substringFromIndex:commaRange.location + commaRange.length + 1];
//        
//        // read to LF #EXTINF line
//        NSRange extinfoLFRange = [remainingSegments rangeOfString:@"\n"];
//        valueRange = NSMakeRange(0, extinfoLFRange.location);
//        value = [remainingSegments substringWithRange:valueRange];
//        [params setValue:value forKey:M3U8_EXTINF_TITLE];
//        
//        remainingSegments = [remainingSegments substringFromIndex:extinfoLFRange.location + 1];
//        
//        // Read the segment link, and ignore line start with # && blank line
//        while (1) {
//            NSRange lfRange = [remainingSegments rangeOfString:@"\n"];
//            NSString *line = [remainingSegments substringWithRange:NSMakeRange(0, lfRange.location)];
//            line = [line stringByReplacingOccurrencesOfString:@" " withString:@""];
//            
//            remainingSegments = [remainingSegments substringFromIndex:lfRange.location + 1];
//            
//            if ([line characterAtIndex:0] != '#' && 0 != line.length) {
//                // remove the CR character '\r'
//                unichar lastChar = [line characterAtIndex:line.length - 1];
//                if (lastChar == '\r') {
//                    line = [line substringToIndex:line.length - 1];
//                }
//                
//                [params setValue:line forKey:M3U8_EXTINF_URI];
//                break;
//            }
//        }
//        
//        M3U8SegmentInfo *segment = [[M3U8SegmentInfo alloc] initWithDictionary:params];
//        if (segment) {
//            [self.segmentList addSegementInfo:segment];
//        }
//        
//		segmentRange = [remainingSegments rangeOfString:M3U8_EXTINF];
//    }
}

@end
