# CCNetwork
   CCNetwork是基于[AFNetworking]封装的iOS网络库，实现了一套高可用性API,提供了更高层次的网络访问抽象。

# CCNetwork提供了哪些功能
## 相比AFNetworking,CCNetwork提供了以下更高级的功能：
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

# 哪些项目适合使用CCNetwork
    CCNetwork适合一些稍复杂的项目使用，不太适合轻量级的个人小项目。
    如果项目中需要缓存网络请求，管理多个网络请求之间的依赖，希望检查服务器返回数据的合法性，那么CCNetwork将会得心应手给你搭建网络请求服务带来很大帮助.如果缓存的网络请求内容需要依赖特定版本号过期，那么CCNetwork将能发挥它最大的优势。当然如果说它有什么不好，那就是你的项目非常简单，使用CCNetwork反而没有直接用AFNetworking将请求逻辑写在Controller中方便，所以简单的项目并不很适合使用CCNetwork。
    
# 如何集成到你的项目里
    目前还没有支持pod，你可以直接找到“CCNetwork”文件夹，并将其中所有的内容拷贝，直接加入到你的项目中即可，注意CCNetwork是基于AFNetworking的封装，依赖AFNetworking 3.0+的版本。
    
# 作者
    ====
    CCNetwork的作者是[cuixinkuan](https://github.com/cuixinkuan)
    
# 感谢
    ====
    CCNetwork是基于AFNetworking进行开发的，网络批量请求和依赖请求的设计思想参考了YTKNetwork的设计思路，感谢他们对开源社区做出的贡献。
