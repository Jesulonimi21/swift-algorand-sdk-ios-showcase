//
//  Data.swift
//  swift-algorand-sdk-ios-showcase
//
//  Created by Jesulonimi on 3/12/21.
//

import Foundation
import  swift_algorand_sdk
 class Config{
   static public var algodClient:AlgodClient?=AlgodClient(host: HACKATHON_API_ADDRESS, port: HACKATHON_API_PORT, token: HACKATHON_API_TOKEN)
    static public var PURESTAKE_API_KEY="ADRySlL0NK5trzqZGAE3q1xxIqlQdSfk1nbHxTNe"
    static  let PURESTAKE_ALGOD_API_TESTNET_ADDRESS="https://testnet-algorand.api.purestake.io/ps2"
    static let PURESTAKE_ALGOD_API_MAINNET_ADDRESS="https://mainnet-algorand.api.purestake.io/ps2"
    static let PURESTAKE_INDEXER_API_ADDRESS="https://testnet-algorand.api.purestake.io/idx2"
    static let PURESTAKE_ALGOD_API_BETANET_ADDRESS="https://betanet-algorand.api.purestake.io/ps2"
    static var PURESTAKE_API_PORT="443";
    static let TESTNET="TESTNET"
    static let BETANET="BETANET"
    static var currentNet=TESTNET
    static var currentNode="Hackathon"
    static var HACKATHON_API_PORT="9100";
    static var HACKATHON_API_ADDRESS="http://hackathon.algodev.network";
    static var HACKATHON_API_TOKEN="ef920e2e7e002953f4b29a8af720efe8e4ecc75ff102b165e0472834b25832c1";
    static var account1:Account? = try! Account("smart cloud tissue evil exercise region brown field town system shy faith aisle mobile amazing salmon van trade velvet crack output robot phrase about slight")
    static var account2:Account? = try!Account("mountain syrup orbit regret ostrich champion either push clock concert tissue slim gadget pencil pilot salt curious horse shallow civil arrange track sleep able alley")
    static var account3:Account? = try! Account( "volcano permit just steak place thumb reason cabin firm bomb mammal harsh blame unit clump future rigid engage alpha erupt garden attend flee above warrior")
    static var multisigAddress:MultisigAddress?
}

