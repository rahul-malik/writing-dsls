theme: Ostrich, 1

## Writing Domain Specific Languages

### Rahul Malik (@rmalik)

---

## [fit] Problem

### [fit] Move fast **with** quality

---

# Domain Specific Languages

![](https://media.giphy.com/media/JIX9t2j0ZTN9S/giphy.gif)

---


# [fit] A computer programming language of
# [fit] **limited expressiveness**
# [fit] focused on a
# [fit] **particular domain**
## > Martin Fowler


---

# Examples

- Makefile
- Podfile
- QuickCheck

---

# Why should we write them?

---

# Ease of use

---

# Type-Safety

---

# Declarative

### **(intent) -> action**

---

![inline](https://github.com/rahul-malik/writing-dsls/raw/master/Deck/Resources/c-dsl.png)

---

## Functional Languages

- Strong type system
- Higher-order functions / lazy evaluation
- Elegant syntax


---

## Recipe for creating a new DSL

- Model the problem (Reify)
- Build modular / composable abstractions
- Work iteratively

---

## **PIN**Core


---

## swift package init

---

## Files & Folders

```bash
➜ mkdir MyLibrary
➜ swift package init
Creating library package: MyLibrary
Creating Package.swift
Creating .gitignore
Creating Sources/
Creating Sources/MyLibrary.swift
Creating Tests/
Creating Tests/LinuxMain.swift
Creating Tests/MyLibraryTests/
Creating Tests/MyLibraryTests/MyLibraryTests.swift
```


---

## Creating folders…

```swift
let frameworkName = "MyLibrary"
// make the directory structure
c.mkdir(frameworkName)
c.currentDirectory += "/\(frameworkName)"
let coreDirectories = ["Sources", "Tests"]
// add placeholder .gitkeep files to directories
coreDirectories.forEach(c.mkdir)
coreDirectories.forEach(c.gitkeep)
```

---

## Creating folders…

```swift
let frameworkName = "MyLibrary"
// make the directory structure
c.mkdir(frameworkName)
c.currentDirectory += "/\(frameworkName)"
let coreDirectories = ["Sources", "Tests"]
// add placeholder .gitkeep files to directories
coreDirectories.forEach(c.mkdir)
coreDirectories.forEach(c.gitkeep)
c.currentDirectory += "/Tests"
c.mkdir("\(frameworkName)Tests")
```

---

## Creating files…

```swift
// ctx - Context variables for all templates

// Create files from templates
evalTemplate(resource: ".gitignore", context: ctx, to: Path(""))

evalTemplate(resource: "Package.swift", context: ctx, to: Path(""))

evalTemplate(resource: "Tests.swift", context: ctx,
				to: Path("Tests/\(frameworkName)Tests/\(frameworkName)Tests.swift"))

// Repeat for every file ...
```

---

![](https://static01.nyt.com/images/2016/08/05/us/05onfire1_xp/05onfire1_xp-master768-v2.jpg)

---

### Whats wrong with this?


- Error prone
- Hard to follow
- Imperative


---

# Model the Problem

---

## Recursive enums

```swift
    enum Tree<A> {
        case Empty
        indirect case Node(left: Tree<A>, value: A, right: Tree<A>)
    }
```


---

# [fit] Algebraic Data Types (ADT) :tada:
## [fit] **type formed by combining other types.**

---

## Reify with Recursive Enums

```swift
    enum DirectoryItem {
      case File(name: String, content: String)
      indirect case Folder(name: String, contents: [DirectoryItem])
    }
```

---

## Files / Folders with ADT

```swift
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
```

---

```swift
func createFiles(atPath path: String, rootDirectory item: DirectoryItem) {
	switch item {
	case .File(name: let name, contents: let contents):
		writeFile(contents: contents, atPath: Path(name))
	}
}
```
---

```swift
func createFiles(atPath path: String, rootDirectory item: DirectoryItem) {
	switch item {
	case .File(name: let name, contents: let contents):
		writeFile(contents: contents, atPath: Path(name))
	case .Folder(name: let name, items: let subdirs):
		c.mkdir(name)
		c.gitkeep(name)
		let newPath = path + "/\(name)"
		c.currentDirectory = newPath
		_ = subdirs.map { createFiles(atPath: newPath, rootDirectory: d) }
		c.currentDirectory = path
	}
}
```

---

## ls

```swift
func ls(_ item: DirectoryItem, _ path: String) {
	switch item {
	case .File(name: let name, content:_):
		print([path, name].joined(separator: "/"))
	case .Folder(name: let name, contents: let contents):
		contents.map { ls($0, [path, name].joined(separator: "/"))}
	}
}
```

---

# Deep DSL
## [fit] `1 + 2 = Expr(+, 1, 2)`

---

# Plank
![inline 80%](https://cdn-images-1.medium.com/max/1600/1*Bgfy3LbWkhMWOR2SYTlzPQ.png)

---

## Code generation

```swift
typealias CodeGenerator = () -> [String]
```

---

## fibonacci


```swift
func fibonacci(_ i: Int) -> Int {
    if i <= 2 {
        return 1
    } else {
        return fibonacci(i - 1) + fibonacci(i - 2)
    }
}
```
---

## First attempt

```swift
func generatefib () {
    return [
        "if i <= 2 {",
        "	return 1",
        "} else {",
        "	return fibonacci(i - 1) + fibonacci(i - 2)",
        "}",
    ]
}
```


---

## if / else structure

```swift
if (/* some condition */ ) {
  /* line 1 */
  /* line 2 */
  /* ...    */
} else {
  /* line 1 */
  /* line 2 */
  /* ...    */
}
```

---


## if
```swift
func ifStmt(_ condition: String,
			_ body: CodeGenerator) -> [String] {
	return [
		"if \(condition) {",
			-->body,
		"}"
	]
}
```

---
## else


```swift
func elseStmt(_ body: CodeGenerator) -> [String] {
	return [
		" else {",
			-->body,
		"}"
	]
}
```

---


# if + else
```swift
func ifElseStmt(_ condition: String,
				body: @escaping CodeGenerator) -> (CodeGenerator) -> [String] {
	return { elseBody in [
		ifStmt(condition, body),
		elseStmt(elseBody)
      ].flatMap { $0 }
	}
}
```

---
# fibonacci with dsl

```swift
ifElseStmt("i <= 2") {[
	// If
	"return 1"
]} ({
	// Else
	"return fibonacci(i - 1) + fibonacci(i - 2)"
})
```



---

# Higher Order Functions!

---

# Shallow DSL
## [fit]  `1 + 2 = 3`


---

Shallow|Deep
---|---
`1 + 2 = 3`|`1 + 2 = Expr(+, 1, 2)`


---

# Lets build something new!

---

## GraphQL

---


## What is GraphQL?

GraphQL is a **query language for APIs**.
It’s an alternative to the traditional RESTful endpoints.

---

# GitHub
![inline](https://assets-cdn.github.com/images/modules/logos_page/Octocat.png)

---

## Issues in repository

```typescript
{
  repository(owner:"pinterest", name:"plank") { // Repo
    name,
    description,
    homepageURL
  }
}
```
---

## Issues in repository

```typescript
{
  repository(owner:"pinterest", name:"plank") { // Repo
    name,
    description,
    homepageURL,
    owner { // User
      avatarURL
    }
}
```
---

## Issues in repository

```typescript
{
  repository(owner:"pinterest", name:"plank") { // Repo
    name,
    description,
    homepageURL,
    owner { // User
      avatarURL
    },
    issues(first:10) { // Issues
      nodes {
        title,
        state
      }
    }
  }
}
```

---

## JSON response

```json
{
  "data": {
    "repository": {
      "name": "plank",
      "description": "A tool for generating immutable model objects",
      "homepageURL": "https://pinterest.github.io/plank/",
      "owner": {
        "avatarURL": "https://avatars1.githubusercontent.com/u/541152?v=3"
      },
      "issues": {
        "nodes": [
          {
            "title": "Model value type in Schema.Map / Schema.Array as a separate enum",
            "state": "OPEN"
          },
        ]
      }
    }
  }
}
```

---
## Types of DSLs

  - External
  - Internal / Embedded


---

## Problem:
### How can we write concise
### type-safe queries?

---

```swift
let query = [
    "{",
    "  repository(owner:\"pinterest\", name:\"plank\") {",
    "    name,",
    "    description,",
    "    homepageURL,",
    "    owner {",
    "      avatarURL",
    "    }",
    "    issues(first:10) {",
    "      nodes {",
    "        title,",
    "        state",
    "      }",
    "    }",
    "  }",
    "}"].joined(separator: " ")
```

---

![inline](https://media.giphy.com/media/143vPc6b08locw/giphy.gif)

---

# Query

---

# Structure

```typescript
repository(owner: "pinterest", name: "plank") {
	name,
	description,
	owner {
	    avatarURL
	}
}
```

---

# Structure

```typescript
object(arguments) {
	field1,
	field2,
	object {
		field3
	}
}
```

---

## Reify :tada:

```swift
enum Node {
    case Scalar(label: String)
    indirect case Object(label: String, arguments: [InputArgument]?, fields:[Node])
}

enum InputType {
    case string(String)
    case integer(Int)
}

typealias InputArgument = (String, InputType)
```
---

## Query with Nodes : Repository


```swift
.Object(label: "repository",
        arguments: [("owner", .string("pinterest")), ("name", .string("plank"))],
        fields: [.Scalar(label: "name"),
                 .Scalar(label: "description"),
                 .Scalar(label: "homepageURL"),
        ]
)
```

---

## Query with Nodes : Repository Owner

```swift
.Object(label: "repository",
        arguments: [("owner", .string("pinterest")), ("name", .string("plank"))],
        fields: [.Scalar(label: "name"),
                 .Scalar(label: "description"),
                 .Scalar(label: "homepageURL"),
                 .Object(label: "owner",
                        arguments: nil,
                        fields: [.Scalar(label: "avatarURL")]),
        ]
)
```

---

## Query with Nodes : Repository Issues


```swift
.Object(label: "repository",
        arguments: [("owner", .string("pinterest")), ("name", .string("plank"))],
        fields: [.Scalar(label: "name"),
                 .Scalar(label: "description"),
                 .Scalar(label: "homepageURL"),
                 .Object(label: "owner",
                        arguments: nil,
                        fields: [.Scalar(label: "avatarURL")]),
                 .Object(label: "issues",
                         arguments: [("first", .integer(10))],
                         fields: [
                             .Object(label: "nodes",
                                     arguments: nil,
                                     fields: [.Scalar(label: "title"),
                                              .Scalar(label: "state")])
                         ])
        ]
)
```

---

## Node -> Query String : Scalar

```swift
func renderQueryString(node: Node) -> String {
	switch node {
	case .Scalar(label: let label):
		return label
    }
}
```

---

## Node -> Query String : Object

```swift
func renderQueryString(node: Node) -> String {
	switch node {
	case .Scalar(label: let label):
		return label
	case .Object(label: let label, arguments: .none, fields: let fields):
		// Object without arguments
		let fieldString = fields.map(renderQueryString).joined(separator: " ")
		return "\(label) { \(fieldString) }"
    }
}
```

---

## Node -> Query String : Object with Args

```swift
func renderQueryString(node: Node) -> String {
	switch node {
	case .Scalar(label: let label):
		return label
	case .Object(label: let label, arguments: .none, fields: let fields):
		// Object without arguments
		let fieldString = fields.map(renderQueryString).joined(separator: " ")
		return "\(label) { \(fieldString) }"
	case .Object(label: let label, arguments: .some(let args), fields: let fields):
		// Object with arguments
		let fieldString = fields.map(renderQueryString).joined(separator: " ")
		let argString = args.map(renderArgument).joined(separator: ", ")
		return "\(label) (\(argString)) { \(fieldString) }"
	}
}
```

---

## Field Arguments

```swift
func renderArgument(arg: InputArgument) -> String {
	switch arg.1 {
	case .string(let argVal):
		return "\(arg.0):\"\(argVal)\""
	case .integer(let argVal):
		return "\(arg.0):\(argVal)"
	}
}
```


---

# Types

---

## Fields

```swift

typealias FieldSelection<T> = () -> [T]

enum QueryRoot {
    case repository(owner: String, name: String, FieldSelection<RepositoryField>)
	// Other root objects...
}
```

---

```swift
enum RepositoryField {
    case name
    case description
    case homepageURL
    case owner(FieldSelection<UserField>)
    case issues(first: Int, FieldSelection<IssueField>)
}

enum UserField {
    case login
    case avatarURL
}

enum IssueField {
    case title
    case state
}
```

---

# Field Selection DSL

```swift
.repository(owner: "pinterest", name: "plank") {[
	.name,
	.description,
	.owner {[
		.login,
		.avatarURL
	]},
	.issues(first: 10) {[
		.nodes {[
			.title,
			.state
		]}
	]}
]}
```

---

## (Fields) -> Nodes ?

---

## (Fields) -> Nodes

```swift
protocol NodeRenderer {
    func renderNode() -> Node
}
```

---

# QueryRoot

```swift
enum QueryRoot: NodeRenderer {
    func renderNode() -> Node {
        switch self {
        case .repository(owner: let owner, name: let name, let fieldsFn):
            return Node.Object(label: "repository",
                               arguments: [("owner", .string(owner)),
                                           ("name", .string(name))],
                               fields: fieldsFn().map { $0.renderNode() })
        }
    }
}
```

---

# User, Repository, Issue...

```swift

enum UserField: NodeRenderer { /*...*/ }

enum RepositoryField: NodeRenderer { /*...*/ }

enum IssueField: NodeRenderer { /*...*/ }

```

---

# (Fields) -> (Nodes) -> Query

```swift
func query(_ fields: FieldSelection<QueryRoot>) -> String {
    return "{" +
        fields().map { $0.renderNode() }
                .map { $0.renderQueryString() }
                .joined(separator: " ") +
    "}"
}
```

---

# Demo

![inline](https://cosminpupaza.files.wordpress.com/2015/12/playground.png)

---

# Thank you!

## @rmalik
![](https://media.giphy.com/media/wpoLqr5FT1sY0/giphy.gif)

---

# Appendix

---

## Switch Statement DSL

---

## switch structure

```swift
switch /* variable name */ {
case1:
    / * case 1 logic */
case2:
    / * case 2 logic */
caseN:
    / * case n logic */
default:
    / * default logic */
}
```

---

## Switch / SwitchCase

```swift
enum SwitchCase {
    case Case(condition: String, body: CodeGenerator)
    case Default(body: CodeGenerator)
}

func switchStmt(_ switchVariable: String, body: () -> [SwitchCase]) -> [String] {
    return [
        "switch (\(switchVariable)) {",
            body().map { $0.render() }
                  .flatMap { $0 }
                  .joined(separator: "\n"),
        "}"
    ]
}
```

---

## Rendering Case Statements

```swift
enum SwitchCase {
    func render() -> [String] {
        switch self {
        case .Case(let condition, let body):
            return [
			  "case \(condition):",
                body
            ]
        case .Default(let body):
            return [
			  "default:",
               body
            ]
        }
    }
}

```
---

# Fibonacci with switch dsl
```swift
switchStmt("i") {[
	.Case("0") {[
		"return 1"
	]},
	.Case("1") {[
		"return 1"
	]},
	.Default {[
		"return fibonacci(i - 1) + fibonacci(i - 2)"
	]}
]}
```

---

## Custom Operators

```swift
prefix operator -->

prefix func --> (body: CodeGenerator) -> String {
	return body().flatMap {
		$0.components(separatedBy: "\n").map { "  " + $0 }
	}.joined(separator: "\n")
}
```

