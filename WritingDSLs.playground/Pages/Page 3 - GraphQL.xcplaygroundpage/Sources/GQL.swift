import Foundation
import Cocoa

public enum Node {
    case Scalar(label: String)
    case Object(label: String, arguments: [InputArgument]?, fields:[Node])
}

public enum InputType {
    case string(String)
    case integer(Int)
}

public typealias InputArgument = (String, InputType)

func renderArgument(arg: InputArgument) -> String {
    switch arg.1 {
    case .string(let argVal):
        return "\(arg.0):\"\(argVal)\""
    case .integer(let argVal):
        return "\(arg.0):\(argVal)"
    }
}

func renderQueryString(node: Node) -> String {
    switch node {
    case .Scalar(label: let label):
        return label
    case .Object(label: let label, arguments: .none, fields: let fields):
        let fieldStr = fields.map(renderQueryString).joined(separator: " ")
        return "\(label) { \(fieldStr) }"
    case .Object(label: let label, arguments: .some(let args), fields: let fields):
        let fieldStr = fields.map(renderQueryString).joined(separator: " ")
        let argString = "(\(args.map(renderArgument).joined(separator: " ")))"
        return "\(label) \(argString){ \(fieldStr) }"
    }
}

public typealias FieldSelection<T> = () -> [T]

public enum QueryRoot {
    case repository(owner: String, name: String, FieldSelection<RepositoryField>)
}

public enum RepositoryField {
    case name
    case description
    case homepageURL
    case owner(FieldSelection<UserField>)
    case issues(first: Int, FieldSelection<Connection<IssueField>>)
}

public enum UserField {
    case login
    case avatarURL
}

public enum IssueField {
    case title
    case state
}

public protocol NodeRenderer {
    func renderNode() -> Node
}

public enum Connection<T: NodeRenderer> {
    case nodes(FieldSelection<T>)
}

extension QueryRoot: NodeRenderer {
    public func renderNode() -> Node {
        switch self {
        case .repository(owner: let owner, name: let name, let fieldsFn):
            return Node.Object(label: "repository",
                               arguments: [("owner", .string(owner)),
                                           ("name", .string(name))],
                               fields: fieldsFn().map { $0.renderNode() })
        }
    }
}

extension IssueField: NodeRenderer {
    public func renderNode() -> Node {
        switch self {
        case .title, .state:
            return .Scalar(label: "\(self)")
        }
    }
}

extension Connection: NodeRenderer {
    public func renderNode() -> Node {
        switch self {
        case .nodes(let fieldsFunc):
            return .Object(label: "nodes", arguments: nil, fields: fieldsFunc().map { $0.renderNode() })
        }
    }
}

extension UserField: NodeRenderer {
    public func renderNode() -> Node {
        switch self {
        case .avatarURL, .login:
            return .Scalar(label: "\(self)")
        }
    }
}

extension RepositoryField: NodeRenderer {
    public func renderNode() -> Node {
        switch self {
        case .name, .description, .homepageURL:
            return Node.Scalar(label: "\(self)")
        case .owner(let fieldsFn):
            return Node.Object(label: "owner", arguments: nil, fields:fieldsFn().map { $0.renderNode() })
        case .issues(first: let firstNum, let connection):
            return Node.Object(label: "issues", arguments: [("first", .integer(firstNum))], fields: connection().map { $0.renderNode() })
        }
    }
}


public func query(_ fields: () -> [QueryRoot]) -> String {
    return "{" +
        fields().map { $0.renderNode() }
            .map(renderQueryString)
            .joined(separator: " ") +
    "}"
}

func createGQLRequest(query: String) -> URLRequest {
    let GHToken = "3b62f5915226de4fb8dcb7f0c84a621ef6a340f9"
    var req = URLRequest(url: URL(string: "https://api.github.com/graphql")!)
    req.httpMethod = "POST"
    req.setValue("bearer \(GHToken)", forHTTPHeaderField: "Authorization")
    req.httpBody = try? JSONSerialization.data(withJSONObject: ["query" : query], options:[])
    req.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
    return req
}

func JSONStringify(value: AnyObject) -> String {
    let options = JSONSerialization.WritingOptions.prettyPrinted
    if JSONSerialization.isValidJSONObject(value) {
        if let data = try? JSONSerialization.data(withJSONObject: value, options: options) {
            if let string = String(data: data, encoding: .utf8) {
                return string
            }
        }
    }
    return ""
}


public func loadQuery(query: String,
                      callback: @escaping (Any) -> Void) {
    let dataTask = URLSession.shared.dataTask(with: createGQLRequest(query: query)) { (data, response, err) in
        if let responseData = data {
            if let responseObj = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
                DispatchQueue.main.async {
                    callback(JSONStringify(value: responseObj as AnyObject))
                }
            }
        } else {
            print("error loading req: \(String(describing: err))")
        }
    }
    dataTask.resume()
}

public func GQLTextView() -> NSTextView {
    let textView = NSTextView(frame: CGRect(x: 0, y: 0, width: 345, height: 2048))
    textView.font = NSFont(name: "Monaco", size: 14.0)
    textView.isEditable = false
    textView.backgroundColor = NSColor.white
    return textView
}
