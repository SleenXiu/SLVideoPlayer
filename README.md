## 一个简单的播放器

- 使用

```
    SLVideoPlayer *player = [[SLVideoPlayer alloc] init];
    player.frame = CGRectMake((self.view.frame.size.width-320)*0.5, 200, 320, 240);
    [self.view addSubview:player];
    [player playVideoWithStr:@"https://video.deeppp.com/7325faf9ca1b483f7c111986f2764a68"];
```
- TODO
 
 - 全屏顶部nav返回 ☆
 - 弱网提示 ☆
 - 弹幕支持 ☆☆☆
 - 等