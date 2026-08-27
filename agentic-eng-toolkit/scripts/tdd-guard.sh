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

# Editing a test file itself is allowed (matched by naming convention, not
# a bare substring — "gateway/latest.py" or "contest_handler.py" must NOT match)
BASENAME_ONLY=$(basename "$FILE_PATH")
case "$BASENAME_ONLY" in
  test_*.py|*_test.py|*.test.*|*.spec.*|conftest.py|tests.py|test.py)
    exit 0
    ;;
esac

# Files inside a dedicated test directory are allowed (exact path segment, not substring)
case "$FILE_PATH" in
  __tests__/*|*/__tests__/*|tests/*|*/tests/*|test/*|*/test/*|spec/*|*/spec/*|specs/*|*/specs/*)
    exit 0
    ;;
esac

# Config/type/style files don't need tests — allow
case "$FILE_PATH" in
  *.json|*.css|*.scss|*.md|*.yml|*.yaml|*.env*|*.config.*|*tailwind*|*postcss*|*next.config*|*tsconfig*|*.toml|*.cfg|*.ini|*.lock)
    exit 0
    ;;
esac

# types/ folder and type-declaration files don't need tests — allow
# (matched by basename/exact-segment, not "*/..." suffix, so root-level
# files like a repo-root types.ts aren't missed — see migrations/ fix below
# for why the "*/" form alone isn't enough)
case "$BASENAME_ONLY" in
  types.ts|*.d.ts)
    exit 0
    ;;
esac
case "$FILE_PATH" in
  types/*|*/types/*)
    exit 0
    ;;
esac

# Next.js framework files are allowed (layout, page, loading, error, not-found, global styles)
case "$BASENAME_ONLY" in
  layout.tsx|layout.ts|page.tsx|page.ts|loading.tsx|error.tsx|not-found.tsx|globals.css)
    exit 0
    ;;
esac

# Python packaging/framework files don't need their own tests — allow
case "$BASENAME_ONLY" in
  __init__.py|setup.py|manage.py|wsgi.py|asgi.py)
    exit 0
    ;;
esac
case "$FILE_PATH" in
  migrations/*|*/migrations/*|alembic/versions/*|*/alembic/versions/*)
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
    if [ "$DIR_REAL" = "$PROJECT_ROOT" ]; then
      REL_DIR=""
    else
      REL_DIR="${DIR_REAL#"$PROJECT_ROOT"/}"
    fi
    PARENT_NAME=$(basename "$DIR")

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

    # feature-area convention: tests/test_<parent-dir-name>.py covers every module in that dir
    # (e.g. gateway/providers/openai_adapter.py <- tests/test_providers.py)
    if [ "$TEST_FOUND" = false ] && [ -n "$PARENT_NAME" ] && [ "$PARENT_NAME" != "." ] && [ "$PARENT_NAME" != "/" ]; then
      if [ -f "${PROJECT_ROOT}/tests/test_${PARENT_NAME}.py" ] || [ -f "${PROJECT_ROOT}/test/test_${PARENT_NAME}.py" ]; then
        TEST_FOUND=true
      fi
    fi

    # last resort: any test file that actually imports this module, regardless of naming
    # (e.g. gateway/routes.py tested from tests/test_routing.py via `from gateway.routes import ...`)
    if [ "$TEST_FOUND" = false ]; then
      # escape regex metacharacters so a basename like "my.module" or "weird+name"
      # can't corrupt the pattern or match unrelated text
      BASENAME_RE=$(printf '%s' "$BASENAME" | sed -e 's/[].[^$*+?(){}|\\]/\\&/g')
      for TESTS_DIR in "${PROJECT_ROOT}/tests" "${PROJECT_ROOT}/test" "${DIR}/tests" "${DIR}/test" "${PARENT}/tests" "${PARENT}/test"; do
        if [ -d "$TESTS_DIR" ] && grep -rlE "^[[:space:]]*(from|import)[^#]*[^A-Za-z0-9_]${BASENAME_RE}([^A-Za-z0-9_]|\$)" --include='*.py' "$TESTS_DIR" >/dev/null 2>&1; then
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
    "permissionDecisionReason": "TDD GUARD: No test file exists for '${BASENAME}'. Write a test before writing implementation code. (example test file: test_${BASENAME}.py)"
  }
}
EOF
    fi
    ;;
esac

exit 0
