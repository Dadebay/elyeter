# Elyeter — architecture

Feature-first layering with BLoC. MVP now, MVVM later without moving folders.

## Folder map

```
lib/
├─ main.dart                  # one line: bootstrap(App.new)
├─ bootstrap.dart             # pre-first-frame setup: hydrated storage, DI, error hooks
├─ app/
│  ├─ app.dart                # MaterialApp.router + global providers
│  ├─ cubit/                  # app-wide state: theme_cubit, locale_cubit (persisted)
│  ├─ router/                 # app_router.dart (go_router), app_routes.dart (enum)
│  └─ view/                   # home_shell.dart + widgets/app_bottom_nav_bar.dart
├─ core/                      # no feature imports core-downwards only
│  ├─ bloc/                   # AppBlocObserver
│  ├─ constants/              # app_constants, app_environment (--dart-define flavors)
│  ├─ di/                     # injector.dart (get_it)
│  ├─ error/                  # exceptions (data layer) -> failure (domain layer)
│  ├─ localization/           # failure_localizer: Failure -> localized text
│  ├─ network/                # api_client, api_endpoints, network_info, interceptors/
│  ├─ storage/                # local_storage (prefs), secure_storage (tokens), keys
│  ├─ theme/                  # app_colors, app_typography, app_spacing, app_theme
│  ├─ utils/                  # result.dart, app_logger, extensions/, formatters/
│  └─ widgets/                # shared UI: loader, error view, empty view, network image
├─ features/<feature>/
│  ├─ data/                   # datasources/ (API, cache), models/ (DTO+fromJson), repositories/ (impl)
│  ├─ domain/                 # entities/ (pure Dart), repositories/ (abstract contract)
│  └─ presentation/           # bloc/, view/ (pages), widgets/ (feature-local)
└─ l10n/                      # arb/ source strings + generated AppLocalizations
```

Features present: `auth, home, category, product, cart, favorite, order,
profile, search, settings, notification, address`.

## Rules that keep it clean

1. **Dependencies point inward.** `presentation -> domain <- data`. A bloc never
   imports Dio or a model; it talks to the abstract repository from `domain/`.
2. **Errors are typed.** Data sources throw `AppException`, repositories catch and
   return `Result<T>` (`Success` / `Error(Failure)`). Blocs never see exceptions.
3. **No copy in blocs.** States carry a `Failure`; the widget localizes it with
   `failure.localize(context.l10n)`.
4. **No hard-coded colors, sizes or strings in widgets.** Use `context.colors`,
   `AppSpacing`, `AppRadius`, `context.l10n`.
5. **One registration point.** Everything is wired in `core/di/injector.dart`,
   one `_registerX()` per feature.

## Adding a feature

```
features/checkout/
  data/datasources/checkout_remote_data_source.dart
  data/models/checkout_model.dart
  data/repositories/checkout_repository_impl.dart
  domain/entities/checkout.dart
  domain/repositories/checkout_repository.dart
  presentation/bloc/checkout_bloc.dart        (+ event/state)
  presentation/view/checkout_page.dart
  presentation/widgets/
```

Then register the chain in `injector.dart` and add a route to `app_routes.dart`
+ `app_router.dart`.

## MVP -> MVVM (month ~5)

Only `presentation/` changes. The plan:

| Now (MVP)                        | Later (MVVM)                                   |
| -------------------------------- | ---------------------------------------------- |
| `presentation/bloc/x_bloc.dart`  | `presentation/viewmodel/x_view_model.dart`      |
| `BlocBuilder` in the page        | `ListenableBuilder` / `BlocBuilder` on the VM   |
| `domain/repositories`            | unchanged                                       |
| `data/`                          | unchanged                                       |
| `core/`                          | unchanged                                       |

Because pages already depend on an abstract repository through DI and never on a
concrete bloc type outside their own feature, a feature can be migrated on its
own, one at a time, without touching the rest of the app.

If use cases are wanted at that point, add `domain/usecases/` and let the view
model call those instead of the repository directly — no other layer moves.

## Build flavors

```sh
flutter run --dart-define=FLAVOR=dev     --dart-define=API_BASE_URL=https://api.dev.elyeter.com
flutter build apk --release --dart-define=FLAVOR=prod --dart-define=API_BASE_URL=https://api.elyeter.com
```

## Localization

Strings live in `lib/l10n/arb/app_{en,tr,ru}.arb`. After editing:

```sh
flutter gen-l10n
```

To add Turkmen, copy `app_en.arb` to `app_tk.arb`, translate the values, and
rerun the command — `supportedLocales` picks it up automatically.
