import Files

struct HoardConfig: Codable {
    struct File: Codable {
        let identifier: String
        let path: String
    }
    
    let repoPath: String
    let files: [File]
}
