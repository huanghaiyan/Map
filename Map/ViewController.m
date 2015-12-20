//
//  ViewController.m
//  Map
//
//  Created by huanghy on 15/12/18.
//  Copyright © 2015年 huanghy. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>//引用Search包头文件

#define APIKey     @"4a6eaaa29ee29fb73ca6cc15a20afac4"

@interface ViewController ()<MAMapViewDelegate,AMapSearchDelegate>//用户经纬度变量、search变量，实现AMapSearchDelegate
{
    MAMapView *_mapView;
    AMapSearchAPI *_search;
    CLLocation *_currentLocation;
    UIButton *_locationButton;
}
@end

@implementation ViewController

-(void)initController
{
    _locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _locationButton.frame = CGRectMake(20, CGRectGetHeight(_mapView.bounds) - 80, 40, 40);
    _locationButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    _locationButton.backgroundColor = [UIColor whiteColor];
    _locationButton.layer.cornerRadius = 5;
    
    [_locationButton addTarget:self action:@selector(locationAction) forControlEvents:UIControlEventTouchUpInside];
    [_locationButton setImage:[UIImage imageNamed:@"default_navi_continue_arrow_normal"] forState:UIControlStateNormal];
    
    [_mapView addSubview:_locationButton];
}

#pragma mark - search初始化
-(void)initSearch
{
    [AMapSearchServices sharedServices].apiKey = APIKey;
    _search = [[AMapSearchAPI alloc]init];
    _search.delegate = self;
    
    
}

-(void)locationAction
{
    if (_mapView.userTrackingMode != MAUserTrackingModeFollow) {
        [_mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
    }
}

#pragma mark - 获取当前用户经纬度；使用mapView的回调方法
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    NSLog(@"userlocation:%@",userLocation.location);
    _currentLocation = [userLocation.location copy];
}

-(void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    //选中定位annotation的时候进行逆地理编码查询
    if ([view.annotation isKindOfClass:[MAUserLocation class]]) {
        [self reGeoAction];
    }
    
}

#pragma mark -逆地理编码 发起搜索请求
-(void)reGeoAction
{
    if (_currentLocation) {
        AMapReGeocodeSearchRequest *request = [[AMapReGeocodeSearchRequest alloc]init];
        request.location = [AMapGeoPoint locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];
        [_search AMapReGoecodeSearch:request];
    }
    
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"request:%@,error:%@",request,error);
}

-(void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    NSLog(@"response:%@",response);
    NSString *title = response.regeocode.addressComponent.city;
    if (title.length == 0) {
        title = response.regeocode.addressComponent.province;
    }
    _mapView.userLocation.title = title;
    _mapView.userLocation.subtitle = response.regeocode.formattedAddress;
}


-(void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated
{
    //修改定位按钮状态
    if (mode == MAUserTrackingModeNone) {
        [_locationButton setImage:[UIImage imageNamed:@"default_navi_continue_arrow_normal"] forState:UIControlStateNormal];
    }else if(mode == MAUserTrackingModeFollow){
        [_locationButton setImage:[UIImage imageNamed:@"default_navi_setting_carfrontup"] forState:UIControlStateNormal];
    }else{
         [_locationButton setImage:[UIImage imageNamed:@"default_navi_setting_carPlateState"] forState:UIControlStateNormal];
    }
}

-(void)initMapView
{
    //设置APIKey
    [MAMapServices sharedServices].apiKey = APIKey;
    //初始化地图
    _mapView = [[MAMapView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    //设置地图的delegate
    _mapView.delegate = self;
    //设置地图两个附件的位置
    _mapView.compassOrigin = CGPointMake(_mapView.compassOrigin.x, 22);
    _mapView.scaleOrigin = CGPointMake(_mapView.scaleOrigin.x, 22);
    _mapView.showsUserLocation = YES;
    _mapView.mapType = MAMapTypeSatellite;
    [self.view addSubview:_mapView];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initMapView];
    [self initSearch];
    [self initController];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
