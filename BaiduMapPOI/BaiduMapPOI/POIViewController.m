//
//  POIViewController.m
//  BaiduMapPOI
//
//  Created by 戴明亮 on 17/4/10.
//  Copyright © 2017年 戴明亮. All rights reserved.
//
/*
 int latitudeE6;		///< 纬度，乘以1e6之后的值
	int longitudeE6;	///< 经度，乘以1e6之后的值
 */

#import "POIViewController.h"
#import "ResultTableViewController.h"
#import "POIViewControllerCell.h"
#import "DMBMKPoiInfo.h"


@interface POIViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UISearchResultsUpdating,UISearchControllerDelegate,BMKMapViewDelegate, BMKPoiSearchDelegate,BMKGeoCodeSearchDelegate>{
    UISearchController *_searchController;
    IBOutlet BMKMapView* _mapView;
    BMKPoiSearch* _poisearch;
    //  反地理编码
    BMKGeoCodeSearch* _geocodesearch;
    NSString *_cityText;
    NSString *_keyText;
    NSString *_coordinateLat;
    NSString *_coordinateLong;
    // 地图中心点的标记
    UIImageView *_centerViMaker;
    BMKReverseGeoCodeOption *_geo;
    BMKNearbySearchOption *_citySearchOption;
    int curPage;
    BMKCircle* circle;
}
@property (weak, nonatomic) IBOutlet UIView *viewHandle;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *button_Total;
@property (weak, nonatomic) IBOutlet UIButton *button_Floor;
@property (weak, nonatomic) IBOutlet UIButton *button_Plot;
@property (weak, nonatomic) IBOutlet UIButton *button_School;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger lastBtnTag;
@property (nonatomic, strong) UIView *navTitleView;
@property (nonatomic, assign) CGRect recgodSearchBarFrame;
@property (nonatomic, copy) void (^Resultblock)();
@property (nonatomic, strong) NSMutableArray *resultDataArray;
@property (nonatomic, assign) BOOL isClickSearch;
@end

@implementation POIViewController


- (NSMutableArray *)resultDataArray
{
    if (!_resultDataArray) {
        _resultDataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _resultDataArray;
}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isClickSearch = NO;
    //self.automaticallyAdjustsScrollViewInsets = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"POIViewControllerCell" bundle:nil] forCellReuseIdentifier:@"cellId"];
    [self setupUI];
    _lastBtnTag = 10;
    //[self automaticSearch];
    [self startLocation];
    
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){0, 0};
    if (_coordinateLat != nil && _coordinateLong != nil) {
        pt = (CLLocationCoordinate2D){[_coordinateLat floatValue], [_coordinateLong floatValue]};
        [self automaticSearch:pt];
    }
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 300;
   //
    // 开始地理编码
    [self reverseGeocode];
}


-(void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    // 更新用户位置
    [_mapView updateLocationData:_UserLocation];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _poisearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _geocodesearch.delegate = self; // 不用时，置nil
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _poisearch.delegate = nil; // 不用时，置nil
    _geocodesearch.delegate = nil; // 不用时，置nil
}
- (void)dealloc {
    if (_poisearch != nil) {
        _poisearch = nil;
    }
    if (_mapView) {
        _mapView = nil;
    }
}




/**
 地理编码
 */
- (void)initGeocode{
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
}


/**
 反地理编码
 */
- (void)reverseGeocode
{
   // _geo.reverseGeoPoint = _mapView.getMapStatus.targetGeoPt;
    //mapStatus.targetGeoPt;
    // 经度
//    NSString *longitude = @"116.403981";
    // 纬度
//    NSString *latitude = @"39.915101";
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){0, 0};
    if (_coordinateLat != nil && _coordinateLong != nil) {
        pt = (CLLocationCoordinate2D){[_coordinateLat floatValue], [_coordinateLong floatValue]};
    }
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    _geo = reverseGeocodeSearchOption;
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
}


/**
 开始定位
 */
- (void)startLocation
{
   
    // 更新用户位置
    [_mapView updateLocationData:_UserLocation];
    //_mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层

   
}

/**
 // 周边云检索参数信息类搜索中心点坐标周围的POI
 */
