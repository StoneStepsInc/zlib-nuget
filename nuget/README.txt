This package contains static zLib libraries and header files for
Win32/x64 platforms. There are no dynamic libraries included.

The zLib static library appropriate for the platform and
configuration selected in a Visual Studio solution is explicitly
referenced within this package and will appear within the solution
folder tree after the package is installed. The solution may need
to be reloaded to make the library file visible. This library may
be moved into any solution folder after the installation.

Note that the zLib library path in this package will be selected
as Debug or Release based on whether the active configuration is
designated as a development or as a release configuration in the
underlying .vcxproj file.

Specifically, the initial project configurations have a property
called UseDebugLibraries in the underlying .vcxproj file, which
reflects whether the confiration is intended for building release
or development artifacts. Additional configurations copied from
these initial ones inherit this property. Manually created
configurations should have this property defined in the .vcxproj
file.

Do not install this package if your projects use configurations
without the UseDebugLibraries property.

The static library is built with the stdcall calling convention.

The non-debug versions of the library are built with NDEBUG
defined, so assert calls work as intended for Debug and Release
configurations.
