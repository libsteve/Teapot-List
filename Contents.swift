import Cocoa
import PlaygroundSupport

// MARK: Custom NSCollectionViewLayout

class TestLayout: NSCollectionViewLayout {
    var verticalItemSpacing: CGFloat = 8
    var contentEdgeInsets: NSEdgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    private var cachedContentBounds: NSRect = .zero
    private var cachedItemAttributes: [IndexPath : NSCollectionViewLayoutAttributes] = [:]

    override var collectionViewContentSize: NSSize {
        guard let collectionView = collectionView else { return .zero }
        let height: CGFloat = cachedItemAttributes.values.reduce(0) { height, attributes in
            return height + attributes.size.height
        }
        let totalVerticalSpacing = CGFloat(cachedItemAttributes.count) * verticalItemSpacing + contentEdgeInsets.top + contentEdgeInsets.bottom
        return NSSize(width: collectionView.bounds.width, height: height + totalVerticalSpacing)
    }

    override func prepare() {
        guard let collectionView = collectionView,
            cachedItemAttributes.isEmpty else { return }
        let sectionIndices = 0 ..< collectionView.numberOfSections
        let indexPaths = sectionIndices.flatMap { section -> [IndexPath] in
            let numberOfItems = collectionView.numberOfItems(inSection: section)
            return (0 ..< numberOfItems).map { IndexPath(item: $0, section: section) }
        }
        cachedItemAttributes.keys
            .filter { !indexPaths.contains($0) }
            .forEach { cachedItemAttributes.removeValue(forKey: $0) }

        cachedContentBounds = collectionView.bounds
        let width = collectionView.bounds.width - contentEdgeInsets.left - contentEdgeInsets.right
        let origin = NSPoint(x: contentEdgeInsets.left, y: contentEdgeInsets.top)
        _ = indexPaths.reduce(origin) { origin, indexPath in
            let attributes = cachedItemAttributes[indexPath] ?? NSCollectionViewLayoutAttributes(forItemWith: indexPath)
            let size = NSSize(width: width, height: 10)
            attributes.frame = NSRect(origin: origin, size: size)
            cachedItemAttributes[indexPath] = attributes
            return NSPoint(x: origin.x, y: origin.y + size.height + verticalItemSpacing)
        }
    }
}

extension TestLayout {
    override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        return cachedItemAttributes[indexPath]
    }

    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        return cachedItemAttributes.values.filter { $0.frame.intersects(rect) }
    }
}

extension TestLayout {
    class InvalidationContext: NSCollectionViewLayoutInvalidationContext {
        var preferredLayoutAttributes: NSCollectionViewLayoutAttributes?
    }

    override class var invalidationContextClass: AnyClass { return InvalidationContext.self }

    override func invalidateLayout(with rawContext: NSCollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: rawContext)
        guard !rawContext.invalidateEverything,
            !rawContext.invalidateDataSourceCounts,
            rawContext.contentSizeAdjustment.width == 0 else {
                cachedItemAttributes.removeAll(keepingCapacity: true)
                return
        }
        guard let context = rawContext as? InvalidationContext,
            let preferredAttributes = context.preferredLayoutAttributes,
            let indexPath = preferredAttributes.indexPath,
            let originalAttributes = cachedItemAttributes[indexPath] else {
                cachedItemAttributes.removeAll(keepingCapacity: true)
                return
        }
        cachedItemAttributes.values.forEach { attributes in
            guard attributes.frame.origin.y >= originalAttributes.frame.origin.y else { return }
            guard attributes.indexPath != indexPath else {
                attributes.size.height = preferredAttributes.size.height
                return
            }
            attributes.frame.origin.y += context.contentSizeAdjustment.height
        }
    }

    // MARK: Preferred Attributes

    // NOTE: This method is never called
    override func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: NSCollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: NSCollectionViewLayoutAttributes) -> Bool {
        return preferredAttributes.size != originalAttributes.size
    }

    // NOTE: This method is never called
    override func invalidationContext(forPreferredLayoutAttributes preferredAttributes: NSCollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: NSCollectionViewLayoutAttributes) -> NSCollectionViewLayoutInvalidationContext {
        let rawContext = super.invalidationContext(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes)
        guard let context = rawContext as? InvalidationContext else {
            print("🥥")
            return rawContext
        }
        print("🍇")
        context.preferredLayoutAttributes = preferredAttributes
        context.contentSizeAdjustment.height = preferredAttributes.size.height - originalAttributes.size.height
        let invalidAttributes = cachedItemAttributes.values.filter { attributes in
            attributes.frame.origin.y >= preferredAttributes.frame.origin.y
        }
        let invalidItemIndexPaths = Set(invalidAttributes.compactMap { $0.indexPath })
        context.invalidateItems(at: invalidItemIndexPaths)
        return context
    }

    // MARK: Bounds Change

    override func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
        return newBounds.width != cachedContentBounds.width
    }

    override func invalidationContext(forBoundsChange newBounds: NSRect) -> NSCollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds)
        context.contentSizeAdjustment.width = newBounds.width - cachedContentBounds.width
        return context
    }
}

// MARK: - Custom NSCollectionViewItem

class TextFieldItem: NSCollectionViewItem {
    override func loadView() {
        view =  NSTextField(frame: NSRect(x: 0, y: 0, width: 100, height: 50))
        textField = view as? NSTextField
        textField!.lineBreakMode = .byWordWrapping
        textField!.drawsBackground = false
        textField!.isBordered = false
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    override func apply(_ layoutAttributes: NSCollectionViewLayoutAttributes) {
        textField!.preferredMaxLayoutWidth = layoutAttributes.size.width
        super.apply(layoutAttributes)
    }

    // NOTE: This method is never called
    override func preferredLayoutAttributesFitting(_ layoutAttributes: NSCollectionViewLayoutAttributes) -> NSCollectionViewLayoutAttributes {
        print("🍌")
        return super.preferredLayoutAttributesFitting(layoutAttributes)
    }
}

// MARK: - Test case useage

class DataSource: NSObject, NSCollectionViewDataSource {
    let identifier = NSUserInterfaceItemIdentifier(rawValue: "item")

    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        collectionView.register(TextFieldItem.self, forItemWithIdentifier: identifier)
        return 5
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
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

class ViewController: NSViewController {
    var dataSource: NSCollectionViewDataSource? = DataSource()
    var scrollView: NSScrollView! { return view as? NSScrollView }
    var collectionView: NSCollectionView!

    override func loadView() {
        let frame = NSRect(x: 0, y: 0, width: 300, height: 500)
        view = NSScrollView(frame: frame)
        collectionView = NSCollectionView(frame: frame)
        collectionView.collectionViewLayout = TestLayout()
        collectionView.dataSource = dataSource
        scrollView.documentView = collectionView
        scrollView.verticalScrollElasticity = .allowed
    }
}

let controller = ViewController()
PlaygroundPage.current.liveView = controller
