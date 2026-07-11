# Reading errors you did not expect

An error message looks scary, but it is usually just a computer telling you exactly what went
wrong and where. This page teaches you how to read one calmly. It does not list every error you
might hit - it teaches you the moves that work for all of them. If a word here is new, check the
[glossary](glossary.md) first.

## The one habit that fixes most of them

**Read the whole message, slowly, from the top.** The very first error is almost always the real
cause; everything after it is often just fallout. Beginners tend to scroll to the bottom, see a
wall of red, and panic. Instead:

1. Find the **first** line that says `error` (or `failed`, `Error`, `panic`, `Exception`).
2. Read the sentence next to it - in plain English, what is it complaining about?
3. Find the **file path and line number** it points at (like `src/app.ts:42`). That is where to
   look.
4. Change one thing, run the command again, and see if the message changed.

That loop - read, look, change one thing, re-run - solves the large majority of errors without
any deep knowledge.

## Where the useful part is

A long error is mostly context. The parts that actually help you are:

- **The message**: a short sentence describing the problem (`cannot find name 'usr'`).
- **The location**: a `file:line` pointer to the exact spot.
- **The first occurrence**: the topmost error, not the last.

Everything else - long file paths, memory addresses, framework internals - is background you can
skip until you need it.

## Three kinds you will meet

### A lint failure

[Lint](glossary.md#lint) checks style and likely mistakes. Its errors are the friendliest: they name
a rule, a file, and a line, and often tell you the fix.

```
src/app.ts:42:7  error  'usr' is never reassigned. Use 'const' instead  prefer-const
```

Read it as: in `src/app.ts`, line 42, column 7, the rule `prefer-const` wants `const` instead of
`let`. Many lint problems fix themselves - try the project's auto-fix (often `make fmt` or a
`--fix` flag) before editing by hand.

### A red CI log

[CI](glossary.md#ci) runs your checks on a server after you push. When it goes red, open the failed
job and scroll to the **first** step marked with a red X - the later steps failed only because an
earlier one did. Inside that step, the real error reads just like it would on your own machine.
Two shortcuts:

- Search the log for the word `error` or `failed` and jump to the first hit.
- The check that failed in CI is one you can usually reproduce locally by running
  [`make check`](glossary.md#quality-gate) yourself - fix it there, where the loop is faster, then push again.

### A stack trace

A stack trace appears when a program crashes while running. It is a list of the function calls
that were in progress, printed innermost-first (or sometimes outermost-first). It looks like the
most intimidating error, but you read it the same way:

1. Read the **top line** - it names the actual problem
   (`TypeError: cannot read property 'name' of undefined`).
2. Scan down for the **first file that belongs to you** (your `src/...`), not a library or the
   language runtime. That line is where your code went wrong.
3. Ignore the deep frames inside libraries unless nothing in your own code appears.

The trace is a trail leading back to your mistake - follow it to the first line with your name on
it.

## When the message is not enough

If reading it carefully still leaves you stuck:

- **Copy the exact message into a search engine.** Someone has almost certainly hit it before.
  Drop the parts unique to you (your file paths, your variable names) so the search matches.
- **Re-run with more detail.** Many tools have a `--verbose` or `-v` flag, or a `DEBUG=1`
  setting, that prints more about what it was doing.
- **Change one thing at a time.** If you change five things and the error moves, you will not
  know which change mattered. One change, one re-run.
- **Ask for help with the exact message.** Paste the whole thing, say what command you ran, and
  say what you already tried - that is far easier to help with than "it broke".

## The mindset

An error is not the tool being angry at you - it is the tool doing its job, catching a problem
early and pointing at it so you can fix it before it grows. The goal is not to never see errors;
it is to read them without flinching. Slow down, read the first one, look where it points, and
change one thing.
