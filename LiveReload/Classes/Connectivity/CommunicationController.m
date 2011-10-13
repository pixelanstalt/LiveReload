
#import "CommunicationController.h"
#import "WebSocketServer.h"
#import "Project.h"
#import "Workspace.h"
#import "JSON.h"
#import "Preferences.h"

#define PORT_NUMBER 35729


static CommunicationController *sharedCommunicationController;

NSString *CommunicationStateChangedNotification = @"CommunicationStateChangedNotification";



@interface CommunicationController () <WebSocketServerDelegate, WebSocketConnectionDelegate>

@end


@implementation CommunicationController

@synthesize numberOfSessions=_numberOfSessions;
@synthesize numberOfProcessedChanges=_numberOfProcessedChanges;

+ (CommunicationController *)sharedCommunicationController {
    if (sharedCommunicationController == nil) {
        sharedCommunicationController = [[CommunicationController alloc] init];
    }
    return sharedCommunicationController;
}

- (void)startServer {
    _server = [[WebSocketServer alloc] init];
    _server.delegate = self;
    _server.port = PORT_NUMBER;
    [_server connect];
}

- (void)broadcastChangedPathes:(NSSet *)pathes inProject:(Project *)project {
    NSLog(@"Broadcasting change in %@: %@", project.path, [pathes description]);
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    for (NSString *path in pathes) {
        NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:path, @"path",
                              [NSNumber numberWithBool:[[Preferences sharedPreferences] autoreloadJavascript]], @"apply_js_live",
                              [NSNumber numberWithBool:YES], @"apply_css_live",
                              nil];
        NSArray *command = [NSArray arrayWithObjects:@"refresh", args, nil];
        [_server broadcast:[command JSONRepresentation]];
    }

    [pool drain];
    [self willChangeValueForKey:@"numberOfProcessedChanges"];
    ++_numberOfProcessedChanges;
    [self didChangeValueForKey:@"numberOfProcessedChanges"];
}

- (void)webSocketServer:(WebSocketServer *)server didAcceptConnection:(WebSocketConnection *)connection {
    [self willChangeValueForKey:@"numberOfSessions"];
    if (++_numberOfSessions == 1) {
        [self willChangeValueForKey:@"numberOfProcessedChanges"];
        _numberOfProcessedChanges = 0;
        [self didChangeValueForKey:@"numberOfProcessedChanges"];
    }
    [self didChangeValueForKey:@"numberOfSessions"];
    NSLog(@"Accepted connection.");
    connection.delegate = self;
    [connection send:@"!!ver:1.6"];
    if (![Workspace sharedWorkspace].monitoringEnabled) {
        [Workspace sharedWorkspace].monitoringEnabled = YES;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CommunicationStateChangedNotification object:nil];
}

- (void)webSocketConnection:(WebSocketConnection *)connection didReceiveMessage:(NSString *)message {
    NSLog(@"Received: %@", message);
}

- (void)webSocketConnectionDidClose:(WebSocketConnection *)connection {
    NSLog(@"Connection closed.");

    [self willChangeValueForKey:@"numberOfSessions"];
    --_numberOfSessions;
    [self didChangeValueForKey:@"numberOfSessions"];

    if ([Workspace sharedWorkspace].monitoringEnabled && [connection.server countOfConnections] == 0) {
        [Workspace sharedWorkspace].monitoringEnabled = NO;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CommunicationStateChangedNotification object:nil];
}

- (void)webSocketServerDidFailToInitialize:(WebSocketServer *)server {
    NSInteger result = [[NSAlert alertWithMessageText:@"Failed to start: port occupied" defaultButton:@"Quit" alternateButton:nil otherButton:@"More Info" informativeTextWithFormat:@"LiveReload cannot listen on port %d. You probably have another copy of LiveReload 2.x, a command-line LiveReload 1.x or an alternative tool like guard-livereload running.\n\nPlease quit any other live reloaders and rerun LiveReload.", PORT_NUMBER] runModal];
    if (result == NSAlertOtherReturn) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://help.livereload.com/kb/troubleshooting/failed-to-start-port-occupied"]];
    }
    [NSApp terminate:nil];
}

@end