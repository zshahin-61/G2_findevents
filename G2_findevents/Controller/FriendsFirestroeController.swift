//
//  FriendsFirestroeController.swift
//  G2_findevents
//
//  Created by Golnaz Chehrazi on 2023-07-13.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
class FriendsFirestoreController: ObservableObject {
    
    //@Published var myEventsList: [MyEvent] = [MyEvent]()
    @Published var userProfile: UserProfile?
    @Published var myFriendsList: [Friend] = [Friend]()
    //@Published var stringMyFriendsList: [Friend] = [Friend]()
    private let COLLECTION_USER_PROFILES = "UserProfiles"
    private let db: Firestore
    private static var shared: FirestoreController?
    ////////////////
    private let COLLECTION_FRIENDS = "Friends"
    /////////
    private let FIELD_ID = "id"
    //private let FIELD_TITLE = "title"
    private let FIELd_FRIEND = "friendEmail"

    private var loggedInUserEmail: String = ""
    
    init(db: Firestore) {
        self.db = db
    }
    
    static func getInstance() -> FirestoreController {
        if self.shared == nil {
            self.shared = FirestoreController(db: Firestore.firestore())
        }
        return self.shared!
    }
    
    func getMyEventsList(){
        print(#function, "Trying to get all logged in user firned List.")
        self.myFriendsList = [Friend]()
        
        //get the email address of currently logged in user
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        //get the instance of Auth Helper to access all the user details
        //self.loggedInUserEmail = self.authHelper.user.email
        
        if (self.loggedInUserEmail.isEmpty){
            print(#function, "Logged in user's email address not available. Can't show my Events")
        }
        else{
            do{
                self.db
                    .collection(COLLECTION_USER_PROFILES)
                    .document(self.loggedInUserEmail)
                    .collection(COLLECTION_FRIENDS)
                    .addSnapshotListener({ (querySnapshot, error) in
                        
                        guard let snapshot = querySnapshot else{
                            print(#function, "Unable to retrieve data from database : \(error)")
                            return
                        }
                        
                        snapshot.documentChanges.forEach{ (docChange) in
                            
                            do{
                                //convert JSON document to swift object
                                var myFrd : Friend = try docChange.document.data(as: Friend.self)
                                
                                //get the document id so that it can be used for updating and deleting document
                                var documentID = docChange.document.documentID
                                
                                //set the firestore document id to the converted object
                                myFrd.id = documentID
                                
                                print(#function, "Document ID : \(documentID)")
                                
                                //if new document added, perform required operations
                                if docChange.type == .added{
                                    self.myFriendsList.append(myFrd)
                                    print(#function, "New document added : \(myFrd.friendEmail)")
                                }
                                
                                //get the index of any matching object in the local list for the firestore document that has been deleted or updated
                                let matchedIndex = self.myFriendsList.firstIndex(where: { ($0.id?.elementsEqual(documentID))! })
                                
                                //if a document deleted, perform required operations
                                if docChange.type == .removed{
                                    print(#function, " document removed : \(myFrd.friendEmail)")
                                    
                                    //remove the object for deleted document from local list
                                    if (matchedIndex != nil){
                                        self.myFriendsList.remove(at: matchedIndex!)
                                    }
                                }
                                
                                //if a document updated, perform required operations
                                if docChange.type == .modified{
                                    print(#function, " document updated : \(myFrd.friendEmail)")
                                    
                                    //update the existing object in local list for updated document
                                    if (matchedIndex != nil){
                                        self.myFriendsList[matchedIndex!] = myFrd
                                    }
                                }
                                
                            }catch let err as NSError{
                                print(#function, "Unable to convert the JSON doc into Swift Object : \(err)")
                            }
                            
                        }//ForEach
                        
                    })//addSnapshotListener
                
            }catch let err as NSError{
                print(#function, "Unable to get all logged in user events from database : \(err)")
            }//do..catch
        }//else
    }
    
    func insertFriend(newFriend : Friend){
        print(#function, "Inserting Friend: \(newFriend.friendEmail)")
        
        //get the email address of currently logged in user
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (self.loggedInUserEmail.isEmpty){
            print(#function, "Logged in user's email address not available. Can't add Event")
        }
        else{
            do{
                let docRef = db.collection(COLLECTION_USER_PROFILES)
                    .document(self.loggedInUserEmail).collection(COLLECTION_FRIENDS).document(newFriend.id!)
                try docRef.setData([FIELd_FRIEND : newFriend.friendEmail]){ error in
                    if let err = error {
                        print(#function, "Unable to Insert Friend in database : \(err)")
                    }else{
                        print(#function, "event \(newFriend.friendEmail) successfully added to database")
                    }
                    
                }
            }catch let err as NSError{
                print(#function, "Unable to add friend to database : \(err)")
            }//do..catch
        }//else
    }
    
    func deleteFriend(friendToDelete: Friend){
        print(#function, "Deleting Event \(friendToDelete.friendEmail)")
        
        //get the email address of currently logged in user
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (self.loggedInUserEmail.isEmpty){
            print(#function, "Logged in user's email address not available. Can't delete event")
        }
        else{
            do{
                try self.db
                    .collection(COLLECTION_USER_PROFILES)
                    .document(self.loggedInUserEmail)
                    .collection(COLLECTION_FRIENDS)
                    .document(friendToDelete.id!)
                    .delete{ error in
                        if let err = error {
                            print(#function, "Unable to delete friend from database : \(err)")
                        }else{
                            print(#function, "friend \(friendToDelete.friendEmail) successfully deleted from database")
                        }
                    }
            }catch let err as NSError{
                print(#function, "Unable to delete friend from database : \(err)")
            }
        }
    }
    
    func deleteAllMyEvents(){
        print(#function, "Deleting All My Friends")
        //getMyEventsList()
        for myFrd in self.myFriendsList{
            deleteFriend(friendToDelete: myFrd)
        }
    }
}
