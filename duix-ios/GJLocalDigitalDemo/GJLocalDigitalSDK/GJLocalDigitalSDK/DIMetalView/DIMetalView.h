//
//  DIMetalView.h
//  Digital
//
//  Created by guiji on 2023/11/17.
//

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
@interface DIMetalView : UIView
- (void)renderWithUInt8:(UInt8*)mat_uint8 :(UInt8*)maskMat_uint8 :(UInt8*)bfgMat_uint8 :(UInt8*)bbgMat_unit8 :(int)width :(int)height;
- (void)renderWithMatUInt8:(UInt8*)mat_uint8 :(int)width :(int)height;
- (void)renderWithCVMat:(cv::Mat)mat :(cv::Mat)maskMat :(cv::Mat)bfgMat :(cv::Mat)bbgMat;
- (void)renderWithSimCVMat:(cv::Mat)mat;
-(float)getMetalHeight;
@end


