//
//  NumberPadViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 24.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "NumberPadViewController_iPhone.h"

@interface NumberPadViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UIButton *btnNumPad0;
@property (nonatomic, retain) IBOutlet UIButton *btnNumPad1;
@property (nonatomic, retain) IBOutlet UIButton *btnNumPad2;
@property (nonatomic, retain) IBOutlet UIButton *btnNumPad3;
@property (nonatomic, retain) IBOutlet UIButton *btnNumPad4;
@property (nonatomic, retain) IBOutlet UIButton *btnNumPad5;
@property (nonatomic, retain) IBOutlet UIButton *btnNumPad6;
@property (nonatomic, retain) IBOutlet UIButton *btnNumPad7;
@property (nonatomic, retain) IBOutlet UIButton *btnNumPad8;
@property (nonatomic, retain) IBOutlet UIButton *btnNumPad9;
@property (nonatomic, retain) IBOutlet UIButton *btnNumPadOK;
@property (nonatomic, retain) IBOutlet UIButton *btnNumPadDelete;

@end

@implementation NumberPadViewController_iPhone

@synthesize btnNumPad0 = _btnNumPad0;
@synthesize btnNumPad1 = _btnNumPad1;
@synthesize btnNumPad2 = _btnNumPad2;
@synthesize btnNumPad3 = _btnNumPad3;
@synthesize btnNumPad4 = _btnNumPad4;
@synthesize btnNumPad5 = _btnNumPad5;
@synthesize btnNumPad6 = _btnNumPad6;
@synthesize btnNumPad7 = _btnNumPad7;
@synthesize btnNumPad8 = _btnNumPad8;
@synthesize btnNumPad9 = _btnNumPad9;
@synthesize btnNumPadOK = _btnNumPadOK;
@synthesize btnNumPadDelete = _btnNumPadDelete;

@synthesize textField = _textField;
@synthesize target = _target;
@synthesize action = _action;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)addCharacter:(NSString *)character
{
    if (!self.textField) return;
    
    UITextPosition *beginning = self.textField.beginningOfDocument;
    UITextRange *textRange = self.textField.selectedTextRange;
    UITextPosition *selectionStart = textRange.start;
    UITextPosition *selectionEnd = textRange.end;
    NSInteger location = [self.textField offsetFromPosition:beginning toPosition:selectionStart];
    NSInteger length = [self.textField offsetFromPosition:selectionStart toPosition:selectionEnd];
    NSRange selectedRange = NSMakeRange(location,length);
    
    if (self.textField.delegate && [self.textField.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        if ([self.textField.delegate textField:self.textField shouldChangeCharactersInRange:selectedRange replacementString:character]) {
            self.textField.text = [self.textField.text stringByReplacingCharactersInRange:selectedRange withString:character];
            UITextPosition *newPosition = [self.textField positionFromPosition:selectionStart inDirection:UITextLayoutDirectionRight offset:length + [character length]];
            UITextRange *newRange = [self.textField textRangeFromPosition:newPosition toPosition:newPosition];
            [self.textField setSelectedTextRange:newRange];
        }
    } else {
        NSString *str = [self.textField.text stringByReplacingCharactersInRange:selectedRange withString:character];
        UITextRange *prevTextRange = [self.textField selectedTextRange];
        NSUInteger offset = [character isEqualToString:@""] ? -1 : selectedRange.length + 1;
        self.textField.text = str;
        UITextPosition *cursorPosition = [self.textField positionFromPosition:prevTextRange.start offset:offset];
        [self.textField setSelectedTextRange:[self.textField textRangeFromPosition:cursorPosition toPosition:cursorPosition]];
    }
}

- (IBAction)btnNumPad0_Click:(id)sender
{
    [self addCharacter:@"0"];
}

- (IBAction)btnNumPad1_Click:(id)sender
{
    [self addCharacter:@"1"];
}

- (IBAction)btnNumPad2_Click:(id)sender
{
    [self addCharacter:@"2"];
}

- (IBAction)btnNumPad3_Click:(id)sender
{
    [self addCharacter:@"3"];
}

- (IBAction)btnNumPad4_Click:(id)sender
{
    [self addCharacter:@"4"];
}

- (IBAction)btnNumPad5_Click:(id)sender
{
    [self addCharacter:@"5"];
}

- (IBAction)btnNumPad6_Click:(id)sender
{
    [self addCharacter:@"6"];
}

- (IBAction)btnNumPad7_Click:(id)sender
{
    [self addCharacter:@"7"];
}

- (IBAction)btnNumPad8_Click:(id)sender
{
    [self addCharacter:@"8"];
}

- (IBAction)btnNumPad9_Click:(id)sender
{
    [self addCharacter:@"9"];
}

- (IBAction)btnNumPadOK_Click:(id)sender
{
    if (self.target && self.action && [self.target respondsToSelector:self.action])
    {
        [self.target performSelector:self.action withObject:sender];
        return;
    }
    if (self.textField)
        [self.textField resignFirstResponder];
}

- (IBAction)btnNumPadDelete_Click:(id)sender
{
    if (!self.textField) return;
    
    UITextPosition *beginning = self.textField.beginningOfDocument;
    UITextRange *textRange = self.textField.selectedTextRange;
    UITextPosition *selectionStart = textRange.start;
    UITextPosition *selectionEnd = textRange.end;
    NSInteger location = [self.textField offsetFromPosition:beginning toPosition:selectionStart];
    NSInteger length = [self.textField offsetFromPosition:selectionStart toPosition:selectionEnd];
    if (location - 1 < 0) return;
    NSRange selectedRange = NSMakeRange(location-1,length + 1);

    if (self.textField.delegate && [self.textField.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        if ([self.textField.delegate textField:self.textField shouldChangeCharactersInRange:selectedRange replacementString:@""]) {
            self.textField.text = [self.textField.text stringByReplacingCharactersInRange:selectedRange withString:@""];
            UITextPosition *newPosition = [self.textField positionFromPosition:selectionStart inDirection:UITextLayoutDirectionLeft offset:1];
            UITextRange *newRange = [self.textField textRangeFromPosition:newPosition toPosition:newPosition];
            [self.textField setSelectedTextRange:newRange];
        }
    }
}

@end
