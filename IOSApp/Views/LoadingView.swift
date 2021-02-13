//
//  LoadingView.swift
//  IOSApp
//
//  Created by Dimitar on 10.2.21.
//

import UIKit
import SnapKit

class LoadingView: UIView {

    private lazy var avatarMe: AvatarView = {
        let avatar = AvatarView(state: .loading)
        return avatar
    }()
    
    private lazy var avatarOpponent: AvatarView = {
        let avatar = AvatarView(state: .loading)
        return avatar
    }()
    
    private lazy var lblVs: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 56, weight: .heavy)
        label.textColor = UIColor(hex: "#FFB24C")
        label.text = "VS"
        label.minimumScaleFactor = 0.5
        return label
    }()
    private lazy var lblRequestStatus: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor(hex: "#FFB24C")
        return label
    }()
    private lazy var gradientView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "gradientBackground"))
        return imageView
    }()
    
    private var me: User
    private var opponent: User
    
    init(me: User, opponent: User) {
        self.me = me
        self.opponent = opponent
        super.init(frame: .zero)
        backgroundColor = UIColor(hex: "#3545C8")
        setupViews()
        setupData()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(gradientView)
        addSubview(avatarMe)
        addSubview(lblVs)
        addSubview(avatarOpponent)
        addSubview(lblRequestStatus)
        
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        avatarMe.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.width.equalTo(130)
            make.height.equalTo(200)
            make.centerX.equalToSuperview()
            
        }
        lblVs.snp.makeConstraints { make in
            make.size.equalTo(80)
            make.top.equalTo(avatarMe.snp.bottom).offset(25)
            make.centerX.equalToSuperview()
        }
        avatarOpponent.snp.makeConstraints { make in
            make.width.equalTo(130)
            make.height.equalTo(200)
            make.centerX.equalToSuperview()
            make.top.equalTo(lblVs.snp.bottom).offset(25)
        }
        lblRequestStatus.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(30)
    }
  }
    
    private func setupData() {
        avatarMe.username = me.username
        avatarOpponent.username = opponent.username
        avatarMe.image = me.avatarImage ?? "avatarThree"
        avatarOpponent.image = opponent.avatarImage ?? "avatarOne"
        lblRequestStatus.text = "Waiting opponent"
    }
    
}
