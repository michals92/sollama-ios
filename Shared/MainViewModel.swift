//
//  MainViewModel.swift
//  sense-ios
//
//  Created by Michal Šimík on 01.03.2022.
//

import Foundation
import SwiftUI
import Solana
import KeychainSwift

final class MainViewModel: ObservableObject {

    let network = NetworkingRouter(endpoint: .devnetSolana)
    let accountStorage = KeychainAccountStorageModule()
    let solana: Solana

    @Published var account: Account?
    @Published var phrase = ""
    private var seedPhrase = ConcreteSeedPhrase()
    @Published var accountInfo: AccountInfo?
    @Published var balance: String?


    init() {
        self.solana = Solana(router: network, accountStorage: accountStorage)
        switch accountStorage.account {
        case .success(let account):
            self.account = account
        case .failure(let error):
            print(error.localizedDescription)
        }
    }

//    func getAccountInfo() {
//        guard let account = account else {
//            return
//        }
//
//        solana.api.getAccountInfo(account: account.publicKey.base58EncodedString, decodedTo: AccountInfo.self) { result in
//            print(result)
//            switch result {
//            case.success(let accountInfo):
//                print(accountInfo)
//             //   self.accountInfo = accountInfo.data.value
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }

    func saveAccount() {
        let phrase = phrase.components(separatedBy: " ")
        let account = Account(phrase: phrase, network: .devnet)

        if let account = account {
            switch accountStorage.save(account) {
            case .failure(let error):
                print(error.localizedDescription)
            case .success:
                self.account = account
                print("success!")
            }
        }
    }

    func clear() {
        if case .success = accountStorage.clear() {
            self.account = nil
        }
    }

    func getBalance() {
        guard let account = account else {
            return
        }
        
        solana.api.getBalance(account: account.publicKey.base58EncodedString){ result in
            print(result)

            switch result {
            case .success(let amount):
                print(amount)

                DispatchQueue.main.async {
                    self.balance = "\(Double(amount)*0.000000001). SOL"
                }
            case .failure(let error):
                print(error)
            }
         }
    }

    func requestAirdrop(_ value: Int = 10) async -> AirdropResponse? {
        guard let account = account else {
            return nil
        }

        let json: [String: Any] = ["jsonrpc": "2.0",
                                   "id": 1,
                                   "method":"requestAirdrop",
                                   "params": ["8ZrjwMyQhiiJkpZbpQSc3faDWMnVJUacBtku6qLtp8Kc", 1000000000]]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        guard let url = URL(string: "https://api.devnet.solana.com") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(AirdropResponse.self, from: data)
            return decoded
        } catch {
            print(error)
            return nil
        }
    }

    func createAccount() {
        let phrase = seedPhrase.getSeedPhrase()
        print(phrase)
        guard let account = Account(phrase: phrase, network: .devnet) else {
            print("failed to create account!")
            return
        }

        switch accountStorage.save(account) {
        case .success:
            print("success")
            self.account = account
        case .failure(let error):
            print(error)
        }
    }
}


struct AirdropResponse: Decodable {
    let jsonrpc: String
    let result: String
    let id: Int
}
