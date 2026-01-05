{ ... }:
{
  imports = [
    ./browsers.nix                     
    ./zen.nix
  ];
  
  # xdg.mimeApps =
  #   let
  #     value =
  #       let
  #         zen-browser = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.beta;
  #       in
  #       zen-browser.meta.desktopFileName;

  #     # 这是您已注释掉的 'associations' 列表部分
  #     # associations = builtins.listToAttrs (
  #     #   map (name: { inherit name value; }) [
  #     #     "application/x-extension-shtml"
  #     #     "application/x-extension-xhtml"
  #     #     "application/x-extension-html"
  #     #     "application/x-extension-xht"
  #     #     "application/x-extension-htm"
  #     #     "x-scheme-handler/unknown"
  #     #     "x-scheme-handler/mailto"
  #     #     "x-scheme-handler/chrome"
  #     #     "x-scheme-handler/about"
  #     #     "x-scheme-handler/https"
  #     #     "x-scheme-handler/http"
  #     #     "application/xhtml+xml"
  #     #     "application/json"
  #     #     "text/html"
  #     #   ]
  #     # );
  #   in
  #   {
  #     # associations.added = associations;
  #     # defaultApplications = associations;
  #   };
}
