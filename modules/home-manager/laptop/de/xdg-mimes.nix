{ lib, ... }:
with lib;
let
  defaultApps = {
    text = [ "code.desktop" ];
    image = [ "imv-dir.desktop" ];
    audio = [ "org.fooyin.fooyin" ];
    video = [ "mpv.desktop" ];
    directory = [ "nemo.desktop" ];
    office = [ "libreoffice.desktop" ];
    pdf = [ "org.gnome.Evince.desktop" ];
    terminal = [ "kitty.desktop" ];
    archive = [ "org.gnome.FileRoller.desktop" ];
    discord = [ "webcord.desktop" ];
  };

  mimeMap = {
    text = [
      "text/plain"
      "text/markdown"
      "text/x-shellscript"
      "text/x-python"
      "text/x-csrc"
      "text/x-chdr"
      "text/x-c++src"
      "text/css"
      "text/javascript"
      "text/x-java"
      "text/x-go"
      "text/x-rust"
      "application/json"
      "application/xml"
      "application/javascript"
      "application/x-yaml"
      "application/toml"
      "text/html"
      "application/xhtml+xml"
      "text/x-html"
      "application/sql"
      "text/x-cmake"
      "text/x-makefile"
      "application/x-perl"
      "application/x-php"
    ];
    image = [
      "image/bmp"
      "image/gif"
      "image/jpeg"
      "image/jpg"
      "image/png"
      "image/svg+xml"
      "image/tiff"
      "image/vnd.microsoft.icon"
      "image/webp"
      "image/avif"
      "image/heif"
      "image/jxl"
    ];
    audio = [
      "audio/aac"
      "audio/mpeg"
      "audio/mpg"
      "audio/x-mpeg"
      "audio/mp3"
      "audio/ogg"
      "audio/opus"
      "audio/wav"
      "audio/x-wav"
      "audio/flac"
      "audio/x-flac"
      "audio/x-ape"
      "audio/x-ms-wma"
      "audio/mp4"
      "audio/x-m4a"
      "audio/webm"
      "audio/x-matroska"
      "audio/mpegurl"
      "audio/x-scpls"
    ];
    video = [
      "video/mp2t"
      "video/mp4"
      "video/mpeg"
      "video/ogg"
      "video/webm"
      "video/x-flv"
      "video/x-matroska"
      "video/x-msvideo"
      "video/quicktime"
      "video/x-ms-wmv"
      "video/3gpp"
    ];
    directory = [ "inode/directory" ];
    office = [
      "application/vnd.oasis.opendocument.text"
      "application/vnd.oasis.opendocument.spreadsheet"
      "application/vnd.oasis.opendocument.presentation"
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      "application/vnd.openxmlformats-officedocument.presentationml.presentation"
      "application/msword"
      "application/vnd.ms-excel"
      "application/vnd.ms-powerpoint"
      "application/rtf"
      "text/rtf"
    ];
    pdf = [ "application/pdf" ];
    terminal = [ "terminal" ];
    archive = [
      "application/zip"
      "application/rar"
      "application/x-rar"
      "application/7z"
      "application/x-7z-compressed"
      "application/x-tar"
      "application/x-bzip"
      "application/x-bzip2"
      "application/x-gzip"
      "application/x-lzip"
      "application/x-lzma"
      "application/x-xz"
      "application/x-cpio"
      "application/x-compress"
    ];
    discord = [ "x-scheme-handler/discord" ];
  };

  associations =
    with lists;
    listToAttrs (
      flatten (mapAttrsToList (key: map (type: attrsets.nameValuePair type defaultApps."${key}")) mimeMap)
    );
in
{
  xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps.enable = true;
  xdg.mimeApps.associations.added = associations;
  xdg.mimeApps.defaultApplications = associations;

  home.sessionVariables = {
    # prevent wine from creating file associations
    WINEDLLOVERRIDES = "winemenubuilder.exe=d";
  };
}
