//
//  DataStore.swift
//  IOSApp
//
//  Created by Dimitar on 1.2.21.
//

import Foundation
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseMessaging

class DataStore {
    
    enum FirebaseCollections: String {
        case users
        case gameRequests
        case games
    }
        
    static let shared = DataStore()
    
    let database = Firestore.firestore()
    
    var localUser: User? {
        didSet {
//            if localUser?.avatarImage == nil {
                // one solution 
               //localUser?.avatarImage = avatars.randomElement()
                localUser?.setRandomImage()
                if localUser?.deviceToken == nil {
                setPushToken()
                }
                guard let localUser = localUser else { return }
                DataStore.shared.save(user: localUser) { (_, _) in
                }
//            }
        }
    }
        
    
    var usersListener: ListenerRegistration?
    var gameStatusListener: ListenerRegistration?
    var gameRequestListener: ListenerRegistration?
    var gameRequestDelitionListener: ListenerRegistration?
    var gameListener: ListenerRegistration?
    
    
    init() {}
    
    func setPushToken() {
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
            self.localUser?.deviceToken = token
            self.save(user: self.localUser!) { (_, _) in
                
            }
          }
        }
    }
    
    func checkForExistingUsername(_ username: String,_ comletion: @escaping(_ exists: Bool,_ error: Error?) -> Void) {
        let usernameRef = self.database.collection(FirebaseCollections.users.rawValue).whereField("username", isEqualTo: username)
        
        usernameRef.getDocuments { (snapshot, error) in
            if let snapshot = snapshot, snapshot.documents.count == 0 {
                comletion(false, nil)
                return
            }
            comletion(true, error)
        }
    }
    
    func continueWithGuest(username: String,completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        Auth.auth().signInAnonymously { (result, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            if let currentUser = result?.user {
                let localUser = User.createUser(id: currentUser.uid, username: username)
                    self.save(user: localUser, completion: completion)
            }
        }
    }
    
    func save(user: User ,completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        guard let userId = user.id else { return }
        let userRef = database.collection(FirebaseCollections.users.rawValue).document(userId)
        
        do {
            try userRef.setData(from: user) { error in
                completion(user, error)
            }
        } catch  {
            print(error.localizedDescription)
            completion(nil, error)
        }
    }
    
    func getAllUsers(completion: @escaping (_ users: [User]?,_ error: Error? )->Void) {
        let usersRef = database.collection(FirebaseCollections.users.rawValue)
            usersRef.getDocuments { (snapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                if let snapshot = snapshot {
                    do {
                        let users = try snapshot.documents.compactMap({ try $0.data(as: User.self) })
                        completion(users, nil)
                    } catch (let error) {
                        completion(nil, error)
                    }
                }
            }
   }
    func getUserWithId(id: String, completion: @escaping(_ user: User?,_ error: Error?) -> Void) {
        let userRef = database.collection(FirebaseCollections.users.rawValue).document(id)
        userRef.getDocument { (document, error) in
            if let document = document {
                do {
                    let user = try document.data(as: User.self)
                    completion(user, nil)
                } catch {
                    completion(nil, error)
                }
            }
        }
    }
    func setUsersListener(completion: @escaping () -> Void) {
        if usersListener != nil {
            usersListener?.remove()
            usersListener = nil
        }
        let userRef = database.collection(FirebaseCollections.users.rawValue)
        usersListener = userRef.addSnapshotListener{ (snapshot, error) in
        }
        userRef.addSnapshotListener { (snapshot, error) in
            if let snapshot = snapshot, snapshot.documents.count > 0 {
                completion()
            }
        }
    }
    func removeUsersListener() {
        usersListener?.remove()
        usersListener = nil
    }
}
