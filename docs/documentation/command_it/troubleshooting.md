# Troubleshooting

Common issues with command_it and how to solve them.

::: tip Problem → Diagnosis → Solution
This guide is organized by **symptoms** you observe. Find your issue, diagnose the cause, and apply the solution.
:::

## UI Not Updating

### Command completes but UI doesn't rebuild

**Symptoms:**
- Command executes but UI doesn't update
- Data seems unchanged
- No errors visible

**Diagnosis 1:** Command threw an exception

The command might have failed silently. Check if you're listening to errors:

<<< @/../code_samples/lib/command_it/troubleshooting_ui_not_updating.dart#diagnosis1_bad

**Solution:** Listen to errors or check `.results`:

<<< @/../code_samples/lib/command_it/troubleshooting_ui_not_updating.dart#diagnosis1_good

**Diagnosis 2:** Not watching the command at all

Check if you're actually observing the command's value:

<<< @/../code_samples/lib/command_it/troubleshooting_ui_not_updating.dart#diagnosis2_bad

**Solution:** Use `ValueListenableBuilder` or `watch_it`:

<<< @/../code_samples/lib/command_it/troubleshooting_ui_not_updating.dart#diagnosis2_good

**See also:** [Error Handling](/documentation/command_it/error_handling), [`watch_it` documentation](/documentation/watch_it/getting_started)

---

## Command Execution Issues

### Command doesn't execute / nothing happens

**Symptoms:**
- Calling `command('param')` does nothing
- No loading state, no errors, no results

**Diagnosis:**

Check if command is restricted:

<<< @/../code_samples/lib/command_it/troubleshooting_execution_issues.dart#restriction_diagnosis

**Solution 1:** Check restriction value

<<< @/../code_samples/lib/command_it/troubleshooting_execution_issues.dart#restriction_debug

**Solution 2:** Handle restricted execution

<<< @/../code_samples/lib/command_it/troubleshooting_execution_issues.dart#restriction_handler

