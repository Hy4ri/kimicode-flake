{
  lib,
  stdenv,
  fetchurl,
  patchelf,
  makeWrapper,
  glibc,
}:
let
  version = "0.21.1";

  srcs = {
    x86_64-linux = {
      url = "https://code.kimi.com/kimi-code/binaries/${version}/kimi-code-linux-x64";
      hash = "sha256-rueuFzKSd9Dzh6NFq+/62146ZmAXx2a4GVrcCd4YslI=";
    };
    aarch64-linux = {
      url = "https://code.kimi.com/kimi-code/binaries/${version}/kimi-code-linux-arm64";
      hash = "sha256-TGcxmmCcrX+5ojBuryjDZF0cmtW6e5aSDWH1zOH5s2M=";
    };
  };

  platformSrc = srcs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  libPath = lib.makeLibraryPath [
    stdenv.cc.cc.lib # libstdc++
    glibc
  ];
in
stdenv.mkDerivation {
  pname = "kimi-code";
  inherit version;

  src = fetchurl {
    inherit (platformSrc) url hash;
  };

  # fetchurl expects an archive by default; we're fetching a raw binary
  dontUnpack = true;

  nativeBuildInputs = [
    patchelf
    makeWrapper
  ];

  # autoPatchelfHook corrupts this binary's ELF segments (shifts .init
  # section offset without updating LOAD program headers, causing SIGILL
  # at _init). Manual patchelf preserves segment alignment correctly.
  dontAutoPatchelf = true;
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/kimi
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}" \
      $out/bin/kimi
    runHook postInstall
  '';

  meta = {
    description = "Kimi Code — AI-powered coding assistant CLI by Moonshot AI";
    homepage = "https://code.kimi.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    mainProgram = "kimi";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
