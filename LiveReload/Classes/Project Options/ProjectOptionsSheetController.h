//
//  CoffeeOptionsSheetController.h
//  LiveReload
//
//  Created by Andrey Tarantsov on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class Project;
@class PaneViewController;


@interface ProjectOptionsSheetController : NSWindowController {
@private
    Project                     *_project;
    NSArray                     *_panes;
    NSArrayController           *_servicesArrayController;
    NSBox                       *_placeholderBox;
    PaneViewController          *_selectedPaneViewController;
}

- (id)initWithProject:(Project *)project;

- (IBAction)dismiss:(id)sender;

@property (assign) IBOutlet NSArrayController *servicesArrayController;
@property (assign) IBOutlet NSBox *placeholderBox;

@property (nonatomic, readonly, retain) Project *project;

@end