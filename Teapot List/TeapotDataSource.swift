//
//  TeapotDataSource.swift
//  Example Layout
//
//  Created by Steve Brunwasser on 3/28/19.
//  Copyright © 2019 Steve Brunwasser. All rights reserved.
//

import Cocoa

/// An object that can provide data to an NSCollectionView.
///
/// The collection view will be provided with 5 sections of 5 items each.
/// Each cell is a simple text field, which displays the same three-line statement.
class TeapotDataSource: NSObject, NSCollectionViewDataSource {
    let identifier = NSUserInterfaceItemIdentifier(rawValue: "item")

    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        collectionView.register(TextFieldItem.self, forItemWithIdentifier: identifier)
        return 7
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: identifier, for: indexPath)
        item.textField?.stringValue = """
        I'm a little teapot short and stout
        Here is my index: \(indexPath)
        Here is my stout: 🍺
        """
        return item
    }
}
