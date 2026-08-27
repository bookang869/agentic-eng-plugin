#!/bin/bash
# TDD Guard Hook — PreToolUse[Edit|Write]
# When implementation code is about to be written, check whether a test file for that module already exists.
# Block writing implementation code without a test.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# No file path — allow
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Editing a test file itself is allowed
case "$FILE_PATH" in
  *test*|*spec*|*.test.*|*.spec.*|*__tests__*)
    exit 0
    ;;
esac

# Config/type/style files don't need tests — allow
case "$FILE_PATH" in
  *.json|*.css|*.scss|*.md|*.yml|*.yaml|*.env*|*.config.*|*tailwind*|*postcss*|*next.config*|*tsconfig*|*.toml|*.cfg|*.ini|*.lock)
    exit 0
    ;;
esac

# types/ folder doesn't need tests — allow
case "$FILE_PATH" in
  */types/*|*/types.ts|*/types.d.ts)
    exit 0
    ;;
esac

# Next.js framework files are allowed (layout, page, loading, error, not-found, global styles)
case "$FILE_PATH" in
  */layout.tsx|*/layout.ts|*/page.tsx|*/page.ts|*/loading.tsx|*/error.tsx|*/not-found.tsx|*/globals.css)
    exit 0
    ;;
esac

# Python packaging/framework files don't need their own tests — allow
case "$FILE_PATH" in
  */__init__.py|*/setup.py|*/manage.py|*/wsgi.py|*/asgi.py|*/migrations/*|*/alembic/versions/*)
    exit 0
    ;;
esac

# For lib/ or source files, check whether a test file exists
case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx)
    # Extract the file name
    DIR=$(dirname "$FILE_PATH")
    BASENAME=$(basename "$FILE_PATH" | sed -E 's/\.(ts|tsx|js|jsx)$//')

    # Candidate test file paths
    TEST_FOUND=false

    # .test file in the same folder
    for EXT in ts tsx js jsx; do
      if [ -f "${DIR}/${BASENAME}.test.${EXT}" ] || [ -f "${DIR}/${BASENAME}.spec.${EXT}" ]; then
        TEST_FOUND=true
        break
      fi
    done

    # __tests__ folder
    if [ "$TEST_FOUND" = false ]; then
      PARENT=$(dirname "$DIR")
      for EXT in ts tsx js jsx; do
        if [ -f "${PARENT}/__tests__/${BASENAME}.test.${EXT}" ] || [ -f "${DIR}/__tests__/${BASENAME}.test.${EXT}" ]; then
          TEST_FOUND=true
          break
        fi
      done
    fi

    # src/__tests__/ root test folder
    if [ "$TEST_FOUND" = false ]; then
      PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
      for EXT in ts tsx js jsx; do
        if [ -f "${PROJECT_ROOT}/src/__tests__/${BASENAME}.test.${EXT}" ]; then
          TEST_FOUND=true
          break
        fi
      done
    fi

    if [ "$TEST_FOUND" = false ]; then
      cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "TDD GUARD: No test file exists for '${BASENAME}'. Write a test before writing implementation code. (example test file: ${BASENAME}.test.ts)"
  }
}
EOF
    fi
    ;;
esac

# For Python source files, check whether a pytest test file exists
case "$FILE_PATH" in
  *.py)
    DIR=$(dirname "$FILE_PATH")
    BASENAME=$(basename "$FILE_PATH" .py)
    PARENT=$(dirname "$DIR")
    PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
    DIR_REAL=$(cd "$DIR" 2>/dev/null && pwd -P || echo "$DIR")
    REL_DIR="${DIR_REAL#"$PROJECT_ROOT"/}"

    TEST_FOUND=false

    # same-folder test_<name>.py / <name>_test.py
    if [ -f "${DIR}/test_${BASENAME}.py" ] || [ -f "${DIR}/${BASENAME}_test.py" ]; then
      TEST_FOUND=true
    fi

    # colocated tests/ or test/ folder
    if [ "$TEST_FOUND" = false ]; then
      if [ -f "${DIR}/tests/test_${BASENAME}.py" ] || [ -f "${DIR}/test/test_${BASENAME}.py" ]; then
        TEST_FOUND=true
      fi
    fi

    # parent tests/ or test/ folder
    if [ "$TEST_FOUND" = false ]; then
      if [ -f "${PARENT}/tests/test_${BASENAME}.py" ] || [ -f "${PARENT}/test/test_${BASENAME}.py" ]; then
        TEST_FOUND=true
      fi
    fi

    # repo-root tests/, flat (tests/test_<name>.py)
    if [ "$TEST_FOUND" = false ]; then
      if [ -f "${PROJECT_ROOT}/tests/test_${BASENAME}.py" ] || [ -f "${PROJECT_ROOT}/test/test_${BASENAME}.py" ]; then
        TEST_FOUND=true
      fi
    fi

    # repo-root tests/, mirrored (tests/<same-subpath>/test_<name>.py)
    if [ "$TEST_FOUND" = false ] && [ -n "$REL_DIR" ]; then
      if [ -f "${PROJECT_ROOT}/tests/${REL_DIR}/test_${BASENAME}.py" ] || [ -f "${PROJECT_ROOT}/test/${REL_DIR}/test_${BASENAME}.py" ]; then
        TEST_FOUND=true
      fi
    fi

    if [ "$TEST_FOUND" = false ]; then
      cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "TDD GUARD: No test file exists for '${BASENAME}'. Write a test before writing implementation code. (example test file: test_${BASENAME}.py)"
  }
}
EOF
    fi
    ;;
esac

exit 0
