//
//  DocumentPickerViewController.m
//  MKDocumentProviderDemo
//
//  Created by DONLINKS on 16/6/28.
//  Copyright © 2016年 Donlinks. All rights reserved.
//

#import "DocumentPickerViewController.h"

#define APP_GROUP_ID @"group.com.donlinks.MKDocumentProvider"
#define APP_FILE_NAME @"MKFile"

#define CellIdentifier @"cellIde"

@interface DocumentPickerViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation DocumentPickerViewController
{
    NSArray<NSString *> *fileNamesArray;
    NSString *storagePath;
    
    __weak IBOutlet UITableView *itemsTableView;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [itemsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    itemsTableView.backgroundColor = [UIColor whiteColor];
}

- (void)loadData{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    storagePath = [[self.documentStorageURL path] stringByAppendingPathComponent:APP_FILE_NAME];
    fileNamesArray = [fileMgr contentsOfDirectoryAtPath:storagePath error:nil];
    [itemsTableView reloadData];
}

-(void)prepareForPresentationInMode:(UIDocumentPickerMode)mode {
    // TODO: present a view controller appropriate for picker mode here
    
    switch (mode) {
        case UIDocumentPickerModeImport:
        {
            self.navigationItem.title = @"请选择导入文件";
        }
            break;
        case UIDocumentPickerModeOpen:
        {
            self.navigationItem.title = @"请选择打开文件";
        }
            break;
            
        case UIDocumentPickerModeExportToService:
        {
            self.navigationItem.title = @"导出文件";
        }
            break;
            
        default:
            break;
    }
    
    [self loadData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return fileNamesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text = fileNamesArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.documentPickerMode == UIDocumentPickerModeExportToService ||
       self.documentPickerMode == UIDocumentPickerModeMoveToService){
        return;
    }
//    NSString *filePath = [storagePath stringByAppendingPathComponent: @"fileNotExist.txt"];
    NSString *filePath = [storagePath stringByAppendingPathComponent: fileNamesArray[indexPath.row]];
    NSURL *fileURL = [NSURL fileURLWithPath: filePath];
    [self dismissGrantingAccessToURL: fileURL];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(self.documentPickerMode == UIDocumentPickerModeExportToService){
        UIView *tableFootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        UIButton *btn = [[UIButton alloc] initWithFrame:tableFootView.bounds];
        [btn setTitle:@"导出到这里" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(exportFile) forControlEvents:UIControlEventTouchUpInside];
        [tableFootView addSubview:btn];
        return tableFootView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 44;
}

#pragma mark - exportFile
- (void)exportFile
{
    NSURL *originalURL = self.originalURL;
    NSString *fileName = [originalURL lastPathComponent];
    NSString *exportFilePath = [storagePath stringByAppendingPathComponent: fileName];
    
    BOOL access = [originalURL startAccessingSecurityScopedResource]; 
    if(access){
        NSFileCoordinator *fileCoordinator = [NSFileCoordinator new];
        NSError *error = nil;
        [fileCoordinator coordinateReadingItemAtURL:originalURL options:NSFileCoordinatorReadingWithoutChanges error:&error byAccessor:^(NSURL * _Nonnull newURL) {
            
            NSData *data = [NSData dataWithContentsOfURL: newURL];
            NSString *fileCont = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if([fileCont writeToFile:exportFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil]){
                [self dismissGrantingAccessToURL: [NSURL fileURLWithPath:exportFilePath]];
            }else{
                NSLog(@"保存失败");
            }
        }];
        
    }
    
    [originalURL stopAccessingSecurityScopedResource];
}

@end
