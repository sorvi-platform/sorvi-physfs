const std = @import("std");

const sorvi = @import("sorvi");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const physfs_dep = b.dependency("physfs", .{});

    const libphysfs = b.addLibrary(.{
        .name = "physfs",
        .linkage = .static,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/physfs_platform_sorvi.zig"),
            .target = sorvi.resolveSorviTarget(b, target.query),
            .optimize = optimize,
            .link_libc = true,
        }),
    });

    var files = b.addWriteFiles();
    _ = files.addCopyDirectory(physfs_dep.path("src"), "", .{});
    _ = files.addCopyDirectory(b.path("src"), "", .{});
    libphysfs.root_module.addCSourceFiles(.{
        .files = &.{
            "physfs.c",
            "physfs_byteorder.c",
            "physfs_unicode.c",
            "physfs_platform_posix.c",
            "physfs_archiver_dir.c",
            "physfs_archiver_zip.c",
        },
        .root = files.getDirectory(),
    });
    libphysfs.installHeader(physfs_dep.path("src/physfs.h"), "physfs.h");
    b.installArtifact(libphysfs);
}
