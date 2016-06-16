//
//  Constants.h
//  oZhihuDaily
//
//  Created by Hu Lizhen on 6/2/16.
//  Copyright © 2016 hulz. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

static NSString * const LaunchImageURL          = @"http://news-at.zhihu.com/api/4/start-image/%@";
static NSString * const AppVersionURL           = @"http://news-at.zhihu.com/api/4/version/ios/%@";
static NSString * const LatestStoriesURL        = @"http://news-at.zhihu.com/api/4/news/latest";
static NSString * const StoryContentsURL        = @"http://news-at.zhihu.com/api/4/news/%@";
static NSString * const BeforeStoriesURL        = @"http://news.at.zhihu.com/api/4/news/before/%@";
static NSString * const ExtraStoriesURL         = @"http://news-at.zhihu.com/api/4/story-extra/%@";
static NSString * const LongCommentsURL         = @"http://news-at.zhihu.com/api/4/story/%@/long-comments";
static NSString * const ShortCommentsURL        = @"http://news-at.zhihu.com/api/4/story/%@/short-comments";
static NSString * const StoryThemesURL          = @"http://news-at.zhihu.com/api/4/themes";
static NSString * const StoryThemeContentsURL   = @"http://news-at.zhihu.com/api/4/theme/%@";
static NSString * const HotStorysURL            = @"http://news-at.zhihu.com/api/3/news/hot";
static NSString * const StorySectionsURL        = @"http://news-at.zhihu.com/api/3/sections";
static NSString * const StorySectionContentsURL = @"http://news-at.zhihu.com/api/3/section/%@";
static NSString * const StoryRecommendersURL    = @"http://news-at.zhihu.com/api/4/story/%@/recommenders";
static NSString * const StoryInThemeURL         = @"http://news-at.zhihu.com/api/4/theme/%@/before/%@";
static NSString * const EditorProfileURL        = @"http://news-at.zhihu.com/api/4/editor/%@/profile-page/ios";

static float const TableHeaderViewHeightMin = 220;
static float const TableHeaderViewHeightMax = 320;
static float const StoryCellRowHeight       = 92;


#endif /* Constants_h */
