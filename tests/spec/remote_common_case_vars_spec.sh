# shellcheck shell=bash disable=SC2016
Describe 'remote-cluster common case helpers'
  COMMON="$SHELLSPEC_PROJECT_ROOT/ansible/roles/remote_cluster/files/common.sh"
  RUNNER="$SHELLSPEC_PROJECT_ROOT/tests/helpers/run-remote-common-lib.sh"

  It 'resolves case-prefixed variables'
    When run /usr/bin/bash "$RUNNER" "$COMMON" 'CASE_PREFIX=AWS; AWS_CLUSTER_NAME=demo; printf "%s" "$(case_var CLUSTER_NAME fallback)"'
    The status should equal 0
    The output should equal 'demo'
  End

  It 'falls back across alternate variable names'
    When run /usr/bin/bash "$RUNNER" "$COMMON" 'CASE_PREFIX=AWS; AWS_SSH_PRIVATE_KEY_PATH=/tmp/id_rsa; printf "%s" "$(case_var_first "" SSH_KEY_PATH SSH_PRIVATE_KEY_PATH)"'
    The status should equal 0
    The output should equal '/tmp/id_rsa'
  End

  It 'normalizes release versions by stripping v'
    When run /usr/bin/bash "$RUNNER" "$COMMON" 'normalize_release_version v1.2.3'
    The status should equal 0
    The output should equal '1.2.3'
  End
End
