[![License](https://img.shields.io/npm/l/ts-expose-internals)](https://opensource.org/licenses/MIT)

# ⚠️ Do not use this unless you understand the risks ⚠️

You’re probably better off using [ts-expose-internals](https://github.com/nonara/ts-expose-internals) directly.

# ts-expose-internals-conditionally

A simple fork of the excellent [ts-expose-internals](https://github.com/nonara/ts-expose-internals), but only activates when compiled with:

```json5
// tsconfig.json
{
  "compilerOptions": {
    "module": "nodenext", // or "node16" or "bundler" - must support package.json "exports"
    "customConditions": ["ts-expose-internals"]
  }
}
```

## Why?

If you are publishing a library that uses ts-expose-internals in its implementation, and exposes some of TypeScript’s _non-internal_ types in its API, your own declaration files will end up referencing ts-expose-internals:

```ts
// your-library/index.d.ts

/// <reference types="ts-expose-internals" />

import { CompilerOptions } from "typescript";
export function doSomethingWrappingTypeScript(
  fileName: string,
  typeScriptOptions: CompilerOptions
): unknown;
```

Even though `CompilerOptions` is part of TypeScript’s public API, ts-expose-internals is a module augmentation that re-declares and augments everything in the `typescript` module. So when `tsc --declaration` notices that the `CompilerOptions` you’re referencing in your own compilation is declared in `"typescript"` but augmented in `"ts-expose-internals"`, it adds an explicit reference to `"ts-expose-internals"` to make sure everyone using your library sees the same `CompilerOptions` that you do.

Normally, this is a very desirable behavior. Without it, users could end up with types in their `node_modules` that reference things that don’t exist in their own compilation, leading to errors. But in the case of ts-expose-internals, you probably _don’t_ want to expose all of TypeScript’s internals for all of your users. You want the internals when compiling your own implementation code, but your public API can be consumed without them.

By using `ts-expose-internals-conditionally` and compiling with `"customConditions": ["ts-expose-internals"]` in your tsconfig.json, your compilation will include the ts-expose-internals module augmentation, but your users’ compilations won’t (assuming they don’t also have `"customConditions": ["ts-expose-internals"]`).

Of course, this is **not safe**, because if you accidentally reference anything internal that makes it into your declaration files, your users will get errors:

```ts
// your-library/index.d.ts

/// <reference types="ts-expose-internals-conditionally" />
//  ^ references an empty file for users!

import { ModeAwareCache } from "typescript";
//       ^^^^^^^^^^^^^^
// Module "typescript" has no exported member 'ModeAwareCache'.
```

To be safe, you should re-check your output declaration files _without_ any `customConditions` to ensure they’re portable.

## This must go in `dependencies`, not `devDependencies`

Since `tsc --declaration` will emit a reference to `"ts-expose-internals-conditionally"` in your declaration files, you need to ensure that reference actually resolves (to an empty file) for your users, which means they will need this package installed, which means it should go in your `dependencies`, not your `devDependencies`.

## Why is this a fork and not an intermediate dependency?

I thought I would get away with making a package with two tiny files:

```ts
// index.d.ts
/// <reference types="ts-expose-internals" />
```

```ts
// empty.d.ts
```

But it turns out that `tsc --declaration` still emits a reference directly to `"ts-expose-internals"`, even when it’s referenced transitively through this proxy package. This behavior actually makes sense, so I don’t think there was a way to do this without publishing an independent package.
