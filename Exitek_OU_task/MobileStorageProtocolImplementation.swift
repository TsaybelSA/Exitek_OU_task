//
//  MobileStorageProtocolImplementation.swift
//  
//
//  Created by Сергей Цайбель on 07.09.2022.
//

import Foundation

// Implement mobile phone storage protocol
// Requirements:
// - Mobiles must be unique (IMEI is an unique number)
// - Mobiles must be stored in memory

protocol MobileStorage {
	func getAll() -> Set<Mobile>
	func findByImei(_ imei: String) -> Mobile?
	func save(_ mobile: Mobile) throws -> Mobile
	func delete(_ product: Mobile) throws
	func exists(_ product: Mobile) -> Bool
}

struct Mobile: Hashable, Codable {
	let imei: String
	let model: String
}

class FileManagerMobileStorage: MobileStorage {
	
	private(set) var mobiles: Set<Mobile> = []

	func getAll() -> Set<Mobile> {
		mobiles
	}
	
	func findByImei(_ imei: String) -> Mobile? {
		mobiles.first(where: { $0.imei == imei })
	}
	
	func save(_ mobile: Mobile) throws -> Mobile {
		if findByImei(mobile.imei) != nil {
			throw MobileStorageErrors.alreadyInStorage
		} else {
			mobiles.insert(mobile)
			try saveMobiles()
		}
		return mobile
	}
	
	func delete(_ product: Mobile) throws {
		if let mobileToDelete = findByImei(product.imei) {
			let index = getIndexOfMobile(mobileToDelete)
			// use force unwrapping because we sure that 'mobiles' contains our product
			mobiles.remove(at: index!)
			print(mobiles)
			try saveMobiles()
		} else {
			throw MobileStorageErrors.nothingToDelete
		}
	}
	
	func getIndexOfMobile(_ mobile: Mobile) -> Set<Mobile>.Index? {
		mobiles.firstIndex(where: { $0.imei == mobile.imei })
	}
	
	func exists(_ product: Mobile) -> Bool {
		findByImei(product.imei) == nil ? false : true
	}
			
	private let savePath = FileManager.documentsDirectory.appendingPathComponent("mobileStorage")
	
	private func saveMobiles() throws {
		do {
			let data = try JSONEncoder().encode(mobiles)
			try data.write(to: savePath)
		} catch {
			throw MobileStorageErrors.writingFailure
		}
	}
	
	init() {
		do {
			let data = try Data(contentsOf: savePath)
			let decodedMobiles = try! JSONDecoder().decode(Set<Mobile>.self, from: data)
			mobiles = decodedMobiles
		} catch {
			print("Failed load data from Documents Directory")
		}
	}
	
	enum MobileStorageErrors: Error {
		case nothingToDelete
		case alreadyInStorage
		case writingFailure
	}
}

extension FileManager {
	static var documentsDirectory: URL {
		let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return path[0]
	}
}
