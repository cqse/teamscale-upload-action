#!/bin/bash

# Fails the action with the given message.
function fail() {
  echo "::error::$1"
  exit 1
}

# Fails the action if the given input was not provided for the command that needs it. action.yml
# cannot express this, because an input that is required by one command is unused by the other, so
# every command-specific input has to be declared optional there.
function require_input_for_command() {
  local input_name="$1"
  local input_value="$2"
  if [ -z "$input_value" ]; then
    if [ -z "$COMMAND" ]; then
      fail "The '$input_name' input is required."
    fi
    fail "The '$input_name' input is required by the '$COMMAND' command."
  fi
}

# Transforming the space separated filenames into an array of filenames
read -r -a FILES_ARRAY <<< "$FILES"

# Inputs that belong to the other command are not passed on to teamscale-upload and are ignored.
case "$COMMAND" in
  ""|report)
    # teamscale-upload uploads external analysis reports when no command is named, so the `report`
    # command is left out deliberately and the tool's default runs. Naming it explicitly is planned
    # for later after the default command is deprecated. Blanked before the checks below so
    # their message does not name a command that is never sent.
    COMMAND=""
    require_input_for_command "partition" "$PARTITION"
    ;;
  vulnerability-report)
    require_input_for_command "build-name" "$BUILD_NAME"
    require_input_for_command "build-version" "$BUILD_VERSION"
    # Unlike the 'report' command, this one has no 'input' input as a second way to name the
    # report, and teamscale-upload would report the report missing as a missing positional
    # argument, which does not tell the user which action input to set.
    require_input_for_command "files" "$FILES"
    # Teamscale stores one report per build name and version, so the upload takes a single
    # positional argument. Passing several would reach teamscale-upload as unrecognized arguments,
    # which names neither the input at fault nor the reason only one is allowed.
    if [ "${#FILES_ARRAY[@]}" -gt 1 ]; then
      fail "The 'files' input names ${#FILES_ARRAY[@]} reports, but the '$COMMAND' command uploads exactly one, since Teamscale stores one report per build name and version. Please upload each report separately, with its own build name or build version."
    fi
    ;;
  *)
    fail "Unknown command '$COMMAND'. Please use either 'report' or 'vulnerability-report'."
    ;;
esac

if [[ "$OS" == "Windows" ]]; then
  curl -L "https://github.com/cqse/teamscale-upload/releases/download/$VERSION/teamscale-upload-windows-x86_64.zip" -o teamscale-upload.zip
  unzip teamscale-upload.zip;
  LAUNCHER="./teamscale-upload/bin/teamscale-upload.bat"
else
  wget -O teamscale-upload.zip "https://github.com/cqse/teamscale-upload/releases/download/$VERSION/teamscale-upload-linux-x86_64.zip";
  unzip teamscale-upload.zip
  LAUNCHER="./teamscale-upload/bin/teamscale-upload"
  chmod +x "$LAUNCHER"
fi

# Shared options, in the order of CommonCommandLineOptions.addCommonArguments. Keep action.yml in step.
# Two deviations from that list, both older than the commands: the tool's -c/--commit is the
# 'revision' input, and --proxy, --max-attempts and --debug have no input at all.
#
# $COMMAND is unquoted on purpose: an empty value must expand to no argument at all rather than to
# an empty one, which teamscale-upload would read as an empty report pattern. This is safe because
# the case above has narrowed $COMMAND to a fixed command name or the empty string.
# shellcheck disable=SC2086
ARGS=( $COMMAND "--server" "$SERVER" "--project" "$PROJECT" "--user" "$USER" "--accesskey" "$ACCESSKEY" )

if [[ "$INSECURE" == "true" ]]; then
  ARGS+=( "--insecure" )
fi
if [ -n "$TRUSTED_KEYSTORE" ]; then
  ARGS+=( "--trusted-keystore" "${TRUSTED_KEYSTORE}" )
fi
if [ -n "$TIMEOUT" ]; then
  ARGS+=( "--timeout" "${TIMEOUT}" )
fi
if [[ "$STACKTRACE" == "true" ]]; then
  ARGS+=( "--stacktrace" )
fi

if [[ "$COMMAND" == "vulnerability-report" ]]; then
  # Vulnerability report options, in the order of VulnerabilityReportCommandLineOptions.addCommand.
  ARGS+=( "--build-name" "$BUILD_NAME" "--build-version" "$BUILD_VERSION" )

  if [ -n "$REVISION" ]; then
    ARGS+=( "--commit" "$REVISION" )
  fi
else
  # Report options, in the order of ReportCommandLineOptions.addCommand.
  ARGS+=( "--partition" "$PARTITION" )

  # optional parameters. We only use them if they have been set
  if [ -n "$FORMAT" ]; then
    ARGS+=( "--format" "$FORMAT" )
  fi
  if [ -n "$REVISION" ]; then
    ARGS+=( "--commit" "$REVISION" )
  fi
  if [ -n "$REPOSITORY" ]; then
    ARGS+=( "--repository" "$REPOSITORY" )
  fi
  if [ -n "$BRANCH_AND_TIMESTAMP" ]; then
    ARGS+=( "--branch-and-timestamp" "$BRANCH_AND_TIMESTAMP" )
  fi
  if [ -n "$PATH_PREFIX" ]; then
    ARGS+=( "--path-prefix" "$PATH_PREFIX" )
  fi
  if [ -n "$MESSAGE" ]; then
    ARGS+=( "--message" "${MESSAGE}" )
  fi
  if [ -n "$INPUT" ]; then
    ARGS+=( "--input" "${INPUT}" )
  fi

  # Transforming the space separated parameter into multiple single-value parameters. This is necessary, since it is not
  # possible in a Github Action to specify the same parameter multiple times as we do for teamscale-upload.
  for line in $APPEND_TO_MESSAGE; do
    ARGS+=( "--append-to-message" "$line" )
  done
fi

ARGS+=( "${FILES_ARRAY[@]}" )

"$LAUNCHER" "${ARGS[@]}"
