//
//  MainViewController.swift
//  lesson209
//
//  Created by Garib Agaev on 21.08.2023.
//

import UIKit

protocol SettingViewControllerDelegate {
    func setcolor(_ color: UIColor?)
}

class MainViewController: UIViewController {

    let settingButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        settingBurButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let settingVC = segue.destination as? SettingViewController else { return }
        settingVC.modalPresentationStyle = .fullScreen
        settingVC.delegate = self
        settingVC.settingColor = view.backgroundColor
    }
    
    @objc private func showSettingView() {
        performSegue(withIdentifier: "settingVC", sender: nil)
    }
    
    private func settingBurButton() {
        settingButton.title = "⚙️"
        settingButton.style = .plain
        settingButton.target = self
        settingButton.action = #selector(showSettingView)
        navigationItem.rightBarButtonItem = settingButton
    }
}

extension MainViewController: SettingViewControllerDelegate {
    func setcolor(_ color: UIColor?) {
        view.backgroundColor = color
    }
}


