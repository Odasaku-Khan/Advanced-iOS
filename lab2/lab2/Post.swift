//
//  Post.swift
//  lab2
//
//  Created by Ablaikhan Nusypakhin on 3/7/25.
//


import Foundation

// Part 3: Hashable and Equatable Implementation - Post

struct Post: Hashable, Equatable {
    let id: UUID
    let authorId: UUID
    var content: String
    var likes: Int

    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id) // Use immutable id for hashing
        hasher.combine(authorId) // Use immutable authorId for hashing
        // Consider: Content could be included if considered part of the identity for hashing purposes, but for simplicity and performance, ID and authorId might be sufficient.
    }

    // Implement Equatable
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id // Equality based on unique id
    }
}
