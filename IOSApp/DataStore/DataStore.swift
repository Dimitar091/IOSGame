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

class DataStore {
    
    enum FirebaseCollections: String {
        case users
        case gameRequests
    }
        
    static let shared = DataStore()
    
    let database = Firestore.firestore()
    
    var localUser: User? {
        didSet {
            if localUser?.avatarImage == nil {
                // one solution 
               //localUser?.avatarImage = avatars.randomElement()
                localUser?.setRandomImage()
                guard let localUser = localUser else { return }
                DataStore.shared.save(user: localUser) { (_, _) in
                }
            }
        }
    }
        
    
    var usersListener: ListenerRegistration?
    
    var gameRequestListener: ListenerRegistration?
    var gameRequestDelitionListener: ListenerRegistration?
    
    
    init() {}
    
    func continueWithGuest(completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        Auth.auth().signInAnonymously { (result, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            if let currentUser = result?.user {
//                var avatar = "avatarOne"
//                if let randomAvatar = ["avatarOne","avatarTwo","avatarThree"].randomElement() {
//                    avatar = randomAvatar
//                }                                                                       //avatar
                let localUser = User.createUser(id: currentUser.uid, username: "Error")
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
