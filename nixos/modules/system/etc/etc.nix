# Management of static files in /etc.

{ config, lib, pkgs, ... }:

with lib;

let

  etc' = filter (f: f.enable) (attrValues config.environment.etc);

  etc = pkgs.stdenvNoCC.mkDerivation {
    name = "etc";

    builder = ./make-etc.sh;

    preferLocalBuild = true;
    allowSubstitutes = false;

    /* !!! Use toXML. */
    sources = map (x: x.source) etc';
    targets = map (x: x.target) etc';
    modes = map (x: x.mode) etc';
    users  = map (x: x.user) etc';
    groups  = map (x: x.group) etc';
  };

in

{

  ###### interface

  options = {

    environment.etc = mkOption {
      default = {};
      example = literalExample ''
        { example-configuration-file =
            { source = "/nix/store/.../etc/dir/file.conf.example";
              mode = "0440";
            };
          "default/useradd".text = "GROUP=100 ...";
        }
      '';
      description = ''
        Set of files that have to be linked in <filename>/etc</filename>.
      '';

      type = with types; loaOf (submodule (
        { name, config, ... }:
        { options = {

            enable = mkOption {
              type = types.bool;
              default = true;
              description = ''
                Whether this /etc file should be generated.  This
                option allows specific /etc files to be disabled.
              '';
            };

            target = mkOption {
              type = types.str;
              description = ''
                Name of symlink (relative to
                <filename>/etc</filename>).  Defaults to the attribute
                name.
              '';
            };

            text = mkOption {
              default = null;
              type = types.nullOr types.lines;
              description = "Text of the file.";
            };

            source = mkOption {
              type = types.path;
              description = "Path of the source file.";
            };

            mode = mkOption {
              type = types.str;
              default = "symlink";
              example = "0600";
              description = ''
                If set to something else than <literal>symlink</literal>,
                the file is copied instead of symlinked, with the given
                file mode.
              '';
            };

            uid = mkOption {
              default = 0;
              type = types.int;
              description = ''
                UID of created file. Only takes affect when the file is
                copied (that is, the mode is not 'symlink').
                '';
            };

            gid = mkOption {
              default = 0;
              type = types.int;
              description = ''
                GID of created file. Only takes affect when the file is
                copied (that is, the mode is not 'symlink').
              '';
            };

            user = mkOption {
              default = "+${toString config.uid}";
              type = types.str;
              description = ''
                User name of created file.
                Only takes affect when the file is copied (that is, the mode is not 'symlink').
                Changing this option takes precedence over <literal>uid</literal>.
              '';
            };

            group = mkOption {
              default = "+${toString config.gid}";
              type = types.str;
              description = ''
                Group name of created file.
                Only takes affect when the file is copied (that is, the mode is not 'symlink').
                Changing this option takes precedence over <literal>gid</literal>.
              '';
            };

          };

          config = {
            target = mkDefault name;
            source = mkIf (config.text != null) (
              let name' = "etc-" + baseNameOf name;
              in mkDefault (pkgs.writeText name' config.text));
          };

        }));

    };

    environment.staticEtc = mkOption {
      default = false;
      type = types.bool;
      internal = true;
      description = ''
        Make <filename>/etc</filename> just a static symlink to the
        <filename>/etc</filename> content in store.

        If false, <filename>/etc/static</filename> is a symlink to store,
        and <filename>/etc</filename> contains symlinks into
        <filename>/etc/static</filename> and also writeable files.

        Note that in the current situation this will definitely lock you
        out of your system.
      '';
    };

  };


  ###### implementation

  config = {

    system.build.etc = etc;

    environment.etc.machine-id = mkIf config.environment.staticEtc {
      source = "/var/etc/machine-id";
    };
    environment.etc."resolv.conf" = mkIf config.environment.staticEtc {
      source = "/var/etc/resolv.conf";
    };

    system.activationScripts.etc = stringAfter [ "users" "groups" ]
      (if config.environment.staticEtc then
      ''
        # Set up the static /etc.
        echo "setting up static /etc..."
        if test -d /etc; then
          mv /etc /etc.old-$(date +%Y%m%d-%H%M%S)
        fi
        ln -sfT ${etc}/etc /etc.new
        mv /etc.new /etc
        mkdir /var/etc
      ''
      else
      ''
        # Set up the statically computed bits of /etc.
        echo "setting up /etc..."
        ${pkgs.perl}/bin/perl -I${pkgs.perlPackages.FileSlurp}/${pkgs.perl.libPrefix} ${./setup-etc.pl} ${etc}/etc
      '');

  };

}
