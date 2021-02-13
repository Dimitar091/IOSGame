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
}

class AvatarView: UIView {
    
    var username: String? {
        didSet {
            lblUsername.text = username
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
        }
    }
    
}
