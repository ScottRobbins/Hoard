import Foundation
import Files

extension File {

    func copy(to folder: Folder, overwrite: Bool) throws -> File {
        if overwrite && folder.containsFile(named: name) {
            try folder.file(atPath: name).delete()
        }

        return try copy(to: folder)
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
