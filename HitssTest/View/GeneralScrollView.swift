//
//  GeneralScrollView.swift
//  HitssTest
//
//  Created by Sergio Acosta Vega on 9/6/21.
//

import UIKit

class GeneralScrollView: UIScrollView {
    
    var padding = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)

    public lazy var containerView: UIView = {
        let cView = UIView()
        cView.translatesAutoresizingMaskIntoConstraints = false
        cView.backgroundColor = .clear
        cView.isUserInteractionEnabled = true
        return cView
    }()
    
    init(padding: UIEdgeInsets? = nil) {
        super.init(frame: .zero)
        if let padding = padding {
            self.padding = padding
        }
        setupScroll()
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupScroll() {
        bounces = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        keyboardDismissMode = .onDrag
        
        backgroundColor = UIColor(named: "backgroundDetail")
        
        addSubview(containerView)
        
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding.left).isActive = true
        containerView.topAnchor.constraint(equalTo: topAnchor, constant: padding.top).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: padding.right).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: padding.bottom).isActive = true
        containerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
}
