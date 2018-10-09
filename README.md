# NSCollectionViewLayout.playground

## Description

I’m trying to create a custom `NSCollectionViewLayout` subclass that will use Auto Layout to determine its items’ sizes. This layout is much like that of a `UITableView`, where items are ordered top-to-bottom and all have the same width.

## Assumptions

I know that enabling self-sizing items in my custom layout requires that I override both `shouldInvalidateLayout(forPreferredLayoutAttributes:withOriginalAttributes:)` and `invalidationContext(forPreferredLayoutAttributes:withOriginalAttributes:)`. However, these methods are never called by the `NSCollectionView`.

My understanding is that the `NSCollectionViewLayout` lifecycle will look something like this:

1. The collection view calls `prepare()`, where the layout sets itself up to position the collection view’s items.
- Here, the layout can call `numberOfSections` and `numberOfItems(inSection:)` to determine how many items will be displayed.
2. The collection view calls `layoutAttributesForElements(in:)` to request the properties for all items in a given area.
3. The collection view calls its delegate’s `collectionView(_:itemForRepresentedObjectAt:)` method to get each `NSCollectionViewItem` for the layout attributes provided by the layout.
4. The collection view calls `apply(_:)` on each `NSCollectionViewItem` to configure it with the provided layout attributes.
5. The collection view then allows the item to calculate its preferred size by calling its `preferredLayoutAttributesFitting(_:)` method.
6. The collection view then calls the layout’s `shouldInvalidateLayout(forPreferredLayoutAttributes:withOriginalAttributes:)` method to let the layout determine whether or not to use those attributes.
7. If `true` is returned, the `invalidationContext(forPreferredLayoutAttributes:withOriginalAttributes:)` is called to let the layout determine the kinds of changes needed to incorporate the new attributes.
8. The collection view then calls the layout’s `invalidateLayout(with:)` method, where it can then apply those changes to its cached attributes.
9. The collection view repeats this process until the layout indicates that no more adjustments are needed.
10. Finally, the collection view displays its items.

## Question

However, `preferredLayoutAttributesFitting(_:)`, `shouldInvalidateLayout(forPreferredLayoutAttributes:withOriginalAttributes:)`, and `invalidationContext(forPreferredLayoutAttributes:withOriginalAttributes:)` are never called when I attempt to use my custom layout.

There must be something I’m missing to inform the collection view that is should request its items’ preferred attributes, but I haven’t been able to find any properties or methods that seem to do the trick.

The attached image shows the lack of self-sizing items when running the playground.

[![Each text field should display three lines of text, but only the top of the first line is visible.][1]][1]

[Stack Overflow Question][2]

[1]: https://i.stack.imgur.com/UYfq4.png
[2]: https://stackoverflow.com/questions/52468731/invalidationcontextforpreferredlayoutattributeswithoriginalattributes-isnt