**See also:** [Command Properties - Restrictions](/documentation/command_it/command_properties#restriction)

---

### Command stuck in "running" state

**Symptoms:**
- `isRunning` stays `true` forever
- Loading indicator never disappears
- Command won't execute again

**Diagnosis:**

Check if async function completes:

<<< @/../code_samples/lib/command_it/troubleshooting_execution_issues.dart#stuck_diagnosis

**Cause:** Async function never completes

<<< @/../code_samples/lib/command_it/troubleshooting_execution_issues.dart#stuck_cause

**Solution:**

Add a timeout to catch hanging operations:

<<< @/../code_samples/lib/command_it/troubleshooting_execution_issues.dart#stuck_solution

::: tip Errors Don't Cause Stuck State
If your async function throws an exception, the command catches it and resets `isRunning` to `false`. Errors won't cause a stuck running state - only futures that never complete will.
:::

---

## Error Handling Issues

### Errors not showing in UI

**Symptoms:**
- Command fails but UI doesn't show error state
- Errors logged to crash reporter but not displayed in UI

**Diagnosis:**

Check if error filter only routes to global handler:

<<< @/../code_samples/lib/command_it/troubleshooting_error_handling.dart#global_only_bad

With `globalHandler`, errors go to `Command.globalExceptionHandler` but `.errors` and `.results` listeners are not notified.

**Solution:** Use a filter that includes local handler

<<< @/../code_samples/lib/command_it/troubleshooting_error_handling.dart#local_filter_good

**See also:** [Error Handling - Error Filters](/documentation/command_it/error_handling#error-filters)

---

## Performance Issues

### Too many rebuilds / UI laggy

**Symptoms:**
- UI rebuilds on every command execution
- Even when result is identical

**Diagnosis:**

By default, commands notify listeners on every successful execution, even if the result is identical. This is intentional - a non-updating UI after a refresh action is often more confusing to users.

**Solution:** Use `notifyOnlyWhenValueChanges: true`

If your command frequently returns identical results and rebuilds are causing performance issues:

<<< @/../code_samples/lib/command_it/troubleshooting_performance.dart#notify_only_when_changes

::: tip When to Use This
Use `notifyOnlyWhenValueChanges: true` for polling/refresh commands where identical results are common. Keep the default (`false`) for user-triggered actions where feedback is expected.
:::

---

### Command executes too often

**Symptoms:**
- Command runs multiple times unexpectedly
- Seeing duplicate API calls
- Wasting resources

**Diagnosis:**

Check if you're calling the command in build:

<<< @/../code_samples/lib/command_it/troubleshooting_command_executes_often.dart#diagnosis_bad

**Solution 1:** Call in event handlers only

<<< @/../code_samples/lib/command_it/troubleshooting_command_executes_often.dart#solution1

**Solution 2:** Use `callOnce` for initialization

<<< @/../code_samples/lib/command_it/troubleshooting_command_executes_often.dart#solution2

**Solution 3:** Debounce rapid calls

<<< @/../code_samples/lib/command_it/troubleshooting_command_executes_often.dart#solution3

---

## Memory Leaks

### Commands not being disposed

**Symptoms:**
- Memory usage grows over time
- Flutter DevTools shows increasing listeners
- App becomes sluggish

**Diagnosis:**

Check if you're disposing commands:

<<< @/../code_samples/lib/command_it/troubleshooting_memory_leaks.dart#diagnosis_bad

**Solution:**

Always dispose commands in `dispose()` or `onDispose()`:

<<< @/../code_samples/lib/command_it/troubleshooting_memory_leaks.dart#solution

**For `get_it` singletons:**

<<< @/../code_samples/lib/command_it/troubleshooting_memory_leaks.dart#get_it_dispose

---

## Integration Issues

### `watch_it` not finding command

**Symptoms:**
- `watchValue` throws error: "No registered instance found"
- Command works with direct access but not with `watch_it`

**Diagnosis:**

Check if manager is registered in `get_it`:

<<< @/../code_samples/lib/command_it/troubleshooting_integration.dart#watch_it_not_registered

**Solution:**

Register manager in `get_it` before using `watch_it`:

<<< @/../code_samples/lib/command_it/troubleshooting_integration.dart#register_first

**See also:** [`get_it` documentation](/documentation/get_it/getting_started)

---

### ValueListenableBuilder not updating

**Symptoms:**
- Using `ValueListenableBuilder` directly
- UI doesn't update when command completes

**Diagnosis:**

Common mistake - creating new instance on every build:

<<< @/../code_samples/lib/command_it/troubleshooting_integration.dart#vlb_new_instance_bad

**Solution:**

Command must be created once and reused:

<<< @/../code_samples/lib/command_it/troubleshooting_integration.dart#vlb_reuse_good

---

## Type Issues

### CommandResult doesn't have data during loading/error

**Symptoms:**
- Accessing `result.data` returns null unexpectedly
- Data disappears while command is running
- Previous data gone after an error

**Diagnosis:**

By default, `CommandResult.data` is only available after successful completion. During loading or after an error, `.data` is null:

<<< @/../code_samples/lib/command_it/troubleshooting_commandresult_data.dart#diagnosis

**Solution 1:** Use `includeLastResultInCommandResults: true`

This preserves the last successful result during loading and error states:

<<< @/../code_samples/lib/command_it/troubleshooting_commandresult_data.dart#solution1

**Solution 2:** Check state before accessing data

<<< @/../code_samples/lib/command_it/troubleshooting_commandresult_data.dart#solution2

**Solution 3:** Use the command directly (always has data)

<<< @/../code_samples/lib/command_it/troubleshooting_commandresult_data.dart#solution3

---

### Generic type inference fails

**Symptoms:**
- Dart can't infer command types
- Need to specify types explicitly everywhere

**Diagnosis:**

Command created without explicit types:

<<< @/../code_samples/lib/command_it/troubleshooting_type_issues.dart#inference_bad

**Solution:**

Specify generic types explicitly:

<<< @/../code_samples/lib/command_it/troubleshooting_type_issues.dart#inference_good

---

## Still Having Issues?

1. **Check the documentation:** Each command_it feature has detailed documentation
2. **Search existing issues:** [command_it GitHub issues](https://github.com/escamoteur/command_it/issues)
3. **Ask on Discord:** [flutter_it Discord](https://discord.gg/ZHYHYCM38h)
4. **Create an issue:** Include minimal reproduction code

**When reporting issues, include:**
- Minimal code example that reproduces the problem
- Expected behavior vs actual behavior
- command_it version (`pubspec.yaml`)
- Flutter version (`flutter --version`)
- Any error messages or stack traces
