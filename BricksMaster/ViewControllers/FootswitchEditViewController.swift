//
//  FootswitchEditViewController.swift
//  BricksMaster
//
//  Created by Kirill Shteffen on 16/01/2019.
//  Copyright © 2019 BlackBricks. All rights reserved.
//

import UIKit

class FootswitchEditViewController: UIViewController {
    
    var currentFootswitch: Footswitch?
    var currentBank: Bank?
    var currentBankButton: UIButton?
    
    @IBOutlet weak var currentFootswitchName: UILabel!
    
    @IBOutlet weak var bankButtonsView: UIView!
    
    @IBOutlet weak var presetButtonsView: UIView!
    
    @IBOutlet weak var firstPresetButtonView: UIView!
    @IBOutlet weak var firstPresetButtonLabel: UILabel!
    @IBOutlet weak var firstPresetOnOffButton: UIButton!
    @IBOutlet weak var firstPresetSelectButton: UIButton!
    
    @IBOutlet weak var secondPresetButtonView: UIView!
    @IBOutlet weak var secondPresetButtonLabel: UILabel!
    @IBOutlet weak var secondPresetOnOffButton: UIButton!
    @IBOutlet weak var secondPresetSelectButton: UIButton!
    
    @IBOutlet weak var thirdPresetButtonView: UIView!
    @IBOutlet weak var thirdPresetButtonLabel: UILabel!
    @IBOutlet weak var thirdPresetOnOffButton: UIButton!
    @IBOutlet weak var thirdPresetSelectButton: UIButton!
    
    @IBOutlet weak var fourthPresetButtonView: UIView!
    @IBOutlet weak var fourthPresetButtonLabel: UILabel!
    @IBOutlet weak var fourthPresetOnOffButton: UIButton!
    @IBOutlet weak var fourthPresetSelectButton: UIButton!
    
    @IBOutlet weak var banksCollection: UICollectionView!
    @IBOutlet weak var bricksCollection: UICollectionView!

    @IBOutlet weak var bankNameEditTextField: UITextField!
    @IBOutlet weak var bankNameEditUnderTextView: UIView!
    @IBOutlet weak var bankNameEditButton: UIView!

    var shadowView = UIView(frame: UIScreen.main.bounds)
    
    var banksController: BanksController?
    var bricksCollectionController: BricksCollectionController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bankNameEditTextField.delegate = self
        bankNameEditTextField.returnKeyType = UIReturnKeyType.done
        guard let currentFootswitch = self.currentFootswitch else { return }
        currentFootswitchName.text = currentFootswitch.name
        currentBank = currentFootswitch.banks.first
        
        bricksCollectionController = BricksCollectionController(collection: bricksCollection, footswitch: currentFootswitch)
        bricksCollectionController?.delegate = self
        
        banksController = BanksController(collection: banksCollection, footswitch: currentFootswitch)
        banksController?.delegate = self
        
        bankNameEditView.layer.cornerRadius = 8
        bankNameEditView.layer.masksToBounds = true
        bankNameEditUnderTextView.layer.cornerRadius = 4
        bankNameEditButton.layer.cornerRadius = 6
        