- (void)automaticSearch:(CLLocationCoordinate2D)location
{
    curPage = 0;
    BMKNearbySearchOption *nearbyOption = [[BMKNearbySearchOption alloc]init];
    _citySearchOption = nearbyOption;
    // 中心点
    nearbyOption.location = location;
    nearbyOption.pageCapacity = 50;
    nearbyOption.pageIndex = curPage;
    // // 搜索半径
    nearbyOption.radius = 100000;
    // 搜索结果排序
    nearbyOption.sortType = 1;
//    citySearchOption.city= _cityText;
    nearbyOption.keyword = _keyText;
    BOOL flag = [_poisearch poiSearchNearBy:nearbyOption];
    if(flag)
    {
        
        NSLog(@"城市内范围检索发送成功");
    }
    else
    {
        
        NSLog(@"城市内范围检索发送失败");
    }
    
}



/**
 城市内检索 暂时不用
 */
- (void)automaticSearch
{
    curPage = 0;
    BMKCitySearchOption *citySearchOption = [[BMKCitySearchOption alloc]init];
    
    citySearchOption.pageIndex = curPage;
    citySearchOption.pageCapacity = 50;
    citySearchOption.city= _cityText;
    citySearchOption.keyword = _keyText;
    BOOL flag = [_poisearch poiSearchInCity:citySearchOption];
    if(flag)
    {
        
        NSLog(@"城市内检索发送成功");
    }
    else
    {
      
        NSLog(@"城市内检索发送失败");
    }
    
}




- (void)initCenterMarker
{
    UIImage *image = [UIImage imageNamed:@"centerMarker"];
    _centerViMaker = [[UIImageView alloc] initWithImage:image];
    _centerViMaker.bounds = CGRectMake(0, 0, _centerViMaker.image.size.width, _centerViMaker.image.size.height);
    _centerViMaker.center = CGPointMake(self.view.frame.size.width / 2, (CGRectGetHeight(_mapView.bounds)* 0.5 + _centerViMaker.image.size.height)*0.5 + 64);
    [self.view insertSubview:_centerViMaker aboveSubview:_mapView];
 
}

/**
 设置视图
 */
- (void)setupUI
{
    [self initSearch];
    [self configMap];
    [self initCenterMarker];
    [self initGeocode];
}


- (void)configMap
{
    _poisearch = [[BMKPoiSearch alloc]init];
    
    //_cityText = @"上海";
    _keyText  = @"全部";
    
    // 设置地图级别
    [_mapView setZoomLevel:13];
//    _mapView
    _mapView.isSelectedAnnotationViewFront = NO;
 
    
}


#pragma 添加内置覆盖物
//添加内置覆盖物
- (void)addOverlayView {
    // 添加圆形覆盖物
    if (circle == nil) {
        CLLocationCoordinate2D coor;
        coor.latitude = 39.915;
        coor.longitude = 116.404;
        circle = [BMKCircle circleWithCenterCoordinate:coor radius:5000];
    }
    [_mapView addOverlay:circle];
    
    
}



#pragma mark - initSearch
- (void)initSearch
{
    UIView *navTitleView = [[UIView alloc] init];
    navTitleView.backgroundColor = [UIColor clearColor];
    self.navTitleView = navTitleView;
    navTitleView.frame = CGRectMake(50, 0, [UIScreen mainScreen].bounds.size.width * 0.9, 35);
    ResultTableViewController *resultTableVC = [[ResultTableViewController alloc] init];
    
    _searchController =  [[UISearchController alloc] initWithSearchResultsController:resultTableVC];
    _searchController.searchBar.frame = CGRectMake(50, 0, navTitleView.frame.size.width - 50 - 50, 35);
    _searchController.searchBar.barStyle = UIBarStyleBlackOpaque;
    _searchController.searchBar.placeholder=@"小区/写字楼/学校等";
   
    //展示搜索结果的按钮
    //_searchController.searchBar.showsSearchResultsButton=YES;
    //设置搜索光标的颜色和取消按钮的颜色
    //_searchController.searchBar.tintColor=[UIColor redColor];
    //设置设置整个搜索框的背景颜色
    _searchController.searchBar.barTintColor=[UIColor yellowColor];
    
    //_searchController.searchBar.tintColor = [UIColor grayColor];
     //去掉searchBar的背景线条，会导致searhBar的背景失效，searchbar的颜色其实是透明出底层试图的颜色
//    NSArray *subViews = _searchController.searchBar.subviews.firstObject.subviews;
//    for (id view in subViews) {
//        if ([view isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
//            [view removeFromSuperview];
//        }
//    }
   // [_searchController.searchBar sizeToFit];
    
    // 搜索框文字输入框设置
//    UITextField *textField = [_searchController.searchBar valueForKey:@"_searchField"];
//    textField.backgroundColor = [UIColor grayColor];
//    textField.font = [UIFont systemFontOfSize:16.f];
    // 搜索框文字输入框占位文字颜色
    //[textField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
//    // 搜索框背景图片，会覆盖背景色
//    _searchController.searchBar.backgroundImage = [UIImage imageNamed:@"5"];
//    // 搜索框文字输入框边框图片
//    [_searchController.searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    
    //设置搜索结果的代理 //更新搜索结果
    _searchController.searchResultsUpdater=self;
    
    //设置搜索框的代理
    _searchController.searchBar.delegate=self;
    
    _searchController.delegate = self;
//     [_searchController.searchBar sizeToFit];
//     _searchController.searchBar.frame = _searchController.searchBar.frame;;
    // 搜索时 背景色变暗 默认是yes
    _searchController.dimsBackgroundDuringPresentation = YES;
    // 搜索时背景变模糊 默认是yes
    _searchController.obscuresBackgroundDuringPresentation = YES;
    [_searchController.searchBar setValue:@"取消" forKey:@"_cancelButtonText"];
    // 这句话一定要添加否则点击搜索的时候回导致导航栏向上移动消失
    _searchController.hidesNavigationBarDuringPresentation = NO;
    // 这个属性也必须要设置否则会出现展现结果控制器无法返回
    self.definesPresentationContext = YES;
    
   // self.navigationItem.titleView = navTitleView;

    //navTitleView;
   // navTitleView = _searchController.searchBar;
//    [navTitleView addSubview:_searchController.searchBar];
  

    self.navigationItem.titleView = _searchController.searchBar;
    NSLog(@"-----> _searchController %@",NSStringFromCGRect(_searchController.searchBar.frame));
   
    _recgodSearchBarFrame = _searchController.searchBar.frame;
}







