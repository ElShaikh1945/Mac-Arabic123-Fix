#import <Carbon/Carbon.h>
#import <Foundation/Foundation.h>

// ============================================================
// Mac-Arabic123-Fix Helper Tool (Compiled Objective-C Binary)
// Developed by Muhammad El-Shaikh
// GitHub:  github.com/ElShaikh1945
// Email:   Muhammad.Al-Shaikh@outlook.com
// Copyright © 2026 Muhammad El-Shaikh. All rights reserved.
// ============================================================

#define TARGET_ID @"org.sil.ukelele.keyboardlayout.arabic123pc.arabic-123-pc"

static NSString *getStrProp(TISInputSourceRef source, CFStringRef propertyKey) {
  CFStringRef val = (CFStringRef)TISGetInputSourceProperty(source, propertyKey);
  if (!val)
    return nil;
  return (__bridge NSString *)val;
}

static BOOL isEnabled(TISInputSourceRef source) {
  CFBooleanRef val = (CFBooleanRef)TISGetInputSourceProperty(
      source, kTISPropertyInputSourceIsEnabled);
  if (!val)
    return NO;
  return CFBooleanGetValue(val);
}

static BOOL isArabicKeyboard(TISInputSourceRef source) {
  NSString *category = getStrProp(source, kTISPropertyInputSourceCategory);
  if (![category
          isEqualToString:(__bridge NSString *)kTISCategoryKeyboardInputSource])
    return NO;

  NSString *sourceType = getStrProp(source, kTISPropertyInputSourceType);
  if (![sourceType isEqualToString:(__bridge NSString *)kTISTypeKeyboardLayout])
    return NO;

  NSString *sourceID = getStrProp(source, kTISPropertyInputSourceID);
  if (!sourceID)
    return NO;

  if ([sourceID isEqualToString:TARGET_ID] || [sourceID containsString:@"arabic123pc"])
    return NO;

  NSString *lowerID = [sourceID lowercaseString];
  if ([lowerID containsString:@"syriac"] || [lowerID containsString:@"mandaic"])
    return NO;

  if ([lowerID containsString:@"arabic"])
    return YES;

  NSString *name = [getStrProp(source, kTISPropertyLocalizedName) lowercaseString];
  if (name && ([name containsString:@"arabic"] || [name containsString:@"عربي"]))
    return YES;

  CFArrayRef langs = (CFArrayRef)TISGetInputSourceProperty(
      source, kTISPropertyInputSourceLanguages);
  if (langs) {
    NSArray *langArray = (__bridge NSArray *)langs;
    if ([langArray count] > 0) {
      id firstObj = [langArray firstObject];
      if ([firstObj isKindOfClass:[NSString class]]) {
        NSString *primary = (NSString *)firstObj;
        if ([primary isEqualToString:@"ar"] || [primary hasPrefix:@"ar-"] ||
            [primary hasPrefix:@"ar_"])
          return YES;
      }
    }
  }
  return NO;
}

static BOOL isTargetKeyboard(TISInputSourceRef src) {
  NSString *sid = getStrProp(src, kTISPropertyInputSourceID);
  NSString *name = getStrProp(src, kTISPropertyLocalizedName);
  return ([sid isEqualToString:TARGET_ID] ||
          [sid containsString:@"arabic123pc"] ||
          [name isEqualToString:@"Arabic - 123 - PC"] ||
          [name isEqualToString:@"عربي - 123 - PC"]);
}

static BOOL outputsDot(TISInputSourceRef source) {
  CFDataRef data = (CFDataRef)TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData);
  if (!data) return NO;
  const UCKeyboardLayout *layout = (const UCKeyboardLayout *)CFDataGetBytePtr(data);
  UInt32 keysDown = 0; UniChar chars[4]; UniCharCount len = 0;
  OSStatus status = UCKeyTranslate(layout, 65, kUCKeyActionDown, 0, 41, kUCKeyTranslateNoDeadKeysBit, &keysDown, 4, &len, chars);
  return (status == noErr && len > 0 && chars[0] == '.');
}

