//
//  LivePhoto.swift
//  Media
//
//  Created by Christian Elies on 21.11.19.
//  Copyright © 2019 Christian Elies. All rights reserved.
//

import Photos

/// Represents `LivePhoto` media
///
public struct LivePhoto: MediaProtocol {
    public typealias ResultDisplayRepresentationCompletion = (Result<Media.DisplayRepresentation<PHLivePhotoProtocol>, Error>) -> Void

    static var livePhotoManager: LivePhotoManager = PHImageManager.default()

    private let phAssetWrapper: PHAssetWrapper

    public typealias MediaSubtype = LivePhoto.Subtype
    public typealias MediaFileType = LivePhoto.FileType

    public var phAsset: PHAsset { phAssetWrapper.value }
    public static let type: MediaType = .image

    /// Locally available metadata of the `LivePhoto`
    public var metadata: Metadata {
        Metadata(
            type: phAsset.mediaType,
            subtypes: phAsset.mediaSubtypes,
            sourceType: phAsset.sourceType,
            creationDate: phAsset.creationDate,
            modificationDate: phAsset.modificationDate,
            location: phAsset.location,
            isFavorite: phAsset.isFavorite,
            isHidden: phAsset.isHidden)
    }

    public init(phAsset: PHAsset) {
        phAssetWrapper = PHAssetWrapper(value: phAsset)
    }
}

#if !os(macOS) && !targetEnvironment(macCatalyst)
public extension LivePhoto {
    /// Fetches a display representation of the receiver
    ///
    /// - Parameters:
    ///   - targetSize: the desired size (width and height) of the representation
    ///   - contentMode: the content mode for the representation
    ///   - completion: a closure wich gets the `Result` (`DisplayRepresentation` on `success` and `Error` on `failure`)
    ///
    func displayRepresentation(targetSize: CGSize,
                               contentMode: PHImageContentMode = .default,
                               _ completion: @escaping ResultDisplayRepresentationCompletion) {
        let options = PHLivePhotoRequestOptions()
        options.isNetworkAccessAllowed = true

        Self.livePhotoManager.customRequestLivePhoto(for: phAsset,
                                                     targetSize: targetSize,
                                                     contentMode: contentMode,
                                                     options: options)
        { livePhoto, info in
            PHImageManager.handlePotentialDegradedResult((livePhoto, info), completion)
        }
    }
}

@available(iOS 10, *)
@available(tvOS, unavailable)
public extension LivePhoto {
    /// Saves the given still image data and the movie at the given URL as a `LivePhoto`
    /// if the access to the photo library is allowed
    ///
    /// - Parameters:
    ///   - data: the data object holding the image and video portion of the `LivePhoto`
    ///   - completion: a closure wich gets the `Result` (`LivePhoto` on `success` and `Error` on `failure`)
    ///
    static func save(data: LivePhotoData, _ completion: @escaping ResultLivePhotoCompletion) throws {
        PHAssetChanger.createRequest({
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: data.stillImageData, options: nil)

            let options = PHAssetResourceCreationOptions()
            /*
                Use the shouldMoveFile option
                so that iOS can transfer the movie file from your app’s sandbox
                to the system Photos library without an expensive data-copying operation.
             */
            options.shouldMoveFile = true
            creationRequest.addResource(with: .pairedVideo, fileURL: data.movieURL.value, options: options)

            return creationRequest
        }, completion)
    }
}

#endif

public extension LivePhoto {
    /// Fetches the `LivePhoto` with the given `identifier` if it exists
    ///
    /// Alternative:
    /// @FetchAsset(filter: [.localIdentifier("1234"), .mediaSubtypes([.live])])
    /// private var livePhoto: LivePhoto?
    ///
    /// - Parameter identifier: the identifier of the media
    ///
    static func with(identifier: Media.Identifier<Self>) throws -> LivePhoto? {
        let options = PHFetchOptions()

        let mediaFilter: [Media.Filter<LivePhoto.Subtype>] = [.localIdentifier(identifier.localIdentifier), .mediaSubtypes([.live])]
        let mediaFilterPredicates = mediaFilter.map { $0.predicate }
        let mediaTypePredicate = NSPredicate(format: "mediaType = %d", MediaType.image.rawValue)
        options.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [mediaTypePredicate] + mediaFilterPredicates)

        let livePhoto = try PHAssetFetcher.fetchAsset(options: options) { $0.localIdentifier == identifier.localIdentifier && $0.mediaType == .image && $0.mediaSubtypes.contains(.photoLive) } as LivePhoto?
        return livePhoto
    }
}

public extension LivePhoto {
    /// Updates the favorite state of the receiver if the access to the photo library is allowed
    ///
    /// - Parameters:
    ///   - favorite: a boolean which indicates the new favorite state
    ///   - completion: a closure wich gets the `Result` (`Void` on `success` and `Error` on `failure`)
    ///
    func favorite(_ favorite: Bool, _ completion: @escaping ResultVoidCompletion) {
        PHAssetChanger.favorite(phAsset: phAsset, favorite: favorite) { result in
            do {
                self.phAssetWrapper.value = try result.get()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
