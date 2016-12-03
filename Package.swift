import PackageDescription

let package = Package(
    name: "Stripe",
    dependencies: [
        .Package(url: "https://github.com/vapor/node.git", majorVersion: 1, minor: 0)
    ]
)
