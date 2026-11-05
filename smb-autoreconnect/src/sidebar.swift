// Adds each folder given on the command line to Finder's sidebar Favorites
// unless it's already there, printing the ones it added.
import CoreServices
import Foundation

let list = LSSharedFileListCreate(nil, kLSSharedFileListFavoriteItems.takeUnretainedValue(), nil)!
  .takeRetainedValue()
var seed: UInt32 = 0
let items = LSSharedFileListCopySnapshot(list, &seed)?.takeRetainedValue() as? [LSSharedFileListItem] ?? []
let flags = UInt32(kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes)
var existing = Set(items.compactMap {
  (LSSharedFileListItemCopyResolvedURL($0, flags, nil)?.takeRetainedValue() as URL?)?.standardizedFileURL.path
})

// Insert after the current last item; the kLSSharedFileListItemLast sentinel
// isn't a real object and crashes under Swift's reference counting.
var after = items.last
var failed = false
for arg in CommandLine.arguments.dropFirst() {
  let url = URL(fileURLWithPath: arg, isDirectory: true).standardizedFileURL
  if existing.contains(url.path) { continue }
  if let prev = after, let item = LSSharedFileListInsertItemURL(list, prev, nil, nil, url as CFURL, nil, nil) {
    after = item
    existing.insert(url.path)
    print(url.path)
  } else {
    FileHandle.standardError.write(Data("could not add \(url.path) to the sidebar\n".utf8))
    failed = true
  }
}
exit(failed ? 1 : 0)
