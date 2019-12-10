# URLSession

版本：Swift5, iOS12, Xcode10

Apple提供了URLSession用于上传和下载数据，访问网络。

本教程中我们来构建Apple Tunes的搜索和下载功能。

1. 查询iTunes Search API 
2. 下载30秒的歌曲预览
3. 实现后台数据传输

## URLSession Overview

Before you begin, it’s important to understand `URLSession` and its constituent classes, so take a look at the quick overview below.

`URLSession` is both a class and a suite of classes for handling HTTP- and HTTPS-based requests:

![URLSession Diagram](https://koenig-media.raywenderlich.com/uploads/2019/05/02-URLSession-Diagram-650x432.png)

`URLSession` is the key object responsible for sending and receiving requests. You create it via `URLSessionConfiguration`, which comes in three flavors:

- *default*: Creates a default configuration object that uses the disk-persisted global cache, credential and cookie storage objects.
- *ephemeral*: Similar to the default configuration, except that you store all of the session-related data in memory. Think of this as a “private” session.
- *background*: Lets the session perform upload or download tasks in the background. Transfers continue even when the app itself is suspended or terminated by the system.

`URLSessionConfiguration` also lets you configure session properties such as timeout values, caching policies and HTTP headers. Refer to [Apple’s documentation](https://developer.apple.com/reference/foundation/urlsessionconfiguration) for a full list of configuration options.

`URLSessionTask` is an abstract class that denotes a task object. A session creates one or more tasks to do the actual work of fetching data and downloading or uploading files.

### Understanding Session Task Types

There are three types of concrete session tasks:

- *URLSessionDataTask*: Use this task for GET requests to retrieve data from servers to memory.
- *URLSessionUploadTask*: Use this task to upload a file from disk to a web service via a POST or PUT method.
- *URLSessionDownloadTask*: Use this task to download a file from a remote service to a temporary file location.

![URLSession Task Types](https://koenig-media.raywenderlich.com/uploads/2019/05/03-Session-Tasks.png)

You can also suspend, resume and cancel tasks. `URLSessionDownloadTask` has the extra ability to pause for future resumption.

Generally, `URLSession` returns data in two ways:

- Via a completion handler when a task finishes, either successfully or with an error; or,
- By calling methods on a delegate that you set when you create the session.

Now that you have an overview of what `URLSession` can do, you’re ready to put the theory into practice!

![Putting Theory Into Practice](https://koenig-media.raywenderlich.com/uploads/2019/05/swift-gears-320x320.png)

## DataTask and DownloadTask

You’ll start by creating a data task to query the iTunes Search API for the user’s search term.

In *SearchViewController.swift*, `searchBarSearchButtonClicked` enables the network activity indicator on the status bar to show the user that a network process is running. Then it calls `getSearchResults(searchTerm:completion:)`, which is stubbed out in *QueryService.swift*. You’re about to build it out to make the network request.

In *QueryService.swift*, replace `// TODO 1` with the following:

```swift
let defaultSession = URLSession(configuration: .default)
```

And `// TODO 2` with:

```swift
var dataTask: URLSessionDataTask?
```

Here’s what you’ve done:

1. Created a `URLSession` and initialized it with a default session configuration.
2. Declared `URLSessionDataTask`, which you’ll use to make a GET request to the iTunes Search web service when the user performs a search. The data task will be re-initialized each time the user enters a new search string.

Next, replace the content in `getSearchResults(searchTerm:completion:)` with the following:

```swift
// 1
dataTask?.cancel()
    
// 2
if var urlComponents = URLComponents(string: "https://itunes.apple.com/search") {
  urlComponents.query = "media=music&entity=song&term=\(searchTerm)"      
  // 3
  guard let url = urlComponents.url else {
    return
  }
  // 4
  dataTask = 
    defaultSession.dataTask(with: url) { [weak self] data, response, error in 
    defer {
      self?.dataTask = nil
    }
    // 5
    if let error = error {
      self?.errorMessage += "DataTask error: " + 
                              error.localizedDescription + "\n"
    } else if 
      let data = data,
      let response = response as? HTTPURLResponse,
      response.statusCode == 200 {       
      self?.updateSearchResults(data)
      // 6
      DispatchQueue.main.async {
        completion(self?.tracks, self?.errorMessage ?? "")
      }
    }
  }
  // 7
  dataTask?.resume()
}
```

Taking each numbered comment in turn:

1. For a new user query, you cancel any data task that already exists, because you want to reuse the data task object for this new query.
2. To include the user’s search string in the query URL, you create `URLComponents` from the iTunes Search base URL, then set its query string. This ensures that your search string uses escaped characters.
3. The `url` property of `urlComponents` is optional, so you unwrap it to `url` and return early if it’s `nil`.
4. From the session you created, you initialize a `URLSessionDataTask` with the query `url` and a completion handler to call when the data task completes.
5. If the request is successful, you call the helper method `updateSearchResults`, which parses the response `data` into the `tracks` array.
6. You switch to the main queue to pass `tracks` to the completion handler.
7. All tasks start in a suspended state by default. Calling `resume()` starts the data task.

In `SearchViewController`, take a look at the completion closure in the call to `getSearchResults(searchTerm:completion:)`. After hiding the activity indicator, it stores `results` in `searchResults` then updates the table view.

*Note*: The default request method is GET. If you want a data task to POST, PUT or DELETE, create a `URLRequest` with `url`, set the request’s `HTTPMethod` property then create a data task with the `URLRequest` instead of with the `URL`.

Build and run your app. Search for any song and you’ll see the table view populate with the relevant track results like so:

![Half Tunes Screen With Relevant Track Results](https://koenig-media.raywenderlich.com/uploads/2019/05/04-Search-281x500.png)

With some `URLSession` code, Half Tunes is now a bit functional!

Being able to view song results is nice, but wouldn’t it be better if you could tap a song to download it? That’s your next order of business. You’ll use a *download task*, which makes it easy to save the song snippet in a local file.

### Downloading Classes

The first thing you’ll need to do to handle multiple downloads is to create a custom object to hold the state of an active download.

Create a new Swift file named *Download.swift* in the *Model* group.

Open *Download.swift*, and add the following implementation below the Foundation `import`:

```swift
class Download {
  var isDownloading = false
  var progress: Float = 0
  var resumeData: Data?
  var task: URLSessionDownloadTask?
  var track: Track
  
  init(track: Track) {
    self.track = track
  }
}
```

Here’s a rundown of the properties of `Download`:

- *isDownloading*: Whether the download is ongoing or paused.
- *progress*: The fractional progress of the download, expressed as a float between 0.0 and 1.0.
- *resumeData*: Stores the `Data` produced when the user pauses a download task. If the host server supports it, your app can use this to resume a paused download.
- *task*: The `URLSessionDownloadTask` that downloads the track.
- *track*: The track to download. The track’s `url` property also acts as a unique identifier for `Download`.

Next, in *DownloadService.swift*, replace `// TODO 4` with the following property:

```swift
var activeDownloads: [URL: Download] = [:]
```

This dictionary will maintain a mapping between a URL and its active `Download`, if any.

## URLSession Delegates

You could create your download task with a completion handler, as you did when you created the data task. However, later in this tutorial you’ll check and update the download progress, which requires you to implement a custom delegate. So you might as well do that now.

There are several session delegate protocols, listed in [Apple’s URLSession documentation](https://developer.apple.com/reference/foundation/urlsession). `URLSessionDownloadDelegate` handles task-level events specific to download tasks.

You’re going to need to set `SearchViewController` as the session delegate soon, so now you’ll create an extension to conform to the session delegate protocol.

Open *SearchViewController.swift* and replace `// TODO 5` with the following `URLSessionDownloadDelegate` extension below:

```swift
extension SearchViewController: URLSessionDownloadDelegate {
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                  didFinishDownloadingTo location: URL) {
    print("Finished downloading to \(location).")
  } 
}
```

The only non-optional `URLSessionDownloadDelegate` method is `urlSession(_:downloadTask:didFinishDownloadingTo:)`, which your app calls when a download finishes. For now, you’ll print a message whenever a download completes.

### Downloading a Track

With all the preparatory work out of the way, you’re now ready to put file downloads in place. Your first step is to create a dedicated session to handle your download tasks.

In *SearchViewController.swift*, replace `// TODO 6` with the following code:

```swift
lazy var downloadsSession: URLSession = {
  let configuration = URLSessionConfiguration.default
  
  return URLSession(configuration: configuration, 
                    delegate: self, 
                    delegateQueue: nil)
}()
```

Here, you initialize a separate session with a default configuration and specify a delegate which lets you receive `URLSession` events via delegate calls. This will be useful for monitoring the progress of the task.

Setting the delegate queue to `nil` causes the session to create a serial operation queue to perform all calls to delegate methods and completion handlers.

Note the lazy creation of `downloadsSession`; this lets you delay the creation of the session until *after* you initialize the view controller. Doing that allows you to pass `self` as the delegate parameter to the session initializer.

Now replace `// TODO 7` at the end of `viewDidLoad()` with the following line:

```swift
downloadService.downloadsSession = downloadsSession
```

This sets the `downloadsSession` property of `DownloadService` to the session you just defined.

With your session and delegate configured, you’re finally ready to create a download task when the user requests a track download.

In *DownloadService.swift*, replace the content of `startDownload(_:)` with the following implementation:

```swift
// 1
let download = Download(track: track)
// 2
download.task = downloadsSession.downloadTask(with: track.previewURL)
// 3
download.task?.resume()
// 4
download.isDownloading = true
// 5
activeDownloads[download.track.previewURL] = download
```

When the user taps a table view cell’s *Download* button, `SearchViewController`, acting as `TrackCellDelegate`, identifies the `Track` for this cell, then calls `startDownload(_:)` with that `Track`.

Here’s what’s going on in `startDownload(_:)`:

1. You first initialize a `Download` with the track.
2. Using your new session object, you create a `URLSessionDownloadTask` with the track’s preview URL and set it to the `task` property of the `Download`.
3. You start the download task by calling `resume()` on it.
4. You indicate that the download is in progress.
5. Finally, you map the download URL to its `Download` in `activeDownloads`.

Build and run your app, search for any track and tap the *Download* button on a cell. After a while, you’ll see a message in the *debug console* signifying that the download is complete.

```shell
Finished downloading to file:///Users/mymac/Library/Developer/CoreSimulator/Devices/74A1CE9B-7C49-46CA-9390-3B8198594088/data/Containers/Data/Application/FF0D263D-4F1D-4305-B98B-85B6F0ECFE16/tmp/CFNetworkDownload_BsbzIk.tmp.
```

The Download button is still showing, but you’ll fix that soon. First, you want to play some tunes!

### Saving and Playing the Track

When a download task completes, `urlSession(_:downloadTask:didFinishDownloadingTo:)` provides a URL to the temporary file location, as you saw in the print message. Your job is to move it to a permanent location in your app’s sandbox container directory before you return from the method.

In *SearchViewController.swift*, replace the print statement in `urlSession(_:downloadTask:didFinishDownloadingTo:)` with the following code:

```swift
// 1
guard let sourceURL = downloadTask.originalRequest?.url else {
  return
}

let download = downloadService.activeDownloads[sourceURL]
downloadService.activeDownloads[sourceURL] = nil
// 2
let destinationURL = localFilePath(for: sourceURL)
print(destinationURL)
// 3
let fileManager = FileManager.default
try? fileManager.removeItem(at: destinationURL)

do {
  try fileManager.copyItem(at: location, to: destinationURL)
  download?.track.downloaded = true
} catch let error {
  print("Could not copy file to disk: \(error.localizedDescription)")
}
// 4
if let index = download?.track.index {
  DispatchQueue.main.async { [weak self] in
    self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], 
                               with: .none)
  }
}
```

Here’s what you’re doing at each step:

1. You extract the original request URL from the task, look up the corresponding `Download` in your active downloads and remove it from that dictionary.
2. You then pass the URL to `localFilePath(for:)`, which generates a permanent local file path to save to by appending the `lastPathComponent` of the URL (the file name and extension of the file) to the path of the app’s *Documents directory*.
3. Using `fileManager`, you move the downloaded file from its temporary file location to the desired destination file path, first clearing out any item at that location before you start the copy task. You also set the download track’s `downloaded` property to `true`.
4. Finally, you use the download track’s `index` property to reload the corresponding cell.

Build and run your project, run a query, then pick any track and download it. When the download has finished, you’ll see the file path location printed to your console:

```shell
file:///Users/mymac/Library/Developer/CoreSimulator/Devices/74A1CE9B-7C49-46CA-9390-3B8198594088/data/Containers/Data/Application/087C38CC-0CEB-4895-ADB6-F44D13C2CA5A/Documents/mzaf_2494277700123015788.plus.aac.p.m4a
```

The Download button disappears now, because the delegate method set the track’s `downloaded` property to `true`. Tap the track and you’ll hear it play in the `AVPlayerViewController` as shown below:

![Half Tunes App With Music Player Running](https://koenig-media.raywenderlich.com/uploads/2019/05/06-Playing-Download-281x500.png)

### Pausing, Resuming, and Canceling Downloads

What if the user wants to pause a download or to cancel it altogether? In this section, you’ll implement the pause, resume and cancel features to give the user complete control over the download process.

You’ll start by allowing the user to cancel an active download.

### Canceling Downloads

In *DownloadService.swift*, add the following code inside `cancelDownload(_:)`:

```swift
guard let download = activeDownloads[track.previewURL] else {
  return
}

download.task?.cancel()
activeDownloads[track.previewURL] = nil
```

To cancel a download, you’ll retrieve the download task from the corresponding `Download` in the dictionary of active downloads and call `cancel()` on it to cancel the task. You’ll then remove the download object from the dictionary of active downloads.

### Pausing Downloads

Your next task is to let your users pause their downloads and come back to them later.

Pausing a download is similar to canceling it. Pausing cancels the download task, but also produces *resume data*, which contains enough information to resume the download at a later time if the host server supports that functionality.

*Note*: You can only resume a download under certain conditions. For instance, the resource must not have changed since you first requested it. For a full list of conditions, check out the documentation [here](https://developer.apple.com/reference/foundation/urlsessiondownloadtask/1411634-cancel).

Replace the contents of `pauseDownload(_:)` with the following code:

```swift
guard
  let download = activeDownloads[track.previewURL],
  download.isDownloading 
  else {
    return
}

download.task?.cancel(byProducingResumeData: { data in
  download.resumeData = data
})

download.isDownloading = false
```

The key difference here is that you call `cancel(byProducingResumeData:)` instead of `cancel()`. You provide a closure parameter to this method, which lets you save the resume data to the appropriate `Download` for future resumption.

You also set the `isDownloading` property of the `Download` to `false` to indicate that the user has paused the download.

Now that the pause function is complete, the next order of business is to allow the user to resume a paused download.

### Resuming Downloads

Replace the content of `resumeDownload(_:)` with the following code:

```swift
guard let download = activeDownloads[track.previewURL] else {
  return
}

if let resumeData = download.resumeData {
  download.task = downloadsSession.downloadTask(withResumeData: resumeData)
} else {
  download.task = downloadsSession
    .downloadTask(with: download.track.previewURL)
}

download.task?.resume()
download.isDownloading = true
```

When the user resumes a download, you check the appropriate `Download` for the presence of resume data. If found, you’ll create a new download task by invoking `downloadTask(withResumeData:)` with the resume data. If the resume data is absent for any reason, you’ll create a new download task with the download URL.

In either case, you’ll start the task by calling `resume` and set the `isDownloading` flag of the `Download` to `true` to indicate the download has resumed.

### Showing and Hiding the Pause/Resume and Cancel Buttons

There’s only one item left to do for these three functions to work: You need to show or hide the Pause/Resume and Cancel buttons, as appropriate.

To do this, `TrackCell`‘s `configure(track:downloaded:)` needs to know if the track has an active download and whether it’s currently downloading.

In *TrackCell.swift*, change `configure(track:downloaded:)` to `configure(track:downloaded:download:)`:

```swift
func configure(track: Track, downloaded: Bool, download: Download?) {
```

In *SearchViewController.swift*, fix the call in `tableView(_:cellForRowAt:)`:

```swift
cell.configure(track: track,
               downloaded: track.downloaded,
               download: downloadService.activeDownloads[track.previewURL])
```

Here, you extract the track’s download object from `activeDownloads`.

Back in *TrackCell.swift*, locate `// TODO 14` in `configure(track:downloaded:download:)` and add the following property:

```swift
var showDownloadControls = false
```

Then replace `// TODO 15` with the following:

```swift
if let download = download {
  showDownloadControls = true
  let title = download.isDownloading ? "Pause" : "Resume"
  pauseButton.setTitle(title, for: .normal)
}
```

As the comment notes, a non-nil download object means a download is in progress, so the cell should show the download controls: Pause/Resume and Cancel. Since the pause and resume functions share the same button, you’ll toggle the button between the two states, as appropriate.

Below this if-closure, add the following code:

```swift
pauseButton.isHidden = !showDownloadControls
cancelButton.isHidden = !showDownloadControls
```

Here, you show the buttons for a cell only if a download is active.

Finally, replace the last line of this method:

```swift
downloadButton.isHidden = downloaded
```

with the following code:

```swift
downloadButton.isHidden = downloaded || showDownloadControls
```

Here, you tell the cell to hide the Download button if the track is downloading.

Build and run your project. Download a few tracks concurrently and you’ll be able to pause, resume and cancel them at will:

![Half Tunes App Screen With Pause, Resume, and Cancel Options](https://koenig-media.raywenderlich.com/uploads/2019/05/09-Pausing-And-Resuming-281x500.png)

## Showing Download Progress

At this point, the app is functional, but it doesn’t show the progress of the download. To improve the user experience, you’ll change your app to listen for download progress events and display the progress in the cells. There’s a session delegate method that’s perfect for this job!

First, in *TrackCell.swift*, replace `// TODO 16` with the following helper method:

```swift
func updateDisplay(progress: Float, totalSize : String) {
  progressView.progress = progress
  progressLabel.text = String(format: "%.1f%% of %@", progress * 100, totalSize)
}
```

The track cell has `progressView` and `progressLabel` outlets. The delegate method will call this helper method to set their values.

Next, in *SearchViewController.swift*, add the following delegate method to the `URLSessionDownloadDelegate` extension:

```swift
func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                  didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                  totalBytesExpectedToWrite: Int64) {
  // 1
  guard
    let url = downloadTask.originalRequest?.url,
    let download = downloadService.activeDownloads[url]  
    else {
      return
  }
  // 2
  download.progress = 
    Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
  // 3
  let totalSize = 
    ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, 
                              countStyle: .file) 
  // 4
  DispatchQueue.main.async {
    if let trackCell = 
      self.tableView.cellForRow(at: IndexPath(row: download.track.index,
                                              section: 0)) as? TrackCell {
      trackCell.updateDisplay(progress: download.progress, 
                              totalSize: totalSize)
    }
  }
}
```

Looking through this delegate method, step-by-step:

1. You extract the URL of the provided `downloadTask` and use it to find the matching `Download` in your dictionary of active downloads.
2. The method also provides the total bytes you have written and the total bytes you expect to write. You calculate the progress as the ratio of these two values and save the result in `Download`. The track cell will use this value to update the progress view.
3. `ByteCountFormatter` takes a byte value and generates a human-readable string showing the total download file size. You’ll use this string to show the size of the download alongside the percentage complete.
4. Finally, you find the cell responsible for displaying the `Track` and call the cell’s helper method to update its progress view and progress label with the values derived from the previous steps. This involves the UI, so you do it on the main queue.

### Displaying the Download’s Progress

Now, update the cell’s configuration to display the progress view and status when a download is in progress.

Open *TrackCell.swift*. In `configure(track:downloaded:download:)`, add the following line inside the if-closure, after the pause button title is set:

```swift
progressLabel.text = download.isDownloading ? "Downloading..." : "Paused"
```

This gives the cell something to show before the first update from the delegate method and while the download is paused.

Now, add the following code *below* the if-closure, below the `isHidden` lines for the two buttons:

```swift
progressView.isHidden = !showDownloadControls
progressLabel.isHidden = !showDownloadControls
```

This shows the progress view and label only while the download is in progress.

Build and run your project. Download any track and you should see the progress bar status update as the download progresses:

![Half Tunes App with Download Progress Features](https://koenig-media.raywenderlich.com/uploads/2019/05/10-Download-Progress-281x500.png)

Hurray, you’ve made, erm, progress! :]

## Enabling Background Transfers

Your app is quite functional at this point, but there’s one major enhancement left to add: Background transfers.

In this mode, downloads continue even when your app is in the background or if it crashes for any reason. This isn’t really necessary for song snippets, which are pretty small, but your users will appreciate this feature if your app transfers large files.

But how can this work if your app isn’t running?

The OS runs a separate daemon outside the app to manage background transfer tasks, and it sends the appropriate delegate messages to the app as the download tasks run. In the event that the app terminates during an active transfer, the tasks will continue to run, unaffected, in the background.

When a task completes, the daemon will relaunch the app in the background. The relaunched app will recreate the background session to receive the relevant completion delegate messages and perform any required actions, such as persisting downloaded files to disk.

*Note*: If the user terminates the app by force-quitting from the app switcher, the system will cancel all the session’s background transfers and won’t attempt to relaunch the app.

You’ll access this magic by creating a session with the *background* session configuration.

In *SearchViewController.swift*, in the initialization of `downloadsSession`, find the following line of code:

```swift
let configuration = URLSessionConfiguration.default
```

…and replace it with the following line:

```swift
let configuration = 
  URLSessionConfiguration.background(withIdentifier:
                                       "com.raywenderlich.HalfTunes.bgSession")
```

Instead of using a default session configuration, you’ll use a special background session configuration. Note that you also set a unique identifier for the session to allow your app to create a new background session, if needed.

*Note*: You must not create more than one session for a background configuration, because the system uses the configuration’s identifier to associate tasks with the session.

### Relaunching Your App

If a background task completes when the app isn’t running, the app will relaunch in the background. You’ll need to handle this event from your app delegate.

Switch to *AppDelegate.swift*, replace `// TODO 17` with the following code:

```swift
var backgroundSessionCompletionHandler: (() -> Void)?
```

Next, replace `// TODO 18` with the following method:

```swift
func application(
  _ application: UIApplication,
  handleEventsForBackgroundURLSession 
    handleEventsForBackgroundURLSessionidentifier: String,
  completionHandler: @escaping () -> Void) {
    backgroundSessionCompletionHandler = completionHandler
}
```

Here, you save the provided `completionHandler` as a variable in your app delegate for later use.

`application(_:handleEventsForBackgroundURLSession:)` wakes up the app to deal with the completed background task. You’ll need to handle two items in this method:

- First, the app needs to recreate the appropriate background configuration and session using the identifier provided by this delegate method. But since this app creates the background session when it instantiates `SearchViewController`, you’re already reconnected at this point!
- Second, you’ll need to capture the completion handler provided by this delegate method. Invoking the completion handler tells the OS that your app’s done working with all background activities for the current session. It also causes the OS to snapshot your updated UI for display in the app switcher.

The place to invoke the provided completion handler is `urlSessionDidFinishEvents(forBackgroundURLSession:)`, which is a `URLSessionDelegate` method that fires when all tasks on the background session have finished.

In *SearchViewController.swift* replace `// TODO 19` with the following extension:

```swift
extension SearchViewController: URLSessionDelegate {
  func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    DispatchQueue.main.async {
      if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
        let completionHandler = appDelegate.backgroundSessionCompletionHandler {
        appDelegate.backgroundSessionCompletionHandler = nil
        
        completionHandler()
      }
    }
  } 
}
```

The code above grabs the stored completion handler from the app delegate and invokes it on the main thread. You find the app delegate by getting the shared instance of `UIApplication`, which is accessible thanks to the UIKit import.

### Testing Your App’s Functionality

Build and run your app. Start a few concurrent downloads and tap the *Home* button to send the app to the background. Wait until you think the downloads have completed, then double-tap the Home button to reveal the app switcher.

The downloads should have finished, and you should see their new status in the app snapshot. Open the app to confirm this:

![Completed Half Tunes App With All Functions Enabled](https://koenig-media.raywenderlich.com/uploads/2019/05/11-Background-Download-281x500.png)

You now have a functional music-streaming app! Your move now, Apple Music! :]

## Where to Go From Here?

Congratulations! You’re now well-equipped to handle most common networking requirements in your app.

If you want to explore the subject further, there are more `URLSession` topics than would fit in this tutorial. For example, you can also try out uploading tasks and session configuration settings such as timeout values and caching policies.

To learn more about these features (and others!), check out the following resources:

- Apple’s [URLSession Programming Guide](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/URLLoadingSystem/Articles/UsingNSURLSession.html#//apple_ref/doc/uid/TP40013509-SW1) contains comprehensive information on everything you’d want to do.
- Our own [Networking with URLSession](https://videos.raywenderlich.com/courses/67-networking-with-urlsession/lessons/1) video course starts with HTTP basics, then goes on to cover tasks, background sessions, authentication, App Transport Security, architecture and unit testing.
- [AlamoFire](https://github.com/Alamofire/Alamofire) is a popular third-party iOS networking library; we cover the basics of it in our [Beginning Alamofire](http://www.raywenderlich.com/85080/beginning-alamofire-tutorial) tutorial.

I hope you enjoyed reading this tutorial. If you have any questions or comments, please join the discussion below!