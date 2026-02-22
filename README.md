## zLib Nuget Package

This project builds a zLib Nuget package with static zLib
libraries and header files for `Win32`/`x64` platforms.

Visit the zLib website for additional information about the zLib
project and library documentation:

https://zlib.net/

## Package Configuration

This package contains only static libraries for all platforms
listed above. There are no dynamic libraries included.

The zLib static libraries from this package will appear in the
installation target project after the package is installed.
The solution may need to be reloaded to make these libraries visible.
Both debug and release libraries will be listed in the project,
but only the one appropriate for the currently selected
configuration will be included in the build. These libraries
may be moved into solution folders after the installation (e.g.
`lib/Debug` and `lib/Release`).

Note that the zLib library path in this package will be selected
as `Debug` or `Release` based on whether the selected configuration
is designated as a development or release configuration via
the standard Visual Studio property called `UseDebugLibraries`.
Additional configurations copied from the standard ones will
inherit this property.

Do not install this package if your projects use debug configurations
without `UseDebugLibraries`. Note that CMake-generated Visual Studio
projects will not emit this property.

See `StoneSteps.zLib.VS2022.Static.props` and
`StoneSteps.zLib.VS2022.Static.targets`
for specific package configuration details and file locations.

The static library is built with the `__stdcall` calling convention,
which allows projects building against this library to use any
calling convention.

## Building a Nuget Package

This project can build a Nuget package for zLib either locally
or via a GitHub workflow. In each case, the following steps are taken.

  * The zLib source archive is downloaded from zLib's website and
    its SHA-256 signature is verified.

  * zLib's `CMakeLists.txt` is patched up to build with the
    `ZLIB_WINAPI` calling convention, which translates into
    `__stdcall` after the macro expansion.

  * VS2022 Community Edition is used to build zLib libraries
    locally and Enterprise Edition is used to build libraries on
    GitHub.

  * Build artifacts for all platforms and configurations are
    collected in staging directories under `nuget/build/native/lib`.

  * `nuget.exe` is used to package staged files with the first
    three version components used as the zLib version and the last
    version component used as a package revision. See the _Package
    Version_ section for more details.

  * The Nuget package built on GitHub is uploaded to [nuget.org][].
    The package built locally is saved in the root project
    directory.

## Package Version

### Package Revision

Nuget packages lack a package revision. In order to repackage
the same upstream software version, such as zLib v1.2.11, the
4th component of the Nuget version is used to track the Nuget
package revision.

The Nuget package revision is injected outside of the Nuget package
configuration, during the package build process, and is not present
in the package specification file.

Specifically, `nuget.exe` is invoked with `-Version=1.2.11.123`
to build a package with the revision `123`.

When the upstream version lacks the patch-level version component,
`.0` is injected to keep the version consistent with the version
pattern sequence (e.g. v1.3 is listed in Nuget as v1.3.0).

### Version Locations

The zLib version is located in a few places in this repository and
needs to be changed in all of them for a new version of zLib.

  * nuget/StoneSteps.zLib.VS2022.Static.nuspec (`version`)
  * devops/make-package.bat (`PKG_VER`, `PKG_REV`, `ZLIB_FNAME`,
    `ZLIB_SHA256`, `PKG_VER_PATCH`)
  * .github/workflows/build-nuget-package.yml (`name`, `PKG_VER`,
    `PKG_REV`, `ZLIB_FNAME`, `ZLIB_SHA256`, `PKG_VER_PATCH`)

`ZLIB_SHA256` is a SHA-256 checksum of the zLib package file and
needs to be changed when a new version of zLib is released.

Verify that the new zLib archive follows the directory name pattern
used in the `ZLIB_DNAME` variable.

In the GitHub workflow YAML, `PKG_REV` must be reset to `1` (one)
every time the zLib version is changed. The workflow file must be
renamed with the new version in the name. This is necessary because
GitHub maintains build numbers per workflow file name.

For local builds, the package revision is supplied on the command line
and should be specified as `1` (one) for a new version of zLib.

When the upstream version lacks the patch component, `PKG_VER_PATCH`
should be uncommented in all locations listed above to construct a full
Nuget version. Otherwise it should be commented out.

### GitHub Build Number

The build number within the GitHub workflow YAML is maintained in an
unconventional way because of the lack of build management integration
between GitHub and Nuget.

For example, with build management systems, such as Artifactory, every
build would generate a Nuget package with the same version and package
revision for the upcoming release and build numbers would be tracked
within the build management system. A build that was successfully
tested would be promoted to the production Nuget repository without
generating a new build.

Without a build management system, the GitHub workflow in this
repository uses the pre-release version as a surrogate build number for
builds that do not publish packages to nuget.org, so these builds can
be downloaded and tested before the final build is made and published
to nuget.org. This approach is not recommended for robust production
environments because even though the final published package is built
from the exact same source, the build process may still potentially
introduce some unknowns into the final package (e.g. build VM was
updated).

## Building Package Locally

You can build a Nuget package locally with `make-package.bat`
located in `devops`. This script expects VS2019 Community Edition to
be installed in the default location. If you have another edition of
Visual Studio, edit the file to use the correct path to the
`vcvarsall.bat` file.

Run `make-package.bat` from the repository root directory with a
package revision as the first argument. There is no provision to
manage build numbers from the command line and other tools should be
used for this.

## Sample Application (zPipe)

A Visual Studio project is included in this repository under
`sample-zpipe` to test the Nuget package built by this project.
This application is copied from `zlib-1.2.11/examples` and
adapted to build as a C++ project.

The original C source of this sample application is subject
to zLib's copyright and terms of use.

In order to build `zpipe.exe`, open the Nuget Package Manager in the
solution and install either the locally-built Nuget package or the
one from [nuget.org][].

`zpipe.exe` compresses/decompresses standard input/output and
can be tested with this pipe:

    echo ABC | zpipe | zpipe -d

The output will be `ABC` in this example, which will be compressed
by the first invocation of `zpipe.exe` and decompressed by the
second one.

[nuget.org]: https://www.nuget.org/packages/StoneSteps.zLib.VS2022.Static/
