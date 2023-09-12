#!/bin/bash
# emscripten 3.1.41

set -e

echo -e "\033[01;32m --------------- START -------------------- \033[0m"

get_current_time_in_seconds() {
    local now=$(date +'%Y-%m-%d %H:%M:%S')
    local total_seconds
    if [[ "$OSTYPE" == "darwin"* ]]; then
        total_seconds=$(date -j -f "%Y-%m-%d %H:%M:%S" "$now" "+%s")
    else
        total_seconds=$(date --date="$now" +%s)
    fi
    echo "$total_seconds"
}

start_time=$(get_current_time_in_seconds)

base_dir=$(cd "$(dirname "$0")";pwd)
mode="release"
if [ $1 ]; then mode=$1; fi

if [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin" ]]; then
    script_suffix='.bat'
else
    script_suffix='.sh'
fi


echo "--------|||  CLEAR output  |||--------"
rm -rf physx/bin

echo "--------|||  BUILD  |||--------"
cd $base_dir
echo "|||  GENERATE |||"
cd physx/
./generate_projects${script_suffix} emscripten-wasm
echo "|||  COMPILE |||"
cd compiler/emscripten-wasm-$mode
ninja

echo "|||  COPY  |||"
cd $base_dir
mkdir -p $base_dir/builds
cp $base_dir/physx/bin/emscripten/$mode/physx-fat.$mode.a $base_dir/builds/


echo "|||  FINISH  |||"

end_time=$(get_current_time_in_seconds)
echo -e "\033[01;32m Time Used: "$((end_time-start_time))"s  \033[1m"
echo -e "\033[01;32m ------------- END -----------------  \033[0m"

