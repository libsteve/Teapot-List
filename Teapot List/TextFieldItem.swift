//
//  TextFieldItem.swift
//  Example Layout
//
//  Created by Steve Brunwasser on 3/28/19.
//  Copyright © 2019 Steve Brunwasser. All rights reserved.
//

import Cocoa

/// A simple NSCollectionViewItem displaying a single text field with multiple lines of text.
class TextFieldItem: NSCollectionViewItem {
    override func loadView() {
        view =  NSTextField(frame: NSRect(x: 0, y: 0, width: 100, height: 50))
        view.makeBackingLayer()
        view.layer?.backgroundColor = .white
        textField = view as? NSTextField
        textField!.maximumNumberOfLines = 0
        textField!.lineBreakMode = .byWordWrapping
        textField!.drawsBackground = false
        textField!.isBordered = false
        textField!.isEditable = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    override func apply(_ layoutAttributes: NSCollectionViewLayoutAttributes) {
        // Inform the text field that its width shouldn't exceed the given width.
        // This is necessary to make sure text fields wrap their text.
        textField!.preferredMaxLayoutWidth = layoutAttributes.size.width
        super.apply(layoutAttributes)
    }

    // NOTE: This method is never called, but it should be called immediately after apply(_:).
    override func preferredLayoutAttributesFitting(_ layoutAttributes: NSCollectionViewLayoutAttributes) -> NSCollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let width = layoutAttributes.size.width / 2

        // Constrain the text field's width to that provided by the given layout attributes.
        textField!.preferredMaxLayoutWidth = width
        print("🍌: Calculating preferred layout attributes within width \(width).")

        // Caclulate the text field's size using the provided layout attribite's width.
        attributes.size = view.intrinsicContentSize
        print("🍌: Intrinsic content size is \(view.intrinsicContentSize).")

        return attributes
    }
}
