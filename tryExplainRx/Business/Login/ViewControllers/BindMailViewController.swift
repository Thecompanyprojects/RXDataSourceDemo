//
//  BindMailViewController.swift
//
//
//  Created by  on 2019/4/25.
//  Copyright © . All rights reserved.
//

import UIKit
import RxSwift

class BindMailViewController: BaseViewController {
    private var viewModel: BindMailViewModel?
    var facebookToken: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    private func initUI() {
        self.edgesForExtendedLayout = .bottom
        self.navigationItem.title = "V E R Y V O G A"
        initNavigationBackBar()
        layoutUI()
    }
    
    
    private func boundViewModel(textField:UITextField,button:UIButton) {
        viewModel = BindMailViewModel(eamil: textField.rx.text.orEmpty.asObservable())
        
        viewModel?.emailValid.bind(onNext: { (result) in
            button.backgroundColor = result ? mThemeLabelNormalColor : mThemeGrayColor
            button.isEnabled = result
        }).disposed(by: rx.disposeBag)
        
        button.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let strongSelf = self else { return }
            ProgressHUD.showLoadingIn(strongSelf.navigationController!.view)
           
        }).disposed(by: rx.disposeBag)
    }
    
    private func layoutUI() {
        let imageView = UIImageView(image: mImage(name: "finished"))
        
        let titleLabel = UILabel().then {
            $0.text = "FacebookAuthComplete"
            $0.numberOfLines = 0
            $0.font = mThemeNormalFont
            $0.textColor = mThemeLabelNormalColor
            $0.textAlignment = .center
            $0.lineBreakMode = .byWordWrapping
        }
        
        let provideEmailLabel = UILabel().then {
            $0.text = "ProvideEmailAddress"
            $0.numberOfLines = 0
            $0.textColor = mThemeGrayColor
            $0.font = mThemeNormalFont
            $0.textAlignment = .center
            $0.lineBreakMode = .byWordWrapping
        }
        
        let textField = UITextField().then {
            $0.placeholder = "E-mail Address"
            $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
            $0.leftViewMode = .always
            $0.clearButtonMode = .whileEditing
            $0.layer.borderWidth = 2;
            $0.layer.borderColor = mRGBA(231,233 ,231, 1).cgColor
            $0.layer.backgroundColor = mRGBA(255, 254, 254, 1).cgColor
            $0.layer.cornerRadius = 4;
        }
        
        let button = UIButton().then {
            $0.setTitle("SUBMIT", for: .normal)
            $0.backgroundColor = mThemeLabelNormalColor
            $0.layer.cornerRadius = 4
            $0.clipsToBounds = true
        }
        
        let noteLabel = UILabel().then {
            $0.text = "NoteEmailAlert"
            $0.numberOfLines = 0
            $0.textColor = mThemeGrayColor
            $0.font = mThemeNormalFont
            $0.textAlignment = .center
            $0.lineBreakMode = .byWordWrapping
        }
        
        
        self.view.addSubview(imageView)
        self.view.addSubview(titleLabel)
        self.view.addSubview(provideEmailLabel)
        self.view.addSubview(textField)
        self.view.addSubview(button)
        self.view.addSubview(noteLabel)
        
        imageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(67)
            make.top.equalTo(self.view).offset(51)
            make.centerX.equalTo(self.view)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(48)
            make.right.equalTo(self.view).offset(-48)
            make.top.equalTo(imageView.snp.bottom).offset(18)
        }
        
        provideEmailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(35)
            make.width.equalTo(titleLabel)
            make.centerX.equalTo(titleLabel)
        }
        
        textField.snp.makeConstraints { (make) in
            make.top.equalTo(provideEmailLabel.snp.bottom).offset(6)
            make.width.equalTo(titleLabel)
            make.height.equalTo(40)
            make.centerX.equalTo(titleLabel)
        }
        button.snp.makeConstraints { (make) in
            make.top.equalTo(textField.snp.bottom).offset(22)
            make.width.equalTo(titleLabel)
            make.height.equalTo(40)
            make.centerX.equalTo(titleLabel)
        }
        
        noteLabel.snp.makeConstraints { (make) in
            make.top.equalTo(button.snp.bottom).offset(9)
            make.width.equalTo(titleLabel)
            make.centerX.equalTo(titleLabel)
        }
        boundViewModel(textField: textField, button: button)
        
    }
}
