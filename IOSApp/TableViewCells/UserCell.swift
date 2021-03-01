//
//  UserCell.swift
//  IOSApp
//
//  Created by Dimitar on 1.2.21.
//

import UIKit
import SnapKit

protocol UserCellDelegate: class {
    func requestGameWith(user: User)
}

class UserCell: UITableViewCell {
        
    private lazy var holderView: UIView = {
        let imageView = UIView()
        imageView.backgroundColor = UIColor.white
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
     lazy var lblUsername: UILabel = {
       var label = UILabel()
        label.textColor = UIColor(named: "systemOposite")
        return label
    }()
    
    lazy var userImage: UIImageView = {
        var image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    private lazy var btnStart: UIButton = {
       var button = UIButton()
        button.setImage(UIImage(named: "play"),for: .normal)
        //button.setTitle("Start Game", for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
//        button.setTitleColor(UIColor(named: "systemOposite"), for: .normal)
//        button.layer.borderWidth = 1.0
//        button.layer.borderColor = .none
//        button.layer.cornerRadius = 5
//        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(onStart), for: .touchUpInside)
        return button
    }()
    
    private var user: User?
    weak var delegate: UserCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) //.zero
        separatorInset = .zero
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(holderView)
        holderView.addSubview(userImage)
        holderView.addSubview(lblUsername)
        holderView.addSubview(btnStart)
        
        holderView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview()
        }
        
        userImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.bottom.equalToSuperview().inset(10)
            make.width.equalTo(45)
          //  make.trailing.equalTo(lblUsername.snp.leading).inset(10)
        }
        
        lblUsername.snp.makeConstraints { make in
            make.left.equalTo(userImage.snp.right).offset(30)
            make.top.bottom.equalToSuperview()
            make.trailing.equalTo(btnStart.snp.leading).inset(10)
        }
        
        btnStart.snp.makeConstraints { make in
            make.top.bottom.equalTo(holderView).inset(18)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
    }
    @objc private func onStart() {
        guard let user = user else { return }
        delegate?.requestGameWith(user: user)
        btnStart.isHidden = true
    }
    
    func setData(user: User) {
        self.user = user
        lblUsername.text = user.username
        if let avatarImage = user.avatarImage {
            userImage.image = UIImage(named: avatarImage)
        } else {
            userImage.image = UIImage(named: "avatarOne")
        }
        
        //userImage.image = UIImage(named:"avatarOne")
        
    }
    
}
