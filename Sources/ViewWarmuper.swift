//
//  ViewWarmuper.swift
//  WebViewWarmuper
//
//  Created by Tomoya Hayakawa on 2019/02/10.
//  Copyright © 2019年 simorgh3196. All rights reserved.
//

open class ViewWarmuper<View: UIView> {

    public typealias ViewFactory = () -> View

    private var queuedViews: [View]
    private let warmupQueue = DispatchQueue(label: "ViewWarmuper." + UUID().uuidString, qos: .background)

    public let maxSize: UInt
    public let viewFactory: ViewFactory

    public var currentSize: UInt {
        return UInt(queuedViews.count)
    }

    public init(maxSize: UInt, viewFactory: @escaping ViewFactory) {
        queuedViews = []
        self.maxSize = maxSize
        self.viewFactory = viewFactory
    }

    public func warmup(_ count: UInt, completion: (() -> Void)? = nil) {
        warmupQueue.async {
            for _ in 0 ..< count {
                guard self.currentSize < self.maxSize else {
                    break
                }

                var newView: View!
                DispatchQueue.main.sync {
                    newView = self.viewFactory()
                }
                self.queuedViews.append(newView)
            }
            completion?()
        }
    }

    public func warmupUpToSize(completion: (() -> Void)? = nil) {
        warmupQueue.async {
            let count = self.maxSize - self.currentSize
            self.warmup(count, completion: completion)
        }
    }

    public func getView() -> View? {
        guard let view = queuedViews.first else { return nil }
        queuedViews = Array(queuedViews.dropFirst())
        return view
    }
}
