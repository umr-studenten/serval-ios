//
//  ServalManager.m
//  serval-ios
//
//  Created by Jonas Höchst on 17.12.15.
//  Copyright © 2015 Jonas Höchst. All rights reserved.
//

#import "ServalManager.h"
#import "UNIHTTPJsonResponse.h"
#import "UNIRest.h"

// copied from serval_main.c
#include <signal.h>
#include "serval.h"
#include "conf.h"

@implementation ServalManager
NSThread* servaldThread;
NSString* confPath;

#pragma mark - Singleton Methods

+ (id)sharedManager {
    static ServalManager *sharedServalManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedServalManager = [[self alloc] init];
    });
    return sharedServalManager;
}

- (id) init {
    self = [super init];
    confPath = [NSString stringWithFormat:@"%s/serval.conf", INSTANCE_PATH];
    self.restUser = @"ios";
    self.restPassword = @"password";
    return self;
}

# pragma mark - serval daemon helpers

- (void) testOrCopyConfig {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:confPath]){
        NSLog(@"serval.conf is missing, copying default configuration...");
        
        NSString *confPath_bundle = [[NSBundle mainBundle] pathForResource:@"serval.conf" ofType:nil];
        NSError *error;
        
        if (![fm copyItemAtPath:confPath_bundle toPath:confPath error:&error]) {
            NSLog(@"Error occured copying config file: %@", error);
        }
    }
}

- (void) overwriteConfig {
    NSLog(@"replacing serval.conf with default configuration...");
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *confPath_bundle = [[NSBundle mainBundle] pathForResource:@"serval.conf" ofType:nil];
    NSError *error;
    
    BOOL success = [fm removeItemAtPath:confPath error:&error];
    if (!success) NSLog(@"Error removing config file: %@", error.localizedDescription);
    
    success = [fm copyItemAtPath:confPath_bundle toPath:confPath error:&error];
    if (!success) NSLog(@"Error copying config file: %@", error.localizedDescription);
}

- (void) wipeLogs {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString* logFilePath =[NSString stringWithFormat:@"%s/serval.log", INSTANCE_PATH];
    NSString* logFolderPath =[NSString stringWithFormat:@"%s/log/", INSTANCE_PATH];
    
    NSError *error;
    BOOL success = [fm removeItemAtPath:logFilePath error:&error];
    if (!success) NSLog(@"Error removing log file: %@", error.localizedDescription);
    
    success = [fm removeItemAtPath:logFolderPath error:&error];
    if (!success) NSLog(@"Error removing log folder: %@", error.localizedDescription);
    
}

- (void) wipeRhizomeDB {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString* instancePath = [NSString stringWithFormat:@"%s/rhizome.db", INSTANCE_PATH];
    
    NSError *error;
    BOOL success = [fm removeItemAtPath:instancePath error:&error];
    if (!success) NSLog(@"Error removing instance files: %@", error.localizedDescription);
}

#pragma mark - serval configuration

- (BOOL) setConfigOption:(NSString*) option toValue:(NSString*) value{
    if([servaldThread isExecuting]){
        [self servaldCommand: @[@"config", @"set", option, value]];
        return TRUE;
    }
    return FALSE;
}

- (NSString*) getConfig{
    NSError *error;
    NSString *content = [NSString stringWithContentsOfFile:confPath encoding:NSUTF8StringEncoding error:&error];
    
    return content;
}


#pragma mark - serval daemon start/stops

- (void)startServald {
//    [self testOrCopyConfig];
    [self overwriteConfig];
    [self wipeLogs];
    [self wipeRhizomeDB];
    
    
    if(servaldThread == nil || [servaldThread isCancelled] || [servaldThread isFinished]){
        // start thread
        servaldThread = [self dispatchServalCommand:@[@"start",@"foreground"]];
        
        NSString* logFilePath =[NSString stringWithFormat:@"%s/serval.log", INSTANCE_PATH];
        int i = 0;
        // busy-wait until file logfile exists
        while (![[NSFileManager defaultManager] fileExistsAtPath:logFilePath] && i < 10){
            [NSThread sleepForTimeInterval:0.1];
        }
        
        self.logFile = [NSFileHandle fileHandleForReadingAtPath:logFilePath];
        [self setConfigOption:@"server.motd" toValue:[[UIDevice currentDevice] name]];

    } else if([servaldThread isExecuting]){
        NSLog(@"servald is already running.");
        return;
    } else {
        NSLog(@"Unknow state of servald thread");
    }
}

- (void)stopServald {
    if(servaldThread == nil || [servaldThread isCancelled] || [servaldThread isFinished]){
        NSLog(@"servald has already stopped.");
        return;
    } else if([servaldThread isExecuting]){
        [servaldThread cancel];
    } else {
        NSLog(@"Unknow state of servald thread");
    }
}

#pragma mark - serval invoke methods

- (NSThread*) dispatchServalCommand:(NSArray* )ns_argv{
    NSThread* servalThread = [[NSThread alloc] initWithTarget:self selector:@selector(servaldCommand:) object:ns_argv];
    [servalThread start];
    return servalThread;
}

#pragma mark - servald_main methods

