//
//  AuthenticatorRequestViewController+TransactionSignature.swift
//  Eosio
//
//  Created by Todd Bowden on 11/12/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import EosioSwift
import EosioSwiftReferenceAuthenticatorSignatureProvider
import EosioSwiftAbieosSerializationProvider
import EosioSwiftVaultSignatureProvider


extension AuthenticatorRequestViewController {
   
    
    func handleTransactionSignatureRequest(payload: EosioReferenceAuthenticatorSignatureProvider.RequestPayload,
                                           manifest: AppManifest,
                                           completion: @escaping (EosioTransactionSignatureResponse?) -> Void) {

        // Get the transactionSignature request, otherwise return nil
        guard let transactionSignatureRequest = payload.request.transactionSignature else { return completion(nil) }

        // Some security flags
        var shouldAddAssert = true
        var strictParsingCTT = true
        var shouldEnforceActionsWhitelist = true
        
        //TODO: is this still needed now that security exclusions are in place???
        // Env var for skiping add assert require
        if ProcessInfo.processInfo.environment["SKIP_ASSERT_REQUIRE"] != nil { shouldAddAssert = false }

        // If there are security exclusions, update some security flags
        if let secuityExclusions = getActiveSecurityExclusions() {
            if shouldAddAssert && secuityExclusions.addAssertToTransactions {
                shouldAddAssert = false
            }
            strictParsingCTT = !secuityExclusions.relaxedContractParsing
            shouldEnforceActionsWhitelist = !secuityExclusions.whitelistedActions
        }

        let transaction: EosioTransaction
        do {
            // try and deserialize the serialized transaction
            let serializedTransaction = try Data(hex: transactionSignatureRequest.transaction.packedTrx)
            transaction = try EosioTransaction.deserialize(serializedTransaction, serializationProvider: EosioAbieosSerializationProvider())
            transaction.chainId = transactionSignatureRequest.chainId
            // enforce whitelist
            if shouldEnforceActionsWhitelist {
                if let nonWhitelistedActions = transaction.nonWhitelistedActionsList(manifest: manifest) {
                    let reason = nonWhitelistedActions + " are not whitelisted in the app manifest"
                    return completion(EosioTransactionSignatureResponse(error: EosioError(.signatureProviderError, reason: reason)))
                }
            }
            // add abis
            for abi in transactionSignatureRequest.abis {
                try transaction.abis.addAbi(name: EosioName(abi.accountName), hex: abi.abi)
            }
            // add assert require
            if shouldAddAssert {
                try transaction.addAssertRequireAction(appManifest: manifest)
            }
            // render ricardians
            try transaction.deserializeActionData(exclude: [EosioName("eosio.assert")])
            do {
                try transaction.renderRicardians(strictParsingCTT: strictParsingCTT)
            } catch (let error) {
                completion(EosioTransactionSignatureResponse(error: error.eosioError))
            }

        } catch {
            return completion(EosioTransactionSignatureResponse(error: error.eosioError))
        }


        ResourceIntegrity.getActionIconUrls(transaction: transaction, progress: { (dataFetcher, dataFetcherState) in

            // Check for network connection and display any errors.
            let fetcher = dataFetcher
            let networkOfflineVC = UIStoryboard(name: "ErrorScreens", bundle: nil).instantiateViewController(withIdentifier: "NetworkOfflineViewController") as! NetworkOfflineViewController
            switch dataFetcherState {
            case DataFetcherState.WaitingForNetwork:
                networkOfflineVC.networkOnline = { self.navigationController?.popViewController(animated: true) }
                networkOfflineVC.userCancelled = { self.navigationController?.popViewController(animated: true, completion: { fetcher.cancelCurrentTask() }) }
                self.navigationController?.pushViewController(networkOfflineVC, animated: true)

            case DataFetcherState.NotConnectedToInternet:
                networkOfflineVC.networkOnline = { self.navigationController?.popViewController(animated: true, completion: { fetcher.retryCurrentTask() }) }
                networkOfflineVC.userCancelled = { self.navigationController?.popViewController(animated: true, completion: { fetcher.cancelCurrentTask() }) }
                self.navigationController?.pushViewController(networkOfflineVC, animated: true)
            default: break
            }

        // upon success
        }, completion: { (arrayOfUrlStrings, possibleError) in

            guard possibleError == nil else {
                return completion(EosioTransactionSignatureResponse(error: EosioError(.signatureProviderError, reason: possibleError?.reason ?? "")))
            }

            self.presentConfirmation(transaction: transaction, appManifest: manifest, reply: { (didAccept) in
                self.handleConfirmationResponse(transaction: transaction, request: transactionSignatureRequest, didAccept: didAccept, completion: completion)
            })
        })

        
    }
    
    
    
    private func presentConfirmation(transaction: EosioTransaction, appManifest: AppManifest, reply: @escaping (Bool)->Void) {
        let confirmationController = UIStoryboard(name: "Confirmation", bundle: nil).instantiateViewController(withIdentifier: "ConfirmationViewController") as! ConfirmationViewController
        var appManifest = appManifest
        confirmationController.unpackedtrx = transaction
        confirmationController.reply = reply
        confirmationController.chainID = transaction.chainId
        confirmationController.appName = appManifest.metadata.shortname
        confirmationController.appDomain = appManifest.domain
        confirmationController.chainName = appManifest.metadata.chain.chainName
        confirmationController.appImage = appManifest.metadata.iconImage
        confirmationController.chainIconImage = appManifest.metadata.chain.iconImage
        
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(confirmationController, animated: false)
        }
        
    }
    
    private func handleConfirmationResponse(transaction: EosioTransaction, request: EosioReferenceAuthenticatorSignatureProvider.TransactionSignatureRequest, didAccept: Bool, completion: @escaping (EosioTransactionSignatureResponse?)->Void) {
        guard didAccept else {
            return completion(EosioTransactionSignatureResponse(error: EosioError(.signatureProviderError, reason: "User Declined")))
        }

        transaction.signatureProvider = EosioVaultSignatureProvider(accessGroup: Constants.vaultAccessGroup, requireBio: true)
        transaction.sign(publicKeys: request.publicKeys) { (result) in
            switch result {
            case .failure(let error):
                return completion(EosioTransactionSignatureResponse(error: error))
            case .success:
                var response = EosioTransactionSignatureResponse()
                var signedTransaction = EosioTransactionSignatureResponse.SignedTransaction()
                guard let signatures = transaction.signatures else {
                    return completion(EosioTransactionSignatureResponse(error: EosioError(.signatureProviderError, reason: "No signatures")))
                }
                guard let serializedTransaction = transaction.serializedTransaction else {
                    return completion(EosioTransactionSignatureResponse(error: EosioError(.signatureProviderError, reason: "No serialized transaction")))
                }
                signedTransaction.signatures = signatures
                signedTransaction.serializedTransaction = serializedTransaction
                response.signedTransaction = signedTransaction
                completion(response)
            }
        }

    }
    
    

    
    
}
