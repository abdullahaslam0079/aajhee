# Architecture

Feature-first Flutter. Each feature lives in `lib/src/features/<feature>/`.

## Layers

- **Domain** holds entities and repository contracts. It does not import Dio or Flutter widgets.
- **Data** implements repositories and talks to HTTP.
- **Presentation** is widgets, Riverpod, and screen controllers. It calls repositories, not `DioService`.

Auth is the reference: `AuthRepository` plus `AuthRepositoryImpl`. Commerce follows the same boundary through `CommerceRepository`. Product lists and the cart are typed (`CommerceProduct`, `CartLine`). Order and catalog payloads that are still nested JSON are parsed at the repository edge and rendered by screen widgets.

## Screens

A screen library stays small:

- `*_controller.dart` is a mixin with loading, refresh, and actions.
- `*_view.dart` is the `build` method.
- Other files in the same folder are the widgets that view composes.

Files should stay near 400 lines. Split a widget or a mixin before adding the next section to the same file.

## Language

Customer marketplace copy is English. `easy_localization` remains for the auth and onboarding strings that already use it. Do not add a second language until those commerce screens are translated together.
