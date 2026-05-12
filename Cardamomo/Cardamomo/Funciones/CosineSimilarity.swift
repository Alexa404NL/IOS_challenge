//
//  CosineSimilarity.swift
//  Cardamomo
//
//  Created by Alexa Lara on 11/05/26.
//

import Accelerate
import Foundation

enum CosineSimilarity {
    static func calculate(_ lhs: [Double], _ rhs: [Double]) -> Double {
        guard lhs.count == rhs.count, !lhs.isEmpty else { return 0 }

        var dotProduct = 0.0
        var lhsMagnitudeSquared = 0.0
        var rhsMagnitudeSquared = 0.0

        vDSP_dotprD(lhs, 1, rhs, 1, &dotProduct, vDSP_Length(lhs.count))
        vDSP_svesqD(lhs, 1, &lhsMagnitudeSquared, vDSP_Length(lhs.count))
        vDSP_svesqD(rhs, 1, &rhsMagnitudeSquared, vDSP_Length(rhs.count))

        let denominator = sqrt(lhsMagnitudeSquared) * sqrt(rhsMagnitudeSquared)
        guard denominator > 0 else { return 0 }

        return dotProduct / denominator
    }
}
