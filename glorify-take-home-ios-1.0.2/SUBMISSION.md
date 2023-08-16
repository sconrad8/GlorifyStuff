# Submission

**[Instructions](./README.md) Summary**:
* Refactor the prototype to adopt 1 to 2 Glorify practices
* Elaborate on your thought process in SUBMISSION.md

## Your Response

### Which aspects of the codebase did you choose to work on and why?

I chose to work on improving the architecture of the Blog Post Detail Screen to follow the MVVM pattern along with refactoring the UI to be built programatically. I chose this because architecture and UI layout is extrememly import to ensure app features are easily scalable, code is easy to manage, and all pieces of the code are testable. 

By following the MVVM pattern, we are able to separate presentation logic from UI to make the code easier to understand. I added data bindings to bind the UI and ViewModel, so the UI would react to changes in the ViewModel and automatically reflect on the UI. The original code manually tracked the state of a favorited post, but this wasn't safe because the post could be favorited from other parts of the app. To improve this, we are now observing "GlorifyBlogFavoritesChanged" Notifications from the ViewModel to react to favorites being updated. Yes, this would be triggered whenever any post is favorited, but this could potentially be improved by updating the Notifications and observing changes to specific posts. We won't worry about that though. The logic for favoriting a post has been moved to the ViewModel and only a single updateFavorites function is exposed to the ViewController to handle favorite and unfavorite to keep things simple on the UI.

 

### Additional thoughts

// YOUR RESPONSE HERE
