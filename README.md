## zLib Nuget Package

This project builds a zLib Nuget package with static zLib
libraries and header files  for `Win32`/`x64` platforms and
`Debug`/`Release` configurations.

Visit zLib website for additional information about the zLib
project and library documentation:

https://zlib.net/

## Package Configuration

This package contains only static libraries for all platforms
and configurations listed above. There are no dynamic libraries
included.

The zLib static library appropriate for the platform and
configuration selected in a Visual Studio solution is explicitly
referenced within this package and will appear within the solution
folder tree after the package is installed. The solution may need
to be reloaded to make the library file visible. This library may
be moved into any solution folder after the installation.

Note that the zLib library path in this package is valid only
for build configurations named `Debug` and `Release` and will
not work for any other configuration names. Do not install this
package for projects with configurations other than `Debug` and
`Release`.

See `StoneSteps.zLib.Static.props` and `StoneSteps.zLib.Static.targets`
for specific package configuration details and file locations.

The static library is built with the `stdcall` calling convention.

The debug versions of the library are built with `NDEBUG` defined,
so `assert` calls work as intended for `Debug` and `Release`
configurations.

## Building a Nuget Package

This project can build a Nuget package for zLib either locally
or via a GitHub workflow. In each case, following steps are taken.

  * zLib source archive is downloaded from zLib's website and
    its SHA-256 signature is verified.

  * zLib's `Makefile.msc` is patched up to build debug libraries
    using the debug CRT. See the _What's Debug CRT_ section for
    more details.

  * VS2019 Community Edition is used to build zLib libraries
    locally and Enterprise Edition to build libraries on GitHub.

  * Build artifacts for all platforms and configurations are
    collected in staging directories under `nuget/build/native/lib`.

  * `nuget.exe` is used to package staged files with the first
    three version components used as a zLib version and the last
    version component used as a package revision. See _Package
    Version_ section for more details.

  * The Nuget package built on GitHub is uploaded to [nuget.org][].
    The package built locally is saved in the root project
    directory.

## Package Version

### Package Revision

Nuget packages lack package revision and in order to repackage
the same upstream software version, such as zLib v1.2.11, the
4th component of the Nuget version is used to track the Nuget
package revision.

Nuget package revision is injected outside of the Nuget package
configuration, during the package build process, and is not present
in the package specification file.

Specifically, `nuget.exe` is invoked with `-Version=1.2.11.123`
to build a package with the revision `123`.

### Version Locations

zLib version is located in a few places in this repository and
needs to be changed in all of them for a new version of zLib.

  * nuget/StoneSteps.zLib.Static.nuspec (`version`)
  * devops/make-package.bat (`PKG_VER`, `PKG_REV`, `ZLIB_FNAME`,
    `ZLIB_SHA256`)
  * .github/workflows/build-nuget-package.yml (`name`, `PKG_VER`,
    `PKG_REV`, `ZLIB_FNAME`, `ZLIB_SHA256`)

`ZLIB_SHA256` ia a SHA-256 checksum of the zLib package file and
needs to be changed when a new version of zLib is released.

Verify that the new zLib archive follows the directory name
pattern used in the `ZLIB_DNAME` variable.

In the GitHub workflow YAML, `PKG_REV` must be reset to `1` (one)
every time zLib version is changed. The workflow file must be
renamed with the new version in the name. This is necessary because
GitHub maintains build numbers per workflow file name.

For local builds package revision is supplied on the command line
and should be specified as `1` (one) for a new version of zLib.

### GitHub Build Number

Build number within the GitHub workflow YAML is maintained in an
unconventional way because of the lack of build maturity management
between GitHub and Nuget.

For example, using build management systems, such as Artifactory,
every build would generate a Nuget package with the same version
and package revision for the upcoming release and build numbers
would be tracked within the build management system. A build that
was successfully tested would be promoted to the production Nuget
repository without generating a new build.

Without a build management system, the GitHub workflow in this
repository uses the pre-release version as a surrogate build
number for builds that do not publish packages to nuget.org,
so these builds can be downloaded and tested before the final
build is made and published to nuget.org. This approach is not
recommended for robust production environments because even
though the final published package is built from the exact
same source, the build process may still potentially introduce 
some unknowns into the final package (e.g. build VM was updated).

## Building Package Locally

You can build a Nuget package locally with `make-package.bat`
located in `devops`. This script expects VS2019 Community Edition
installed in the default location. If you have other edition of
Visual Studio, edit the file to use the correct path to the
`vcvarsall.bat` file.

Run `make-package.bat` from the repository root directory with a
package revision as the first argument. There is no provision to
manage build numbers from the command line and other tools should
be used for this (e.g. Artifactory).

## Sample Application (zPipe)

A Visual Studio project is included in this repository under
`sample-zpipe` to test the Nuget package built by this project.
This application is copied from `zlib-1.2.11/examples` and
adapted to build as a C++ project.

The original C source of this sample application is subject
to zLib's copyright and terms of use.

In order to build `zpipe.exe`, open Nuget Package manager in
the solution and install either the locally-built Nuget package
or the one from [nuget.org][].

`zpipe.exe` compresses/decompresses standard input/output and
can be tested with this pipe:

    echo ABC | zpipe | zpipe -d

The output will be `ABC` in this example, which will be compressed
by the first invocation of `zpipe.exe` and decompressed by the
second one.

## What's Debug CRT?

Visual C/C++ provides C runtime library (CRT), which comes
in several flavors designed for specific purposes. The debug
CRT is intended to help identifying various runtime issues
early in the development process, such as memory corruption.

Mixing different flavors of the CRT within one application
will yield undesired side effects ranging from compiler errors
to application crashes.

The patched version of `Makefile.msc` in this project builds
zLib debug and release versions using multi-threaded debug DLL
CRT (`/MDd`) and multi-threaded non-debug DLL CRT (`/MD`). See
this page for additional information about the CRT.

https://docs.microsoft.com/en-us/cpp/c-runtime-library/crt-library-features?view=msvc-160

See `Makefile.msc.patch` in `patches` for changes against the
zLib source.

[nuget.org]: https://www.nuget.org/packages/StoneSteps.zLib.Static/
