//
//  CrypterTests.swift
//  StrafenProjectTests
//
//  Created by Steven on 06.04.23.
//

import XCTest
@testable import StrafenProject

final class CrypterTestSuite: XCTestSuite {
    final class BitTests: XCTestCase {
        func testNot() {
            XCTAssertEqual(~Bit.zero, .one)
            XCTAssertEqual(~Bit.one, .zero)
        }
        
        func testAnd() {
            XCTAssertEqual(Bit.zero & Bit.zero, .zero)
            XCTAssertEqual(Bit.one & Bit.zero, .zero)
            XCTAssertEqual(Bit.zero & Bit.one, .zero)
            XCTAssertEqual(Bit.one & Bit.one, .one)
        }
        
        func testOr() {
            XCTAssertEqual(Bit.zero | Bit.zero, .zero)
            XCTAssertEqual(Bit.one | Bit.zero, .one)
            XCTAssertEqual(Bit.zero | Bit.one, .one)
            XCTAssertEqual(Bit.one | Bit.one, .one)
        }
        
        func testXor() {
            XCTAssertEqual(Bit.zero ^ Bit.zero, .zero)
            XCTAssertEqual(Bit.one ^ Bit.zero, .one)
            XCTAssertEqual(Bit.zero ^ Bit.one, .one)
            XCTAssertEqual(Bit.one ^ Bit.one, .zero)
        }
        
        func testByteToBits() {
            let dataset: [(byte: UInt8, expected: [Bit])] = [
                (byte: 0x00, expected: [.zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero]),
                (byte: 0x01, expected: [.zero, .zero, .zero, .zero, .zero, .zero, .zero, .one]),
                (byte: 0x4e, expected: [.zero, .one, .zero, .zero, .one, .one, .one, .zero]),
                (byte: 0xff, expected: [.one, .one, .one, .one, .one, .one, .one, .one])
            ]
            for data in dataset {
                XCTAssertEqual(data.byte.bits, data.expected)
            }
        }
    }
    
    final class PseudoRandomTests: XCTestCase {
        func testRandomByte() {
            var pseudoRandom = PseudoRandom(seed: [0x1e, 0x33, 0x43, 0xe0, 0x25, 0x3a, 0xb5, 0xa0, 0xf9, 0x0d, 0x33, 0x95, 0x10, 0xaa, 0x7d, 0xee])
            let expectedBytes: [UInt8] = [
                223, 151, 156, 50, 123, 196, 29, 177, 74, 148, 156, 220, 244, 146, 22, 131, 21, 111, 117, 65, 23, 89, 254, 68, 206, 148, 185, 154, 156, 29, 165, 91
            ]
            for expectedByte in expectedBytes {
                XCTAssertEqual(pseudoRandom.randomByte(), expectedByte)
            }
        }
    }
    
    final class DataToBitIteratorTests: XCTestCase {
        func testDataToBitIterator1() {
            let bitIterator = DataToBitIterator(Data())
            let expected = Array<Bit>().makeIterator()
            XCTAssertEqualIterator(bitIterator, expected)
        }
        
        func testDataToBitIterator2() {
            let bitIterator = DataToBitIterator(Data([0x23]))
            let expected = [Bit.zero, .zero, .one, .zero, .zero, .zero, .one, .one].makeIterator()
            XCTAssertEqualIterator(bitIterator, expected)
        }
        
        func testDataToBitIterator3() {
            let bitIterator = DataToBitIterator(Data([0x23, 0x45, 0x67, 0xaf]))
            let expected = [
                Bit.zero, .zero, .one, .zero, .zero, .zero, .one, .one,
                .zero, .one, .zero, .zero, .zero, .one, .zero, .one,
                .zero, .one ,.one, .zero, .zero, .one, .one, .one,
                .one, .zero, .one, .zero, .one, .one, .one, .one
            ].makeIterator()
            XCTAssertEqualIterator(bitIterator, expected)
        }
        
        func testBitIteratorToData1() {
            let bitIterator = Array<Bit>().makeIterator()
            let expected = Data()
            XCTAssertEqual(bitIterator.data, expected)
        }
        
        func testBitIteratorToData2() {
            let bitIterator = [Bit.zero, .zero, .one, .zero, .zero, .zero, .one, .one].makeIterator()
            let expected = Data([0x23])
            XCTAssertEqual(bitIterator.data, expected)
        }
        
