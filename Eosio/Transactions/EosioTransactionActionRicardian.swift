//
//  EosioTransactionActionRicardian.swift
//
//  Created by Todd Bowden on 4/18/19.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import EosioSwift

extension EosioTransaction.Action {
    
    private static var ricardians = NSMapTable<EosioTransaction.Action, Ricardian>(keyOptions: [NSMapTableWeakMemory,NSMapTableObjectPointerPersonality], valueOptions: [NSMapTableStrongMemory])
    
    var ricardian: Ricardian? {
        get {
            return EosioTransaction.Action.ricardians.object(forKey: self)
        }
        set {
            EosioTransaction.Action.ricardians.setObject(newValue, forKey: self)
        }
    }
    
    /// Ricardian struct for `EosioTransaction.Action`
    class Ricardian {
        /// Rendered ricardian contract in html format
        public var html = ""
        /// Ricardian metadata (title, summary and icon)
        public var metadata = Metadata()
        /// Error rendering the ricardian contract
        public var error = ""
        
        /// Ricardian metadata (title, summary and icon)
        public struct Metadata {
            /// Action title
            public var title = ""
            /// Action summary
            public var summary = ""
            /// Action icon url
            public var icon = ""
        }
    }
    
}