- (IBAction)switchArea:(UIButton *)sender {
    
    
    // 取出上一个按钮
    UIButton *lastBtn =  [self.viewHandle viewWithTag:_lastBtnTag];
    [lastBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    // 设置当前按钮
    [sender setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    _lastBtnTag = sender.tag;
    _citySearchOption.keyword = sender.titleLabel.text;
    _citySearchOption.sortType = 1;
    BOOL flag = [_poisearch poiSearchNearBy:_citySearchOption];
    
    if (flag) {
        NSLog(@"检索成功");
    }else{
        NSLog(@"检索失败");
    }
    [self.tableView reloadData];
    
    
}


#pragma mark searchBar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    _isClickSearch = YES;
    //[_searchController.searchBar sizeToFit];
    //该方法只会被调用一次
    NSLog(@"搜索框已经正在开始编辑");
     NSLog(@"-----> _searchController %@",NSStringFromCGRect(_searchController.searchBar.frame));
    //_searchController.searchBar.frame = _recgodSearchBarFrame;
      NSLog(@"-----> _searchController %@",NSStringFromCGRect(_searchController.searchBar.frame));
    //需求当文本框开始编辑的时候让取消按钮变成中文的取消 改变取消按钮上的文字
    //[self performSelector:@selector(changeText) withObject:self afterDelay:0.05];
    
}


#pragma mark 改变搜索框上取消按钮上的文字
-(void)changeText
{
    //查看所有在搜索框上的子视图 寻找按钮
    
    UIView*view=[_searchController.searchBar.subviews lastObject];
     //_searchController.searchBar.frame = CGRectMake(50, 0, self.navTitleView.frame.size.width - 50 - 10, 35);
    _searchController.searchBar.frame = _recgodSearchBarFrame;
    for (UIView* subView in  view.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton*button=(UIButton*)subView;
            [button setTitle:@"取消" forState:UIControlStateNormal];
        }
  
    }

    NSLog(@"-----> _searchController %@",NSStringFromCGRect(_searchController.searchBar.frame));
     [_searchController.searchBar sizeToFit];
}

#pragma mark 搜索框结束编辑时候调用的方法
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    //该方法只会被调用一次
    _isClickSearch = NO;
    NSLog(@"搜索框已经结束编辑");
    
}
#pragma mark 单击搜索框上的陈列按钮时会被调用
- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"点击展示结果会调用的方法");
    
}
#pragma mark 点击取消按钮会调用的方法
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    
    _isClickSearch = NO;
    NSLog(@"已经点击了取消按钮");
    
}



- (void)willPresentSearchController:(UISearchController *)searchController {
    
    
}

- (void)didPresentSearchController:(UISearchController *)searchController {
  
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    _isClickSearch = NO;
}

