import Foundation
import Files

extension File {

    func copy(to folder: Folder, overwrite: Bool) throws -> File {
        if overwrite && folder.containsFile(named: name) {
            try folder.file(atPath: name).delete()
        }

        return try copy(to: folder)
    }

    func rename(to newName: String, keepExtension: Bool = true, overwrite: Bool) throws {
        if overwrite {
            let fullNewFileName = [newName, self.extension].compactMap { $0 }.joined(separator: ".")
            if let parent = parent, let file = try? parent.file(named: fullNewFileName) {
                try file.delete()
            } else if let file = try? File(path: fullNewFileName) {
                try file.delete()
            }
        }

        try rename(to: newName, keepExtension: keepExtension)
    }
}
