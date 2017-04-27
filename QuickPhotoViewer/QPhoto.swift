//
//  QPhoto.swift
//  QuickPhotoViewer
//
//  Created by 洪鑫 on 2017/3/15.
//  Copyright © 2017年 Teambition. All rights reserved.
//

import UIKit
import Kingfisher

public struct QPhoto {
    public var image: UIImage?
    public var thumbnailImage: UIImage?
    public var url: URL?
    public var thumbnailUrl: URL?

    public init(image: UIImage, thumbnailImage: UIImage?) {
        self.image = image
        self.thumbnailImage = thumbnailImage
    }

    public init(url: URL, thumbnailUrl: URL?) {
        self.url = url
        self.thumbnailUrl = thumbnailUrl
    }
}

public extension QPhoto {
    public var localImage: UIImage? {
        if let image = image {
            return image
        } else if let url = url {
            return KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: url.cacheKey) ?? KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: url.cacheKey)
        }
        return nil
    }

    public var localThumbnailImage: UIImage? {
        if let thumbnailImage = thumbnailImage {
            return thumbnailImage
        } else if let thumbnailUrl = thumbnailUrl {
            return KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: thumbnailUrl.cacheKey) ?? KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: thumbnailUrl.cacheKey)
        }
        return nil
    }
}

public struct QPhotoDownloadProgress {
    public var downloadedCount: Int64
    public var totalCount: Int64

    public init(downloadedCount: Int64, totalCount: Int64) {
        self.downloadedCount = downloadedCount
        self.totalCount = totalCount
    }
}

internal extension URL {
    var cacheKey: String {
        var cacheKey = absoluteString
        if let query = query {
            cacheKey = cacheKey.replacingOccurrences(of: query, with: "")
        }
        return cacheKey
    }
}
