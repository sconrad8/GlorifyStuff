# Submission

**[Instructions](./README.md) Summary**:
* Refactor the prototype to adopt 1 to 2 Glorify practices
* Elaborate on your thought process in SUBMISSION.md

## Your Response

### Which aspects of the codebase did you choose to work on and why?

I chose to work on improving the architecture of the Blog Post Detail Screen to follow the MVVM pattern along with refactoring the UI to be built programatically. I chose this because architecture and UI layout is extrememly import to ensure app features are easily scalable, code is easy to manage, and all pieces of the code are testable. 

By following the MVVM pattern, we are able to separate presentation logic from UI to make the code easier to understand. I added data bindings to bind the UI and ViewModel, so the UI would react to changes in the ViewModel and automatically reflect on the UI. The original code manually tracked the state of a favorited post, but this wasn't safe because the post could be favorited from other parts of the app. To improve this, we are now observing "GlorifyBlogFavoritesChanged" Notifications from the ViewModel to react to favorites being updated. Yes, this would be triggered whenever any post is favorited, but this could potentially be improved by updating the Notifications and observing changes to specific posts. We won't worry about that though. The logic for favoriting a post has been moved to the ViewModel and only a single updateFavorites function is exposed to the ViewController to handle favorite and unfavorite to keep things simple on the UI.

Another significant change that I made was separating the UserManager into AuthAPI and PostAPI. UserManager was focusing on two separate things that should live independently. AuthAPI conforms to the AuthAPIProvider which exposes logIn, logOut, and get currentUser. logIn and logOut handle updating the state of currentUser, so there is no need to expose a currentUser setter. This ensures that currentUser isn't set somewhere else causing something to break. The more that is exposed than needed, the harder the code is to maintain and ultimately more things end up breaking. PostAPI manages post favorites and fetching a post data. PostAPI doesn't need to know anything about Auth and vice versa. In a production app, I'd expect Post favorites to require an API call, so I've left them to PostAPI to manage. Favorites could be broken out into their own service which manages the Favorite Posts. Persisted Local storage could be interesting to use here especially if favorite posts ends up also being stored in an external database. We are also observing changes in favoritePosts now, so "GlorifyBlogFavoritesChanged" is fired when adding/removing a favorite post. Moving this notification post into a single location and being completely managed within PostAPI, means we don't have to worry about forgetting to post the notification.

PostAPI conforms to PostAPIProvider protocol and AuthAPI conforms to AuthAPIProvider protocol. By adding these protocols as dependencies to the code that uses these, we are able to significantly increase are unit test coverage and do so much more easily. We can mock these APIs and completely control how they should function within our testing environment. BlogPostDetailViewModel is a great example of how we can inject the PostAPI into the ViewModel. When initializing this ViewModel in our unit tests, we can pass in a MockPostAPI and control how the PostAPI should function.

From a UI perspective, moving the UI from storyboard to UIKit was pretty straight forward. One of the major things I took into account was adding a scroll view to ensure the view scrolls in case there is a post with a large amount of text. I contained the body and title labels within a StackView since StackViews are easy to work with, require less constraints, and views can easily be added or removed. In a production app, I would have added some view extensions to allow us to add subviews and anchor the code much easier along with increasing readability. The BlogPostDetail screen also handles dark mode properly now. Developing this in SwiftUI would also have significantly improved the UI from Storyboards and would probably be the better approach for building the UI.

The last thing I'll mention is that I also moved the tab bar item badge state handling to the RootTabBarController. RootTabBarController is observing "GlorifyBlogFavoritesChanged" notifications and updates the badge accordingly. Previosly this was being managed by the child ViewControllers, which is messier. The RootTabBarController manages the tabs, so it should also manage the tab badges. The child ViewController don't need to know the tabs exist. 

### Additional thoughts

Implementing Alamofire along with the Networking layer would have also been an interesting practice to implement, but I saw way too many things that needed to be improved in the ViewControllers and architecture, so had to focus on that. Maybe I touched a bit more code than necessary outside of the BlogPostDetailViewController lol. I would have built an API service that conforms to a protocol that defines the possible inputs of an API request and returns some object that conforms to Codable. Alamofire would have then been built behind this layer and the source that makes the network requests and handles returning a Codable response. The PostAPI and AuthAPI would inject this API Service Protocol and make their api requests through this. Of course there is a lot more to this.

Implementing a library sounds like it would have been too easy, so didn't really look into that much. 


Thanks for spending the time to read all this and consider me for this role :)
