set -e
pushd apps/ui/assets && brunch build --production && popd
pushd apps/ui && mix phx.digest && popd
pushd apps/firmware && mix firmware && ./upload.sh && popd
echo "--------------- ALL DONE! -----------------"
