// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "Nudi",
  platforms: [.macOS(.v13)],
  products: [.executable(name: "Nudi", targets: ["Nudi"])],
  targets: [
    .target(name: "PetCore"),
    .executableTarget(name: "Nudi", dependencies: ["PetCore"]),
    .executableTarget(name: "NudiChecks", dependencies: ["PetCore"], path: "Tests/PetCoreChecks")
  ]
)
