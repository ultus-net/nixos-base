{ pkgs ? import <nixpkgs> {}
, python3 ? pkgs.python3
, lib ? pkgs.lib
}:

let
  pythonPkgs = python3.pkgs;

  pinceSrc = pkgs.fetchurl {
    url = "https://github.com/korcankaraokcu/PINCE/archive/refs/tags/v0.4.4.tar.gz";
    sha256 = "0bk354817gzmv4g4v14fbdbb33wppnz5kdya7bn2h05jrvmyil1s";
  };

  libscanmemSrc = pkgs.fetchFromGitHub {
    owner = "brkzlr";
    repo = "libscanmem-PINCE";
    rev = "03b28a7a673bee355a535d756de00d2caf2d10a8";
    hash = "sha256-jAg+Er0KbdwvblEk/wNSEqncQtyAwLqOPHur8jnRZac=";
  };

  libptrscanBin = pkgs.fetchurl {
    url = "https://github.com/kekeimiku/PointerSearcher-X/releases/download/v0.7.4-dylib/libptrscan_pince-x86_64-unknown-linux-gnu.tar.gz";
    sha256 = "1wzvyfwgigc6lzqhx2l9sdwl52in20c0d0mr4vc0z8c0fpskb2n2";
  };

  pythonEnv = pythonPkgs.python.withPackages (ps: [
    ps.pyqt6
    ps.pyqt6-sip
    ps.pyqt6-webengine
    ps.pexpect
    ps.capstone
    ps.keystone-engine
    ps.pygdbmi
    ps.keyboard
    ps.pygobject3
  ]);
in

pkgs.stdenv.mkDerivation rec {
  pname = "pince";
  version = "0.4.4";
  src = pinceSrc;

  sourceRoot = "source";

  nativeBuildInputs = [
    pkgs.cmake
    pkgs.ninja
    pkgs.pkg-config
    pkgs.qt6.qttools
    pkgs.qt6.wrapQtAppsHook
    pkgs.makeWrapper
    pythonEnv
  ];

  buildInputs = [
    pkgs.qt6.qtbase
    pkgs.qt6.qtwayland
    pkgs.gobject-introspection
    pkgs.cairo
    pkgs.gtk3
  ];

  dontWrapQtApps = false;
  configurePhase = ''
    runHook preConfigure
    runHook postConfigure
  '';

  unpackPhase = ''
    runHook preUnpack
    mkdir source
    tar xzf ${pinceSrc} --strip-components=1 -C source
    mkdir -p source/libscanmem-PINCE
    cp -a ${libscanmemSrc}/. source/libscanmem-PINCE/
    runHook postUnpack
  '';

  buildPhase = ''
    runHook preBuild

    chmod -R +w libscanmem-PINCE

    # Build libscanmem shared library
    pushd libscanmem-PINCE
    mkdir -p build
    cd build
    cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$TMPDIR ..
    ninja
    popd

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/pince
    cp -a . $out/share/pince

    # Drop build artifacts to keep output smaller and avoid patchelf touching .o files
    rm -rf $out/share/pince/libscanmem-PINCE/build

    # Install libscanmem artifacts
    install -Dm644 libscanmem-PINCE/build/libscanmem.so $out/share/pince/libpince/libscanmem/libscanmem.so
    install -Dm644 libscanmem-PINCE/wrappers/scanmem.py $out/share/pince/libpince/libscanmem/scanmem.py

    # Install libptrscan binary bundle
    mkdir -p $out/share/pince/libpince/libptrscan
    tar xzf ${libptrscanBin} -C $out/share/pince/libpince/libptrscan --strip-components=1

    # Create wrapper
    mkdir -p $out/bin
    makeWrapper ${pythonEnv}/bin/python3 $out/bin/pince \
      --chdir $out/share/pince \
      --set QT_PLUGIN_PATH ${pkgs.qt6.qtbase}/lib/qt-6/plugins \
      --set QML2_IMPORT_PATH ${pkgs.qt6.qtbase}/lib/qt-6/qml \
      --set GI_TYPELIB_PATH ${pkgs.gobject-introspection}/lib/girepository-1.0 \
      --set LD_LIBRARY_PATH ${lib.makeLibraryPath [ pkgs.qt6.qtbase pkgs.gtk3 pkgs.cairo ]}:$out/share/pince/libpince/libscanmem:$out/share/pince/libpince/libptrscan \
      --set PYTHONPATH "$out/share/pince:${pythonEnv}/${python3.sitePackages}" \
      --add-flags PINCE.py

    runHook postInstall
  '';

  meta = with lib; {
    description = "PINCE reverse-engineering debugger GUI";
    homepage = "https://github.com/korcankaraokcu/PINCE";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = [];
  };
}
