//
//  PHPickerResult+loadImage.swift
//  MediaSwiftUI
//
//  Created by Christian Elies on 14.10.20.
//

#if !os(tvOS) && (!os(macOS) || targetEnvironment(macCatalyst))
import Combine
import MediaCore
import PhotosUI

@available(iOS 14, macCatalyst 14, *)
extension PHPickerResult {
    /// <#Description#>
    public enum Error: Swift.Error {
        ///
        case couldNotLoadObject(underlying: Swift.Error)
        ///
        case unknown
    }

    /// <#Description#>
    ///
    /// - Returns: <#description#>
    public func loadImage() -> AnyPublisher<UniversalImage, Swift.Error> {
        Future { promise in
            guard itemProvider.canLoadObject(ofClass: UniversalImage.self) else {
                promise(.failure(Error.couldNotLoadObject(underlying: Error.unknown)))
                return
            }

            itemProvider.loadObject(ofClass: UniversalImage.self) { newImage, error in
                if let error = error {
                    promise(.failure(Error.couldNotLoadObject(underlying: error)))
                } else if let newImage = newImage {
                    promise(.success(newImage as! UniversalImage))
                } else {
                    promise(.failure(Error.unknown))
                }
            }
        }.eraseToAnyPublisher()
    }
}
#endif
