.PHONY: build watch clean run fresh pods

build:
	flutter pub get
	dart run build_runner build --delete-conflicting-outputs

watch:
	dart run build_runner watch --delete-conflicting-outputs

clean:
	flutter clean
	flutter pub get

# Full reset: clean caches, reinstall deps, regenerate code, then run
fresh:
	flutter clean
	rm -rf ios/Pods ios/Podfile.lock ios/.symlinks
	rm -rf build .dart_tool
	flutter pub get
	dart run build_runner build --delete-conflicting-outputs
	cd ios && pod install --repo-update && cd ..
	flutter run

pods:
	cd ios && pod install --repo-update && cd ..

run:
	flutter run
