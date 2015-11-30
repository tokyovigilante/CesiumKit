#!/bin/sh

mkdir -p CesiumKit/Platform/Dependencies
cd ./CesiumKit/Platform/Dependencies

echo "Cleanup..."
rm -rf *

echo "Cloning glsl-optimizer"
git clone https://github.com/tokyovigilante/glsl-optimizer --depth 1

echo "Cloning AlamoFire"
git clone https://github.com/Alamofire/Alamofire

echo "Ready to build CesiumKit" 
