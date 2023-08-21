//
//  SettingViewController.swift
//  lesson209
//
//  Created by Garib Agaev on 21.08.2023.
//

import UIKit

final class SettingViewController: UIViewController {
    
    var delegate: SettingViewControllerDelegate!
    var settingColor: UIColor! {
        didSet {
            if settingColor == nil { settingColor = .black }
            updateStackViewsData()
            updateColor()
        }
    }
    
    private let sliderMinMax: (min: Float, max: Float) = (0, 1)
    
    private let colorsNames: [(color: UIColor, name: String)] = [
        (.red, "Red"),
        (.green, "Green"),
        (.blue, "Blue")
    ]
    
    private var stackViews: [UIColor: (nameLabel: UILabel, valLable: UILabel, slider: UISlider, textField: UITextField)] = [:]
    
    private var beforeTextInTextField = "0.00"
    
    private let colorScreen = UIView()
    private let stackFull = UIStackView()
    private let doneButton = UIButton()
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        getStackViews()
        settingStackFull()
        settingColorScreen()
        settingDoneButton()
        updateStackViewsData()
        addAllSubViews()
        addMaskFalse()
        setConstraints()
        
        for (_, b) in stackViews {
            b.slider.addTarget(self, action: #selector(targetOFSlider), for: .valueChanged)
            b.textField.delegate = self
        }
        doneButton.addTarget(self, action: #selector(targetDoneButton), for: .touchUpInside)
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    @objc private func targetOFSlider(sender: UISlider) {
        guard let color = sender.minimumTrackTintColor else { return }
        setRGVValue(color, sender.value)
    }
    
    @objc private func targetDoneButton() {
        dismiss(animated: true)
        delegate.setcolor(colorScreen.backgroundColor)
    }
    
    func convertColor() {
        
    }
}

//MARK: Генерация коллекций
private extension SettingViewController {
    
    func getRGBValue(_ color: UIColor) -> [CGFloat] {
        var red: CGFloat = 0.0, green = red, blue = red, alpha = red
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [red, green, blue]
    }
    
    func setRGVValue(_ color: UIColor, _ value: Float) {
        let rgb = getRGBValue(color).map { $0 * CGFloat(value)}
        let newColor = zip(rgb, getRGBValue(settingColor)).map { $0 == 0 ? $1 : $0 }
        settingColor = getColor(red: newColor[0], green: newColor[1], blue: newColor[2])
    }
    
    func getStackViews() {
        for (rgb, name) in colorsNames {
            let nameLabel = UILabel()
            nameLabel.text = name
            nameLabel.textColor = rgb
            
            let valLable = UILabel()
            valLable.textColor = rgb
            
            let slider = UISlider()
            slider.maximumValue = sliderMinMax.max
            slider.minimumValue = sliderMinMax.min
            slider.minimumTrackTintColor = rgb
            slider.maximumTrackTintColor = .white
            
            let textField = UITextField()
            textField.textColor = rgb
            stackViews[rgb] = (nameLabel, valLable, slider, textField)
        }
    }
}

//MARK: Настройки основных вью
private extension SettingViewController {
    
    func settingColorScreen() {
        colorScreen.layer.cornerRadius = 10
    }
    
    func settingDoneButton() {
        doneButton.setTitle("Done", for: .normal)
        doneButton.layer.cornerRadius = 10
    }
    
    func updateStackViewsData() {
        let pair = zip(colorsNames.map {$0.color}, getRGBValue(settingColor))
        for (rgb, val) in pair {
            guard let tuple = stackViews[rgb] else { return }
            let text = String(format: "%.2f", val)
            tuple.valLable.text = text
            tuple.slider.setValue(Float(val), animated: true)
            tuple.textField.text = text
        }
    }
    
    func getColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    func getInvertSettingColor() -> UIColor {
        let a = getRGBValue(settingColor)
        return getColor(red: 1 - a[0], green: 1 - a[1], blue: 1 - a[2])
    }
    
    func updateColor() {
        let invertColor = getInvertSettingColor()
        
        view.backgroundColor = invertColor
        doneButton.setTitleColor(invertColor, for: .normal)
        colorScreen.backgroundColor = settingColor
        doneButton.backgroundColor = settingColor
    }
    
    func settingVerticalStack() -> [UIStackView] {
        var arrayStack = Array(repeating: stackFull, count: 4)
        for i in 0..<arrayStack.count {
            arrayStack[i] = UIStackView()
            arrayStack[i].axis = .vertical
            arrayStack[i].distribution = .fillProportionally
            stackFull.addArrangedSubview(arrayStack[i])
        }
        return arrayStack
    }
    
    func settingStackFull() {
        stackFull.distribution = .fill
        stackFull.axis = .horizontal
        stackFull.spacing = 10
        
        let arrayStack = settingVerticalStack()
        
        for (rgb, _) in colorsNames {
            guard let myViews = stackViews[rgb] else { return }
            arrayStack[0].addArrangedSubview(myViews.nameLabel)
            arrayStack[1].addArrangedSubview(myViews.valLable)
            arrayStack[2].addArrangedSubview(myViews.slider)
            arrayStack[3].addArrangedSubview(myViews.textField)
        }
    }
    
    func addAllSubViews() {
        [colorScreen, stackFull, doneButton].forEach {
            view.addSubview($0)
        }
    }
    
    func addMaskFalse() {
        [colorScreen, stackFull, doneButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}

//MARK: Настройки констреинтов
private extension SettingViewController {
    func setConstraints() {
        NSLayoutConstraint.activate([
            NSLayoutConstraint(
                item: colorScreen, attribute: .centerX,
                relatedBy: .equal,
                toItem: view.safeAreaLayoutGuide, attribute: .centerX,
                multiplier: 1, constant: 0
            ),
            NSLayoutConstraint(
                item: colorScreen, attribute: .width,
                relatedBy: .equal,
                toItem: view.safeAreaLayoutGuide, attribute: .width,
                multiplier: 0.9, constant: 0
            ),
            NSLayoutConstraint(
                item: colorScreen, attribute: .top,
                relatedBy: .equal,
                toItem: view.safeAreaLayoutGuide, attribute: .top,
                multiplier: 1, constant: 16
            ),
            NSLayoutConstraint(
                item: colorScreen, attribute: .height,
                relatedBy: .equal,
                toItem: view.safeAreaLayoutGuide, attribute: .height,
                multiplier: 0.3, constant: 0
            ),
            NSLayoutConstraint(
                item: stackFull, attribute: .centerX,
                relatedBy: .equal,
                toItem: view.safeAreaLayoutGuide, attribute: .centerX,
                multiplier: 1, constant: 0
            ),
            NSLayoutConstraint(
                item: stackFull, attribute: .width,
                relatedBy: .equal,
                toItem: colorScreen, attribute: .width,
                multiplier: 1, constant: 0
            ),
            NSLayoutConstraint(
                item: stackFull, attribute: .top,
                relatedBy: .equal,
                toItem: colorScreen, attribute: .bottom,
                multiplier: 1, constant: 16
            ),
            NSLayoutConstraint(
                item: stackFull, attribute: .height,
                relatedBy: .equal,
                toItem: colorScreen, attribute: .height,
                multiplier: 1, constant: -16
            ),
            NSLayoutConstraint(
                item: doneButton, attribute: .centerX,
                relatedBy: .equal,
                toItem: view.safeAreaLayoutGuide, attribute: .centerX,
                multiplier: 1, constant: 0
            ),
            NSLayoutConstraint(
                item: doneButton, attribute: .bottom,
                relatedBy: .equal,
                toItem: view.safeAreaLayoutGuide, attribute: .bottom,
                multiplier: 1, constant: -16
            ),
            NSLayoutConstraint(
                item: doneButton, attribute: .width,
                relatedBy: .greaterThanOrEqual,
                toItem: view.safeAreaLayoutGuide, attribute: .width,
                multiplier: 0.3, constant: 0
            )
        ])
    }
}

extension SettingViewController: UITextFieldDelegate {
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn: NSRange, replacementString: String) -> Bool {
//        if textField.text?.count ?? 0 >= 2 {
//            textField.text = String(format: "%.2f", textField.text!)
//            return true
//        } else {
//            return false
//        }
//    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        beforeTextInTextField = text
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard
            let text = textField.text,
            let newVal = Float(text),
            let color = textField.textColor,
            sliderMinMax.min <= newVal && newVal <= sliderMinMax.max
        else {
            textField.text = beforeTextInTextField
            return
        }
        setRGVValue(color, newVal)
    }
}

