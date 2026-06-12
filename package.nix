{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
}:
let
  version = "0.14.2";

  srcs = {
    x86_64-linux = {
      url = "https://code.kimi.com/kimi-code/binaries/${version}/kimi-code-linux-x64";
      hash = "sha256-h7y/0lw8RZ9V/CuhbtoDxdwAjcv1HR2oxnXzbHcNWbE=";
    };
    aarch64-linux = {
      url = "https://code.kimi.com/kimi-code/binaries/${version}/kimi-code-linux-arm64";
      hash = "sha256-E8dXaVxQ5aqIJOLYaTFf+QD38qfxbJwbivYH/NkjDSg=";
    };
  };

  src = srcs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "kimi-code";
  inherit version;

  src = fetchurl {
    inherit (src) url hash;
  };

  # fetchurl expects an archive by default; we're fetching a raw binary
  dontUnpack = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib # libstdc++
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/kimi
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