- (void)didDismissSearchController:(UISearchController *)searchController {
   _isClickSearch = NO;
}



#pragma mark UISearchResultsUpdating 搜索框控制器的代理方法 是常用的方法 用来处理数据和逻辑的 该代理方法是必须实现的
//更新搜索结果时会调用的方法
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //将拿到的数据放到一个数组中用于显示在表上
    NSMutableArray*temp_Array=[NSMutableArray array];
    //获取文本框的内容
    NSString*contentStr=searchController.searchBar.text;
    NSLog(@"contentStr===%@",contentStr);
    
    _citySearchOption.keyword = contentStr;
    BOOL flag = [_poisearch poiSearchNearBy:_citySearchOption];
    
    if (flag) {
        NSLog(@"检索成功");
  
    }else{
        NSLog(@"检索失败");
    }
    
    __weak typeof (self)weakSelf = self;
    _Resultblock = ^(){
        for (DMBMKPoiInfo*dmInfo in weakSelf.resultDataArray) {
            //查询的关键是 看输入的内容字符在对象所保存的属性字符串中是否包含
            //rangeOfString 该方法会返回一个字符串的位置和长度如果字符串的长度不为零说明是包含的
            if([[dmInfo.name lowercaseString] rangeOfString:[searchController.searchBar.text lowercaseString]].length != 0 ||  [[dmInfo.address lowercaseString] rangeOfString:[searchController.searchBar.text lowercaseString]].length != 0)
                //将搜索的结果放在数组中
                [temp_Array addObject:dmInfo];
        }
        
        ResultTableViewController *tableVC=(ResultTableViewController*)searchController.searchResultsController; //因为在创建的时候 searchResultsController 包存了一个表的视图控制器 也是搜索控制器的一个属性
        //拿到对象后将数组得到的值传到另一张表中
        tableVC.resultArray= temp_Array;
        NSLog(@"--88->%@",tableVC.resultArray);
        //刷新表格 这里并没有切换页面 页面不需要进行跳转 这个用法比较特殊
        [tableVC.tableView reloadData];
    };
    
    
    
    
}



#pragma mark UITableViewDelegate
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    POIViewControllerCell * cell= [tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.dmInfoModel = self.dataArray[indexPath.row];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark implement BMKMapViewDelegate

//根据overlay生成对应的View
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKCircle class]])
    {
        BMKCircleView* circleView = [[BMKCircleView alloc] initWithOverlay:overlay];
        circleView.fillColor = [[UIColor alloc] initWithRed:1 green:0 blue:0 alpha:0.5];
        circleView.strokeColor = [[UIColor alloc] initWithRed:0 green:0 blue:1 alpha:0.5];
        circleView.lineWidth = 5.0;
        
        return circleView;
    }
    
   
    return nil;
}

