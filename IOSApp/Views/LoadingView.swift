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
    
    private lazy var btnClose: UIButton = {
        let button = UIButton()
        button.setTitle("X", for: .normal)
//        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium)
//        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        button.addTarget(self, action: #selector(onClose), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.tintColor = .black
        button.isHidden = true
        return button
    }()
    
    private var me: User
    private var opponent: User
    private var closeTimer: Timer?
    private var gameRequest: GameRequest?
    private var cancelGameTimer: Timer?
    private var elapsedSeaconds = 0
    
    var gameAccepted: ((_ game: Game) -> Void)?
    
    init(me: User, opponent: User, requset: GameRequest?) {
        self.me = me
        self.opponent = opponent
        gameRequest = requset
        super.init(frame: .zero)
        backgroundColor = UIColor(hex: "#3545C8")
        setupViews()
        setupData()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        // when superview is not nil then its adaSubview method
        if newSuperview != nil {
            setupTimers()
            setGameListener()
        }
        //when superview is nil then its removeFromSuperview
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupTimers() {
        closeTimer = Timer.scheduledTimer(timeInterval: CancelGameSeaconds, target: self, selector: #selector(enableCancelGame), userInfo: nil, repeats: false)
        cancelGameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
    }
    
    private func setGameListener() {
        DataStore.shared.setGameListener { [weak self] (game, _) in
            guard let game = game else { return }
            self?.gameAccepted?(game)
            self?.removeFromSuperview()
        }
    }
    
    @objc func enableCancelGame() {
        btnClose.isHidden = false
        closeTimer?.invalidate()
        closeTimer = nil
    }
    
    @objc func timerTick() {
        elapsedSeaconds += 1 // elapsedSeaconds = elapsedSeaconds + 1
        if elapsedSeaconds == WaitingGameSeaconds {
            cancelGameTimer = nil
            onClose()
        }
    }
    
    private func setupViews() {
        addSubview(gradientView)
        addSubview(avatarMe)
        addSubview(lblVs)
        addSubview(avatarOpponent)
        addSubview(lblRequestStatus)
        addSubview(btnClose)
        
        btnClose.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(20)
            make.size.equalTo(50)
        }
        
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
    
    @objc private func onClose() {
        guard let request = gameRequest else { return }
        cancelGameTimer?.invalidate()
        cancelGameTimer = nil
        DataStore.shared.deleteGameRequest(gameRequest: request)
        removeFromSuperview()
    }
}
