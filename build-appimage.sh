#!/usr/bin/env bash

source ./config.sh
version=""

while (($#)); do
  case "$1" in
    --version|-v)
      if [[ -z "${2:-}" ]]; then
        echo "ERROR: --version requires a version number." >&2
        exit 1
      fi
      version="$2"
      shift 2
      ;;
    --help|-h)
      echo "Usage: $0 [--version VERSION]"
      echo "  --version, -v  Download a specific release tag"
      echo "  --help, -h     Show this help"
      exit 0
      ;;
    *)
      echo "ERROR: Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

find_library() {
  local lib="$1"
  local path

  path="$(ldconfig -p | awk -v lib="$lib" '$1 == lib { print $NF; exit }')"

  if [[ -z "$path" || ! -e "$path" ]]; then
    echo "ERROR: Required library not found: $lib" >&2
    return 1
  fi

  printf '%s\n' "$path"
}

prepare_binary() {
  local asset_url
  local extracted_dir
  local api_url
  local release_json

  if [[ -n "$version" ]]; then
    api_url="https://api.github.com/repos/$repo/releases/tags/$version"
    echo "Downloading $name version: $version"
  else
    api_url="https://api.github.com/repos/$repo/releases/latest"
    echo "Downloading latest Linux x86-64 binary..."
  fi

  # Fetch release metadata.
  release_json="$(curl -fsSL "$api_url")" || {
    echo "ERROR: Failed to fetch release metadata: $api_url" >&2
    return 1
  }

  # Find the Linux x64 archive URL.
  asset_url="$(
    jq -er '
      [
        .assets[]
        | select(.name | test("linux-x64\\.tar\\.gz$"; "i"))
      ]
      | if length == 1 then
          .[0].browser_download_url
        else
          error("Expected exactly one Linux x64 tar.gz asset")
        end
    ' <<< "$release_json"
  )" || {
    echo "ERROR: Could not find the expected Linux x64 archive." >&2
    jq -r '.tag_name, (.assets[]?.name)' <<< "$release_json" >&2
    return 1
  }

  echo "Downloading archive: $asset_url"
  curl -fL --retry 3 "$asset_url" -o "$archive"
  tar -xzf "$archive"
}

include_icons() {
  local i
  local icon_dir

  for i in "${!icons[@]}"; do
    [[ -f "${icons[$i]}" ]] || {
      echo "ERROR: Missing icon: ${icons[$i]}" >&2
      return 1
    }

    icon_dir="$appdir/usr/share/icons/hicolor/${icon_sizes[$i]}/apps"
    mkdir -p "$icon_dir"
    cp "${icons[$i]}" "$icon_dir/$icon_name"
  done
}

build() {
  local libsdl2_path

  [[ -f "$desktop_file_path" ]] || {
    return 1
  }

  libsdl2_path="$(find_library libSDL2-2.0.so.0)"

  mkdir -p "$appdir/usr/bin"
  cp -a build/. "$appdir/usr/bin/"

  linuxdeploy \
    --appdir "$appdir" \
    --executable $executable_path \
    -l "$libsdl2_path" \
    --desktop-file "$desktop_file_path" \
    --icon-file "$icon_path"
}

package() {
  LDAI_OUTPUT="$appimage_filename" \
    linuxdeploy \
      --appdir "$appdir" \
      --output appimage

  chmod +x "$appimage_filename"
}

prepare_binary
build
include_icons
package
