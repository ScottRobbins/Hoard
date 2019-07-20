import Basic

extension TerminalController {

    func writeln(_ string: String, inColor: TerminalController.Color = .noColor, bold: Bool = false) {
        write(string, inColor: inColor, bold: bold)
        write("\n")
    }
}
