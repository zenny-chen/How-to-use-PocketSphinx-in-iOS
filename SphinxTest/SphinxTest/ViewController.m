//
//  ViewController.m
//  SphinxTest
//
//  Created by Zenny Chen on 2018/9/5.
//  Copyright © 2018年 Zenny Chen. All rights reserved.
//

#import "ViewController.h"
#include "pocketsphinx.h"

#ifndef var
#define var     __auto_type
#endif

@interface ViewController ()

@end

@implementation ViewController
{
@private
    
    cmd_ln_t *mSphinxConfig;
    ps_decoder_t *mPS;
}

- (void)dealloc
{
    cmd_ln_free_r(mSphinxConfig);
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    var rootPath = [NSBundle.mainBundle pathForResource:@"model" ofType:nil];
    var hmmDir = [rootPath stringByAppendingPathComponent:@"en-us/en-us"];
    var lmDir = [rootPath stringByAppendingPathComponent:@"en-us/en-us.lm.bin"];
    var dictDir = [rootPath stringByAppendingPathComponent:@"en-us/cmudict-en-us.dict"];
    
    mSphinxConfig = cmd_ln_init(NULL, ps_args(), TRUE,
                          "-hmm", hmmDir.UTF8String,
                          "-lm", lmDir.UTF8String,
                          "-dict", dictDir.UTF8String, NULL);
    
    var button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(20.0, 100.0, 90.0, 35.0);
    [button setTitle:@"Test1" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(test1ButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(120.0, 100.0, 90.0, 35.0);
    [button setTitle:@"Test2" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(test2ButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(220.0, 100.0, 90.0, 35.0);
    [button setTitle:@"Test3" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(test3ButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

/// Process the raw PCM data from the specified file
/// @param filePath the specified file path
- (void)processRawPCMData:(NSString*)filePath
{
    var ps = ps_init(mSphinxConfig);
    if(ps == NULL)
    {
        NSLog(@"Failed to create recognizer!");
        return;
    }
    
    var fp = fopen(filePath.UTF8String, "r");
    if(fp == NULL)
    {
        NSLog(@"File cannot be opened!");
        return;
    }
    
    var rv = ps_start_utt(ps);
    if(rv != 0)
    {
        NSLog(@"Decoder failed to start!");
        return;
    }
    
    int16_t buffer[512];
    
    while(!feof(fp))
    {
        const var nSamples = fread(buffer, 2, 512, fp);
        rv = ps_process_raw(ps, buffer, nSamples, FALSE, FALSE);
    }
    
    rv |= ps_end_utt(ps);
    
    fclose(fp);
    
    if(rv != 0)
        NSLog(@"Recognition failed!");
    else
    {
        int32_t score;
        var hyp = ps_get_hyp(ps, &score);
        
        var alert = [UIAlertController alertControllerWithTitle:@"Recognized" message:@(hyp) preferredStyle:UIAlertControllerStyleAlert];
        var defaultAction = [UIAlertAction actionWithTitle:@"OK"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }

    ps_free(ps);
}

// MARK: button event handlers

- (void)test1ButtonTouched:(UIButton*)sender
{
    // Here will print:
    // Recognized: go forward ten meters
    [self processRawPCMData:[NSBundle.mainBundle pathForResource:@"goforward" ofType:@"raw"]];
}

- (void)test2ButtonTouched:(UIButton*)sender
{
    // Here will print:
    // Recognized: go somewhere and do something
    [self processRawPCMData:[NSBundle.mainBundle pathForResource:@"something" ofType:@"raw"]];
}

- (void)test3ButtonTouched:(UIButton*)sender
{
    // Here will print:
    // Recognized: thirty three four or six ninety two
    [self processRawPCMData:[NSBundle.mainBundle pathForResource:@"numbers" ofType:@"raw"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


