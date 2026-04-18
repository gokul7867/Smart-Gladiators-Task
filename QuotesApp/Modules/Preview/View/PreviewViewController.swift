//
//  PreviewViewController.swift
//  QuotesApp
//
//  Created by gokul gokul on 18/04/26.
//

import UIKit

final class PreviewViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    private let image: UIImage
    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: "PreviewViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
}
