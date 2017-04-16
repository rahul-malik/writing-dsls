//: Concise, Type-safe queries with GraphQL
import Cocoa
import PlaygroundSupport

/*:
 You'll need a valid Github access token to display results.
 Setup your OAuth token by following the [documentation](https://developer.github.com/early-access/graphql/guides/accessing-graphql/)
*/
let GithubToken = "OAUTH TOKEN HERE"

//: Here is the base of our query. The types are defined in `GQL.swift` which is in the sources directory of this page. You can modify the RepositoryField, UserField, IssueField enum to add additional fields and relationships that are present on in the [query documentation](https://developer.github.com/early-access/graphql/object/query/)
let q = query {[
    .repository(owner: "pinterest", name: "plank") {[
        .name,
        .homepageURL,
        .description
    ]}
]}


//: Below we create a simple text view to act as our live view. To show the live view in the playground you'll need to show the assistant editor (`View` -> `Assistant Editor` -> `Show Assistant Editor`)

let textView = GQLTextView()
PlaygroundPage.current.liveView = textView
loadQuery(token: GithubToken, query: q) { text in
    textView.string = "\(text)"
}

PlaygroundPage.current.needsIndefiniteExecution = true

//: [Previous](@previous)
