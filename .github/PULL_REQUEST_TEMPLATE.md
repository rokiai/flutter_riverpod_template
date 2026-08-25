## Summary

-

## Test plan

- [ ] `flutter gen-l10n`
- [ ] `dart run pigeon --input pigeons/app_platform.dart`
- [ ] `dart run build_runner build`
- [ ] `dart format --output=none --set-exit-if-changed lib test`
- [ ] `flutter analyze --fatal-warnings --fatal-infos`
- [ ] `flutter test`

## Checklist

- [ ] Followed `AGENTS.md` directory, naming, and layering rules
- [ ] No empty shell files, flavor leftover, or compatibility shims
