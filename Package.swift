// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "Nudi",
  platforms: [.macOS(.v13)],
  // The native menu bar entry point is not implemented yet.
  products: [.library(name: "NudiPrototype", targets: ["Nudi"])],
  targets: [
    .target(name: "PetCore"),
    .target(name: "Nudi", dependencies: ["PetCore"]),
    .testTarget(name: "PetCoreTests", dependencies: ["PetCore"])
  ]
)