- (void) servaldCommand:(NSArray*) ns_argv{
    //capture stdout
//    NSString *pathForLog = [NSString stringWithFormat:@"%s/exec_%i.txt", INSTANCE_PATH, arc4random() % 100000];
//    freopen([pathForLog cStringUsingEncoding:NSASCIIStringEncoding],"a+", stdout);
//    freopen([pathForLog cStringUsingEncoding:NSASCIIStringEncoding],"a+", stderr);
    
    // split and convert input command
//    NSArray* argv_array = [command componentsSeparatedByString:@" "];
    char* argv[[ns_argv count]+1];
    int argc = 0;
    
    argv[argc++] = "servald"; // stub: name of the binary
    for(NSString* arg in ns_argv){
        argv[argc] = calloc([arg length]+1, 1);
        strncpy(argv[argc], [arg UTF8String], [arg length]);
        argc++;
    }
    
    /* Catch crash signals so that we can log a backtrace before expiring. */
    struct sigaction sig;
    sig.sa_handler = crash_handler;
    sigemptyset(&sig.sa_mask); // Don't block any signals during handler
    sig.sa_flags = SA_NODEFER | SA_RESETHAND; // So the signal handler can kill the process by re-sending the same signal to itself
    sigaction(SIGSEGV, &sig, NULL);
    sigaction(SIGFPE, &sig, NULL);
    sigaction(SIGILL, &sig, NULL);
    sigaction(SIGBUS, &sig, NULL);
    sigaction(SIGABRT, &sig, NULL);
    
    /* Setup i/o signal handlers */
    signal(SIGPIPE,sigPipeHandler);
    signal(SIGIO,sigIoHandler);
    
    srandomdev();
    cf_init();
    parseCommandLine(NULL, argv[0], argc - 1, (const char*const*)&argv[1]);
//    NSString *out = [[NSString alloc] initWithData: [[NSFileHandle fileHandleForReadingAtPath:pathForLog]  readDataToEndOfFile] encoding: NSASCIIStringEncoding];
    return;
}

char crash_handler_clue[1024] = "no clue";
static void crash_handler(int signal) {
    LOGF(LOG_LEVEL_FATAL, "Caught signal %s", alloca_signal_name(signal));
    LOGF(LOG_LEVEL_FATAL, "The following clue may help: %s", crash_handler_clue);
    dump_stack(LOG_LEVEL_FATAL);
    BACKTRACE;
    // Now die of the same signal, so that our exit status reflects the cause.
    INFOF("Re-sending signal %d to self", signal);
    kill(getpid(), signal);
    // If that didn't work, then die normally.
    INFOF("exit(%d)", -signal);
    exit(-signal);
}

# pragma mark - rest api helpers

+ (NSDictionary*) jsonDictForApiPath:(NSString*) path {
    return [ServalManager jsonDictForApiPath:path withParameters:nil];
}

+ (NSDictionary*) jsonDictForApiPath:(NSString*) path withParameters:(NSDictionary*) parameters{
    ServalManager *m = [self sharedManager];
    
    NSError *error = nil;
    NSString *url = [NSString stringWithFormat:@"http://localhost:4110/restful%@", path];
    UNIHTTPJsonResponse *response = [[UNIRest get:^(UNISimpleRequest *request) {
        [request setUrl:url];
        [request setUsername:[m restUser]];
        [request setPassword:[m restPassword]];
        if (parameters) [request setParameters:parameters];
    }] asJson:&error];
    
    if(error){
        NSLog(@"Request failed: %@", error.localizedDescription);
        return nil;
    }
    
    NSLog(@"Response sucessful for url: %@", url);
    return response.body.object;
}

- (void) refreshSidProperties{
    NSDictionary *sidDict = [ServalManager jsonDictForApiPath:@"/keyring/identities.json"];
    
    // For now, we are just supporting the first (aka. primary) SID
    _sid = [[[sidDict objectForKey:@"rows"] objectAtIndex:0] objectAtIndex:0];
    _did = [[[sidDict objectForKey:@"rows"] objectAtIndex:0] objectAtIndex:1];
    _name = [[[sidDict objectForKey:@"rows"] objectAtIndex:0] objectAtIndex:2];
}

- (void) setSid:(NSString *)sid{
    NSLog(@"Sid can never be set by the app.");
    return;
}

- (void) setDid:(NSString *)did{
    NSString *path = [NSString stringWithFormat:@"/keyring/%@/set", self.sid];
    NSDictionary *response = [ServalManager jsonDictForApiPath:path withParameters:@{@"did": did, @"name": _name}];
    if (!response) NSLog(@"error updating the did for %@", self.sid);
    else {
        NSLog(@"%@", response);
        _did = did;
    }
}

- (void) setName:(NSString *)name{
    NSString *path = [NSString stringWithFormat:@"/keyring/%@/set", self.sid];
    NSDictionary *response = [ServalManager jsonDictForApiPath:path withParameters:@{@"name": name, @"did": _did}];
    if (!response) NSLog(@"error updating the name for %@", self.sid);
    else {
        NSLog(@"%@", response);
        _name = name;
    }
}



@end