        func testBitIteratorToData3() {
            let bitIterator = [
                Bit.zero, .zero, .one, .zero, .zero, .zero, .one, .one,
                .zero, .one, .zero, .zero, .zero, .one, .zero, .one,
                .zero, .one ,.one, .zero, .zero, .one, .one, .one,
                .one, .zero, .one, .zero, .one, .one, .one, .one
            ].makeIterator()
            let expected = Data([0x23, 0x45, 0x67, 0xaf])
            XCTAssertEqual(bitIterator.data, expected)
        }
    }
    
    final class RandomBitIteratorTests: XCTestCase {
        func testRandomBits() {
            var randomBitIterator = RandomBitIterator(seed: [0x1e, 0x33, 0x43, 0xe0, 0x25, 0x3a, 0xb5, 0xa0, 0xf9, 0x0d, 0x33, 0x95, 0x10, 0xaa, 0x7d, 0xee])
            let expectedBits: [Bit] = [
                .one, .one, .zero, .one, .one, .one, .one, .one, .one, .zero, .zero, .one, .zero, .one, .one, .one, .one, .zero, .zero, .one, .one, .one, .zero, .zero, .zero, .zero, .one, .one, .zero, .zero, .one, .zero,
                .zero, .one, .one, .one, .one, .zero, .one, .one, .one, .one, .zero, .zero, .zero, .one, .zero, .zero, .zero, .zero, .zero, .one, .one, .one, .zero, .one, .one, .zero, .one, .one, .zero, .zero, .zero, .one
            ]
            for expectedBit in expectedBits {
                XCTAssertEqual(randomBitIterator.next(), expectedBit)
            }
            
        }
    }
    
    final class CombineIteratorTests: XCTestCase {
        func testCombine1() {
            let combineIterator = CombineIterator(lhs: [1, 2, 3].makeIterator(), rhs: [4, 5, 6].makeIterator()) { 10 * $0 + $1 }
            let expected = [14, 25, 36].makeIterator()
            XCTAssertEqualIterator(combineIterator, expected)
        }
        
        func testCombine2() {
            let combineIterator = CombineIterator(lhs: [1, 2].makeIterator(), rhs: [4, 5, 6].makeIterator()) { 10 * $0 + $1 }
            let expected = [14, 25].makeIterator()
            XCTAssertEqualIterator(combineIterator, expected)
        }
        
        func testCombine3() {
            let combineIterator = CombineIterator(lhs: [1, 2, 3].makeIterator(), rhs: [4, 5].makeIterator()) { 10 * $0 + $1 }
            let expected = [14, 25].makeIterator()
            XCTAssertEqualIterator(combineIterator, expected)
        }
    }
    
