// Re-exports the PhunwareMapping binary framework so that consumers of the
// `PhunwareMapping` SwiftPM product can `import PhunwareMapping` directly.
//
// The PhunwareMappingWrapper target exists so the binary xcframework
// (PhunwareMappingBinary) can be linked alongside its runtime dependencies
// (PWMapKit, PhunwarePermissionPriming, PhunwareNetworking, PhunwareTheming,
// PhunwareFoundation), which a binaryTarget cannot declare on its own.
@_exported import PhunwareMapping
