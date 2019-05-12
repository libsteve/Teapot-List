//
//  ListViewController.swift
//  Teapot List
//
//  Created by Steve Brunwasser on 4/4/19.
//  Copyright © 2019 Steve Brunwasser. All rights reserved.
//

import Cocoa

class ListViewController: NSViewController {
    var dataSource: NSCollectionViewDataSource? = TeapotDataSource()
    var scrollView: NSScrollView!
    var collectionView: NSCollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView = NSScrollView()
        collectionView = NSCollectionView()
        collectionView.collectionViewLayout = ListLayout()
        collectionView.dataSource = dataSource
        scrollView.documentView = collectionView
        scrollView.verticalScrollElasticity = .allowed
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
                                     scrollView.heightAnchor.constraint(equalTo: view.heightAnchor),
                                     scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
    }
}
