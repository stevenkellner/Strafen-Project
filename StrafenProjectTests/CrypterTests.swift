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
    
    final class PaddingTests: XCTestCase {
        let crypter = Crypter(keys: Crypter.Keys(
            encryptionKey: try! FixedLength(value: [0x37, 0xe6, 0x91, 0x57, 0xda, 0xc0, 0x1c, 0x0a, 0x9c, 0x93, 0xea, 0x1c, 0x72, 0x10, 0x41, 0xe6, 0x26, 0x86, 0x94, 0x3f, 0xda, 0x9d, 0xab, 0x30, 0xf7, 0x56, 0x5e, 0xdb, 0x3e, 0xf1, 0x5f, 0x5b]),
            initialisationVector: try! FixedLength(value: [0x69, 0x29, 0xd3, 0xdc, 0x8d, 0xd4, 0x1c, 0x90, 0x81, 0x2e, 0x30, 0x2a, 0x4b, 0x01, 0x03, 0x78]),
            vernamKey: try! FixedLength(value: [0x9f, 0x10, 0x2b, 0x4b, 0x5f, 0x0b, 0x5c, 0x50, 0x82, 0xd2, 0xa7, 0xbb, 0x7c, 0x7f, 0x13, 0x9f, 0xed, 0x6a, 0x99, 0x5e, 0xcf, 0x1f, 0x28, 0x80, 0x94, 0x20, 0x3c, 0xc3, 0x92, 0xf9, 0x6b, 0x5e])
        ))
        
        let dataset: [(decrypted: [UInt8], encrypted: [UInt8])] = [
            ([170, 75, 61, 13, 14, 114, 106, 162, 157, 106, 126, 148, 10, 146, 237, 38, 199, 130, 112, 181, 249, 177, 47, 41, 112, 28, 203, 146, 49, 166, 30, 53], [137, 242, 23, 251, 185, 141, 78, 137, 169, 184, 72, 54, 117, 155, 168, 31, 68, 74, 236, 230, 177, 33, 150, 95, 96, 144, 35, 94, 71, 228, 9, 189, 86, 3, 123, 136, 217, 27, 215, 47, 196, 45, 172, 50, 42, 3, 58, 247]),
            ([168, 30, 249, 191, 240, 106, 114, 72, 35, 10, 48, 21, 136, 177, 81, 212, 206, 176, 48, 251, 55, 24, 17, 224, 229, 106, 220, 152, 189, 65, 83, 174, 39], [207, 221, 188, 9, 133, 81, 139, 62, 131, 48, 232, 110, 211, 143, 141, 109, 80, 89, 196, 7, 45, 137, 158, 81, 239, 184, 2, 237, 59, 51, 4, 155, 144, 38, 117, 186, 224, 157, 241, 252, 253, 241, 10, 93, 221, 115, 41, 8]),
            ([2, 55, 148, 101, 113, 236, 77, 94, 211, 55, 39, 84, 162, 55, 142, 175, 129, 58, 1, 246, 2, 195, 186, 161, 5, 176, 172, 115, 211, 202, 80, 193, 45, 22], [125, 147, 213, 174, 101, 244, 238, 247, 116, 61, 107, 180, 133, 103, 173, 198, 13, 108, 249, 113, 173, 36, 118, 145, 140, 115, 230, 7, 34, 227, 198, 152, 130, 254, 49, 232, 226, 57, 141, 97, 22, 66, 98, 105, 169, 140, 155, 125]),
            ([44, 102, 120, 185, 109, 133, 239, 153, 163, 4, 90, 54, 148, 60, 27, 135, 100, 68, 231, 82, 25, 29, 63, 145, 153, 72, 14, 138, 96, 213, 79, 53, 114, 150, 99], [121, 187, 241, 234, 236, 202, 208, 120, 220, 135, 193, 200, 15, 75, 166, 247, 172, 165, 86, 46, 154, 28, 20, 187, 153, 82, 236, 48, 92, 13, 40, 93, 44, 214, 101, 183, 36, 3, 52, 88, 254, 229, 247, 34, 234, 222, 138, 194]),
            ([1, 89, 120, 187, 120, 226, 85, 175, 103, 79, 181, 51, 95, 161, 87, 245, 192, 125, 108, 69, 71, 46, 12, 176, 28, 37, 7, 181, 188, 170, 168, 232, 61, 219, 238, 216], [95, 133, 103, 241, 183, 49, 232, 49, 35, 229, 197, 152, 199, 225, 23, 14, 110, 194, 152, 113, 193, 81, 80, 97, 88, 151, 156, 42, 31, 174, 142, 61, 153, 69, 98, 140, 126, 118, 47, 168, 29, 65, 190, 111, 121, 63, 36, 53]),
            ([86, 100, 224, 248, 35, 8, 161, 27, 1, 94, 156, 223, 21, 154, 88, 252, 24, 226, 171, 156, 120, 53, 197, 214, 43, 246, 246, 232, 203, 209, 245, 46, 203, 50, 227, 205, 205], [17, 218, 6, 74, 130, 142, 194, 78, 113, 88, 81, 173, 45, 162, 248, 160, 6, 121, 250, 196, 73, 53, 158, 51, 192, 151, 29, 156, 235, 1, 215, 216, 200, 187, 55, 232, 193, 78, 111, 163, 28, 38, 52, 163, 223, 184, 166, 159]),
            ([141, 238, 172, 234, 162, 82, 23, 248, 154, 248, 30, 7, 66, 141, 216, 46, 50, 224, 164, 201, 116, 109, 92, 243, 79, 10, 33, 226, 211, 249, 59, 54, 192, 37, 194, 132, 245, 79], [76, 206, 141, 103, 164, 214, 124, 39, 60, 170, 213, 209, 110, 11, 255, 125, 44, 198, 97, 142, 125, 223, 11, 238, 39, 88, 174, 132, 72, 42, 152, 122, 84, 84, 96, 70, 32, 167, 151, 191, 54, 113, 2, 56, 205, 193, 51, 22]),
            ([102, 203, 201, 196, 232, 120, 234, 146, 96, 227, 133, 32, 94, 120, 29, 203, 101, 169, 51, 8, 215, 254, 251, 230, 3, 180, 130, 195, 51, 223, 133, 140, 120, 41, 243, 102, 37, 91, 139], [243, 162, 36, 206, 222, 194, 86, 95, 53, 12, 227, 120, 208, 69, 209, 56, 238, 153, 228, 6, 235, 240, 52, 170, 69, 242, 218, 135, 121, 248, 141, 26, 243, 225, 161, 213, 129, 79, 33, 43, 221, 242, 36, 69, 217, 55, 233, 46]),
            ([230, 248, 78, 100, 142, 255, 84, 125, 133, 203, 150, 173, 12, 211, 65, 68, 14, 76, 98, 218, 227, 173, 140, 251, 180, 182, 10, 57, 254, 136, 185, 110, 46, 99, 146, 157, 21, 218, 181, 159], [71, 188, 156, 97, 100, 237, 28, 170, 5, 233, 11, 148, 1, 251, 59, 53, 171, 216, 128, 145, 238, 113, 105, 78, 6, 147, 89, 37, 90, 219, 227, 164, 87, 141, 76, 244, 54, 55, 183, 179, 204, 14, 1, 47, 227, 54, 111, 124]),
            ([10, 83, 121, 140, 131, 150, 207, 171, 10, 246, 196, 181, 172, 189, 207, 37, 83, 159, 50, 101, 231, 242, 73, 52, 68, 16, 86, 107, 69, 197, 107, 135, 36, 213, 141, 83, 27, 149, 197, 50, 3], [56, 63, 226, 190, 100, 161, 177, 232, 195, 95, 233, 19, 246, 55, 243, 13, 220, 82, 71, 31, 98, 21, 183, 40, 211, 50, 9, 226, 20, 105, 45, 254, 241, 221, 154, 188, 19, 128, 111, 176, 199, 21, 126, 149, 27, 107, 60, 123]),
            ([8, 92, 204, 211, 199, 129, 208, 80, 252, 194, 32, 252, 204, 152, 62, 227, 116, 150, 59, 210, 16, 68, 98, 215, 39, 201, 8, 52, 213, 80, 117, 255, 2, 189, 40, 119, 121, 150, 165, 193, 40, 33], [131, 208, 177, 101, 166, 189, 191, 251, 247, 11, 191, 17, 0, 52, 44, 122, 108, 239, 16, 50, 248, 226, 186, 171, 190, 84, 234, 22, 236, 154, 218, 105, 173, 126, 187, 124, 219, 102, 107, 32, 10, 31, 202, 51, 119, 33, 53, 136]),
            ([131, 122, 34, 225, 156, 10, 7, 81, 67, 233, 243, 187, 231, 87, 113, 245, 192, 58, 32, 113, 149, 154, 65, 232, 218, 187, 204, 234, 53, 69, 77, 121, 74, 16, 164, 102, 251, 171, 122, 197, 188, 241, 185], [214, 179, 93, 86, 143, 50, 134, 147, 244, 131, 118, 92, 120, 193, 250, 196, 101, 176, 44, 20, 88, 163, 182, 44, 176, 198, 72, 48, 255, 76, 209, 16, 54, 46, 149, 62, 188, 248, 158, 244, 56, 89, 218, 193, 98, 31, 192, 92]),
            ([212, 85, 180, 152, 197, 31, 125, 140, 235, 196, 34, 156, 48, 168, 157, 209, 117, 18, 191, 182, 48, 183, 173, 43, 199, 150, 57, 101, 54, 245, 212, 78, 9, 96, 204, 152, 193, 14, 94, 191, 194, 160, 153, 69], [191, 23, 106, 220, 173, 149, 141, 178, 212, 45, 43, 10, 150, 55, 80, 108, 122, 240, 197, 144, 157, 180, 192, 177, 127, 119, 171, 25, 230, 37, 213, 170, 115, 29, 220, 239, 59, 15, 163, 152, 162, 194, 90, 168, 73, 217, 119, 135]),
            ([187, 167, 180, 149, 102, 241, 211, 194, 135, 164, 92, 245, 32, 100, 249, 19, 84, 177, 56, 0, 40, 28, 68, 243, 16, 180, 73, 39, 198, 226, 146, 59, 66, 66, 236, 157, 213, 140, 143, 88, 32, 64, 172, 167, 169], [139, 181, 86, 220, 247, 242, 115, 183, 220, 170, 201, 189, 26, 196, 71, 116, 238, 112, 48, 19, 175, 71, 116, 127, 41, 138, 151, 38, 32, 17, 1, 4, 254, 9, 176, 82, 237, 111, 54, 86, 91, 155, 244, 70, 244, 70, 12, 159]),
            ([152, 253, 35, 230, 12, 20, 124, 183, 97, 204, 125, 156, 230, 122, 156, 234, 65, 221, 62, 171, 231, 222, 231, 44, 34, 70, 223, 174, 222, 125, 19, 69, 96, 165, 158, 187, 244, 113, 152, 217, 95, 34, 55, 109, 224, 40], [63, 181, 74, 27, 181, 113, 251, 180, 17, 35, 7, 3, 12, 99, 255, 87, 104, 166, 34, 7, 254, 229, 223, 203, 181, 172, 13, 174, 234, 181, 189, 27, 166, 159, 78, 66, 231, 182, 61, 169, 3, 222, 35, 98, 190, 199, 228, 226]),
            ([45, 99, 69, 121, 62, 57, 50, 121, 60, 25, 105, 81, 71, 81, 150, 232, 9, 135, 160, 1, 212, 80, 76, 29, 39, 182, 252, 139, 202, 250, 28, 62, 26, 117, 155, 150, 100, 209, 210, 28, 192, 170, 222, 117, 182, 163, 122], [143, 206, 52, 15, 143, 81, 248, 167, 36, 7, 118, 123, 229, 37, 61, 246, 19, 15, 13, 104, 58, 221, 115, 3, 180, 172, 26, 12, 154, 86, 25, 74, 128, 170, 54, 215, 119, 27, 56, 153, 39, 176, 88, 44, 246, 24, 166, 100])
        ]
        
        func testPadding() {
            for i in 0..<16 {
                let original = Array<UInt8>(repeating: 0, count: 32 + i)
                let withPadding = original.addPadding()
                XCTAssertEqual(withPadding.count % 16, 0)
                let withoutPadding = withPadding.removePadding()
                XCTAssertEqual(withoutPadding, original)
            }
        }
        
        func testEncryptAes() throws {
            for data in self.dataset {
                let actual = try crypter.encryptAes(Data(data.decrypted))
                XCTAssertEqual(actual, Data(data.encrypted))
            }
        }
        
        func testDecryptAes() throws {
            for data in self.dataset {
                let actual = try crypter.decryptAes(Data(data.encrypted))
                XCTAssertEqual(actual, Data(data.decrypted))
            }
        }
    }
    
    final class OtherTests: XCTestCase {
        func testHash() {
            XCTAssertEqual(Crypter.sha512("lkjdasflnc"), "rbswGhojGpzw7EoB61dz3LpecUiFV7y0QHhO7xLHbgtPHhjsKxH6nbUg2p6B5CpSAa1hMzJKBfM8twldRbKj1g")
            XCTAssertEqual(Crypter.sha512("lkjdasflnc", key: "oimli"), "5NRfmNX8NnSCP2jrQIrhmkpo+wpz27FQDyU4_4lheOiJ8etSQ+spWak39WgaF8lzd8qwHzlkrfixZIZlf_1hSQ")
        }
    }
}