static void enableAndSelect() {
  NSString *homeBundle = [@"~/Library/Keyboard Layouts/Arabic - 123 - PC.bundle" stringByExpandingTildeInPath];
  NSString *sysBundle = @"/Library/Keyboard Layouts/Arabic - 123 - PC.bundle";
  NSFileManager *fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:homeBundle]) {
    TISRegisterInputSource((__bridge CFURLRef)[NSURL fileURLWithPath:homeBundle]);
  }
  if ([fm fileExistsAtPath:sysBundle]) {
    TISRegisterInputSource((__bridge CFURLRef)[NSURL fileURLWithPath:sysBundle]);
  }

  CFArrayRef sources = TISCreateInputSourceList(NULL, true);
  if (!sources) {
    printf("Error: Could not retrieve input sources.\n");
    exit(1);
  }
  NSArray *list = (__bridge NSArray *)sources;
  TISInputSourceRef bestSource = NULL;
  NSMutableArray *outdatedSources = [NSMutableArray array];

  for (id obj in list) {
    TISInputSourceRef src = (__bridge TISInputSourceRef)obj;
    if (isTargetKeyboard(src)) {
      if (outputsDot(src)) {
        bestSource = src;
      } else {
        [outdatedSources addObject:(__bridge id)src];
      }
    }
  }

  if (!bestSource) {
    for (id obj in list) {
      TISInputSourceRef src = (__bridge TISInputSourceRef)obj;
      if (isTargetKeyboard(src)) {
        bestSource = src;
        break;
      }
    }
  }

  for (id oldObj in outdatedSources) {
    TISInputSourceRef oldSrc = (__bridge TISInputSourceRef)oldObj;
    TISDisableInputSource(oldSrc);
  }

  if (bestSource) {
    TISEnableInputSource(bestSource);
    TISSelectInputSource(bestSource);
    printf("Successfully activated: Arabic - 123 - PC\n");
    fflush(stdout);
    CFRelease(sources);
    exit(0);
  } else {
    printf("Error: Custom layout not found in input sources list.\n");
    fflush(stdout);
    CFRelease(sources);
    exit(1);
  }
}

static void listArabic() {
  CFArrayRef sources = TISCreateInputSourceList(NULL, true);
  if (!sources)
    exit(0);
  NSArray *list = (__bridge NSArray *)sources;
  for (id obj in list) {
    TISInputSourceRef src = (__bridge TISInputSourceRef)obj;
    if (!isArabicKeyboard(src))
      continue;
    if (!isEnabled(src))
      continue;

    NSString *sid = getStrProp(src, kTISPropertyInputSourceID) ?: @"unknown";
    NSString *name = getStrProp(src, kTISPropertyLocalizedName) ?: sid;
    printf("%s|%s\n", [sid UTF8String], [name UTF8String]);
  }
  CFRelease(sources);
  exit(0);
}

static void disableIDs(NSString *idsStr) {
  NSArray *targetIDs = [idsStr componentsSeparatedByString:@","];
  CFArrayRef sources = TISCreateInputSourceList(NULL, true);
  if (!sources)
    exit(0);
  NSArray *list = (__bridge NSArray *)sources;
  for (id obj in list) {
    TISInputSourceRef src = (__bridge TISInputSourceRef)obj;
    NSString *sid = getStrProp(src, kTISPropertyInputSourceID);
    if (!sid)
      continue;
    for (NSString *tid in targetIDs) {
      NSString *cleanTid =
          [tid stringByTrimmingCharactersInSet:[NSCharacterSet
                                                   whitespaceCharacterSet]];
      if ([sid isEqualToString:cleanTid]) {
        TISDisableInputSource(src);
        break;
      }
    }
  }
  CFRelease(sources);
  exit(0);
}

static void checkInstalled() {
  CFArrayRef sources = TISCreateInputSourceList(NULL, true);
  if (!sources) {
    printf("NOT_INSTALLED\n");
    exit(1);
  }
  NSArray *list = (__bridge NSArray *)sources;
  BOOL found = NO;
  for (id obj in list) {
    TISInputSourceRef src = (__bridge TISInputSourceRef)obj;
    NSString *sid = getStrProp(src, kTISPropertyInputSourceID);
    NSString *name = getStrProp(src, kTISPropertyLocalizedName);
    if ([sid isEqualToString:TARGET_ID] ||
        [name isEqualToString:@"Arabic - 123 - PC"] ||
        [name isEqualToString:@"عربي - 123 - PC"]) {
      found = YES;
      BOOL en = isEnabled(src);
      printf("INSTALLED|%s|%s\n", [sid UTF8String],
             en ? "ENABLED" : "DISABLED");
      break;
    }
  }
  CFRelease(sources);
  if (found) {
    exit(0);
  } else {
    printf("NOT_INSTALLED\n");
    exit(1);
  }
}

