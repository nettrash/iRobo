//
//  ProfileViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 09.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "ProfileViewController_iPhone.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import "ChangePersonViewController_iPhone.h"
#import "AboutViewController_iPhone.h"
#import "UIViewController+KeyboardExtensions.h"

@interface ProfileViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITableViewController *tblProfile;
@property (nonatomic, retain) UITextField *tfLastName;
@property (nonatomic, retain) UITextField *tfFirstName;
@property (nonatomic, retain) UITextField *tfSecondName;
@property (nonatomic, retain) UITextField *tfAddress;

@end

@implementation ProfileViewController_iPhone

@synthesize tblProfile = _tblProfile;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.navigationItem.title = NSLocalizedString(@"Profile_Title", @"Profile_Title");
        
        self.tfLastName = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, 280, 30)];
        self.tfLastName.adjustsFontSizeToFitWidth = YES;
        self.tfLastName.textColor = [UIColor darkGrayColor];
        self.tfLastName.placeholder = NSLocalizedString(@"Payer_LastName", @"Payer_LastName");;
        self.tfLastName.keyboardType = UIKeyboardTypeDefault;
        self.tfLastName.delegate = self;
        self.tfLastName.text = app.userProfile.lastName;
        
        self.tfFirstName = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, 280, 30)];
        self.tfFirstName.adjustsFontSizeToFitWidth = YES;
        self.tfFirstName.textColor = [UIColor darkGrayColor];
        self.tfFirstName.placeholder = NSLocalizedString(@"Payer_FirstName", @"Payer_FirstName");;
        self.tfFirstName.keyboardType = UIKeyboardTypeDefault;
        self.tfFirstName.delegate = self;
        self.tfFirstName.text = app.userProfile.firstName;
        
        self.tfSecondName = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, 280, 30)];
        self.tfSecondName.adjustsFontSizeToFitWidth = YES;
        self.tfSecondName.textColor = [UIColor darkGrayColor];
        self.tfSecondName.placeholder = NSLocalizedString(@"Payer_SecondName", @"Payer_SecondName");;
        self.tfSecondName.keyboardType = UIKeyboardTypeDefault;
        self.tfSecondName.delegate = self;
        self.tfSecondName.text = app.userProfile.secondName;
        
        self.tfAddress = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, 280, 30)];
        self.tfAddress.adjustsFontSizeToFitWidth = YES;
        self.tfAddress.textColor = [UIColor darkGrayColor];
        self.tfAddress.placeholder = NSLocalizedString(@"Payer_Address", @"Payer_Address");;
        self.tfAddress.keyboardType = UIKeyboardTypeDefault;
        self.tfAddress.delegate = self;
        self.tfAddress.text = app.userProfile.address;

        SWRevealViewController *revealViewController = [self revealViewController];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"] style:UIBarButtonItemStylePlain target:revealViewController action:@selector(revealToggle:)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tblProfile.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 16, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 16);
    [self.view addSubview:self.tblProfile.view];

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
    
//    if (_needToShowDoneButton)
//        [self addDoneButtonToNumberPadKeyboard];
//    else
//        [self removeDoneButtonFromNumberPadKeyboard];
    
	CGRect frame = self.tblProfile.view.frame;
	frame.size.height -= [_keyboardHeight floatValue];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3f];
	
	self.tblProfile.view.frame = frame;
	
	[UIView commitAnimations];
}

- (void)keyboardDidShow : (NSNotification *) note
{
//    if (_needToShowDoneButton)
//        [self addDoneButtonToNumberPadKeyboard];
//    else
//        [self removeDoneButtonFromNumberPadKeyboard];
}

