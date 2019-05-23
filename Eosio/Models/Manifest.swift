//
//  Manifest.swift
//  Eosio
//
//  Created by Adam Halper on 8/15/18.
//  Copyright © 2018 Block.one. All rights reserved.
//

import Foundation

/*
struct Manifest: Decodable {
    let short_name: String?
    let name: String
    //let description: String
    
    struct Icon: Decodable {
        //let name: String
        //let role: String
        let src: String
        let sizes: String
        let type: String
    }

    let icons: [Icon]?
    //let eosio: [String : Float]
    
    let start_url: String?
    //let scope: String
    let display: String?
    let theme_color: String?
    let background_color: String?
    
    //add hash of icon?
}


extension Manifest {
    
    func isValidManifest()->Bool {
       print("\n\nIS VALID MANIFEST CALLED\n\n")
        return short_name != nil && name != nil && start_url != nil && icons != nil
    }
    
}
*/

struct AppManifest: Decodable {
    let name: String?
    let shortname: String?
    let scope: String?
    let apphome: String?
    let icon: String?
    let description: String?
    let sslfingerprint: String?
    var hash: String?
}


extension AppManifest {

    func isValidManifest(url: URL)->Bool {
        print("\n\nisValidManifest Called\nshort name: \(self.shortname)\n, name: \(self.name)\n, scope: \(self.scope)\n, apphome: \(self.apphome)\n, icon: \(self.icon)\n, description: \(self.description)\n, ssl: \(self.sslfingerprint)\n")

        if scope == nil {return false}
        if icon == nil {return false}

        if (name ?? "").isEmpty {return false}
        if (shortname ?? "").isEmpty {return false}

        if  ResourceIntegrity.getResourceHash(resourceUrlPath: icon!) == nil { //force unwrap ok because was checked above
            print("App icon from manifest is invalid")
            return false
        }
        return true
    }
}
