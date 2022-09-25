//
//  StringSHA1.swift
//  LoopFollow
//
//  Created by peng on 2022/9/25.
//  Copyright © 2022 Jon Fawcett. All rights reserved.
//

import Foundation


extension Int
{
    //添加一个扩展方法，用来将整数类型，转换成十六进制的字符串。
    func hexedString() -> String
    {
      //通过设置十六进制的格式，
     //将自身转换成十六进制的字符串，
     //并返回该字符串。
     return NSString(format:"%02x", self) as String
    }
}

//添加一个数据类型的扩展
extension NSData
{
    //添加一个扩展方法，用来将数据类型，转换成十六进制的字符串。
    func hexedString() -> String
    {
         //初始化一个字符串对象
        var string = String()

        //将不安全原始指针格式的字节，
        //转换成不安全指针的格式
        let unsafePointer = bytes.assumingMemoryBound(to: UInt8.self)
        //添加一个循环语句
        for i in UnsafeBufferPointer<UInt8>(start: unsafePointer, count: length)
        {
            //通过整形对象的扩展方法，将二进制数据转换成十六进制的字符串。
            string += Int(i).hexedString()
        }
        //返回十六进制的字符串。
        return string
    }

    //添加一个扩展方法，实现对数据的SHA1加密功能
    func SHA1() -> NSData
    {
        //首先创建一个20位长度的可变数据对象。
        let result = NSMutableData(length: Int(CC_SHA1_DIGEST_LENGTH))!
        //将不安全原始指针格式的字节，转换成不安全指针的格式。
        let unsafePointer = result.mutableBytes.assumingMemoryBound(to: UInt8.self)
        //通过调用加密方法，对数据进行加密，并将加密后的数据，存储在可变数据对象中。
        CC_SHA1(bytes, CC_LONG(length), UnsafeMutablePointer<UInt8>(unsafePointer))
        //最后将结果转换成数据格式对象并返回。
        return NSData(data: result as Data)
    }
}

//添加一个字符串类型的扩展。
extension String
{
    //添加一个扩展方法，实现SHA1加密的功能。
    func SHA1() -> String
    {
        //将字符串对象，转换成自定编码的数据对象
        let data = (self as NSString).data(using: String.Encoding.utf8.rawValue)! as NSData
        //调用数据对象的扩展方法，进行加密操作
        //并返回十六进制的结果。
        return data.SHA1().hexedString()
    }
}


extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
            }
            .joined(separator: "&")
            .data(using: .utf8)
    }
}

extension CharacterSet {
     static let urlQueryValueAllowed: CharacterSet = {
         let generalDelimitersToEncode = ":#[]@"
         let subDelimitersToEncode = "!$&'()*+,;="
 
         var allowed = CharacterSet.urlQueryAllowed
         allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
         return allowed
     }()
}
