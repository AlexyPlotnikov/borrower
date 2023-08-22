//
//  ContactController.swift
//  Borrower
//
//  Created by RX Group on 12.02.2021.
//

import UIKit
import Foundation
import ContactsUI

class ContactController: UIViewController {

    @IBOutlet weak var table: UITableView!
    var embededController:AddBorrowerController!
    var embededInvestor:AddInvestorController!
    var isInvestor = false
    var contacts:[CNContact] = []
    var searchContacts:[CNContact] = []
    @IBOutlet weak var searchBar: UISearchBar!
    var isSearch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contacts = self.getContact()
        table.reloadData()
        searchBar.delegate = self
        searchBar.returnKeyType = .search
        searchBar.enablesReturnKeyAutomatically = false

    }
    
    func getContact() -> [CNContact]{
        let contactStore = CNContactStore()
        var contacts = [CNContact]()
        let keys = [
                CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                        CNContactPhoneNumbersKey,
                        CNContactEmailAddressesKey
                ] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request){
                    (contact, stop) in
                contacts.append(contact)
            }
        } catch {

        }
        return contacts
    }


}


extension ContactController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearch ? searchContacts.count:contacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "contact"
        let cell:ContactCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ContactCell
        if(isSearch ? searchContacts[indexPath.row].phoneNumbers.count>0:contacts[indexPath.row].phoneNumbers.count>0){
            var phone = isSearch ? searchContacts[indexPath.row].phoneNumbers[0].value.stringValue:contacts[indexPath.row].phoneNumbers[0].value.stringValue
            if phone.prefix(1) == "+"{
                let prefix = "+7" // What ever you want may be an array and step thru it
                if (phone.hasPrefix(prefix)){
                    phone  = String(phone.dropFirst(prefix.count).trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }else  if phone.prefix(1) == "8"{
                let prefix = "8" // What ever you want may be an array and step thru it
                if (phone.hasPrefix(prefix)){
                    phone  = String(phone.dropFirst(prefix.count).trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
                cell.phoneLbl.text = phone
        }else{
            cell.phoneLbl.text = "Нет данных"
        }
        cell.nameLbl.text = isSearch ? searchContacts[indexPath.row].givenName:contacts[indexPath.row].givenName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(!isInvestor){
            embededController.borrower.title = isSearch ? searchContacts[indexPath.row].givenName: contacts[indexPath.row].givenName
        }else{
            embededInvestor.regInvestor.title = isSearch ? searchContacts[indexPath.row].givenName: contacts[indexPath.row].givenName
        }
        
        if(contacts[indexPath.row].phoneNumbers.count > 0){
            var phone = isSearch ? searchContacts[indexPath.row].phoneNumbers[0].value.stringValue:contacts[indexPath.row].phoneNumbers[0].value.stringValue
            if phone.prefix(1) == "+"{
                let prefix = "+" // What ever you want may be an array and step thru it
                if (phone.hasPrefix(prefix)){
                    phone  = String(phone.dropFirst(prefix.count).trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }else  if phone.prefix(1) == "8"{
                let prefix = "8" // What ever you want may be an array and step thru it
                if (phone.hasPrefix(prefix)){
                    phone  = String(phone.dropFirst(prefix.count).trimmingCharacters(in: .whitespacesAndNewlines))
                    phone = "7"+phone
                }
            }
            let vowels: Set<Character> = [" ", "(", ")", "-"]
            phone.removeAll(where: { vowels.contains($0) })
            if(!isInvestor){
                embededController.borrower.borrowerPhones[0] = phone
            }else{
                embededInvestor.regInvestor.investorPhones[0] = phone
            }
            self.dismiss(animated: true, completion: {
                if(!self.isInvestor){
                    self.embededController.collectionView.reloadData()
                }else{
                    self.embededInvestor.table.reloadData()
                }
            })
        }
    }

    
}

extension ContactController:UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.isSearch = searchText.count > 0
        self.searchContacts = self.contacts.filter({(($0.givenName).localizedCaseInsensitiveContains(searchText))})
        self.table.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.isSearch = false
        self.table.reloadData()
    }
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
}

