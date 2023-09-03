This package contains static zLib libraries and header files for
Win32/x64 platforms and Debug/Release configurations. There are
no dynamic libraries included.

The zLib static library appropriate for the platform and
configuration selected in a Visual Studio solution is explicitly
referenced within this package and will appear within the solution
folder tree after the package is installed. The solution may need
to be reloaded to make the library file visible. This library may
be moved into any solution folder after the installation.

Note that the zLib library path in this package is valid only
for build configurations named Debug and Release and will
not work for any other configuration names. Do not install this
package for projects with configurations other than Debug and
Release.

The static library is built with the stdcall calling convention.

The non-debug versions of the library are built with NDEBUG
defined, so assert calls work as intended for Debug and Release
configurations.
