//
//  ViewController.m
//  DeviceTracker
//
//  Created by Dhara on 22/12/15.
//  Copyright © 2015 Net4Nuts. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "FGRoute.h"


@interface ViewController ()
{
NSString *uniqueId;
NSString *combinedString;
NSString *macAddress;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    macAddress = [[NSUserDefaults standardUserDefaults] objectForKey:@"MACADDRESS"];
    NSLog(@"MAC Address:%@",macAddress);
       if([macAddress length] == 0)
        {
            NSLog(@"null");
            [self showalert];
        }else{
            NSLog(@"not null");
        }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btninfo:(id)sender {
    [self showalert];
    
}


-(void)showalert{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ENTER MAC ADDRESS" message:@"Go To Settings > General > About. Paste Wi-Fi Address below." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alertView.tag = 100;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    [textField.delegate self];
    textField.keyboardType = UIKeyboardTypeDefault;
    
    
    
    
    macAddress = [[NSUserDefaults standardUserDefaults] objectForKey:@"MACADDRESS"];
    if(![macAddress isEqualToString:@""]){
       textField.text = macAddress;
    }else{
        textField.text = [FGRoute getBSSID];
    }
    
    [alertView show];
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex    {
    
    NSLog(@"Button Index:%ld",(long)buttonIndex);
    if(buttonIndex == 1 && alertView.tag == 100){

        UITextField * alertTextField = [alertView textFieldAtIndex:0];
        NSLog(@"alerttextfiled - %@",alertTextField.text);

        if([alertTextField.text length] == 0){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"MAC Address should not blank." delegate:self cancelButtonTitle:@"OK"otherButtonTitles:nil];
            alertView.tag = 200;
            [alertView show];
        }
        [[NSUserDefaults standardUserDefaults] setValue:alertTextField.text forKey:@"MACADDRESS"];

        
    }
    
    if(buttonIndex == 0 && alertView.tag == 200){
        [self showalert];
    }
}

@end
