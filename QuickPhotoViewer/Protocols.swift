//
//  Protocols.swift
//  QuickPhotoViewer
//
//  Created by 洪鑫 on 2017/3/15.
//  Copyright © 2017年 Teambition. All rights reserved.
//

import UIKit

public protocol QuickPhotoViewerDataSource: class {

}

public protocol QuickPhotoViewerDelegate: class {
    func photoViewer(_ photoViewer: QuickPhotoViewer, willScrollToPageAt pageIndex: Int)
    func photoViewer(_ photoViewer: QuickPhotoViewer, didScrollToPageAt pageIndex: Int)
}

public protocol QuickPhotoViewerDownloadDelegate: class {
    func photoViewer(_ photoViewer: QuickPhotoViewer, willStartDownloading photo: QPhoto)
    func photoViewer(_ photoViewer: QuickPhotoViewer, isDownloading photo: QPhoto, with progress: QPhotoDownloadProgress)
    func photoViewer(_ photoViewer: QuickPhotoViewer, didFinishDownloading photo: QPhoto)
}

public extension QuickPhotoViewerDataSource {

}

public extension QuickPhotoViewerDelegate {
    func photoViewer(_ photoViewer: QuickPhotoViewer, willScrollToPageAt pageIndex: Int) { }
    func photoViewer(_ photoViewer: QuickPhotoViewer, didScrollToPageAt pageIndex: Int) { }
}

public extension QuickPhotoViewerDownloadDelegate {
    func photoViewer(_ photoViewer: QuickPhotoViewer, willStartDownloading photo: QPhoto) { }
    func photoViewer(_ photoViewer: QuickPhotoViewer, isDownloading photo: QPhoto, with progress: QPhotoDownloadProgress) { }
    func photoViewer(_ photoViewer: QuickPhotoViewer, didFinishDownloading photo: QPhoto) { }
}
