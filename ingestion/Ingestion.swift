//  Ingestion.swift
//
//  ProtoKit
//  Copyright © 2016 Trevor Squires.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

public enum IngestionError: Error {
    // A general failure you can throw, best constructed by makeProcessingFailed()
    case processingFailed(message: String, callerInfo: CallerInfo)
    
    // generated by checkedDowncast
    case checkedDowncastFailed(message: String, callerInfo: CallerInfo)
    
    case nullPayloadIdentityValue(ingesterName: String, key: String)
    case payloadMappingFailed(ingesterName: String, underlyingError: Error)
    
    public static func makeProcessingFailed(_ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) -> IngestionError {
        return IngestionError.processingFailed(message: message, callerInfo: CallerInfo(file, function, line))
    }
}

public func checkedDowncast<T: Any, U : Any>(_ source: T, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) throws -> U {
    guard let result = source as? U else {
        throw IngestionError.checkedDowncastFailed(message: "failed downcast from \(type(of: source)) to \(U.self)", callerInfo: CallerInfo(file, function, line))
    }
    return result
}

public func checkedDowncast<T: Any, U : Any>(_ source: Optional<T>, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) throws -> U {
    guard let result = source as? U else {
        throw IngestionError.checkedDowncastFailed(message: "failed downcast from \(type(of: source)) to \(U.self)", callerInfo: CallerInfo(file, function, line))
    }
    return result
}

public extension Array where Element: ValueTransformer {
    public func applyTransfomations(to value: Any?) -> Any? {
        var result = value
        for transformer in self {
            result = transformer.transformedValue(result)
        }
        return result
    }
}

public extension Sequence {
    public func indexedBy<T: Hashable>(_ keyForElement: (Iterator.Element) throws -> T?) rethrows -> Dictionary<T, Iterator.Element> {
        var reduced = Dictionary<T, Iterator.Element>()
        for element in self {
            if let key = try keyForElement(element) {
                if reduced[key] == nil {
                    reduced[key] = element
                }
            }
        }
        return reduced
    }
    
    public func groupedBy<T: Hashable>(_ keyForElement: (Iterator.Element) throws -> T?) rethrows -> Dictionary<T, [Iterator.Element]> {
        var reduced = Dictionary<T, [Iterator.Element]>()
        for element in self {
            if let key = try keyForElement(element) {
                var accumulator = reduced[key] ?? Array<Iterator.Element>()
                accumulator.append(element)
                reduced[key] = accumulator
            }
        }
        return reduced
    }
}

public extension Dictionary {
    // specialized to reserve initial capacity
    public func indexedBy<T: Hashable>(_ keyForElement: (Element) throws -> T?) rethrows -> Dictionary<T, Element> {
        var reduced = Dictionary<T, Element>(minimumCapacity: count)
        for element in self {
            if let key = try keyForElement(element) {
                if reduced[key] == nil {
                    reduced[key] = element
                }
            }
        }
        return reduced
    }
}

public extension Set {
    // specialized to reserve initial capacity
    public func indexedBy<T: Hashable>(_ keyForElement: (Element) throws -> T?) rethrows -> Dictionary<T, Element> {
        var reduced = Dictionary<T, Element>(minimumCapacity: count)
        for element in self {
            if let key = try keyForElement(element) {
                if reduced[key] == nil {
                    reduced[key] = element
                }
            }
        }
        return reduced
    }
}

public extension Array {
    // specialized to reserve initial capacity
    public func indexedBy<T: Hashable>(_ keyForElement: (Element) throws -> T?) rethrows -> Dictionary<T, Element> {
        var reduced = Dictionary<T, Element>(minimumCapacity: count)
        for element in self {
            if let key = try keyForElement(element) {
                if reduced[key] == nil {
                    reduced[key] = element
                }
            }
        }
        return reduced
    }
}
