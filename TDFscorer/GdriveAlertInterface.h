//
//  GdriveAlertInterface.h
//  TDFscorer
//
//  Created by DJ from iMac on 2015/08/06.
//  Copyright (c) 2015 DJ Janse van Rensburg. All rights reserved.
//

@protocol GdriveAlertInterface
-(void)notifyOfGdriveComplete:(NSString *)crud object:(NSObject *)anyObject;
@end