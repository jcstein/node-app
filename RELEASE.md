# How to make a new release of Quazar

1. Open the project in Xcode.
2. Double-check the build and version number is what you want it to be.
3. Rebuild your archive.
4. Sign the application with "Distribute App" > "Developer ID"
5. Create the new `quazar.dmg` with `dmg.txt` format.
6. Publish release on GitHub

## Enabling hardened runtime on `celestia` binary

This covers how to sign the binary correctly when it is updated to a new version.

CD:

```bash
cd $HOME/node-app/quazar
```

Sign:

```bash
codesign --force --options runtime --sign "YOUR_DEVELOPER_ID" celestia
```

Verify:

```bash
codesign --verify --verbose celestia
```
