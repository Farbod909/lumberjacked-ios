//
//  Util.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 7/5/24.
//

extension Optional where Wrapped == String {
    var _bound: String? {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
    public var bound: String {
        get {
            return _bound ?? ""
        }
        set {
            _bound = newValue.isEmpty ? nil : newValue
        }
    }
}

/// source: https://gist.github.com/mredig/f6d9efb196a25d857fe04a28357551a6
/// Makes an Encodable and Decodable properties encode to `null` instead of omitting the value altogether.
@propertyWrapper
public struct NullCodable<T> {
    public var wrappedValue: T?

    public init(wrappedValue: T?){
        self.wrappedValue = wrappedValue
    }
}

extension NullCodable: Encodable where T: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch wrappedValue {
        case .some(let value):
            try container.encode(value)
        case .none:
            try container.encodeNil()
        }
    }
}

extension NullCodable: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.wrappedValue = try? container.decode(T.self)
    }
}
