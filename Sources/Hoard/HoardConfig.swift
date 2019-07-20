import Files

struct HoardConfig: Decodable {
    struct File: Decodable {
        let identifier: String
        let path: String
    }

    let repoPath: String
    let files: [File]
}
