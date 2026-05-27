# shellcheck shell=bash disable=SC2016
Describe 'productive-k3s-infra profile-driven commands'
  SCRIPT="$SHELLSPEC_PROJECT_ROOT/scripts/productive-k3s-infra.sh"

  It 'lists profiles relative to the repo root'
    repo_dir="$(mktemp -d)"
    mkdir -p "${repo_dir}/profiles/team"
    printf 'PK3S_INFRA_PROFILE_NAME=demo\n' >"${repo_dir}/profiles/team/demo.env"

    When run bash -lc 'PRODUCTIVE_K3S_INFRA_REPO_DIR="$1" "$2" list-profiles' bash "$repo_dir" "$SCRIPT"
    The status should equal 0
    The output should equal 'profiles/team/demo.env'
  End

  It 'runs doctor and reports a missing profiles directory as a warning'
    repo_dir="$(mktemp -d)"
    mock_bin="$(mktemp -d)"
    cat >"${mock_bin}/make" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
    chmod +x "${mock_bin}/make"

    When run bash -lc 'PATH="$1:$PATH" PRODUCTIVE_K3S_INFRA_REPO_DIR="$2" "$3" doctor' bash "$mock_bin" "$repo_dir" "$SCRIPT"
    The status should equal 0
    The output should include 'bash is available'
    The output should include 'make is available'
    The output should include 'profiles directory not found yet'
  End

  It 'requires --profile for validate-profile'
    When run bash -lc '"$1" validate-profile' bash "$SCRIPT"
    The status should equal 3
    The stderr should include 'requires --profile <file>'
  End

  It 'rejects unsupported bundle subcommands'
    When run bash -lc '"$1" bundle nope --json' bash "$SCRIPT"
    The status should equal 2
    The stderr should include 'unsupported bundle command'
  End

  It 'requires --json for bundle info'
    When run bash -lc '"$1" bundle info' bash "$SCRIPT"
    The status should equal 2
    The stderr should include 'bundle info requires --json'
  End

  It 'prints the release version in plain mode'
    When run bash -lc 'PRODUCTIVE_K3S_INFRA_VERSION=2.4.6 "$1" version' bash "$SCRIPT"
    The status should equal 0
    The output should equal '2.4.6'
  End

  It 'uses make -n for onprem plan mode with the profile env file'
    profile="$(mktemp)"
    mock_bin="$(mktemp -d)"
    log_file="$(mktemp)"
    cat >"${profile}" <<'EOF'
PK3S_INFRA_PROFILE_NAME=onprem
PK3S_INFRA_ENGINE=ansible
PK3S_INFRA_SCENARIO=onprem-basic
ONPREM_SERVER_IP=10.0.0.10
ONPREM_SSH_USER=ubuntu
ONPREM_SSH_KEY_PATH=/tmp/id_ed25519
EOF
    cat >"${mock_bin}/make" <<'EOF'
#!/usr/bin/env bash
printf 'ONPREM_ENV_FILE=%s\n' "${ONPREM_ENV_FILE:-}" >>"${MOCK_MAKE_LOG}"
printf '%s\n' "$*" >>"${MOCK_MAKE_LOG}"
exit 0
EOF
    chmod +x "${mock_bin}/make"

    When run bash -lc 'PATH="$1:$PATH" MOCK_MAKE_LOG="$2" "$3" plan --profile "$4"; printf "\n__MAKE__\n"; cat "$2"' bash "$mock_bin" "$log_file" "$SCRIPT" "$profile"
    The status should equal 0
    The output should include "Plan mode delegates to 'make -n'"
    The output should include '__MAKE__'
    The output should include "ONPREM_ENV_FILE=${profile}"
    The output should include '-n'
    The output should include 'scenarios/onprem-basic'
    The output should include 'up'
  End

  It 'blocks onprem destroy without --yes'
    profile="$(mktemp)"
    cat >"${profile}" <<'EOF'
PK3S_INFRA_PROFILE_NAME=onprem
PK3S_INFRA_ENGINE=ansible
PK3S_INFRA_SCENARIO=onprem-basic
ONPREM_SERVER_IP=10.0.0.10
ONPREM_SSH_USER=ubuntu
ONPREM_SSH_KEY_PATH=/tmp/id_ed25519
EOF

    When run bash -lc '"$1" destroy --profile "$2"' bash "$SCRIPT" "$profile"
    The status should equal 2
    The stderr should include "unsupported command 'destroy' for scenario 'onprem-basic'"
  End

  It 'dispatches aws apply through make with AWS_ENV_FILE'
    profile="$(mktemp)"
    mock_bin="$(mktemp -d)"
    log_file="$(mktemp)"
    cat >"${profile}" <<'EOF'
PK3S_INFRA_PROFILE_NAME=aws
PK3S_INFRA_ENGINE=opentofu
PK3S_INFRA_SCENARIO=aws-single-node
AWS_REGION=us-east-1
AWS_CLUSTER_NAME=demo
AWS_INSTANCE_TYPE=t3.large
AWS_SSH_USER=ubuntu
AWS_SSH_KEY_PATH=/tmp/id_ed25519
AWS_ROOT_VOLUME_SIZE_GB=50
EOF
    cat >"${mock_bin}/make" <<'EOF'
#!/usr/bin/env bash
printf 'AWS_ENV_FILE=%s\n' "${AWS_ENV_FILE:-}" >>"${MOCK_MAKE_LOG}"
printf '%s\n' "$*" >>"${MOCK_MAKE_LOG}"
exit 0
EOF
    chmod +x "${mock_bin}/make"

    When run bash -lc 'PATH="$1:$PATH" MOCK_MAKE_LOG="$2" "$3" apply --profile "$4"; printf "\n__MAKE__\n"; cat "$2"' bash "$mock_bin" "$log_file" "$SCRIPT" "$profile"
    The status should equal 0
    The output should include '__MAKE__'
    The output should include "AWS_ENV_FILE=${profile}"
    The output should include 'scenarios/aws-single-node'
    The output should include 'up'
  End
End
