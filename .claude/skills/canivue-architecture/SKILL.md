---
name: canivue-architecture
description: "Use whenever adding, moving, or reviewing code in the Canivue Flutter app (lib/**) — covers the layered feature architecture, Riverpod/go_router conventions, design-token rules, and the required small-commit Conventional Commits discipline. Load before writing new screens, providers, repositories, or making theming changes."
---

# Canivue architecture

Canivue is a Flutter app for dog health monitoring, AI disease prediction, vet
consultation, and community. It is being built **UI-first**: all data comes
from fake/mock repositories today so a real backend can be swapped in later
without touching presentation code. This skill is the reference for how new
code should be structured so that swap stays cheap.

## Layering

```
lib/
  core/
    design_system/
      tokens/        AppColors, AppSpacing, AppRadius, AppTypography, AppMotion
      components/    reusable widgets (buttons, cards, chips, avatars, states...)
    routing/          go_router config: routes, shells, redirects
    widgets/          legacy shared widgets (pre-design-system; migrate on touch)
    theme/            AppTheme — ThemeData built FROM design_system/tokens
  features/<feature>/
    domain/           entities, value objects, repository *interfaces*
    data/             repository implementations — `Fake<Thing>Repository` for now
    presentation/
      screens/
      widgets/
      controllers/    Riverpod Notifiers / providers
```

Rules:
- **Domain layer has no Flutter imports.** Plain Dart classes only.
- **Data layer implements domain interfaces.** A feature's fake repository
  simulates latency (`Future.delayed`) and can simulate errors/empty states —
  screens must be built to actually exercise their loading/empty/error UI,
  not just the happy path.
- **Presentation never talks to a repository directly** — always through a
  Riverpod provider, so swapping `FakeDogsRepository` for a real one later is
  a one-line provider override, not a UI change.
- Existing pre-architecture screens (most of `features/*`) are migrated into
  this shape **incrementally, as each is touched** for the UI build-out —
  not a big-bang rewrite.

## State management: Riverpod

- Feature/domain data (dogs, health metrics, predictions, appointments,
  messages, community posts, notifications, etc.) is modeled with
  `flutter_riverpod` providers — `Provider`, `FutureProvider`,
  `NotifierProvider`/`AsyncNotifierProvider` as appropriate.
- Naming: `xyzRepositoryProvider`, `xyzListProvider`, `xyzControllerProvider`.
- One narrow exception: `AppTheme.themeModeNotifier` (a plain
  `ValueNotifier<ThemeMode>`) stays as-is — it's single-reader UI chrome
  state, not domain data. Don't use this exception as precedent for new
  feature state; new state goes through Riverpod.
- `ProviderScope` wraps the app in `main.dart`.

## Routing: go_router

- Top-level flow (auth → role-based shell) is declared in
  `core/routing/app_router.dart`.
- The dog-owner experience and the veterinarian experience are **separate
  shells** (different bottom nav, different home) selected by role — never
  bolt vet screens onto the owner's shell or vice versa.
- Nested/contextual navigation (opening a detail screen, a bottom sheet, a
  wizard step) can still use `Navigator.push`/`showModalBottomSheet` from
  within a routed screen — go_router owns the top-level stack, not every
  single push.

## Design tokens

- Never hardcode a color, spacing, radius, or font size in a screen/widget.
  Use `AppColors` / `AppSpacing` / `AppRadius` / `Theme.of(context).textTheme`
  (populated from `AppTypography`).
- `core/theme/app_theme.dart` also exposes legacy named constants
  (`AppTheme.primaryBlue`, `AppTheme.heroGradient`, etc.) kept for the many
  screens written before this system existed. They're aliased onto the teal
  design tokens so old screens rebrand automatically — **new code should use
  `AppColors`/`Theme.of(context)` directly instead of adding to that legacy
  list.**
- Every new component (`core/design_system/components/`) supports the
  states that apply to it: default, loading, disabled, error, success,
  selected — and both light/dark themes.

## Git commit discipline

- **Conventional Commits**, scoped: `feat(<scope>): ...`,
  `fix(<scope>): ...`, `refactor(<scope>): ...`, `chore(<scope>): ...`,
  `docs(<scope>): ...`, `style(<scope>): ...`.
- **One logical change per commit.** A large feature/milestone is split into
  several small commits (e.g. "add health repository + fake data", "add
  health score card widget", "wire health screen to provider") rather than
  landed as one giant commit.
- **Never use a numeric or placeholder message** ("task 1", "wip", "part 2").
  Every commit message describes what changed, in imperative mood.
- Stage only the files that belong to the change being committed — don't
  sweep up unrelated pending edits into a commit.

## Verification

After a change, run `flutter analyze` (and `flutter pub get` if
`pubspec.yaml` changed) before committing. For UI changes, prefer verifying
visually via the `canivue-web` preview config
(`flutter run -d web-server`, see `.claude/launch.json`) over asking the user
to check manually.