/**
 *根据anntation生成对应的View
 
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
    // 生成重用标示identifier
    NSString *AnnotationViewID = @"xidanMark";
    
    // 检查是否有重用的缓存
    BMKAnnotationView* annotationView = [view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorRed;
        // 设置重天上掉下的效果(annotation)
        ((BMKPinAnnotationView*)annotationView).animatesDrop = YES;
    }
    
    // 设置位置
    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
    annotationView.canShowCallout = YES;
    // 设置是否可以拖拽
    annotationView.draggable = NO;
    annotationView.hidden = YES;
    annotationView.image = nil;
    return annotationView;
}
//- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
//{
//    [mapView bringSubviewToFront:view];
//    [mapView setNeedsDisplay];
//}
//- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views
//{
//    NSLog(@"didAddAnnotationViews");
//}


- (void)mapStatusDidChanged:(BMKMapView *)mapView
{
    NSLog(@"=====");
    [_mapView updateLocationData:_UserLocation];
    BMKMapStatus *mapStatus=[mapView getMapStatus];
    
    NSLog(@"缩放级别--> %f",mapStatus.fLevel);
  
    // 中心点
    
    NSLog(@"中心点坐标---> %f == %f",mapView.centerCoordinate.latitude,mapView.centerCoordinate.longitude);
    _citySearchOption.location = mapStatus.targetGeoPt;
    
    //  中心点坐标**********> 39.914884 ****** 116.403883
    // 2017-04-11 01:29:17.581 BaiduMapPOI[5636:252626] _name = 住邦2000商务楼-1号楼, _address = 八里庄西里100, _city = 北京市,
   
    NSLog(@"中心点坐标**********> %f ****** %f",mapStatus.targetScreenPt.x,mapStatus.targetScreenPt.y);
    _citySearchOption.radius = 100000;
    
    

    _citySearchOption.pageCapacity = 50;
    _citySearchOption.pageIndex = curPage;
 
    // 搜索结果排序
    _citySearchOption.sortType = 1;
   
    _citySearchOption.keyword = _keyText;
    BOOL flag = [_poisearch poiSearchNearBy:_citySearchOption];
    
    if (flag) {
        NSLog(@"检索成功");
    }else{
        NSLog(@"检索失败");
    }
    
//    BMKMapStatus *mapStatus=[mapView getMapStatus];
//    
//    _geo.reverseGeoPoint = mapStatus.targetGeoPt;
//    
//    [_geocodesearch reverseGeoCode:_geo];
    
    NSLog(@"mapStatusDidChanged");
}



#pragma mark -
#pragma mark implement BMKSearchDelegate
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult*)result errorCode:(BMKSearchErrorCode)error
{
    // 清楚屏幕中所有的annotation
    [_mapView updateLocationData:_UserLocation];
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        
       
        NSLog(@"地址--> %@",result.poiAddressInfoList);
        
        if (_isClickSearch == YES) { // 开始点击搜索
           
             [self.resultDataArray removeAllObjects];
            NSLog(@"数组的数量-> %ld",result.poiInfoList.count);
            for (BMKPoiInfo *info in result.poiInfoList) {
                
                NSLog(@"_name = %@, _address = %@, _city = %@,",info.name,info.address,info.city);
                NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
                [dictM setValue:info.name forKey:@"name"];
                [dictM setValue:info.address forKey:@"address"];
                [dictM setValue:info.city forKey:@"city"];
                DMBMKPoiInfo *dmInfoMdeol = [DMBMKPoiInfo poiInfoWithDict:dictM];
                [self.resultDataArray addObject:dmInfoMdeol];
                
            }
            if (self.resultDataArray.count) {
                if (_Resultblock) {
                    _Resultblock();
                }
            }
        }else{// 没有点击搜索
             [self.dataArray removeAllObjects];
            NSLog(@"数组的数量-> %ld",result.poiInfoList.count);
            for (BMKPoiInfo *info in result.poiInfoList) {
                
                NSLog(@"_name = %@, _address = %@, _city = %@,",info.name,info.address,info.city);
                NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
                [dictM setValue:info.name forKey:@"name"];
                [dictM setValue:info.address forKey:@"address"];
                [dictM setValue:info.city forKey:@"city"];
                DMBMKPoiInfo *dmInfoMdeol = [DMBMKPoiInfo poiInfoWithDict:dictM];
                [self.dataArray addObject:dmInfoMdeol];
                [self.tableView reloadData];
                
            }
           
        }
        
        
        
    } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        NSLog(@"起始点有歧义");
    } else {
        // 各种情况的判断。。。
    }
}


#pragma mark -- 反地理编码



-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    [_mapView updateLocationData:_UserLocation];
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == 0) {
        BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
        item.coordinate = result.location;
        item.title = result.address;
        [_mapView addAnnotation:item];
        _mapView.centerCoordinate = result.location;
        
        NSString* titleStr;
        NSString* showmeg;
        titleStr = @"反向地理编码";
        showmeg = [NSString stringWithFormat:@"%@",item.title];
        
        BMKPoiInfo *info=result.poiList[0];
        
        _cityText = result.addressDetail.city;
        
        NSLog(@"---> %@",result);
        NSLog(@"---> %@",info.name);
    }
    
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

/*
 
 - (void)willPresentSearchController:(UISearchController *)searchController {
 
 
 }
 
 - (void)didPresentSearchController:(UISearchController *)searchController {
 self.isSearching = YES;
 [self.tableView reloadSectionIndexTitles];
 [searchController.view.superview addSubview:self.shadowView];
 }
 
 - (void)willDismissSearchController:(UISearchController *)searchController {
 
 }
 
 - (void)didDismissSearchController:(UISearchController *)searchController {
 self.isSearching = NO;
 [self.tableView reloadSectionIndexTitles];
 }
 
 // 修改searchBar取消按钮的字体大小
 - (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
 searchBar.showsCancelButton = YES;
 for (UIView *view in [[searchBar.subviews lastObject] subviews]) {
 if ([view isKindOfClass:[UIButton class]]) {
 UIButton *cancelBtn = (UIButton *)view;
 cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
 }
 }
 }

*/

@end
