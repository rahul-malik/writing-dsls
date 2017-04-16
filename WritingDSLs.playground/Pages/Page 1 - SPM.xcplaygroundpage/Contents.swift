//: Deep DSL for defining File Hierarchies
import Foundation

enum DirectoryItem {
    case File(name: String, content: String)
    case Folder(name: String, contents: [DirectoryItem])
}

let package = DirectoryItem.Folder(
    name: "MyLibrary",
    contents: [
        .File(name: ".gitignore", content: ""),
        .Folder(
            name: "Sources",
            contents: [.File(name: "MyLibrary.swift", content: "...")]),
        .Folder(
            name: "Tests",
            contents: [
                .File(name: "LinuxMain.swift", content: "..."),
                .Folder(name: "MyLibraryTests",
                        contents: [.File(name: "MyLibraryTests.swift", content: "...")])
            ]
        )
    ]
)

func ls(_ item: DirectoryItem, _ path: String = "") {
    switch item {
    case .File(name: let name, content:_):
        print([path, name].joined(separator: "/"))
    case .Folder(name: let name, contents: let contents):
        contents.map { ls($0, [path, name].joined(separator: "/"))}
    }
}

ls(package)

//: [Previous](@previous) [Next](@next)
