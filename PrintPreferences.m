//
//  PrintPreferences.m
//  SubEthaEdit
//
//  Created by Dominik Wagner on 29.09.04.
//  Copyright (c) 2004 TheCodingMonkeys. All rights reserved.
//

#import "PrintPreferences.h"
#import "DocumentMode.h"
#import "DocumentModeManager.h"

NSString * PrintPreferencesDidChangeNotification=@"PrintPreferencesDidChangeNotification";

@implementation PrintPreferences
static NSArray *S_relevantPrintOptionKeys=nil;

+ (NSArray *)relevantPrintOptionKeys {
    if (!S_relevantPrintOptionKeys) {
        S_relevantPrintOptionKeys=
        [[NSArray arrayWithObjects:@"NSTopMargin",@"NSLeftMargin",@"NSRightMargin",@"NSBottomMargin",@"SEEFacingPages",
                                   @"SEEParticipants", @"SEEParticipantImages", 
                                   @"SEEParticipantsAIMAndEmail", @"SEEParticipantsVisitors",
                                   @"SEEHighlightSyntax", @"SEELineNumbers", 
                                   @"SEEUseCustomFont", @"SEEResizeDocumentFont",
                                   @"SEEResizeDocumentFontTo", @"SEEFontAttributes", @"SEEPageHeader",
                                   @"SEEPageHeaderFilename",@"SEEPageHeaderCurrentDate", 
                                   @"SEEColorizeChangeMarks", @"SEEColorizeWrittenBy",
                                   @"SEEAnnotateChangeMarks", @"SEEAnnotateWrittenBy",
                                   @"SEEWhiteBackground",
                                   nil] retain];
    }
    return S_relevantPrintOptionKeys;
}

- (id)init {
    self=[super init];
    if (self) {
        I_defaultModeDictionary=[NSMutableDictionary new];
    }
    return self;
}

- (void)dealloc {
    [I_printDictionary release];
    [I_defaultModeDictionary release];
    [super dealloc];
}

- (NSImage *)icon {
    return [NSImage imageNamed:@"PrintPrefs"];
}

- (NSString *)iconLabel {
    return NSLocalizedString(@"PrintPrefsIconLabel", @"Label displayed below print icon and used as window title.");
}

- (NSString *)identifier {
    return @"de.codingmonkeys.subethaedit.preferences.print";
}

- (NSString *)mainNibName {
    return @"PrintPrefs";
}

- (void)setSubviewsOfView:(NSView *)aView enabled:(BOOL)aBool {
    id subview=nil;
    NSEnumerator *subviews=[[aView subviews] objectEnumerator];
    while ((subview=[subviews nextObject])) {
        if ([subview respondsToSelector:@selector(setEnabled:)]) {
            [subview setEnabled:aBool];
        } else {
            [self setSubviewsOfView:subview enabled:aBool];
        }
    }
}

- (void)validateDefaultState {
    if ([[I_currentMode defaultForKey:DocumentModeUseDefaultPrintPreferenceKey] boolValue]) {
        [I_defaultModeDictionary removeAllObjects];
        [I_defaultModeDictionary setDictionary:[[NSKeyedUnarchiver unarchiveObjectWithData:[[DocumentModeManager baseMode] defaultForKey:DocumentModePrintInfoPreferenceKey]] dictionary]];
        [O_printOptionController setContent:I_defaultModeDictionary];
        [self setSubviewsOfView:O_printOptionView enabled:NO];
    } else{
        [self setSubviewsOfView:O_printOptionView enabled:YES];
        [O_printOptionController setContent:I_printDictionary];
    }
    
}

static NSString *S_measurementUnits;

- (void)mainViewDidLoad {
    // Initialize user interface elements to reflect current preference settings
    [NSBundle loadNibNamed:@"PrintOptions" owner:self];
    if (!S_measurementUnits) {
        S_measurementUnits=[[[NSUserDefaults standardUserDefaults] stringForKey:@"AppleMeasurementUnits"] retain];
    }
    NSString *labelText=NSLocalizedString(([NSString stringWithFormat:@"Label%@",S_measurementUnits]),
                                          @"Centimeters or Inches, short label string for them");
    int i=996;
    for (i=996;i<1000;i++) {
        [[O_printOptionView viewWithTag:i] setStringValue:labelText];
    }
    NSView *superview=[O_placeholderView superview];
    [O_printOptionView setFrame:[O_placeholderView frame]];
    [superview replaceSubview:O_placeholderView with:O_printOptionView];
    
    [self changeMode:O_modePopUpButton];
}

