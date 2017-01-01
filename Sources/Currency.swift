//
//  Currency.swift
//  Stripe
//
//  Created by Hakon Hanesand on 12/2/16.
//
//

import Foundation
import Node
import Vapor

enum Currency: String, NodeConvertible {
    
    case aed
    case all
    case ang
    case ars
    case aud
    case awg
    case bbd
    case bdt
    case bif
    case bmd
    case bnd
    case bob
    case brl
    case bsd
    case bwp
    case bzd
    case cad
    case chf
    case clp
    case cny
    case cop
    case crc
    case cve
    case czk
    case djf
    case dkk
    case dop
    case dzd
    case egp
    case etb
    case eur
    case fjd
    case fkp
    case gbp
    case gip
    case gmd
    case gnf
    case gtq
    case gyd
    case hkd
    case hnl
    case hrk
    case htg
    case huf
    case idr
    case ils
    case inr
    case isk
    case jmd
    case jpy
    case kes
    case khr
    case kmf
    case krw
    case kyd
    case kzt
    case lak
    case lbp
    case lkr
    case lrd
    case mad
    case mdl
    case mnt
    case mop
    case mro
    case mur
    case mvr
    case mwk
    case mxn
    case myr
    case nad
    case ngn
    case nio
    case nok
    case npr
    case nzd
    case pab
    case pen
    case pgk
    case php
    case pkr
    case pln
    case pyg
    case qar
    case rub
    case sar
    case sbd
    case scr
    case sek
    case sgd
    case shp
    case sll
    case sos
    case std
    case svc
    case szl
    case thb
    case top
    case ttd
    case twd
    case tzs
    case uah
    case ugx
    case usd
    case uyu
    case uzs
    case vnd
    case vuv
    case wst
    case xaf
    case xof
    case xpf
    case yer
    case zar

    init(node: Node, in context: Context = EmptyNode) throws {
        guard let value = node.string else {
            throw Abort.custom(status: .internalServerError, message: "Expected \(String.self) for currency code")
        }

        guard let _self = Currency(rawValue: value.lowercased()) else {
            throw Abort.custom(status: .internalServerError, message: "Currency code \(value.lowercased()) doesn't match any known codes.")
        }

        self = _self
    }
}
