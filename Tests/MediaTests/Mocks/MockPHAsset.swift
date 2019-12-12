//
//  MockPHAsset.swift
//  MediaTests
//
//  Created by Christian Elies on 06.12.19.
//

import Photos

final class MockPHAsset: PHAsset {
    static var fetchResult = MockPHAssetsFetchResult()

    var localIdentifierToReturn = UUID().uuidString
    var mediaTypeToReturn: PHAssetMediaType = .image
    var mediaSubtypesToReturn: PHAssetMediaSubtype = []

    override var localIdentifier: String { localIdentifierToReturn }
    override var mediaType: PHAssetMediaType { mediaTypeToReturn }
    override var mediaSubtypes: PHAssetMediaSubtype { mediaSubtypesToReturn }

    override class func fetchAssets(with options: PHFetchOptions?) -> PHFetchResult<PHAsset> {
        fetchResult
    }
}