- (void)keyboardWillHide : (NSNotification *) note
{
    if (_keyboardIsShowing) {
//        [self removeDoneButtonFromNumberPadKeyboard];
        _keyboardIsShowing = NO;
        CGRect frame = self.tblProfile.view.frame;
        frame.size.height += [_keyboardHeight floatValue];
		
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3f];
		
        self.tblProfile.view.frame = frame;
		
        [UIView commitAnimations];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return NSLocalizedString(@"ProfileView_SectionProfile_Title", @"ProfileView_SectionProfile_Title");
        case 1:
            return NSLocalizedString(@"ProfileView_SectionUserData_Title", @"ProfileView_SectionUserData_Title");
        case 2:
            return NSLocalizedString(@"ProfileView_SectionActions_Title", @"ProfileView_SectionActions_Title");
        default:
            return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3;
        case 1:
            return 4;
        case 2:
            return 2;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    switch (indexPath.section) {
        case 0: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileViewCell"];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ProfileViewCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            switch (indexPath.row) {
                case 0: {
                    cell.textLabel.text = NSLocalizedString(@"Profile_Phone", @"Profile_Phone");
                    cell.detailTextLabel.text = app.userProfile.phone;
                    cell.imageView.image = [UIImage imageNamed:@"PhoneIcon.png"];
                    break;
                }
                case 1: {
                    cell.textLabel.text = NSLocalizedString(@"Profile_EMail", @"Profile_EMail");
                    cell.detailTextLabel.text = app.userProfile.email;
                    cell.imageView.image = [UIImage imageNamed:@"EMailIcon.png"];
                    break;
                }
                case 2: {
                    cell.textLabel.text = NSLocalizedString(@"Profile_Password", @"Profile_Password");
                    cell.detailTextLabel.text = @"*******";
                    cell.imageView.image = [UIImage imageNamed:@"PasswordIcon.png"];
                    break;
                }
                default:
                    break;
            }
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            [cell.textLabel setTextColor:[UIColor darkGrayColor]];
            [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
            return cell;
        }
        case 1: {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ProfileUserDataCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            switch (indexPath.row) {
                case 0: {
                    [cell addSubview:self.tfLastName];
                    break;
                }
                case 1: {
                    [cell addSubview:self.tfFirstName];
                    break;
                }
                case 2: {
                    [cell addSubview:self.tfSecondName];
                    break;
                }
                case 3: {
                    [cell addSubview:self.tfAddress];
                    break;
                }
                default:
                    break;
            }
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            [cell.textLabel setTextColor:[UIColor darkGrayColor]];
            [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
            return cell;
        }
        case 2: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileActionCell"];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ProfileActionCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            switch (indexPath.row) {
                case 0: {
                    cell.textLabel.text = NSLocalizedString(@"ProfileView_ChangeProfileTitle", @"ProfileView_ChangeProfileTitle");
                    cell.detailTextLabel.text = NSLocalizedString(@"ProfileView_ChangeProfileDetails", @"ProfileView_ChangeProfileDetails");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
                case 1: {
                    cell.textLabel.text = NSLocalizedString(@"ProfileView_AboutTitle", @"ProfileView_AboutTitle");
                    cell.detailTextLabel.text = NSLocalizedString(@"ProfileView_AboutDetails", @"ProfileView_AboutDetails");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
                default:
                    break;
            }
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
            [cell.textLabel setTextColor:[UIColor darkGrayColor]];
            [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
            return cell;
        }
        default:
            return nil;
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideKeyboard];
    switch (indexPath.section) {
        case 2: {
            switch (indexPath.row) {
                case 0: {
                    ChangePersonViewController_iPhone *cp = [[ChangePersonViewController_iPhone alloc] initWithNibName:@"ChangePersonViewController_iPhone" bundle:nil];
                    [self.navigationController pushViewController:cp animated:YES];
                    break;
                }
                case 1: {
                    AboutViewController_iPhone *ab = [[AboutViewController_iPhone alloc] initWithNibName:@"AboutViewController_iPhone" bundle:nil];
                    [self.navigationController pushViewController:ab animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = nil;
    if (textField == self.tfLastName)
    {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    }
    if (textField == self.tfFirstName)
    {
        indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    }
    if (textField == self.tfSecondName)
    {
        indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
    }
    if (textField == self.tfAddress)
    {
        indexPath = [NSIndexPath indexPathForRow:3 inSection:1];
    }
    [self.tblProfile.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (textField == self.tfLastName)
    {
        [app.userProfile setLastName:textField.text];
        [app.userProfile storeUserDataToCloud];
    }
    if (textField == self.tfFirstName)
    {
        [app.userProfile setFirstName:textField.text];
        [app.userProfile storeUserDataToCloud];
    }
    if (textField == self.tfSecondName)
    {
        [app.userProfile setSecondName:textField.text];
        [app.userProfile storeUserDataToCloud];
    }
    if (textField == self.tfAddress)
    {
        [app.userProfile setAddress:textField.text];
        [app.userProfile storeUserDataToCloud];
    }
    return YES;
}

@end
