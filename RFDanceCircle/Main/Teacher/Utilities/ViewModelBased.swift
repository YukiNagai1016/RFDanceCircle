//
//  ViewModelBased.swift
//  R&FDanceCircleApp
//
//  Created by YukiNagai on 2020/01/30.
//  Copyright © 2020 YukiNagai. All rights reserved.
//

import Foundation
import UIKit

protocol ViewModelBased {
    associatedtype ViewModelType
    
    var viewModel: ViewModelType! { set get }
}


extension ViewModelBased where Self: UIViewController, Self: NibBased {

    // MARK: Static functions

    static func instantiate(viewModel: Self.ViewModelType) -> Self {
        var viewController = Self.init(nibName: self.nibName, bundle: Bundle(for: self))
        viewController.viewModel = viewModel
        return viewController
    }

}
