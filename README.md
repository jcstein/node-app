# quasar ✨ a Celestia light node macOS app

This repository is for quasar, a Celestia light node macOS app, written in Swift.

This is [v0.1.6-alpha](https://github.com/jcstein/node-app/releases/tag/quasar_v0.1.6-alpha_CN-v0.11.0-rc2_Arabica) of quasar.

## Features ⚙️

v0.1.6 of this app runs on the [Arabica devnet](https://docs.celestia.org/nodes/arabica-devnet/) and has the following functions:

* `🟣 Initialize your Celestia light node`: this initializes a Celestia light node in the application's local storage
* `🟢 Start your node`: this starts the light node
* `🔴 Stop your node`: this stops the light node
* `🪙 Check your balance`: this now displays a balance in TIA to 6 decimal places
* `⛓️ Chain height`: fetches the chain height every 3s
* `🗑️ Delete your data store`: deletes the data store for the node (use with caution)
* `🔐 Delete your key store`: deletes the key store for the node, the accoutn `my_celes_key` (use with caution)
* `🔥 Delete entire node store`: deletes both the data and key store ((use with caution)

## Installation 🏗️

### macOS download 💾

The latest release with `quasar.dmg`
images for Mac can be found on the
[latest release](https://github.com/jcstein/node-app/releases/latest) page.

Download `quasar.dmg` to your computer and open it from your downloads folder.
Then, drag the "quasar" icon to the "Applications" folder.

<img width="912" alt="Screenshot 2023-06-04 at 1 59 25 AM" src="https://github.com/jcstein/node-app/assets/46639943/9b91f374-e459-4d59-9b02-acf1e07ebac9">

### Troubleshooting 🛠️

If you encounter a warning when you open the app, you will need to go to your
System Preferences > Privacy & Security > Security and select "App Store and identified developers".
Click "Open Anyway" next in the box that says `"quasar" was blocked from use because it is not from an identified developer."`

<img width="726" alt="Screenshot 2023-06-04 at 12 26 59 AM" src="https://github.com/jcstein/node-app/assets/46639943/db505d6b-37c9-4757-8eed-4b03fdd53a99">

## Prerequisites 🧱

The current version requires:

* macOS 13.1 or higher
* Macs equipped with M1 or M2 chips (as the `celestia` binary is built specifically for ARM Macs in the 
versions)

## Application dependencies ⬇️

* `celestia-node` ("CN") binary version: [v0.11.0-rc2](https://github.com/celestiaorg/celestia-node/releases/tag/v0.11.0-rc2)

## Xcode project 🔨

The Xcode project can be found in [node-app](./node-app/).

### Developer dependencies 👩‍💻

* Xcode

## App previews 💻

### Before starting a node 🎬

<img width="912" alt="Screenshot 2023-06-04 at 2 01 36 AM" src="https://github.com/jcstein/node-app/assets/46639943/1fd32756-d9e5-4baa-b4ed-7837b0c4783b">

### Initializing a node 🟣

<img width="912" alt="Screenshot 2023-06-04 at 2 01 40 AM" src="https://github.com/jcstein/node-app/assets/46639943/5e815f72-c922-47b2-859e-da6294ce4369">

### Running a node 🟢

<img width="912" alt="Screenshot 2023-06-04 at 2 01 49 AM" src="https://github.com/jcstein/node-app/assets/46639943/2f71a135-59bf-417a-a544-c46a83b6d275">
