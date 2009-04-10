//
//  SEPDocument.h
//  SubEthaEdit
//
//  Created by Dominik Wagner on 09.04.09.
//  Copyright 2009 TheCodingMonkeys. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DocumentMode.h"
#import "SyntaxHighlighter.h"

@interface SEPDocument : NSObject {
	NSTextStorage *I_textStorage;
	DocumentMode *I_documentMode;

    struct {
        NSFont *plainFont;
        NSFont *boldFont;
        NSFont *italicFont;
        NSFont *boldItalicFont;
    } I_fonts;
    NSMutableDictionary *I_styleCacheDictionary;
}

- (void)setPlainFont:(NSFont *)aFont;

- (id)initWithURL:(NSURL *)inURL;

- (NSTimeInterval)timedHighlightAll;

@end