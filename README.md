# CCNetwork

## CCNetwork是什么
CCNetwork是基于 [AFNetworking](https://github.com/AFNetworking/AFNetworking) 封装的iOS网络库，实现了一套高可用性API,提供了更高层次的网络访问抽象。

## CCNetwork提供了哪些功能
### 相比AFNetworking,CCNetwork提供了以下更高级的功能：
* 支持按时间缓存网络请求内容
* 支持按版本号缓存网络请求内容
* 支持统一设置服务器和CDN的地址
* 支持检查返回JSON内容的合法性
* 支持文件的断点续传
* 支持 block 和 delegate 两种模式的回调方式
* 支持批量的网络请求发送，并统一设置它们的回调(在CCBatchRequest类中查看详情)
* 支持设置有相互依赖的网络请求的发送，例如：发送请求A,根据请求A的返回结果，选择性的发送请求B和请求C，再根据其结果选择性的发送请求D，以此类推(在CCChainRequest类中查看详情)
* 支持网络请求URL的Filter，可以统一为网络请求加上一些参数或者修改一些路径
* 可自定义插件机制，方便的为CCNetwork添加功能，比如在网络请求发起时，给界面添加“正在加载...”的HUD等

## 哪些项目适合使用CCNetwork
CCNetwork是笔者为了替换东方航空iOS客户端底层网络库而设计编写的。主要是为了满足东航App对复杂业务网络请求的执行效率和质量的要求，在它所涉及需要的网络层管理需求之上进行了扩展。所以CCNetwork适合一些稍复杂的项目使用，不太适合轻量级的个人小项目。

如果项目中需要缓存网络请求，管理多个网络请求之间的依赖，希望检查服务器返回数据的合法性，那么CCNetwork将会得心应手给你搭建网络请求服务带来很大帮助.如果缓存的网络请求内容需要依赖特定版本号过期，那么CCNetwork将能发挥它最大的优势。当然如果说它有什么不好，那就是你的项目非常简单，使用CCNetwork反而没有直接用AFNetworking将请求逻辑写在Controller中方便，所以简单的项目并不很适合使用CCNetwork。
    
## CCNetwork的设计思想
基本思想是把每一个网络请求封装成对象。所以使用CCNetwork，你的每一个请求都需要继承CCRequest类，通过覆盖父类的一些方法来构造指定的网络请求。

把每一个网络请求封装成对象实际上是使用了设计模式中的Command模式，它有一下优点：
* 将网络请求与具体的第三方依赖库隔离，方便以后更换底层网络库。东航App最初是基于ASIHttpRequest设计的网络层，使用CCNetwork，只需要很短的时间就可以轻松切换到AFNetworking。
* 方便在基类处理公共逻辑，例如版本号信息、CDN地址等就可以在基类中处理。
* 方便在基类中处理缓存逻辑和和其他一些公共逻辑。
* 方便做对象的持久化。
    
## 如何集成到你的项目里
目前还没有支持pod，你可以直接找到“CCNetwork”文件夹，并将其中所有的内容拷贝，直接加入到你的项目中，在需要使用的类头部引入 #import "CCNetwork.h" 头文件即可。注意CCNetwork是基于AFNetworking的封装，依赖 AFNetworking 3.0 + 的版本
    
## 使用说明
CCNetwork包含以下几个基本的类：

- CCNetworkConfig类：用于统一设置网络请求的服务器和 CDN 的地址。

- CCRequest 类：所有的网络请求类需要继承于 CCRequest 类，每一个 CCRequest 类的子类代表一种专门的网络请求。

具体的用法是，在程序刚启动的回调中，设置好 CCNetworkConfig 的信息，如下所示：
### CCNetworkConfig 类
```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
// Override point for customization after application launch.
CCNetworkConfig * config = [CCNetworkConfig sharedConfig];
config.baseUrl = @"http://ceair.com";
config.cdnUrl = @"http://****";
[self setupRequestFilters];
return YES;
}
```
设置好之后，所有的网络请求都会默认使用 CCNetworkConfig 中 baseUrl 参数指定的地址。
大部分企业应用都需要对一些静态资源（例如图片、js、css）使用 CDN。CCNetworkConfig 的 cdnUrl 参数用于统一设置这一部分网络请求的地址。
当需要切换服务器地址时，只需要修改 CCNetworkConfig 中的 baseUrl 和 cdnUrl 参数即可。
### CCRequest 类
CCRequest 的基本的思想是把每一个网络请求封装成对象。
每一种网络请求继承 CCRequest 类后，需要用方法覆盖（overwrite）的方式，来指定网络请求的具体信息。如下是一个示例：
假如我们要向网址 http://www.ceair.com/iphone/register 发送一个 POST 请求，请求参数是 username 和 password。那么，这个类应该如下所示：
```objective-c
// RegisterApi.h
#import "CCRequest.h
@interface RegisterApi : CCRequest
- (id)initWithUsername:(NSString *)username password:(NSString *)password;
- (NSString *)userId;
@end

// RegisterApi.m
@implementation RegisterApi {
NSString * _username;
NSString * _password;
}
- (id)initWithUsername:(NSString *)username password:(NSString *)password {
if (self = [super init]) {
_username = username;
_password = password;
}
return self;
}

- (NSString *)userId {
return [[[self responseJSONObject] objectForKey:@"userId"] stringValue];
}

#pragma mark - others -
- (CCRequestMethod)requestMethod {
return CCRequestMethodPOST;
}

- (NSString *)requestUrl {
return @"/iphone/register";
}

- (id)requestArgument {
return @{
@"username":_username,
@"password":_password
};
}

- (id)jsonValidator {
return @{
@"userId":[NSNumber class],
@"nick":[NSString class],
@"level":[NSNumber class]
};
}

@end
```
在上面这个示例中可以看到：

通过覆盖 CCRequest 类的 requestUrl 方法，实现了指定网址信息。并且只需要指定除去域名剩余的网址信息，因为域名信息在 CCNetworkConfig 中已经设置过了。

通过覆盖 CCRequest 类的 requestMethod 方法，实现了指定 POST 方法来传递参数。

通过覆盖 CCRequest 类的 requestArgument 方法，提供了 POST 的信息。这里面的参数 username 和 password 如果有一些特殊字符（如中文或空格），也会被自动编码。

### 调用RegisterApi
在构造完成 RegisterApi 之后，具体如何使用呢？可以在登录的ViewController中，调用RegisterApi，并用 block 的方式来取得网络请求结果：
```objective-c
RegisterApi * api = [[RegisterApi alloc] initWithUsername:@"username**" password:@"password**"];
[api startWithCompletionBlockWithSuccess:^(__kindof CCBaseRequest * _Nonnull request) {
// 你可以直接在这里使用self
} failure:^(__kindof CCBaseRequest * _Nonnull request) {
// 你可以直接在这里使用self
}];
```
注意：你可以直接在 block 回调中使用 self，不用担心循环引用。因为 CCRequest 会在执行完 block 回调之后，将相应的 block 设置成 nil。从而打破循环引用。除了 block 的回调方式外，CCRequest 也支持 delegate 方式的回调。
### 验证服务器返回内容
有些时候由于服务器的Bug，会造成服务器返回一些不合法的数据，如果盲目地信任这些数据可能会造成客户端crash。如果加入大量的验证代码，又使得编程体力活增加，费时费力。
    使用 CCRequest的验证服务器返回值功能，可以很大程度上节省验证代码的编写时间。
例如，我们要向网址 http://www.ceair.com/iphone/users 发送一个 GET 请求，请求参数是 userId 。我们想获得某一个用户的信息，包括他的昵称和等级，我们需要服务器必须返回昵称（字符串类型）和等级信息（数值类型），则可以覆盖 jsonValidator 方法，实现简单的验证。
```objective-c
- (id)jsonValidator {
return @{
@"nick":[NSString class],
@"level":[NSNumber class]
};
}
```
### 使用CDN地址
如果要使用CDN地址，只需要覆盖 CCRequest 类的 -(BOOL)useCDN; 方法。
例如我们有一个取图片的接口，则我们可以这么写代码：
```objective-c
// GetImageApi.h
#import "CCRequest.h"
@interface GetImageApi : CCRequest
- (id)initWithImageId:(NSString *)imageId;
@end

// GetImageApi.m
#import "GetImageApi.m"
@implementation GetImageApi {
NSString * _imageId;
}

- (id)initWithImageId:(NSString *)imageId {
if (self = [super init]) {
_imageId = imageId;
}
return self;
}

#pragma mark - others -
- (BOOL)useCDN {
return YES;
}

- (NSString *)requestUrl {
return [NSString stringWithFormat:@"/iphone/images/%@",_imageId];
}

@end
```
### 断点续传
要启动断点续传功能，只需要覆盖 resumableDownloadPath 方法，指定断点续传时文件的存储路径即可，文件会被自动保存到此路径。如下代码将刚刚的取图片的接口改造成了支持断点续传：
```objective-c
- (NSString *)resumableDownloadPath {
NSString * libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
NSString * cachePath = [libPath stringByAppendingPathComponent:@"Caches"];
NSString * filePath = [cachePath stringByAppendingPathComponent:_imageId];
return filePath;
}
```
### 按时间缓存内容
想像这样一个场景，假设你在完成一个类似微博的客户端，GetUserInfoApi 用于获得你的某一个好友的资料，因为好友并不会那么频繁地更改昵称，那么短时间内频繁地调用这个接口很可能每次都返回同样的内容，所以我们可以给这个接口加一个缓存。
在如下示例中，通过覆盖 cacheTimeInSeconds 方法，给 GetUserInfoApi 增加了一个 3 分钟的缓存，3 分钟内调用调 Api 的 start 方法，实际上并不会发送真正的请求。
```objective-c
#import "GetUserInfoApi.h"

@implementation GetUserInfoApi {
NSString * _userId;
}

- (id)initWithUserId:(NSString *)userId {
if (self = [super init]) {
_userId = userId;
}
return self;
}

#pragma mark - others -
- (NSString *)requestUrl {
return @"/iphone/users";
}

- (id)requestArgument {
return @{@"id":_userId};
}

- (id)jsonValidator {
return @{
@"nick":[NSString class],
@"level":[NSNumber class]
};
}

- (NSInteger)cacheTimeInSeconds {
return 60 * 3;
}

@end
```
该缓存逻辑对上层是透明的，所以上层可以不用考虑缓存逻辑，每次调用 GetUserInfoApi 的 start 方法即可。GetUserInfoApi 只有在缓存过期时，才会真正地发送网络请求。
### 高级用法
CCNetwork还提供了一下两个类：
· CCBatchRequest 用以方便的发送批量请求。
· CCChainRequest 用以管理有相互依赖的网络请求。
```objective-c
// send batch request
- (void)sendBatchRequest {
GetImageApi * a = [[GetImageApi alloc] initWithImageId:@"1.jpg"];
GetImageApi * b = [[GetImageApi alloc] initWithImageId:@"2.jpg"];
GetImageApi * c = [[GetImageApi alloc] initWithImageId:@"3.jpg"];
GetUserInfoApi * d = [[GetUserInfoApi alloc] initWithUserId:@"123"];
CCBatchRequest * batchRequest = [[CCBatchRequest alloc] initWithRequestArray:@[a,b,c,d]];
[batchRequest startWithCompletionBlockWithSuccess:^(CCBatchRequest * _Nonnull batchRequest) {
NSLog(@"--------> Sucess");
NSArray * requests = batchRequest.requestArray;
GetImageApi * a = (GetImageApi *)requests[0];
//....
NSLog(@"--------> %@",a);
// deal with requests result ...
} failure:^(CCBatchRequest * _Nonnull batchRequest) {
NSLog(@"--------> Failed");
}];
}

// send chain request
- (void)sendChainRequest {
RegisterApi * reg = [[RegisterApi alloc] initWithUsername:@"username" password:@"password"];
CCChainRequest * chainReq = [[CCChainRequest alloc] init];
[chainReq addRequest:reg callback:^(CCChainRequest * _Nonnull chainRequest, CCBaseRequest * _Nonnull baseRequest) {
RegisterApi * result = (RegisterApi *)baseRequest;
NSString * userId = [result userId];
GetUserInfoApi * api = [[GetUserInfoApi alloc] initWithUserId:userId];
[chainRequest addRequest:api callback:nil];
}];
chainReq.delegate = self;
// start to send request
[chainReq start];
}
```
还可以定制网络请求的 HeaderField：
- 通过覆盖requestHeaderFieldValueDictionary方法返回一个dictionary对象来自定义请求的HeaderField，返回的dictionary，其key即为HeaderField的keyvalue为HeaderField的Value，需要注意的是key和value都必须为string对象。
    还可以定制 buildCustomUrlRequest：
- 通过覆盖buildCustomUrlRequest方法，返回一个NSURLRequest对象来达到完全自定义请求的需求。该方法定义在 CCBaseRequest类
### 相关Demo
以上功能所涉及的类和用法可参见 [CCNetworkDemo](https://github.com/cuixinkuan/CCNetworkDemo)
    
## 作者
CCNetwork的作者是 [cuixinkuan](https://github.com/cuixinkuan)
    
## 感谢
CCNetwork是基于AFNetworking进行开发的，网络批量请求和依赖请求的设计思想参考了YTKNetwork的设计思路，感谢他们对开源社区做出的贡献。
