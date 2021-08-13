//
//  ApplicationExtensions.swift
//  ApplicationExtensions
//
//  Created by Rodrigo Labrador Serrano on 11/8/21.
//
import Vapor
import Foundation

extension Application {
    func createFolder(path: String) -> String? {
        let docURL = URL(string: self.directory.workingDirectory)!
        let dataPath = docURL.appendingPathComponent(path)
        if !FileManager.default.fileExists(atPath: dataPath.path) {
            do {
                try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
        return dataPath.path
    }
}