- (void)didUnselect {
    // Save preferences
    [[[NSFontManager sharedFontManager] fontPanel:NO] orderOut:self];
}

- (IBAction)changeMode:(id)aSender {
    DocumentMode *newMode=[aSender selectedMode];
    NSPrintInfo *printInfo=[NSKeyedUnarchiver unarchiveObjectWithData:[newMode defaultForKey:DocumentModePrintInfoPreferenceKey]];
    NSMutableDictionary *myDictionary=[I_printDictionary autorelease];
    I_printDictionary=[[NSMutableDictionary dictionaryWithDictionary:[printInfo dictionary]] retain];
    NSEnumerator *keyPaths=[[PrintPreferences relevantPrintOptionKeys] objectEnumerator];
    NSString     *keyPath=nil;
    while ((keyPath=[keyPaths nextObject])) {
        [myDictionary   removeObserver:self forKeyPath:keyPath];
        [I_printDictionary addObserver:self forKeyPath:keyPath options:NULL context:nil];
    }
    [O_printOptionController setContent:nil];
    I_currentMode=newMode;
    [O_defaultButton setHidden:[I_currentMode isBaseMode]];
    [O_defaultButton setState:[[I_currentMode defaultForKey:DocumentModeUseDefaultPrintPreferenceKey] boolValue]?NSOnState:NSOffState];
    [self validateDefaultState];
}

- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)anObject change:(NSDictionary *)aChange context:(void *)aContext {
//    DEBUGLOG(@"Blah",AlwaysLogLevel,@"%@ %@ %@",aKeyPath,anObject,aChange);
    NSPrintInfo *printInfo=[NSKeyedUnarchiver unarchiveObjectWithData:[I_currentMode defaultForKey:DocumentModePrintInfoPreferenceKey]];
    NSEnumerator *keyPaths=[[PrintPreferences relevantPrintOptionKeys] objectEnumerator];
    NSString     *keyPath=nil;
    while ((keyPath=[keyPaths nextObject])) {
        id value=[I_printDictionary objectForKey:keyPath];
        if (value) {
            [[printInfo dictionary] setObject:value forKey:keyPath];
        }
    }
    [[I_currentMode defaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:printInfo] 
                                 forKey:DocumentModePrintInfoPreferenceKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:PrintPreferencesDidChangeNotification object:I_currentMode];
}

- (IBAction)changeFontViaPanel:(id)sender {
    NSDictionary *fontAttributes=[[O_printOptionController content] valueForKeyPath:@"SEEFontAttributes"];
    NSFont *newFont=[NSFont fontWithName:[fontAttributes objectForKey:NSFontNameAttribute] size:[[fontAttributes objectForKey:NSFontSizeAttribute] floatValue]];
    if (!newFont) newFont=[NSFont userFixedPitchFontOfSize:[[fontAttributes objectForKey:NSFontSizeAttribute] floatValue]];
    
    [[NSFontManager sharedFontManager] 
        setSelectedFont:newFont 
             isMultiple:NO];
    [[NSFontManager sharedFontManager] orderFrontFontPanel:self];
}

- (void)changeFont:(id)aSender {
    if (![[I_currentMode defaultForKey:DocumentModeUseDefaultPrintPreferenceKey] boolValue]) {
        NSFont *newFont = [aSender convertFont:[NSFont systemFontOfSize:0.]];
        NSMutableDictionary *dict=[NSMutableDictionary dictionary];
        [dict setObject:[newFont fontName] 
                 forKey:NSFontNameAttribute];
        [dict setObject:[NSNumber numberWithFloat:[newFont pointSize]] 
                 forKey:NSFontSizeAttribute];
        [[O_printOptionController content] setValue:dict forKeyPath:@"SEEFontAttributes"];
    }
}

- (IBAction)changeUseDefault:(id)aSender {
    [[I_currentMode defaults] setObject:[NSNumber numberWithBool:[aSender state]==NSOnState] forKey:DocumentModeUseDefaultPrintPreferenceKey];
    [self validateDefaultState];
}

@end