    final class CrypterTests: XCTestCase {
        struct TestData {
            let aesOriginal: [UInt8] = [99, 122, 245, 248, 47, 68, 70, 62, 71, 153, 220, 248, 163, 227, 180, 24, 206, 134, 165, 182, 94, 51, 220, 212, 182, 158, 191, 243, 95, 233, 85, 252, 231, 192, 0, 188, 94, 61, 234, 248, 122, 48, 17, 83, 155, 175, 46, 187, 38, 50, 222, 28, 5, 28, 194, 226, 130, 77, 45, 208, 164, 201, 77, 162]
            let aesEncrypted: [UInt8] = [137, 242, 23, 251, 185, 141, 78, 137, 169, 184, 72, 54, 117, 155, 168, 31, 242, 110, 95, 148, 120, 226, 9, 104, 45, 43, 73, 64, 204, 206, 224, 227, 236, 188, 40, 55, 196, 14, 18, 205, 185, 227, 131, 166, 26, 133, 227, 213, 107, 98, 46, 102, 197, 56, 195, 11, 9, 158, 83, 239, 64, 198, 126, 200, 100, 5, 151, 139, 92, 252, 48, 211, 110, 122, 104, 203, 150, 169, 159, 178]
            let vernamOriginal: [UInt8] = [72, 56, 194, 240, 185, 253, 190, 97, 149, 6, 161, 255, 167, 3, 235, 145, 165, 17, 31, 242, 102, 199, 5, 5, 168, 163, 115, 201, 54, 145, 83, 107, 240, 53, 21, 165, 34, 109, 174, 141, 20, 250, 77, 65, 246, 52, 100, 149, 27, 116, 145, 100, 198, 56, 154, 78, 160, 204, 216, 243, 18, 33, 102, 45]
            let vernamEncrypted: [UInt8] = [216, 201, 86, 198, 5, 5, 235, 31, 164, 136, 122, 46, 247, 83, 8, 204, 128, 254, 79, 143, 8, 193, 230, 46, 239, 162, 155, 245, 226, 160, 175, 57, 45, 189, 204, 53, 5, 34, 228, 12, 10, 227, 186, 15, 103, 149, 104, 39, 251, 26, 66, 68, 132, 32, 158, 11, 152, 166, 250, 218, 106, 82, 208, 211, 239, 231, 167, 145, 192, 169, 201, 96, 132, 22, 105, 116, 157, 185, 129, 35, 172, 171, 24, 218, 29, 5, 116, 131, 122, 28, 54, 41, 238, 172, 126, 28]
            let aesVernamOriginal: [UInt8] = [97, 210, 8, 55, 123, 249, 117, 74, 185, 36, 165, 140, 204, 242, 154, 237, 29, 113, 95, 28, 222, 229, 35, 197, 229, 244, 107, 4, 159, 128, 239, 240, 61, 44, 59, 104, 63, 226, 132, 246, 129, 150, 72, 118, 164, 174, 54, 173, 224, 66, 226, 232, 212, 27, 85, 54, 195, 235, 154, 129, 215, 117, 38, 194]
            let aesVernamEncrypted: [UInt8] = [137, 242, 23, 251, 185, 141, 78, 137, 169, 184, 72, 54, 117, 155, 168, 31, 252, 138, 134, 206, 63, 100, 30, 154, 231, 251, 122, 177, 223, 148, 100, 9, 185, 223, 95, 250, 62, 199, 172, 87, 18, 133, 48, 164, 9, 79, 105, 178, 44, 244, 225, 94, 65, 196, 201, 226, 179, 96, 40, 178, 52, 253, 99, 120, 167, 40, 111, 141, 96, 2, 132, 161, 239, 30, 41, 160, 16, 238, 208, 106, 127, 177, 4, 83, 147, 48, 233, 140, 136, 182, 55, 215, 168, 196, 228, 225, 80, 47, 164, 47, 121, 20, 254, 70, 10, 102, 141, 174, 212, 136, 119, 32]
            let decryptedDecoded = "QXLRTd9ZAImS2rtoie2/5HMP2dNvNn8mw/moIQGlw/b2RfGFs51zeEdfgVe6Gy3W9PhG6iriZ1hka94JyyW2Xg=="
            let encodedEncrypted: [UInt8] = [106, 77, 168, 62, 129, 27, 44, 195, 157, 11, 129, 18, 14, 212, 135, 172, 58, 214, 145, 176, 237, 159, 131, 168, 144, 194, 95, 163, 99, 113, 164, 28, 161, 28, 218, 143, 81, 30, 196, 245, 161, 207, 48, 157, 111, 13, 115, 188, 164, 160, 201, 124, 73, 160, 30, 45, 33, 155, 154, 99, 215, 21, 254, 108, 98, 150, 210, 124, 31, 58, 154, 52, 36, 217, 185, 190, 241, 159, 68, 40, 23, 142, 143, 255, 112, 225, 245, 225, 158, 203, 102, 162, 93, 217, 196, 204, 81, 70, 194, 22, 72, 15, 35, 251, 253, 60, 183, 32, 226, 229, 200, 81, 129, 194, 167, 117, 255, 89, 215, 111, 14, 215, 95, 201, 27, 105, 133, 72]
        }
        
        let crypter = Crypter(keys: Crypter.Keys(
            encryptionKey: try! FixedLength(value: [0x37, 0xe6, 0x91, 0x57, 0xda, 0xc0, 0x1c, 0x0a, 0x9c, 0x93, 0xea, 0x1c, 0x72, 0x10, 0x41, 0xe6, 0x26, 0x86, 0x94, 0x3f, 0xda, 0x9d, 0xab, 0x30, 0xf7, 0x56, 0x5e, 0xdb, 0x3e, 0xf1, 0x5f, 0x5b]),
            initialisationVector: try! FixedLength(value: [0x69, 0x29, 0xd3, 0xdc, 0x8d, 0xd4, 0x1c, 0x90, 0x81, 0x2e, 0x30, 0x2a, 0x4b, 0x01, 0x03, 0x78]),
            vernamKey: try! FixedLength(value: [0x9f, 0x10, 0x2b, 0x4b, 0x5f, 0x0b, 0x5c, 0x50, 0x82, 0xd2, 0xa7, 0xbb, 0x7c, 0x7f, 0x13, 0x9f, 0xed, 0x6a, 0x99, 0x5e, 0xcf, 0x1f, 0x28, 0x80, 0x94, 0x20, 0x3c, 0xc3, 0x92, 0xf9, 0x6b, 0x5e])
        ))
        
