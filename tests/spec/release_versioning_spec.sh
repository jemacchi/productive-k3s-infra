Describe 'release versioning wrapper'
  SCRIPT="$SHELLSPEC_PROJECT_ROOT/scripts/release-versioning.sh"

  It 'accepts composite release tags'
    When run script "$SCRIPT" validate '1.2.3-0.9.1'
    The status should equal 0
  End

  It 'rejects invalid release tags'
    When run script "$SCRIPT" validate '1.2.3'
    The status should equal 1
    The error should include 'invalid composite release tag'
  End

  It 'emits split release environment values'
    When run script "$SCRIPT" env '1.2.3-0.9.1'
    The status should equal 0
    The output should include 'PK3S_INFRA_SEMVER=1.2.3'
    The output should include 'PK3S_CORE_SEMVER=0.9.1'
    The output should include 'PK3S_INFRA_IS_RELEASE=true'
  End
End
