//
//  WALSettings.m
//  Wallabag
//
//  Created by Kevin Meyer on 20.02.14.
//  Copyright (c) 2014 Wallabag. All rights reserved.
//

#import "WALSettings.h"
#define kWallabagAppGroupId @"group.de.Kevin-Meyer.Wallabag"

@interface WALSettings ()
@property (nonatomic, strong) NSString *wallabagVersion;
@end

@implementation WALSettings
@synthesize wallabagURL = _wallabagURL;

+ (WALSettings*) settingsFromSavedSettings {
	return [self settingsFromSavedSettingsOnFallback:NO];
}

+ (WALSettings*) settingsFromSavedSettingsOnFallback:(BOOL) fallback {
	
	WALSettings* settings = [[WALSettings alloc] init];
	
	NSUserDefaults *defaults;
	if (!fallback) {
		defaults = [[NSUserDefaults alloc] initWithSuiteName:kWallabagAppGroupId];
	} else {
		defaults = [NSUserDefaults standardUserDefaults];
	}
	
	settings.wallabagURL = [defaults URLForKey:@"wallabagURL"];
	settings.wallabagVersion = [defaults stringForKey:@"wallabagVersion"];
	settings.userID = [defaults integerForKey:@"userID"];
	settings.apiToken = [defaults stringForKey:@"apiToken"];
	
	if (!settings.isValid && fallback)
		return nil;
	else if (!settings.isValid) {
		settings = [self settingsFromSavedSettingsOnFallback:YES];
		if (settings) {
			[settings saveSettings];
		}
	}
	
	return settings;
}

- (void) saveSettings
{
	NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kWallabagAppGroupId];
	
	[defaults setURL:self.wallabagURL forKey:@"wallabagURL"];
	[defaults setObject:self.wallabagVersion forKey:@"wallabagVersion"];
	[defaults setInteger:self.userID forKey:@"userID"];
	[defaults setObject:self.apiToken forKey:@"apiToken"];
	[defaults synchronize];
}

#pragma mark - Version Handling

- (void)setVersionV2:(BOOL)isV2 {
	if (isV2) {
		self.wallabagVersion = @"v2";
	} else {
		self.wallabagVersion = @"v1";
	}
}

- (BOOL)isVersionV2 {
	return [self.wallabagVersion isEqualToString:@"v2"];
}

#pragma mark - URL Handling

- (void)setWallabagURL:(NSURL *)url {
	if (!url)
		return;
	
	if (![url.absoluteString hasSuffix:@"/"])
		url = [NSURL URLWithString:[url.absoluteString stringByAppendingString:@"/"]];
	
	_wallabagURL = url;
}

- (NSURL *)getWallabagURL {
	if (!_wallabagURL) {
		return nil;
	}
	return _wallabagURL.absoluteURL;
}

#pragma mark - Validator

- (BOOL)isValid {
	if (!self.wallabagVersion) {
		return NO;
	}
	
	if ([self isVersionV2]) {
		return self.wallabagURL != nil;
	} else {
		return self.wallabagURL != nil && self.apiToken != nil;
	}
}

@end
