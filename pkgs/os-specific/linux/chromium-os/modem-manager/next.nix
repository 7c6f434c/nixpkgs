{ modemmanager, lib, fetchFromGitiles, upstreamInfo, autoreconfHook
, libqmi, libxslt
}:

modemmanager.overrideAttrs (
  { pname, nativeBuildInputs ? [], passthru ? {}, meta ? {}, ... }:
  {
    pname = "${pname}-chromiumos-next-unstable";
    version = "2019-10-17";

    src = fetchFromGitiles
      upstreamInfo.components."chromiumos/third_party/modemmanager-next";

    nativeBuildInputs = nativeBuildInputs ++ [ autoreconfHook libqmi libxslt ];

    passthru = passthru // {
      updateScript = ../update.py;
    };

    meta = with lib; meta // {
      maintainers = with maintainers; [ qyliss ];
    };
  }
)
