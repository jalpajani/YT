//
//  PhoneContacts.swift
//  PayIt
//
//  Created by vivek versatile on 21/02/18.
//  Copyright © 2018 Kaira NewMac. All rights reserved.
//

import Foundation
import ContactsUI

class PhoneContacts {
    
    class func getContacts() -> [CNContact] {
        var results: [CNContact] = []
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactMiddleNameKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor,CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactThumbnailImageDataKey as CNKeyDescriptor, CNContactImageDataAvailableKey as CNKeyDescriptor])
        
        fetchRequest.sortOrder = CNContactSortOrder.userDefault
        
        let store = CNContactStore()
        
        do {
            try store.enumerateContacts(with: fetchRequest, usingBlock: { (contact, stop) -> Void in
                print(contact.phoneNumbers.first?.value ?? "no")
                results.append(contact)
                
            })
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        return results
    }
}
