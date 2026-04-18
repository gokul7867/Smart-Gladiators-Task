//
//  ViewController.swift
//  QuotesApp
//
//  Created by gokul gokul on 16/04/26.
//

import UIKit

class QuotesViewController: UIViewController {

    @IBOutlet private weak var loadingView: UIView!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var quotesCollectionView: UICollectionView!
        
    private var viewModel: QuotesViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupViewModel()
        bindViewModel()
        viewModel.fetchQuotes()
    }
    
    private func setupNavigationBar() {
        title = "Quotes"
        let cameraButton = UIBarButtonItem(
            image: UIImage(systemName: "camera.fill"),
            style: .plain,
            target: self,
            action: #selector(didTapCamera)
        )
        navigationItem.rightBarButtonItem = cameraButton
    }
    
    @objc private func didTapCamera() {
        navigateToCamera()
    }
    
    private func setupUI() {
        if let layout = quotesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            layout.minimumLineSpacing = 12
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        quotesCollectionView.dataSource = self
        quotesCollectionView.delegate = self
        let nib = UINib(nibName: "QuoteCell", bundle: nil)
        quotesCollectionView.register(nib, forCellWithReuseIdentifier: "QuoteCell")
        loadingView.isHidden = true
        activityIndicator.hidesWhenStopped = true
    }
    
    private func setupViewModel() {
        let apiService = APIService()
        viewModel = QuotesViewModel(service: apiService)
    }
    
    private func bindViewModel() {
        viewModel?.isLoading = { [weak self] isLoading in
            DispatchQueue.main.async {
                self?.showLoading(isLoading)
            }
        }
        viewModel.reloadData = { [weak self] in
            self?.quotesCollectionView.reloadData()
        }
        
        viewModel.onError = { [weak self] error in
            self?.showErrorAlert(error: error)
        }
    }
    
    private func showLoading(_ show: Bool) {
        loadingView.isHidden = !show
        if show {
            activityIndicator.startAnimating()
            view.isUserInteractionEnabled = false
        } else {
            activityIndicator.stopAnimating()
            view.isUserInteractionEnabled = true
        }
    }
    
    private func navigateToCamera() {
        let cameraVM = CameraViewModel()
        let cameraVC = CameraViewController(viewModel: cameraVM)
        navigationController?.pushViewController(cameraVC, animated: true)
    }
    
    private func showErrorAlert(error: AppError) {
        let alert = UIAlertController(
            title: error.title,
            message: error.message,
            preferredStyle: .alert
        )

        let retry = UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel?.fetchQuotes()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(retry)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
}

extension QuotesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.quotes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "QuoteCell",
            for: indexPath
        ) as? QuoteCell else {
            return UICollectionViewCell()
        }
        let quote = viewModel.quotes[indexPath.item]
        cell.configure(with: quote, index: indexPath.row)
        cell.onFavoriteTapped = { [weak self, weak collectionView] in
            guard let self = self,
                  let indexPath = collectionView?.indexPath(for: cell) else { return }
            self.viewModel.toggleFavorite(at: indexPath.item)
        }
        return cell
    }
}

