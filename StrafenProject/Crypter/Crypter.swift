//
//  Crypter.swift
//  StrafenProject
//
//  Created by Steven on 06.04.23.
//

import Foundation
import CryptoSwift

struct Crypter {
    struct Keys {
        let encryptionKey: FixedLength<[UInt8], Length32>
        let initialisationVector: FixedLength<[UInt8], Length16>
        let vernamKey: FixedLength<[UInt8], Length32>
    }
    
    enum CryptionError: Error {
        case encryptAesError
        case decryptAesError
    }
    
    static func sha512(_ value: String, key: String? = nil) -> String {
        var hash: String
        if let key {
            let hmac = HMAC(key: key.data(using: .utf8)?.bytes ?? Array(key.utf8), variant: .sha2(.sha512))
            hash = try! hmac.authenticate(value.data(using: .utf8)?.bytes ?? Array(value.utf8)).toBase64()
        } else {
            let sha = SHA2(variant: .sha512)
            hash = sha.calculate(for: value.data(using: .utf8)?.bytes ?? Array(value.utf8)).toBase64()
        }
        if hash.hasSuffix("==") {
            hash.removeLast(2)
        }
        hash.replace("/", with: "_")
        return hash
    }
    
    private let cryptionKeys: Keys
    
    init(keys cryptionKeys: Keys) {
        self.cryptionKeys = cryptionKeys
    }
    
    func encryptAes(_ data: Data) throws -> Data {
        do {
            let aes = try AES(key: self.cryptionKeys.encryptionKey.value, blockMode: CBC(iv: self.cryptionKeys.initialisationVector.value))
            return try Data(aes.encrypt(Array(data).addPadding()).dropLast(16))
        } catch {
            throw CryptionError.encryptAesError
        }
    }
        
    func decryptAes(_ data: Data) throws -> Data {
        do {
            let aes = try AES(key: self.cryptionKeys.encryptionKey.value, blockMode: CBC(iv: self.cryptionKeys.initialisationVector.value))
            return try Data(aes.decrypt(Array(data)).removePadding())
        } catch {
            throw CryptionError.decryptAesError
        }
    }
    
    func encryptVernamCipher(_ data: Data) throws -> Data {
        let key = try Array.random(length: 32)
        let randomBitIterator = RandomBitIterator(seed: key + self.cryptionKeys.vernamKey.value)
        let dataToBitsIterator = DataToBitIterator(data)
        let combineIterator = CombineIterator(lhs: randomBitIterator, rhs: dataToBitsIterator, combine: ^)
        return key + combineIterator.data
    }
    
    func decryptVernamCipher(_ data: Data) throws -> Data {
        let randomBitIterator = RandomBitIterator(seed: data.prefix(32) + self.cryptionKeys.vernamKey.value)
        let dataToBitIterator = DataToBitIterator(data.dropFirst(32))
        let combineIterator = CombineIterator(lhs: randomBitIterator, rhs: dataToBitIterator, combine: ^)
        return combineIterator.data
    }
    
    func encryptVernamAndAes(_ data: Data) throws -> Data {
        let vernamEncryptedData = try self.encryptVernamCipher(data)
        return try self.encryptAes(vernamEncryptedData)
    }
        
    func decryptAesAndVernam(_ encrypted: Data) throws -> Data {
        let aesDecryptedData = try self.decryptAes(encrypted)
        return try self.decryptVernamCipher(aesDecryptedData)
    }
    
    func decryptDecode<T>(type: T.Type, _ data: String) throws -> T where T: Decodable {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601WithMilliseconds
        decoder.dataDecodingStrategy = .base64
        let decryptedData = try self.decryptAesAndVernam(Data(unishortString: data))
        return try decoder.decode(type, from: decryptedData)
    }
    
    func encodeEncrypt<T>(_ data: T) throws -> String where T: Encodable {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.dataEncodingStrategy = .base64
        let encodedData = try encoder.encode(data)
        let encryptedData = try self.encryptVernamAndAes(encodedData)
        return encryptedData.unishortString
    }
}
