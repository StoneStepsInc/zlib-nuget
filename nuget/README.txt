This package contains static zLib libraries and header files for
Win32/x64 platforms. There are no dynamic libraries included.

The zLib static libraries from this package will appear in the
installation target project after the package is installed.
The solution may need to be reloaded to make libraries visible.
Both debug and release libraries will be listed in the project,
but only the one appropriate for the currently selected
configuration will be included in the build. These libraries
may be moved into solution folders after the installation (e.g.
lib/Debug and lib/Release).

Note that the zLib library path in this package will be selected
as Debug or Release based on whether the selected configuration
is designated as a development or release configuration via the
standard Visual Studio property called UseDebugLibraries.
Additional configurations copied from the standard ones will
inherit this property.

Do not install this package if your projects use debug configurations
without UseDebugLibraries. Note that CMake-generated Visual Studio
projects will not emit this property.

The static library is built with the `__stdcall` calling convention,
which allows projects building against this library to use any
calling convention.
