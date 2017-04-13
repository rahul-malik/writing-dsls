import Cocoa
import PlaygroundSupport

let q = query {[
    .repository(owner: "pinterest", name: "plank") {[
        .name,
        .homepageURL
    ]}
]}
