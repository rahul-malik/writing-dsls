# Writing Domain Specific Languages

## Presented at:
- Functional Swift Conference - Brooklyn, NY 2017
- Mobiconf - Krakow, Poland 2017

## Video
[![Writing Domain Specific Languages - Functional Swift 2017](https://img.youtube.com/vi/YLeaRtB3GfY/0.jpg)](https://www.youtube.com/watch?v=YLeaRtB3GfY)

[Writing Domain Specific Languages - Functional Swift 2017](https://www.youtube.com/watch?v=YLeaRtB3GfY)

## Abstract
> A Domain Specific Language (DSL) is a computer programming language of limited expressiveness focused on a particular domain. Most languages you hear of are General Purpose Languages, which can handle most things you run into during a software project. Each DSL can only handle one specific aspect of a system.

Domain specific languages allow us to create an ideal environment for solving a specific problem. In this talk we’ll discuss how to use various language features like recursive enums, trailing closures and higher order functions to create elegant and type-safe domain specific languages.

We will go through real-world problems we encountered at Pinterest and will end by building a domain specific language for crafting type-safe GraphQL queries using the Github API.

## Playground

The examples I covered in the presentation are all available as pages in the [WritingDSLs](https://github.com/rahul-malik/writing-dsls/tree/master/WritingDSLs.playground) playground.

### Contents
- Page 1: File Hierarchies
- Page 2: Code Generation
- Page 3: GraphQL queries with Github

> Note: The GraphQL playground requires you to create your own access token for Github
https://developer.github.com/early-access/graphql/guides/accessing-graphql/

## Resources

- [Functional Programming for Domain-Specific Languages](https://pdfs.semanticscholar.org/b4c3/51cec897ae909e850f1ef6246b140a64544b.pdf) by Jeremy Gibbons
- [The difference between shallow and deep embedding](http://alessandrovermeulen.me/2013/07/13/the-difference-between-shallow-and-deep-embedding/)
- [DSL Q&A](https://martinfowler.com/bliki/DslQandA.html) by Martin Fowler
