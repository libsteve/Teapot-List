# ListLayout.playground

[Link to the relevant StackOverflow question][2]

## Description

I’m trying to create a custom `NSCollectionViewLayout` subclass that uses use Auto Layout to determine its items’ sizes.  This layout positions items from top-to-bottom, where all items share the same width, but each item's height is deretmined by its content. Think of it as a `UITableView` layout for macOS.

## Assumption

The initial layout attributes are calculated in the layout's `prepare()` method, and given to the collection view through  `layoutAttributesForElements(in:)`. These attributes are used by the collection view to determine which items will need to be displayed. These items are be provided by the collection view's delegate, and each item's `apply(_:)` method is called to to set up its view properties.

The collection view will then call the item's `preferredLayoutAttributesFitting(_:)` method to caclulate its content's fitting size. The returned attributes will then be passed into the collection view layout's `shouldInvalidateLayout(forPreferredLayoutAttributes:withOriginalAttributes:)` method, where the layout determines whether or not it needs to make adjustments in response to the new attributes, and returns that boolean decision to the collection view.

If the layout decides it needs to be invalidated, the collection view will then call `invalidationContext(forPreferredLayoutAttributes:withOriginalAttributes:)` to get specific information from the layout for how it should update itself. When the collection view then calls `invalidationContext(forPreferredLayoutAttributes:withOriginalAttributes:)`, the layout can apply those changes.

This process is then repeated until `shouldInvalidateLayout(forPreferredLayoutAttributes:withOriginalAttributes:)` returns `false` for each layout item—prompting the collection view to display the items on the screen.

## Premise

The `ListLayout` subclass of `NSCollectionViewLayout` is able to create an initial set of layout attributes for each `NSCollectionViewItem` with an "estimated" initial height of `10` points. We are expecting to use Auto Layout to determine each item's actual height, so this initial value shouldn't matter.

The layout is then able to provide the correct set of those initial attributes through `layoutAttributesForElements(in:)`.

The `TextFieldItem` subclass of `NSCollectionViewItem` contains a single `NSTextField` instance, which is set to both its `view` and `textField` properties. This view has its `translatesAutoresizingMaskIntoConstraints` property set to false, and has a required vertical content compression resistance priority. The item's `apply(_:)` method is overriden to set the text field's `preferredMaxLayoutWidth` to the width provided by the given attributes. The item's `preferredLayoutAttributesFitting(_:)` method is overriden to set the preferred attribute's height to equal the text field's `intrinsicContentSize` property.

The collection view is provided instances of `TextFieldItem` populated with multiple lines of text.

It is expected that each `TextFieldItem` will have its `preferredLayoutAttributesFitting(_:)` method called after its `apply(_:)` method, followed by a call to both the layout's `shouldInvalidateLayout(forPreferredLayoutAttributes:withOriginalAttributes:)` and `invalidationContext(forPreferredLayoutAttributes:withOriginalAttributes:)` methods.

However, neither `preferredLayoutAttributesFitting(_:)`, nor `shouldInvalidateLayout(forPreferredLayoutAttributes:withOriginalAttributes:)`, nor `invalidationContext(forPreferredLayoutAttributes:withOriginalAttributes:)` are ever called when the playground is run. As a result, each item's height remains at that initial "estimated" height.

[![Each text field should display three lines of text, but only the top of the first line is visible.][1]][1]

## Question

There must be something I’m missing about `NSCollectionViewLayout` and Auto Layout, but I haven't found anything in the documentation to indicate that.

I've tried manually calling these methods at various different points in the collection view's lifecycle, but nothing has been able to correctly trigger the layout to adjust its caclulated attributes.

Is there a property that needs to be set on the collection view, its layout, or the items to indicate that `preferredLayoutAttributesFitting(_:)` should be called? Is Auto Layout only supported for subclasses of `NSCollectionViewFlowLayout` and `NSCollectionViewGridLayout`? Or am I misunderstanding the lifecycle of an `NSCollectionViewLayout` instance?

[1]: https://i.stack.imgur.com/UYfq4.png
[2]: https://stackoverflow.com/questions/52468731/invalidationcontextforpreferredlayoutattributeswithoriginalattributes-isnt
