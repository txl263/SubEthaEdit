//
//  SEECollaborationPreferenceModule.h
//  SubEthaEdit
//
//  Created by Lisa Brodner on 10/04/14.
//  Copyright (c) 2014 TheCodingMonkeys. All rights reserved.
//

#import "TCMPreferenceModule.h"
@class SEECollaborationPreferenceModule;
#import "SEEUserColorsPreviewView.h"
#import "SEEAvatarImageView.h"

@interface SEECollaborationPreferenceModule : TCMPreferenceModule

// network
@property (nonatomic, strong) IBOutlet NSButton *O_automaticallyMapPortButton;
@property (nonatomic, strong) IBOutlet NSTextField *O_localPortTextField;
@property (nonatomic, strong) IBOutlet NSTextField *O_mappingStatusTextField;
@property (nonatomic, strong) IBOutlet NSImageView *O_mappingStatusImageView;
@property (nonatomic, strong) IBOutlet NSProgressIndicator *O_mappingStatusProgressIndicator;
@property (nonatomic, strong) IBOutlet NSButton *O_disableNetworkingButton;
@property (nonatomic, strong) IBOutlet NSButton *O_invisibleOnNetowrkButton;
@property (nonatomic, strong) IBOutlet NSTextField *O_invisibleOnNetworkExplanationTextField;

// me-card
@property (nonatomic, strong) IBOutlet SEEAvatarImageView *O_avatarImageView;
@property (nonatomic, strong) IBOutlet NSTextField *O_nameTextField;
@property (nonatomic, strong) IBOutlet NSComboBox  *O_emailComboBox;

// colors
@property (nonatomic, strong) IBOutlet SEEUserColorsPreviewView *O_userColorsPreview;
@property (nonatomic, strong) IBOutlet NSButton *O_higlightChangesButton;

// localization
@property (nonatomic, readonly) NSString *localizedNetworkBoxLabelText;
@property (nonatomic, readonly) NSString *localizedLocalPortLabelText;
@property (nonatomic, readonly) NSString *localizedAutomaticallyMapPortsLabelText;
@property (nonatomic, readonly) NSString *localizedAutomaticallyMapPortsExplanationText;
@property (nonatomic, readonly) NSString *localizedAutomaticallyMapPortsToolTipText;

@property (nonatomic, readonly) NSString *localizedUserNameLabel;
@property (nonatomic, readonly) NSString *localizedUserEmailLabel;

@property (nonatomic, readonly) NSString *localizedImageMenuAddressBook;
@property (nonatomic, readonly) NSString *localizedImageMenuChoose;
@property (nonatomic, readonly) NSString *localizedImageMenuClear;

// actions - network
- (IBAction)changeAutomaticallyMapPorts:(id)aSender;
- (IBAction)changeDisableNetworking:(id)aSender;
- (IBAction)changeVisiblityOnNetwork:(id)aSender;

// actions - me-card
- (IBAction)chooseImage:(id)aSender;

- (IBAction)changeName:(id)aSender;
- (IBAction)changeEmail:(id)aSender;

- (IBAction)postGeneralViewPreferencesDidChangeNotificiation:(id)aSender;
- (IBAction)updateChangesColor:(id)sender;

@end