        let testData = TestData()
        
        func testAesEncrypt() throws {
            let originalData = Data(testData.aesOriginal)
            let encryptedData = try crypter.encryptAes(originalData)
            let expectedEncryptedData = Data(testData.aesEncrypted)
            XCTAssertEqual(encryptedData, expectedEncryptedData)
        }
        
        func testAesDecrypt() throws {
            let enryptedData = Data(testData.aesEncrypted)
            let originalData = try crypter.decryptAes(enryptedData)
            let expectedOriginalData = Data(testData.aesOriginal)
            XCTAssertEqual(originalData, expectedOriginalData)
        }
        
        func testAesEncryptDecrypt() throws {
            let originalData = Data(testData.aesOriginal)
            let encryptedData = try crypter.encryptAes(originalData)
            let decyptedData = try crypter.decryptAes(encryptedData)
            XCTAssertEqual(decyptedData, originalData)
        }
                
        func testVernamDecrypt() throws {
            let enryptedData = Data(testData.vernamEncrypted)
            let originalData = try crypter.decryptVernamCipher(enryptedData)
            let expectedOriginalData = Data(testData.vernamOriginal)
            XCTAssertEqual(originalData, expectedOriginalData)
        }
        
        func testVernamEncryptDecrypt() throws {
            let originalData = Data(testData.vernamOriginal)
            let encryptedData = try crypter.encryptVernamCipher(originalData)
            let decyptedData = try crypter.decryptVernamCipher(encryptedData)
            XCTAssertEqual(decyptedData, originalData)
        }
        
        func testAesVernamDecrypt() throws {
            let encryptedData = Data(testData.aesVernamEncrypted)
            let originalData = try crypter.decryptAesAndVernam(encryptedData)
            let expectedOriginalData = Data(testData.aesVernamOriginal)
            XCTAssertEqual(originalData, expectedOriginalData)
        }
        
        func testAesVernamEncryptDecrypt() throws {
            let originalData = Data(testData.aesVernamOriginal)
            let encryptedData = try crypter.encryptVernamAndAes(originalData)
            let decryptedData = try crypter.decryptAesAndVernam(encryptedData)
            XCTAssertEqual(decryptedData, originalData)
        }
        
        func testDecryptDecode() throws {
            let encrypted = Data(testData.encodedEncrypted).unishortString
            let decrypted = try crypter.decryptDecode(type: String.self, encrypted)
            XCTAssertEqual(decrypted, testData.decryptedDecoded)
        }
        
        func testDecryptDecodeEncodeEncrypt() throws {
            let encrypted = try crypter.encodeEncrypt(testData.decryptedDecoded)
            let decrypted = try crypter.decryptDecode(type: String.self, encrypted)
            XCTAssertEqual(decrypted, testData.decryptedDecoded)
        }
    }
    
    final class FixedLengthTests: XCTestCase {
        func testLengthValid() throws {
            let fixedLength = try FixedLength<String, Length16>(value: "abcdefghijklmnop")
            XCTAssertEqual(fixedLength.value, "abcdefghijklmnop")
        }
        
        func testLengthInvalid() {
            XCTAssertThrowsError(try FixedLength<String, Length16>(value: "")) { error in
                XCTAssertTrue(error is FixedLength<String, Length16>.Error)
                XCTAssertEqual(error as! FixedLength<String, Length16>.Error, FixedLength<String, Length16>.Error.notExpectedLength)
            }
        }
    }
    
    final class OtherTests: XCTestCase {
        func testPadding() {
            for i in 0..<16 {
                let original = Array<UInt8>(repeating: 0, count: 32 + i)
                let withPadding = original.addPadding()
                XCTAssertEqual(withPadding.count % 16, 0)
                let withoutPadding = withPadding.removePadding()
                XCTAssertEqual(withoutPadding, original)
            }
        }
        
        func testHash() {
            XCTAssertEqual(Crypter.sha512("lkjdasflnc"), "rbswGhojGpzw7EoB61dz3LpecUiFV7y0QHhO7xLHbgtPHhjsKxH6nbUg2p6B5CpSAa1hMzJKBfM8twldRbKj1g")
            XCTAssertEqual(Crypter.sha512("lkjdasflnc", key: "oimli"), "5NRfmNX8NnSCP2jrQIrhmkpo+wpz27FQDyU4_4lheOiJ8etSQ+spWak39WgaF8lzd8qwHzlkrfixZIZlf_1hSQ")
        }
    }
}
