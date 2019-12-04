//
//  FetchAlbums.swift
//  
//
//  Created by Christian Elies on 03.12.19.
//

import Photos

/// Property wrapper for fetching albums
///
@propertyWrapper
public final class FetchAlbums {
    private let options = PHFetchOptions()
    private let defaultSort: Sort<AlbumSortKey> = Sort(key: .localizedTitle, ascending: true)

    private let albumType: AlbumType?

    private lazy var albums: [Album] = {
        AlbumFetcher.fetchAlbums(with: (albumType?.assetCollectionType) ?? .album,
                                 subtype: .any,
                                 options: options) { collection in
            self.albumType?.subtypes.contains(collection.assetCollectionSubtype) ?? true
        }
    }()

    public var wrappedValue: [Album] { albums }

    /// Initializes the property wrapper without an album type filter and
    /// with a default sort descriptor (sort by `localizedTitle ascending`)
    ///
    public init() {
        albumType = nil
        options.sortDescriptors = [defaultSort.sortDescriptor]
    }

    /// Initializes the property wrapper using the given album type
    /// Uses the given predicate and the sort descriptors as fetch options
    ///
    /// - Parameters:
    ///   - type: specifies the type of albums to be fetched, fetches all albums if nil
    ///   - filter: a set of `AlbumFilter` for the fetch, defaults to empty
    ///   - sort: a set of `Sort<AlbumSortKey>` for the fetch, defaults to empty
    ///
    public init(ofType type: AlbumType? = nil,
                filter: Set<AlbumFilter> = [],
                sort: Set<Sort<AlbumSortKey>> = []) {
        albumType = type

        if !filter.isEmpty {
            let predicates = filter.map { $0.predicate }
            options.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        var sortKeys = sort
        sortKeys.insert(defaultSort)

        if !sortKeys.isEmpty {
            let sortDescriptors = sortKeys.map { $0.sortDescriptor }
            options.sortDescriptors = sortDescriptors
        }
    }
}