static void cleanOldArabic() {
  CFArrayRef sources = TISCreateInputSourceList(NULL, true);
  if (!sources)
    exit(0);
  NSArray *list = (__bridge NSArray *)sources;
  int disabledCount = 0;
  for (id obj in list) {
    TISInputSourceRef src = (__bridge TISInputSourceRef)obj;
    if (!isArabicKeyboard(src))
      continue;
    if (!isEnabled(src))
      continue;

    NSString *name = getStrProp(src, kTISPropertyLocalizedName) ?: @"unknown";
    NSString *sid = getStrProp(src, kTISPropertyInputSourceID) ?: @"unknown";

    OSStatus status = TISDisableInputSource(src);
    if (status == noErr) {
      printf("Disabled: %s (%s)\n", [name UTF8String], [sid UTF8String]);
      disabledCount++;
    }
  }
  printf("Total disabled: %d\n", disabledCount);
  CFRelease(sources);
  exit(0);
}

static void listAllArabic() {
  CFArrayRef sources = TISCreateInputSourceList(NULL, true);
  if (!sources)
    exit(0);
  NSArray *list = (__bridge NSArray *)sources;
  for (id obj in list) {
    TISInputSourceRef src = (__bridge TISInputSourceRef)obj;
    if (!isArabicKeyboard(src))
      continue;

    NSString *sid = getStrProp(src, kTISPropertyInputSourceID) ?: @"unknown";
    NSString *name = getStrProp(src, kTISPropertyLocalizedName) ?: sid;
    BOOL en = isEnabled(src);
    printf("%s|%s|%s\n", [sid UTF8String], [name UTF8String],
           en ? "ENABLED" : "DISABLED");
  }
  CFRelease(sources);
  exit(0);
}

static void enableID(NSString *targetID) {
  NSString *cleanID = [targetID
      stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  CFArrayRef sources = TISCreateInputSourceList(NULL, true);
  if (!sources) {
    printf("Error: Could not retrieve input sources.\n");
    exit(1);
  }
  NSArray *list = (__bridge NSArray *)sources;
  TISInputSourceRef found = NULL;
  for (id obj in list) {
    TISInputSourceRef src = (__bridge TISInputSourceRef)obj;
    NSString *sid = getStrProp(src, kTISPropertyInputSourceID);
    if ([sid isEqualToString:cleanID]) {
      found = src;
      break;
    }
  }
  if (found) {
    TISEnableInputSource(found);
    TISSelectInputSource(found);
    NSString *name = getStrProp(found, kTISPropertyLocalizedName) ?: cleanID;
    printf("Successfully activated: %s\n", [name UTF8String]);
    CFRelease(sources);
    exit(0);
  } else {
    printf("Error: Input source '%s' not found.\n", [cleanID UTF8String]);
    CFRelease(sources);
    exit(1);
  }
}

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    setbuf(stdout, NULL);
    if (argc > 1) {
      NSString *arg1 = [NSString stringWithUTF8String:argv[1]];
      if ([arg1 isEqualToString:@"--check-installed"]) {
        checkInstalled();
      } else if ([arg1 isEqualToString:@"--list-arabic"]) {
        listArabic();
      } else if ([arg1 isEqualToString:@"--list-all-arabic"]) {
        listAllArabic();
      } else if ([arg1 isEqualToString:@"--enable-id"] && argc > 2) {
        NSString *arg2 = [NSString stringWithUTF8String:argv[2]];
        enableID(arg2);
      } else if ([arg1 isEqualToString:@"--disable-ids"] && argc > 2) {
        NSString *arg2 = [NSString stringWithUTF8String:argv[2]];
        disableIDs(arg2);
      } else if ([arg1 isEqualToString:@"--clean-old-arabic"]) {
        cleanOldArabic();
      } else {
        enableAndSelect();
      }
    } else {
      enableAndSelect();
    }
  }
  return 0;
}
