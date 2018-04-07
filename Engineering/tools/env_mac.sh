
ENV_MAC_SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export LOCAL_TOOLS_DIR="${ENV_MAC_SCRIPTDIR}"

export HAXETOOLKIT_PATH="${LOCAL_TOOLS_DIR}/environment/HaxeToolkit"
export HAXEPATH="${HAXETOOLKIT_PATH}/haxe/"
export NEKO_INSTPATH="${HAXETOOLKIT_PATH}/neko_mac"
export PATH="${HAXETOOLKIT_PATH}/haxe:${NEKO_INSTPATH}:$PATH"

export LIME_CONFIG="${LOCAL_TOOLS_DIR}/lime_config.xml"
export HXCPP_CONFIG="${LOCAL_TOOLS_DIR}/.hxcpp_config.xml"

export DYLD_LIBRARY_PATH="${NEKO_INSTPATH}${DYLD_LIBRARY_PATH:+:${DYLD_LIBRARY_PATH}}"
"${HAXEPATH}haxelib" setup "${HAXEPATH}lib"

"${HAXEPATH}haxelib" set lime 5.7.1