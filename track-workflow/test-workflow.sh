ROOST_DIR="/var/tmp/Roost"
BIN_DIR="$ROOST_DIR/bin"
ROOST_CONTROLLER="$BIN_DIR/gcpController"
ROOST_CONFIG="$BIN_DIR/gcp_config.json.template"

main() {
  echo $ROOST_DIR
  echo $ROOST_CONTROLLER
}
DDMM=$(date +%Y%M%d.%H%M%S)
main $* > /var/tmp/roostController.${DDMM}.log 2>&1
echo "Logs are at /var/tmp/roostController.${DDMM}.log"

