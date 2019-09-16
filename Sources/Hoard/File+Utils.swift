import Foundation
import Files

extension File {
    
    func copy(to folder: Folder, overwrite: Bool) throws -> File {
        if overwrite && folder.containsFile(named: name) {
            try folder.file(atPath: name).delete()
        }
        
        return try copy(to: folder)
    }
    
    func copy(toPath newPath: String, overwrite: Bool) throws -> File {
        let fileManager = FileManager.default
        let absoluteNewPath = try fileManager.absolutePath(for: newPath)
        let absolutePath = try fileManager.absolutePath(for: path)
        
        if overwrite, let deleteFile = try? File(path: newPath) {
            try deleteFile.delete()
        }
        
        try fileManager.copyItem(atPath: absolutePath, toPath: absoluteNewPath)
        return try File(path: absoluteNewPath)
    }
    
    func rename(to newName: String, overwrite: Bool) throws {
        if overwrite {
            if let parent = parent, let file = try? parent.file(named: newName) {
                try file.delete()
            } else if let file = try? File(path: newName) {
                try file.delete()
            }
        }
        
        try rename(to: newName, keepExtension: false)
    }
}

// Credit to https://github.com/JohnSundell/Files for this part
extension FileManager {
    func absolutePath(for path: String) throws -> String {
        if path.hasPrefix("/") {
            return try pathByFillingInParentReferences(for: path)
        }
        
        if path.hasPrefix("~") {
            let prefixEndIndex = path.index(after: path.startIndex)
            
            let path = path.replacingCharacters(
                in: path.startIndex..<prefixEndIndex,
                with: ProcessInfo.processInfo.homeFolderPath
            )
            
            return try pathByFillingInParentReferences(for: path)
        }
        
        return try pathByFillingInParentReferences(for: path, prependCurrentFolderPath: true)
    }
    
    func pathByFillingInParentReferences(for path: String, prependCurrentFolderPath: Bool = false) throws -> String {
        var path = path
        var filledIn = false
        
        while let parentReferenceRange = path.range(of: "../") {
            let currentFolderPath = String(path[..<parentReferenceRange.lowerBound])
            
            guard let currentFolder = try? Folder(path: currentFolderPath) else {
                throw FileSystem.Item.PathError.invalid(path)
            }
            
            guard let parent = currentFolder.parent else {
                throw FileSystem.Item.PathError.invalid(path)
            }
            
            path = path.replacingCharacters(in: path.startIndex..<parentReferenceRange.upperBound, with: parent.path)
            filledIn = true
        }
        
        if prependCurrentFolderPath {
            guard filledIn else {
                return currentDirectoryPath + "/" + path
            }
        }
        
        return path
    }
}

extension ProcessInfo {
    var homeFolderPath: String {
        return environment["HOME"]!
    }
}
