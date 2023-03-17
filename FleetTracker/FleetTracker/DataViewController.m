//
//  DataViewController.m
//  DeviceTracker
//
//  Created by Dhara on 27/01/16.
//  Copyright © 2016 Net4Nuts. All rights reserved.
//

#import "DataViewController.h"
#import "DataTableViewCell.h"
#import "AppDelegate.h"
#import "MapVC.h"

@interface DataViewController ()
{
    
    NSMutableArray *arrLocationInfo;
    NSString *details;
}
@property (nonatomic, strong) DBmanager *dbmanager;
@end

@implementation DataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.title=[NSString stringWithFormat:@"Details:%d",details];
    [self getdata];
//    [self.tableView reloadData];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)getdata
{
    self.dbmanager = [[DBmanager alloc] initWithDatabaseFilename:@"FleetData.db"];
    NSString *query = @"select * from locationdetail";
    
    // Get the results.
    if (arrLocationInfo != nil) {
        arrLocationInfo= nil;
    }
    arrLocationInfo = [[NSMutableArray alloc] initWithArray:[self.dbmanager loadDataFromDB:query]];
    [self.tableView reloadData];
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrLocationInfo count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //self.tableView.scrollEnabled=TRUE;
    self.tableView.scrollsToTop=TRUE;
    static NSString *m_str=@"locationdetail";
    DataTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:m_str forIndexPath:indexPath];
    if(cell == nil)
    {
        cell=[[DataTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:m_str];
    }
    
    for(int i = 0 ; i <[arrLocationInfo count]; i++){
        
        NSInteger indexOfLatitude = [self.dbmanager.arrColumnNames indexOfObject:@"location"];
        NSString *uLatitude = [[arrLocationInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfLatitude];
        cell.lbllocation.text=uLatitude;
        
        NSInteger indexOfTime = [self.dbmanager.arrColumnNames indexOfObject:@"time"];
        NSString *uTime = [[arrLocationInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfTime];
        cell.lbltime.text=uTime;
        
        NSInteger indexOfSpeed = [self.dbmanager.arrColumnNames indexOfObject:@"speed"];
        NSString *uSpeed = [[arrLocationInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfSpeed];
        cell.lblspeed.text=uSpeed;
        
        NSInteger indexOfType = [self.dbmanager.arrColumnNames indexOfObject:@"type"];
        NSString *uType = [[arrLocationInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfType];
        cell.lbltype.text=uType;
        
       }

    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnDelete:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete" message:@"Are you sure you want to delete all data?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertView show];
    
//    self.dbmanager = [[DBmanager alloc] initWithDatabaseFilename:@"FleetData.db"];
//    NSString *query = @"Delete * from locationdata";
//    if (arrLocationInfo != nil) {
//        arrLocationInfo= nil;
//    }
//    arrLocationInfo = [[NSMutableArray alloc] initWithArray:[self.dbmanager loadDataFromDB:query]];
   // [self.tableView reloadData];

    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex    {
    
    if(buttonIndex == 1){
        self.dbmanager = [[DBmanager alloc] initWithDatabaseFilename:@"FleetData.db"];
            NSString *query = @"Delete  from locationdetail";
            if (arrLocationInfo != nil) {
                arrLocationInfo= nil;
            }
            arrLocationInfo = [[NSMutableArray alloc] initWithArray:[self.dbmanager loadDataFromDB:query]];
            //[self.tableView reloadData];
        [self getdata];
        
    }
}



- (IBAction)btnReferesh:(id)sender {
    
    [self getdata];
   // [self.tableView reloadData];
}

- (IBAction)btnMap:(id)sender {
    
    MapVC *dvc = [self.storyboard instantiateViewControllerWithIdentifier:@"MapVC"];
    [dvc setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self.navigationController pushViewController:dvc animated:YES];

}

@end
