//
//  ViewController.m
//  WTFrequency
//
//  Created by WT on 2018/10/17.
//  Copyright © 2018年 王通. All rights reserved.
//

#import "ViewController.h"
#import "SetSoundViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)enterHZSetter:(id)sender {
    SetSoundViewController *SSVC = [[SetSoundViewController alloc] init];
    [self.navigationController pushViewController:SSVC animated:YES];
}


@end