        shadowView.backgroundColor = UIColor.black
        shadowView.alpha = 0.0
        shadowView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeBankNameEdit(_:))))
        self.view.addSubview(shadowView)
        firstPresetButtonView.layer.cornerRadius = 4
        secondPresetButtonView.layer.cornerRadius = 4
        thirdPresetButtonView.layer.cornerRadius = 4
        fourthPresetButtonView.layer.cornerRadius = 4

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UserDevicesManager.default.footswitchController = self
        
        guard let currentFootswitch = self.currentFootswitch else { return }
        if currentFootswitch.banks.count != 0 {
            //
            configurePresetButtons()
        }
        shadowView.frame = self.view.bounds
        banksController?.updateSelection()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UserDevicesManager.default.footswitchController = nil
    }
    

    
    @IBAction func closeEditController(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func bankSelected(_ sender: UIButton) {
        guard let currentFootswitch = self.currentFootswitch else { return }
        if sender.titleLabel?.text == "NewBank" {
            let newBank: Bank = Bank(id: UUID().uuidString, name: bankNameEditTextField.text ?? "Unnamed")
            currentFootswitch.banks.append(newBank)
            currentBank = currentFootswitch.banks.last
            footswitchEditView.alpha = 0.4
            footswitchEditView.isUserInteractionEnabled = false
            self.view.addSubview(bankNameEditView)
            bankNameEditView.center = self.view.center
        }
        
        configurePresetButtons()
        currentFootswitch.save()
    }
    @IBOutlet weak var footswitchEditView: UIView!
    
    @IBOutlet var bankNameEditView: UIView!
    
    
    
    func openBankNameEdit() {
        configurePresetButtons()
        footswitchEditView.isUserInteractionEnabled = false
        self.view.addSubview(bankNameEditView)
        let size = CGSize(width: self.view.bounds.width * 0.9, height: 190)
        let bankNameEditFrame = CGRect(x: self.view.bounds.width * 0.05, y: self.view.bounds.height, width: size.width, height: size.height)
        self.bankNameEditView.frame = bankNameEditFrame
        
        UIView.animate(withDuration: 0.3, animations: {
            self.shadowView.alpha = 0.45
            self.bankNameEditView.frame = CGRect(x: bankNameEditFrame.origin.x, y: self.view.bounds.midY - 120, width: size.width, height: size.height)
        }) { (isFinished) in
            self.becomeFirstResponder()
        }
    }
    
    @IBAction func closeBankNameEdit(_ sender: Any) {
        if let selected = banksController?.selectedIndex {
            banksCollection.selectItem(at: selected, animated: false, scrollPosition: .left)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.shadowView.alpha = 0.0
            let size = CGSize(width: self.view.bounds.width * 0.9, height: 190)
            self.bankNameEditView.frame = CGRect(x: self.view.bounds.width * 0.05, y: self.view.bounds.height, width: size.width, height: size.height)
        }) { (isFinished) in
            self.becomeFirstResponder()
            self.footswitchEditView.isUserInteractionEnabled = true
            self.bankNameEditView.removeFromSuperview()
        }
    }
    
    @IBAction func saveEditedBankName(_ sender: UIButton) {
        currentBank?.name = bankNameEditTextField.text
        currentBank?.empty = false
        if let selected = currentFootswitch?.banks.firstIndex(where: { (bank) -> Bool in
            return bank.id == currentBank?.id
        }) {
            banksCollection.selectItem(at: IndexPath(item: selected, section: 0), animated: false, scrollPosition: .left)
        }
        banksController?.update()
        currentBank?.save()
        UIView.animate(withDuration: 0.3, animations: {
            self.shadowView.alpha = 0.0
            let size = CGSize(width: self.view.bounds.width * 0.9, height: 190)
            self.bankNameEditView.frame = CGRect(x: self.view.bounds.width * 0.05, y: self.view.bounds.height, width: size.width, height: size.height)
        }) { (isFinished) in
            self.becomeFirstResponder()
            self.footswitchEditView.isUserInteractionEnabled = true
            self.bankNameEditView.removeFromSuperview()
        }
    }
    
    
    @IBAction func openPresetPicker(_ sender: UIButton) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let desVC = mainStoryboard.instantiateViewController(withIdentifier: "PresetPickerViewController") as? PresetPickerViewController else {
            return
        }
        desVC.editedFootswitch = self.currentFootswitch
        desVC.editedBank = self.currentBank
        switch sender {
        case firstPresetSelectButton:
            desVC.footswitchButtonNumber = 0
        case secondPresetSelectButton:
            desVC.footswitchButtonNumber = 1
        case thirdPresetSelectButton:
            desVC.footswitchButtonNumber = 2
        case fourthPresetSelectButton:
            desVC.footswitchButtonNumber = 3
        default:
            return
        }
        desVC.completion = {
            self.configurePresetButtons()
        }
        present(desVC, animated: false, completion: nil)
    }
    
    
    @IBAction func onOffFootswitchButton(_ sender: UIButton) {
        guard let selectedBank = currentBank, let currentFootswitch = currentFootswitch else {
            return
        }
        var footswitchButtons = selectedBank.footswitchButtons
        var selectedPreset: Preset? = nil
        var selectedButton = -1;
        switch sender {
        case firstPresetOnOffButton:
            selectedButton = 0;
            guard footswitchButtons[0].preset != nil else { return }
            selectedPreset = footswitchButtons[0].preset
            if footswitchButtons[0].isOn == false{
                footswitchButtons[0].isOn = true
                footswitchButtons[1].isOn = false
                footswitchButtons[2].isOn = false
                footswitchButtons[3].isOn = false
            } else {
                for button in footswitchButtons {
                    button.isOn = false
                }
            }
        case secondPresetOnOffButton:
            selectedButton = 1;
            guard footswitchButtons[1].preset != nil else { return }
            selectedPreset = footswitchButtons[1].preset
            if footswitchButtons[1].isOn == false {
                footswitchButtons[0].isOn = false
                footswitchButtons[1].isOn = true
                footswitchButtons[2].isOn = false
                footswitchButtons[3].isOn = false
            } else {
                for button in footswitchButtons {
                    button.isOn = false
                }
            }
        case thirdPresetOnOffButton:
            selectedButton = 2;
            guard footswitchButtons[2].preset != nil else { return }
            selectedPreset = footswitchButtons[2].preset
            if footswitchButtons[2].isOn == false {
                footswitchButtons[0].isOn = false
                footswitchButtons[1].isOn = false
                footswitchButtons[2].isOn = true
                footswitchButtons[3].isOn = false
            } else {
                for button in footswitchButtons {
                    button.isOn = false
                }
            }
        case fourthPresetOnOffButton:
            selectedButton = 3;
            guard footswitchButtons[3].preset != nil else { return }
            selectedPreset = footswitchButtons[3].preset
            if footswitchButtons[3].isOn == false {
                footswitchButtons[0].isOn = false
                footswitchButtons[1].isOn = false
                footswitchButtons[2].isOn = false
                footswitchButtons[3].isOn = true
            } else {
                for button in footswitchButtons {
                    button.isOn = false
                }
            }
        default:
            return
        }
        configurePresetButtons()
        if let selectedPreset = selectedPreset {
            UserDevicesManager.default.sendPreset(preset: selectedPreset, to: currentFootswitch)
            UserDevicesManager.default.lightButton(id: selectedButton, to: currentFootswitch, on: footswitchButtons[selectedButton].isOn)
            selectedPreset.saveInBackground()
        }
    }
    
    func newBankSelected(bank: Bank, index: Int) {
        currentBank = bank
        let path = IndexPath(item: index, section: 0)
        banksController?.selectedIndex = IndexPath(item: index, section: 0)
        banksCollection.selectItem(at: path, animated: true, scrollPosition: .left)
        configurePresetButtons()
    }
    
    func configurePresetButtons() {
        guard let selectedBank = currentBank else {
            return
        }
        var footswitchButtons = selectedBank.footswitchButtons
        firstPresetButtonLabel.text = footswitchButtons[0].preset?.name ?? "None"
        secondPresetButtonLabel.text = footswitchButtons[1].preset?.name ?? "None"
        thirdPresetButtonLabel.text = footswitchButtons[2].preset?.name ?? "None"
        fourthPresetButtonLabel.text = footswitchButtons[3].preset?.name ?? "None"
        
        
        if footswitchButtons[0].isOn == true && footswitchButtons[0].preset != nil
        {
            firstPresetOnOffButton.setTitle("ON", for: .normal)
            firstPresetOnOffButton.backgroundColor = UIColor.white
            firstPresetButtonView.backgroundColor = UIColor(hexString: "6A9BD5")
        } else {
            firstPresetOnOffButton.setTitle("OFF", for: .normal)
            firstPresetOnOffButton.backgroundColor = UIColor(hexString: "6A9BD5").withAlphaComponent(0.3)
            firstPresetButtonView.backgroundColor = UIColor(hexString: "6A9BD5").withAlphaComponent(0.1)
        }
        if footswitchButtons[1].isOn == true && footswitchButtons[1].preset != nil
        {
            secondPresetOnOffButton.setTitle("ON", for: .normal)
            secondPresetOnOffButton.backgroundColor = UIColor.white
            secondPresetButtonView.backgroundColor = UIColor(hexString: "6A9BD5")
        } else {
            secondPresetOnOffButton.setTitle("OFF", for: .normal)
            secondPresetOnOffButton.backgroundColor = UIColor(hexString: "6A9BD5").withAlphaComponent(0.3)
            secondPresetButtonView.backgroundColor = UIColor(hexString: "6A9BD5").withAlphaComponent(0.1)
        }
        if footswitchButtons[2].isOn == true && footswitchButtons[2].preset != nil
        {
            thirdPresetOnOffButton.setTitle("ON", for: .normal)
            thirdPresetOnOffButton.backgroundColor = UIColor.white
            thirdPresetButtonView.backgroundColor = UIColor(hexString: "6A9BD5")
        } else {
            thirdPresetOnOffButton.setTitle("OFF", for: .normal)
            thirdPresetOnOffButton.backgroundColor = UIColor(hexString: "6A9BD5").withAlphaComponent(0.3)
            thirdPresetButtonView.backgroundColor = UIColor(hexString: "6A9BD5").withAlphaComponent(0.1)
        }
        if footswitchButtons[3].isOn == true && footswitchButtons[3].preset != nil
        {
            fourthPresetOnOffButton.setTitle("ON", for: .normal)
            fourthPresetOnOffButton.backgroundColor = UIColor(hexString: "6A9BD5").withAlphaComponent(0.3)
            fourthPresetButtonView.backgroundColor = UIColor(hexString: "6A9BD5")
        } else {
            fourthPresetOnOffButton.setTitle("OFF", for: .normal)
            fourthPresetOnOffButton.backgroundColor = UIColor(hexString: "6A9BD5").withAlphaComponent(0.3)
            fourthPresetButtonView.backgroundColor = UIColor(hexString: "6A9BD5").withAlphaComponent(0.1)
        }
    }
    
}
extension FootswitchEditViewController: PinIOModuleManagerDelegate {
    
    func onPinIODidReceivePinState() {
        configurePresetButtons()
    }
}
extension FootswitchEditViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        currentBank?.name = bankNameEditTextField.text
        bankNameEditView.removeFromSuperview()
        footswitchEditView.alpha = 1
        footswitchEditView.isUserInteractionEnabled = true
        guard let button = currentBankButton else { return false}
        return true
    }
    
}

extension FootswitchEditViewController: BanksControllerDelegate {
   
    func didCreateNew(bank: Bank) {
        currentBank = bank
        openBankNameEdit()
    }
    
    func selectedBank(bank: Bank) {
        currentBank = bank
        configurePresetButtons()
    }
    
}
