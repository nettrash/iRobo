//
//  AdditionalParametersViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 20.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "AdditionalParametersViewController_iPhone.h"
#import "svcParameter.h"
#import "UIParameterTextField.h"
#import "NSString+RegEx.h"

@interface AdditionalParametersViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITableViewController *tblPrms;

@end

@implementation AdditionalParametersViewController_iPhone

@synthesize delegate = _delegate;
@synthesize tblPrms = _tblPrms;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withParameters:(NSArray *)parameters
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.navigationItem setHidesBackButton:YES animated:NO];
        self.navigationItem.title = NSLocalizedString(@"AdditionalParameters_Title", @"AdditionalParameters_Title");
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(btnCancel_Click:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(btnDone_Click:)];
        _parameters = parameters;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self validate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tblPrms.view removeFromSuperview];
    self.tblPrms.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 20, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 20);
    if (_keyboardIsShowing) {
        CGRect frame = self.tblPrms.view.frame;
        frame.size.height -= [_keyboardHeight floatValue];
        self.tblPrms.view.frame = frame;
	}
    
    [self.view addSubview:self.tblPrms.view];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardDidShow:)
     name:UIKeyboardDidShowNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification
     object:nil];
}

- (void)keyboardWillShow : (NSNotification *) note
{
	if (_keyboardIsShowing) return;
    
    CGRect keyboardBounds;
	
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
	
    _keyboardHeight = [NSNumber numberWithFloat:keyboardBounds.size.height];
	
	_keyboardIsShowing = YES;
	
	CGRect frame = self.tblPrms.view.frame;
	frame.size.height -= [_keyboardHeight floatValue];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3f];
	
	self.tblPrms.view.frame = frame;
	
	[UIView commitAnimations];
}

- (void)keyboardDidShow : (NSNotification *) note
{
}

- (void)keyboardWillHide : (NSNotification *) note
{
    if (_keyboardIsShowing) {
        _keyboardIsShowing = NO;
        CGRect frame = self.tblPrms.view.frame;
        frame.size.height += [_keyboardHeight floatValue];
		
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3f];
		
        self.tblPrms.view.frame = frame;
		
        [UIView commitAnimations];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)btnCancel_Click:(id)sender
{
    [self.delegate userCancelAction:self];
}

- (void)btnDone_Click:(id)sender
{
    [self.delegate parametersEntered:self parameters:_parameters];
}

- (void)validate
{
    BOOL bValidParams = YES;
    
    for (svcParameter *p in _parameters)
    {
        if (!p.DefaultValue || p.DefaultValue == nil || [p.DefaultValue isEqualToString:@""] || ![p.DefaultValue checkFormat:p.Format])
            bValidParams = NO;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = bValidParams;
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_parameters count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    svcParameter *p = (svcParameter *)[_parameters objectAtIndex:section];
    return p.Label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"ParameterCell";
    svcParameter *prm = (svcParameter *)[_parameters objectAtIndex:indexPath.section];
    identifier = prm.Name;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    BOOL dequeued = YES;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        dequeued = NO;
    }
    
    if (!dequeued && ([prm.Type isEqualToString:@"Text"] || [prm.Type isEqualToString:@"Options"]))
    {
        UIParameterTextField *tf = [[UIParameterTextField alloc] initWithFrame:CGRectMake(15, 6, 285, 30) andParameter:prm];
        tf.delegate = self;
        [cell addSubview:tf];
    }
    if ([prm.Type isEqualToString:@"Check"])
    {
        cell.textLabel.text = [prm.Label uppercaseString];
        if ([[prm.DefaultValue uppercaseString] isEqualToString:@"TRUE"])
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    }

    cell.textLabel.font = [UIFont boldSystemFontOfSize:10];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = nil;
    UIParameterTextField *ptf = (UIParameterTextField *)textField;
    for (int idx = 0; idx < [_parameters count]; idx++)
    {
        if ([ptf.parameter.Name isEqualToString:[(svcParameter *)[_parameters objectAtIndex:idx] Name]])
        {
            indexPath = [NSIndexPath indexPathForRow:0 inSection:idx];
            break;
        }
    }
    [self.tblPrms.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    textField.text = str;
    if ([textField isKindOfClass:[UIParameterTextField class]])
    {
        [(UIParameterTextField *)textField parameter].DefaultValue = str;
    }
    [self validate];
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self validate];
    return YES;
}

@end
