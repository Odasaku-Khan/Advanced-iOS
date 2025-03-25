//
//  UserProfile.swift
//  lab2
//
//  Created by Ablaikhan Nusypakhin on 3/7/25.
//


import Foundation

// Part 3: Hashable and Equatable Implementation - UserProfile

struct UserProfile: Hashable, Equatable {
    let id: UUID
    let username: String
    var bio: String
    var followers: Int

    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id) // Use immutable id for hashing
        hasher.combine(username) // Use immutable username for hashing
    }

    // Implement Equatable
    static func == (lhs: UserProfile, rhs: UserProfile) -> Bool {
        return lhs.id == rhs.id // Equality based on unique id
    }
}