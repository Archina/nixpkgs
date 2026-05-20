{
  stdenv,
  fetchurl,
  pkgs,
  pkg-config,
  lib,
  # Add other dependencies here (e.g., pkg-config, libxml2, etc.)
}:

stdenv.mkDerivation rec {
  pname = "MagicSetEditor2";
  version = "2.5.6";

  src = fetchurl {
    url = "https://github.com/haganbmj/${pname}/archive/refs/tags/v${version}.tar.gz";
    sha256 = "sha256-0ipcXWKebn50TGqPWWROwnWgOXwMzaPppIgULKzJSyk=";
  };

  # Build inputs needed at compile time
  nativeBuildInputs = with pkgs; [
    gcc
    cmake
    # wxwidgets_3_1
    boost.dev
    hunspell.dev
    pkg-config
    # pkg-config, cmake, etc. go here
    wrapGAppsHook3
  ];

  # Runtime dependencies
  buildInputs = with pkgs; [
    wxwidgets_3_1
    boost.out
    hunspell.out
    # Libraries your program links against
    gsettings-desktop-schemas
  ];

  # If using Autotools/Makefile, stdenv handles this automatically
  # For custom build systems, override configurePhase, buildPhase, installPhase
  installPhase = ''
    mkdir -p $out/bin
    cp magicseteditor $out/bin
    cp -r $NIX_BUILD_TOP/$sourceRoot/resource $out/bin
    cp -r $NIX_BUILD_TOP/$sourceRoot/data $out/bin
  '';
  # mkdir -p $out/share/magicseteditor

  meta = {
    description = "Magic Set Editor is a card design engine";
    homepage = "https://github.com/haganbmj/MagicSetEditor2";
    license = lib.licenses.gpl2Only; # or gpl3, bsd3, etc.
    maintainers = [ lib.maintainers.yourgithub ];
    platforms = lib.platforms.unix; # or lib.platforms.linux
  };
}
