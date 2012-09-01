args : with args; 
let 
  s = import ./src-for-default.nix;
  version = lib.attrByPath ["version"] s.version args;
in
rec {
  src = fetchurl {
    url = s.url;
    sha256 = s.hash;
  };

  buildInputs = [gtk glib atk cairo curl fontconfig freetype
    gettext libjpeg libpng libtiff libxml2 libxslt pango
    sqlite icu gperf bison flex autoconf automake libtool 
    perl intltool pkgconfig libsoup gtkdoc libXt libproxy
    enchant python ruby which renderproto libXrender geoclue
    kbproto mesa gobjectIntrospection
    ];

  propagatedBuildInputs = [
    gstreamer gst_plugins_base gst_ffmpeg gst_plugins_good
    ];

  configureFlags = [
      "--enable-spellcheck"
      "--enable-webgl"
      "--enable-channel-messaging"
      #"--enable-notifications"
      "--enable-meter-tag"
      "--enable-microdata"
      "--enable-page-visibility-api"
      "--enable-progress-tag"
      "--enable-javascript-debugger"
      "--enable-gamepad"
      "--enable-datagrid"
      "--enable-data-transfer-items"
      "--enable-mutation-observers"
      "--enable-dom-storage"
      "--enable-indexed-database"
      "--enable-input-color"
      "--enable-input-speech"
      "--enable-sql-database"
      "--enable-icon-database"
      "--enable-image-resizer"
      "--enable-datalist"
      "--enable-sandbox"

      "--disable-video"
      #"--enable-video"
      #"--enable-video-track"
      #"--enable-media-source"
      #"--enable-media-statistics"
      "--enable-fullscreen-api"
      #"--enable-media-stream"
      "--enable-xslt"
      "--enable-geolocation"
      "--enable-mathml"
      "--enable-mhtml"
      "--enable-svg"
      "--enable-shadow-dom"
      "--enable-shared-workers"
      "--enable-workers"
      "--enable-directory-upload"
      "--enable-file-system"
      "--enable-style-scoped"
      "--enable-quota"
      "--enable-filters"
      "--enable-svg-fonts"
      "--enable-web-sockets"
      "--enable-web-audio"
      "--enable-web-timing"
      "--enable-blob"
      "--enable-fast-mobile-scrolling"
      "--enable-jit"
      "--enable-introspection"
      "--enable-animation-api"
      "--enable-request-animation-frame"
      "--enable-touch-icon-loading"
      "--enable-register-protocol-handler"
      "--enable-plugin-process"
    ];

  /* doConfigure should be specified separately */
  phaseNames = ["setVars" "fixGstreamerVersion" "fixIncludes" /* "paranoidFixComments" */ "doConfigure" (doPatchShebangs ".") 
    "doReplaceUsrBin" "doMakeInstall" "doAddPrograms"];

  setVars = fullDepEntry (''
    export NIX_LDFLAGS="$NIX_LDFLAGS -lXt"

    for i in glib-2.0 gio-unix-2.0; do
      export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE $(pkg-config $i --cflags)"
    done

    echo "$NIX_CFLAGS_COMPILE"

    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I${glib}/include/glib-2.0 -I ${glib}/include/gio-unix-2.0"
  '') ["minInit" "addInputs"];

  doReplaceUsrBin = fullDepEntry (''
    for i in $(find . -name '*.pl') $(find . -name '*.pm'); do 
        sed -e 's@/usr/bin/gcc@gcc@' -i $i
    done
  '') ["minInit" "doUnpack"];

  doAddPrograms = fullDepEntry (''
    mkdir -p $out/bin
    for i in Programs/.libs/* Programs/*; do 
        cp $i $out/bin/webkit-program-$(basename $i) || true
    done
  '') ["minInit" "doMake" "defEnsureDir"];
      
  paranoidFixComments = fullDepEntry (''
    sed -re 's@( |^)//.*@/* & */@' -i $(find . -name '*.c' -o -name '*.h')
  '') ["minInit" "doUnpack"];

  fixGstreamerVersion = fullDepEntry ''
    sed -e 's/=GSTREAMER/=$GSTREAMER/g' -i configure
  '' ["minInit" "doUnpack"];

  fixIncludes = fullDepEntry ''
  '' ["minInit" "doUnpack"];

  name = s.name;
  meta = {
    description = "WebKit - a fast and correct HTML renderer";
    maintainers = [stdenv.lib.maintainers.raskin];
  };
  passthru = {
    inherit gstreamer gst_plugins_base gst_plugins_good gst_ffmpeg;
  };
}
