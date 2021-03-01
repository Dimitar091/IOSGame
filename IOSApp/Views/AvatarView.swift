//
//  AvatarView.swift
//  IOSApp
//
//  Created by Dimitar on 10.2.21.
//

import UIKit
import SnapKit

enum AvatarUIState {
    case loading
    case imageAndName
}

class AvatarView: UIView {
    
    var username: String? {
        didSet {
            if state == .imageAndName {
                lblUsername.textColor = UIColor(hex: "4A6495")
                lblUsername.textAlignment = .left

            } else {
                lblUsername.textColor = .white
                lblUsername.textAlignment = .center
            }
            lblUsername.text = username
            lblUsername.textAlignment = .center
        }
    }
    
    var image: String? {
        didSet {
            if let image = image {
            avatarImage.image = UIImage(named: image)
         }
      }
   }

   private lazy var lblUsername: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
   private lazy var lblWinsLoses: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var avatarImage: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 5
        return stackView
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 5
        return stackView
    }()
    
    var state: AvatarUIState
    init(state: AvatarUIState) {
        self.state = state
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        switch state {
        case .loading:
            addSubview(stackView)
            stackView.addArrangedSubview(lblUsername)
            stackView.addArrangedSubview(avatarImage)
            stackView.addArrangedSubview(lblWinsLoses)
        case .imageAndName:
            addSubview(horizontalStackView)
            horizontalStackView.addArrangedSubview(avatarImage)
            horizontalStackView.addArrangedSubview(lblUsername)
        }
        setupConstraints()
    }
    
    private func setupConstraints() {
        switch state {
        case .loading:
            stackView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            avatarImage.snp.makeConstraints { (make) in
                make.width.equalTo(85)
                make.height.equalTo(100)
            }
        case .imageAndName:
            horizontalStackView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            avatarImage.snp.makeConstraints { make in
                make.width.equalTo(45)
                make.height.equalTo(40)
            }
        }
    }
    
}
