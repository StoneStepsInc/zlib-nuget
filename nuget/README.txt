This package contains zLib header files and static libraries
built with VS2019 for Win32 and x64 platforms using zLib's
build script in win32/Makefile.msc, modified to generate
a static library referencing debug CRT for Debug configurations.

The zLib static library appropriate for current platform and
configuration is explicitly referenced within this package and
will appear within the solution folder tree after the package
is installed. The solution may need to be reloaded to make the
library file visible. This library may be moved into any solution
folder after the installation.

Note that the zLib library path is valid only for build
configurations named Debug and Release and will not work for any
other configuration names. Do not install this package for projects
with configurations other than Debug and Release.
