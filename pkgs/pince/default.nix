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
    pkgs.gdb
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

  postPatch = ''
python - <<'PY'
from pathlib import Path
from textwrap import dedent

p = Path("GUI/Utils/guitypedefs.py")
text = p.read_text()

helper = (
    "from libpince import debugcore, typedefs\n"
  "import queue\n\n"
  "hotkey_error_logged = False\n\n"
  "def safe_add_hotkey(key: str, func: Callable):\n"
  "    global hotkey_error_logged\n"
  "    if key == \"\" or func is None:\n"
  "        return None\n"
  "    try:\n"
  "        return add_hotkey(key.lower(), func)\n"
  "    except Exception as e:\n"
  "        if not hotkey_error_logged:\n"
  "            print('[PINCE] hotkeys disabled:', e)\n"
  "            hotkey_error_logged = True\n"
  "        return None\n\n"
)
marker = "from libpince import debugcore, typedefs\nimport queue\n\n"
if marker not in text:
    raise SystemExit("marker not found in guitypedefs.py")
text = text.replace(marker, helper, 1)

start = text.find("class Hotkey:")
end = text.find("class Hotkeys:")
if start == -1 or end == -1:
    raise SystemExit("Hotkey class bounds not found")

hotkey_block = dedent(
    """
class Hotkey:
    def __init__(self, name="", desc="", default="", func=None, custom="", handle=None) -> None:
        self.name = name
        self.desc = desc
        self.default = default
        self.func = func
        self.custom = custom
        if default == "" or func is None:
            self.handle = handle
        else:
            self.handle = safe_add_hotkey(default, func)

    def change_key(self, custom: str) -> None:
        if self.handle is not None:
            remove_hotkey(self.handle)
            self.handle = None
        self.custom = custom
        if custom == "":
            return
        self.handle = safe_add_hotkey(custom, self.func)

    def change_func(self, func: Callable) -> None:
        self.func = func
        if self.handle is not None:
            remove_hotkey(self.handle)
        if self.custom != "":
            self.handle = safe_add_hotkey(self.custom, func)
        elif self.default != "":
            self.handle = safe_add_hotkey(self.default, func)

    def get_active_key(self) -> str:
        if self.custom == "":
            return self.default
        return self.custom
"""
)

text = text[:start] + hotkey_block + text[end:]
p.write_text(text)

hexview = Path("GUI/TableViews/HexView.py")
hex_lines = hexview.read_text().splitlines()
for idx, line in enumerate(hex_lines):
  if line.strip().startswith("def selectionCommand("):
    start = idx
    break
else:
  raise SystemExit("selectionCommand not found in HexView.py")

indent = len(hex_lines[start]) - len(hex_lines[start].lstrip(" "))
end = start + 1
while end < len(hex_lines):
  candidate = hex_lines[end]
  cand_indent = len(candidate) - len(candidate.lstrip(" "))
  if candidate.startswith("    def ") and cand_indent == indent:
    break
  end += 1

hex_block = [
  "    def selectionCommand(self, index: QModelIndex, event: QKeyEvent):",
  "        if event is None:",
  "            return super().selectionCommand(index, event)",
  "        if event.modifiers() == Qt.KeyboardModifier.ControlModifier:",
  "            # Disable multi-selection when Ctrl key is pressed",
  "            return QItemSelectionModel.SelectionFlag.ClearAndSelect",
  "        return super().selectionCommand(index, event)",
]

hex_lines[start:end] = hex_block
hexview.write_text("\n".join(hex_lines) + "\n")

dbg = Path("libpince/debugcore.py")
dbg_text = dbg.read_text()
start = dbg_text.find("    libpince_dir = utils.get_libpince_directory()")
end = dbg_text.find("    child.setecho(")
if start == -1 or end == -1:
  raise SystemExit("spawn block not found in debugcore.py")
spawn_block = (
  "    libpince_dir = utils.get_libpince_directory()\n"
  "    is_appimage = os.environ.get(\"APPDIR\")\n"
  "    import shutil\n"
  "    gdb_cmd = gdb_path\n"
  "    if not (os.path.isfile(gdb_cmd) and os.access(gdb_cmd, os.X_OK)):\n"
  "        found = shutil.which(\"gdb\")\n"
  "        if found:\n"
  "            gdb_cmd = found\n"
  "    env = os.environ.copy()\n"
  "    env[\"LC_NUMERIC\"] = \"C\"\n"
  "    if is_appimage and os.environ.get(\"PYTHONHOME\"):\n"
  "        env[\"PYTHONHOME\"] = os.environ.get(\"PYTHONHOME\")\n"
  "    use_sudo = os.environ.get(\"PINCE_USE_SUDO\", \"\").lower() in (\"1\", \"true\", \"yes\")\n"
  "    if use_sudo and os.geteuid() != 0:\n"
  "        command = \"sudo\"\n"
  "        args = [\"-E\", \"--preserve-env=PATH\", gdb_cmd, \"--nx\", \"--interpreter=mi\"]\n"
  "    else:\n"
  "        command = gdb_cmd\n"
  "        args = [\"--nx\", \"--interpreter=mi\"]\n"
  "    child = pexpect.spawn(\n"
  "        command,\n"
  "        args=args,\n"
  "        cwd=libpince_dir,\n"
  "        env=env,\n"
  "        encoding=\"utf-8\",\n"
  "    )\n"
)
dbg_text = dbg_text[:start] + spawn_block + dbg_text[end:]
dbg.write_text(dbg_text)
PY
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

    # Install desktop entry and icon for launchers/menus
    install -Dm644 media/logo/ozgurozbek/pince_big_orange.png \
      $out/share/icons/hicolor/256x256/apps/pince.png
    install -Dm644 media/logo/ozgurozbek/pince_small_orange.png \
      $out/share/icons/hicolor/128x128/apps/pince.png
    mkdir -p $out/share/applications
    cat > $out/share/applications/pince.desktop <<EOF
  [Desktop Entry]
  Name=PINCE
  GenericName=Debugger GUI
  Comment=Reverse engineering debugger front-end for GDB
  Exec=$out/bin/pince %f
  TryExec=$out/bin/pince
  Icon=pince
  Type=Application
  Categories=Development;Debugger;
  Terminal=false
  StartupNotify=true
  EOF

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
      --set GI_TYPELIB_PATH ${lib.makeSearchPath "lib/girepository-1.0" [ pkgs.gobject-introspection pkgs.gtk3 ]} \
      --set LD_LIBRARY_PATH ${lib.makeLibraryPath [ pkgs.qt6.qtbase pkgs.gtk3 pkgs.cairo ]}:$out/share/pince/libpince/libscanmem:$out/share/pince/libpince/libptrscan \
      --set PYTHONPATH "$out/share/pince:${pythonEnv}/${python3.sitePackages}" \
      --set PYTHON_KEYBOARD_SUPPRESS 1 \
      --prefix PATH : ${pkgs.gdb}/bin \
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
