{ ... }:
{
  imports = [
    ./browsers                     # based browser
    ./dev
    ./media
    ./note
    ./office
    ./social
    ./packages                        # other packages
    ./tools
    ./gaming.nix                      # packages related to gaming
    ./zno-apps.nix                    # apps for zno
  ];
}
