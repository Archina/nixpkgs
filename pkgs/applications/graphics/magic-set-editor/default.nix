{ lib
, stdenv
, fetchFromGitHub
, cmake
, boost
, hunspell
, pkg-config
, gtk3
, libGL
, libGLU
, curl
, wrapGAppsHook3
}:

let
  wxGTK33-cmake = stdenv.mkDerivation rec {
    pname = "wxwidgets";
    version = "3.3.1";

    src = fetchFromGitHub {
      owner = "wxWidgets";
      repo = "wxWidgets";
      rev = "v${version}";
      fetchSubmodules = true;
      hash = "sha256-eYmZrh9lvDnJ3VAS+TllT21emtKBPAOhqIULw1dTPhk=";
    };

    nativeBuildInputs = [ cmake pkg-config ];
    buildInputs = [ gtk3 libGL libGLU curl ];

    cmakeFlags = [
      "-DwxBUILD_PRECOMP=ON"
      "-DwxBUILD_USE_STATIC_RUNTIME=OFF"
    ];

    postInstall = ''
      cat > $out/bin/wx-config << 'EOF'
      #!/bin/sh
      exec $out/lib/wx/config/gtk3-unicode-3.3 "$@"
      EOF
      chmod +x $out/bin/wx-config
    '';

    enableParallelBuilding = true;
  };
in

stdenv.mkDerivation {
  pname = "magicseteditor";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "G-e-n-e-v-e-n-s-i-S";
    repo = "MagicSetEditor2";
    rev = "main";
    hash = "sha256-WgLsU2WCV6n/bd/HZub4uB2+n0nixOBLzQWbMHL/kAM=";
  };

  patches = [
    ./fix-absolute-package-path.patch
  ];
  prePatch = ''
    sed -i 's/\r$//' src/util/io/package_manager.cpp
  '';
  postPatch = "";


  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    wxGTK33-cmake
    boost
    hunspell
    libGL
    libGLU
    curl
    gtk3
  ];

  preConfigure = ''
    export CMAKE_PREFIX_PATH=${wxGTK33-cmake}''${CMAKE_PREFIX_PATH:+:}$CMAKE_PREFIX_PATH
    export wxWidgets_ROOT_DIR=${wxGTK33-cmake}
    export wxWidgets_CONFIG_EXECUTABLE=${wxGTK33-cmake}/bin/wx-config
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp magicseteditor $out/bin/
    mkdir -p $out/share/magicseteditor
    cp -r ../resource $out/share/magicseteditor/
    cp -r ../data $out/share/magicseteditor/
    runHook postInstall
  '';
  enableParallelBuilding = true;

  meta = with lib; {
    description = "Magic Set Editor is a card design engine.";
    homepage = "https://github.com/G-e-n-e-v-e-n-s-i-S/MagicSetEditor2";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
