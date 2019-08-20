How to build netcode.io
=======================

## Building on Windows

Download [premake 5](https://premake.github.io/download.html) and copy the **premake5** executable somewhere in your path. Please make sure you have at least premake5 alpha 13.

You need Visual Studio to build the source code. If you don't have Visual Studio 2015 you can [download the community edition for free](https://www.visualstudio.com/en-us/downloads/download-visual-studio-vs.aspx).

Once you have Visual Studio installed, go to the command line under the netcode.io/c directory and type:

    premake5 solution

This creates netcode.sln and opens it in Visual Studio for you.

Now you can build the library and run individual test programs as you would for any other Visual Studio solution.

## Building on MacOS and Linux

First, download and install [premake 5](https://premake.github.io/download.html) alpha 13 or greater.

Next, install libsodium.

On MacOS X, this can be done most easily with `brew install libsodium`.

If you don't have Brew, you can install it from <http://brew.sh>.

On Linux, depending on your particular distribution there may be prebuilt packages for libsodium, or you may have to build from source from here [libsodium](https://github.com/jedisct1/libsodium/releases).

Now go to the command line under the netcode.io/c directory and enter:

    premake5 gmake

Which creates makefiles which you can use to build the source via:

    make all

Alternatively, you can use the following shortcuts to build and run test programs directly:

    premake5 test           // build and run unit tests

    premake5 server         // build run a netcode.io server on localhost on UDP port 40000

    premake5 client         // build and run a netcode.io client that connects to the server running on localhost

    premake5 stress         // connect 256 netcode.io clients to a running server as a stress test

If you have questions please create an issue at http://www.netcode.io and I'll do my best to help you out.

cheers

 - Glenn

## Building with CMake

Download and install [CMake](https://cmake.org/).

First clone this repository, then create a build folder and run cmake. In source and out of source build is supported.

```bash
# Clone the repository
git clone https://github.com/OlivierLDff/netcode.io
# Enter the folder and create a build folder (build folder is added in .gitignore)
cd netcode.io && mkdir build && cd build
# Run cmake
cmake ..
```

The `CMakeLists.txt` comes with multiples options for you to override when executing with CMake. simply add `-D<option>=<value>`.

### Parameters

CMake support multiple options.

- **NETCODEIO_TARGET**: The name of the target that will be generated. *Default "netcode.io"*.
- **NETCODEIO_BUILD_SHARED**: Build a shared library. *Default "OFF". [ON/OFF]*.
- **NETCODEIO_FOLDER_PREFIX**: Prefix folder for all netcode.io generated targets in generated project (only decorative). *Default "netcode.io".*
- **NETCODEIO_ENABLE_TESTS**: Enable the tests. This will create a target `${NETCODEIO_TESTS_PREFIX}_test`. *Default "OFF". [ON/OFF]*.
- **NETCODEIO_TESTS_PREFIX**: Prefix for every tests to avoid naming clashes in superbuild. *Default "netcode.io".*
- **NETCODEIO_ENABLE_EXAMPLES**: Enable examples. This will create a target for each examples. *Default "OFF". [ON/OFF]*.
  - `${NETCODEIO_EXAMPLES_PREFIX}soak`: Run a continuous client/server communication with typical production load.
  - `${NETCODEIO_EXAMPLES_PREFIX}profile`
  - `${NETCODEIO_EXAMPLES_PREFIX}client`: Run a netcode.io client that connects to the server running on localhost
  - `${NETCODEIO_EXAMPLES_PREFIX}server`: Run a netcode.io server on localhost on UDP port 40000.
  - `${NETCODEIO_EXAMPLES_PREFIX}client_server`: Run a client and a server and test packet exchange.
- **NETCODEIO_EXAMPLES_PREFIX**: Prefix for every examples to avoid naming clashes in superbuild. *Default "netcode.io".*
- **NETCODEIO_ENABLE_INSTALL**: Enable install target. *Default "OFF". [ON/OFF]*.
- **NETCODEIO_INSTALL_PREFIX**: Folder for all netcode.io headers in the install folder. *Default "netcode.io".*

If you want to enable everything:

```bash
cmake                               \
  -DNETCODEIO_BUILD_SHARED=OFF      \
  -DNETCODEIO_TARGET="netcode.io"   \
  -DNETCODEIO_ENABLE_TESTS=ON       \
  -DNETCODEIO_ENABLE_EXAMPLES=ON    \
  -DNETCODEIO_ENABLE_INSTALL=ON     \
  ..
```

### Dependancies

#### libsodium

`netcode.io` depends on [libsodium](https://github.com/OlivierLDff/libsodium) for encryption. This project is a fork of the regular [libsodium](https://github.com/jedisct1/libsodium) that allow CMake build. The library is added with the new CMake functionnality [FetchContent](https://cmake.org/cmake/help/v3.11/module/FetchContent.html). By building libsodium along with netcode.io, it avoid lots of headaches about finding the correct libsodium binary compatible with your compilation environment. FetchContent also integrate really nice in superbuild. This give you more control over which version of libsodium you want. Checkout the [README](https://github.com/OlivierLDff/libsodium/blob/master/README.markdown) for every libsodium parameters.

* **SODIUM_REPOSITORY**: Libsodium repository for downloading and building. *Default: "https://github.com/OlivierLdff/libsodium.git"*.
* **SODIUM_TAG**: Tag for libsodium to use. *Default: "master"*.

Of course more flags can be specified. Please refer to the README.md in libsodium repository.

### Build

Depending on the generator use, you can use the generator specific command like `make` or `ninja` or `msbuild`. When building with a one release type generator you might need to add `-DCMAKE_BUILD_TYPE=Release` or `-DCMAKE_BUILD_TYPE=Debug`. Available config depends on your generator.

More generally you can simply use cmake build command.

```bash
## Equivalent of make all for any generator
cmake --build .
## Equivalent of "make netcode.io" in release mode
cmake --build . --target netcode.io --config Release
```

The `netcode.io` binary will be available in the `lib` folder of your build folder.

### Install

An install target is available for convenience and will deploy netcode.io on your system or any where you want.

```bash
## Specifify a custom install folder (optionnal)
cmake -DNETCODEIO_ENABLE_INSTALL=ON -DCMAKE_INSTALL_PREFIX="/path/to/my/install/dir" ..
## Equivalent of "make install" (Debug)
cmake --build . --target install --config Debug
## Equivalent of "make install" (Release)
cmake --build . --target install --config Release
```

You can choose the install directory by setting **CMAKE_INSTALL_PREFIX** when configuring the project. By default on Unix system it is set to `/usr/local` and on Windows to `c:/Program Files/netcode.io`.

In this folder you will find an include folder ready to be included by another application. This is a copy of the `include` folder of this repository. A `lib` will be created with all the generated libraries. A `cmake` folder contain all the CMake scripts to find the package.

The installation prefix is also added to `CMAKE_SYSTEM_PREFIX_PATH` so that **find_package()**, **find_program()**, **find_library()**, **find_path()**, and **find_file()** will search the prefix for other software.

### Run Tests

To run the tests you need to compile the library as static, and set the `NETCODE_ENABLE_TEST` flag to ON. Testing is done using CTest framework.

```bash
## Enable the tests
cmake -DNETCODEIO_ENABLE_TESTS=ON ..
## Build all the tests and executables
cmake --build . --config Release
# Then run the tests
ctest -C Release
```