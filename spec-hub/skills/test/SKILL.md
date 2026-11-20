---
name: test
description: Use when writing or running tests, proving a bug fix, choosing what to test, building fixtures or seed data, reading test, tsc or build results, or before saying anything is "green", "passes" or "done" ("เขียนเทส", "เทสแดง", "รันเทส", "เขียวไหม", "jest", "go test", "tsc", "build ผ่านไหม"). Every rule here came from a test that passed while the code was wrong.
---

# Testing

A green test proves only that the test passed. These rules make it prove the code is right.

## 1. Red before the fix

Order: investigate until you know the right answer, write the test and watch it fail, fix, watch it pass,
then **take the fix out and watch it fail again with the same message.**

- A test written after the code checks what the code does, not what it should do. One such test passed
  both before and after a fix; the regression reached review.
- When you take the fix out, check the file really changed before running the test. A replace that did
  not match once left the code untouched and the test "proved" nothing.
- **Read the number of tests run.** `Tests: 0`, a missing `Tests:` line, or fewer tests than the last run
  means the run broke, not that the test passed.
- **Never mock the unit you are proving.** Mock one level lower. A test that is green before the fix is
  probably testing the mock.
- You cannot write the test first when you do not yet know which unit is wrong, the contract does not
  exist yet, or "right" is still a business question. Say which.

## 2. What to test

- **The empty collection** for every loop inside a validator. Zero items means zero checks and "valid".
  Test both "sent an empty list" and "did not send the field".
- **Every DB `CHECK` and `UNIQUE`** on the table a validator guards. List them from the migration, not from
  the spec, and mark each as caught by the DTO tag, the bounds check, the business validator, or left to
  the DB on purpose. Eight were once missed; the user saw a form-wide error with no field marked.
- **Clock-reading gates run again after the lock.** If code checks "has it started / expired" and then
  re-reads under a lock, the time check must run on the locked copy too.
- **Decorators are actually attached.** A permission test that reads only the `@Permissions` list stays
  green when the guard is removed. Assert `GUARDS_METADATA` and `INTERCEPTORS_METADATA` as well.
- **"The user sees X" is tested at the outermost layer we own** (global error formatter, exception filter,
  serializer). A field set by the service was dropped by the shared formatter; the service test was green.
- **Per-row behaviour needs two rows** in one render, with fixture values that differ from the code's
  fallback. `items[0]` cannot tell "reads its own row" from "reads the first row".
- **Selection-driven UI:** switch between items several times and assert one of each panel.
- **Removing implicit behaviour** (auto refetch, remount, page refresh after an action) needs one test per
  place that relied on it. The diff is clean because the lost behaviour never had its own line.
- **Text drawn on a canvas or into an image:** fake `measureText`, test a long name and one unbroken long
  word, then render it for real once. Canvas never wraps and a mocked canvas cannot see overflow.
- **Business gates** ("empty", "not filled in", "valid"): grep the module for the predicate it already
  uses before writing a new one. Two definitions of one meaning is a bug waiting.
- **Unit tests test logic only, never style or layout.** Calculations, state changes, validation, what is
  sent, what the UI decides. No tests on styling, layout, motion or class names; those are checked by eye and
  screenshots. Pull a rule out of a component to test it.

## 3. Test data

- **No fixed dates in tests that compare with now.** Compute from now or pin the clock. Fixed "future"
  dates once set a date on which every pipeline of a repo would turn red with no code change. Before push,
  grep the diff for literal `20\d\d-\d\d-\d\d` dates.
- **Fixtures copy the real payload of each caller**, every field a real row carries. Minimal hand-built
  objects test a shape that never arrives. Thousands of random cases passed while real carts priced
  bundles wrong.
- **Seed data is made the way the real system makes it**: same id version, formats, starting states.
  Derived ids (uuid5, hashes) broke a validator that real data never hits. When a probe fails, check
  whether only seeded data fails.
- **"Fails for every input"** must list the input classes tried.
- **Performance data includes the real extremes.** Count the largest rows on the env where the problem
  shows before you seed. If the sandbox does not reproduce it, ask what the sandbox data left out.
- **Tests against another merchant's store are read-only** or expect-denied. Create fixtures only in a
  store your team owns.

## 4. Reading results honestly

- **Show the real output**: exit code and counts. Not "should pass".
- **Capture the command's exit code, not grep's**: `cmd > out.log 2>&1; echo "exit=$?"`.
- **Quote green only from an idle machine.** `waitFor` timeouts track machine load. With parallel builds
  the same clean tree failed different tests on each run. Rerun idle before calling anything flaky.
- **Count `Warning:` lines** next to `Tests:`. A new React key warning once explained a visible layout bug.
- **zsh does not split words**: `T="a.spec.ts b.spec.ts"; jest $T` runs nothing. Use arrays or literal
  paths.
- **A failure about an error message on dev:** capture the network request first (did one fire, exact
  payload). A fix once mocked a server error for a toast that was client-only.

## 5. Gates

- **While iterating, run only the tests the change can reach**, and say which scope you ran. **Before push,
  run the repo's full suite once** and show the result.
- **tsc in a repo that already has errors:** diff the error set against the base (`sort -u`, `comm -13`),
  both sides with `--incremental false`. Lower counts prove nothing; deleting a file once hid one new error.
- **`ignoreBuildErrors` hides type errors**: run `tsc --noEmit` separately and a real `next build` before
  push. A client component imported from a barrel into a server component fails only in `next build`.
- **Code-first GraphQL `schema.gql` is output**, regenerated at boot. Judge a schema change by the
  resolvers and DTOs, not the committed file.
- **Go repos with `//go:build integration`:** plain `go test ./...` skips them. Run with
  `-tags integration -p 1` against your own throwaway Postgres on the env's version.
- **CI runs only the integration suite** by team choice. Run the rest locally. Do not report it as a gap.
- **Several open branches in one repo:** merge them in a scratch worktree and build and test the result.
  Three branches each green and conflict-free failed together with a redeclared symbol.
- **A PR open for a while:** merge the latest develop into it and rerun its tests before "ready".
- **Seeds, migrations and hand-run scripts:** prove every way they can be run (psql, DBeaver, runner).
