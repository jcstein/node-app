# Celestia light node macOS app ✨

This repository is for the Celestia light node macOS app, written in Swift.

## Installation 🏗️

### macOS download 💾

The latest release with `Celestia_light_node_Installer-v0.1.5-alpha.dmg`
images for Mac can be found on the
[latest release](https://github.com/jcstein/node-app/releases/latest) page.

Download the `.dmg` to your computer, and open it from the downloads folder.
Then, drag the "node-app" icon to the "Applications" folder.

<img width="912" alt="Screenshot 2023-06-03 at 11 03 10 PM" src="https://github.com/jcstein/node-app/assets/46639943/01a7ccc4-d717-401b-8ebb-1ad2813d129e">

#### Troubleshooting 🛠️

If you encounter a warning when you open the app, you will need to go to your
System Preferences > Privacy & Security > Security and select "App Store and identified developers".
Click "Open Anyway" next in the box that says `"node-app" was blocked from use because it is not from an identified developer."

<img width="726" alt="Screenshot 2023-06-04 at 12 26 59 AM" src="https://github.com/jcstein/node-app/assets/46639943/db505d6b-37c9-4757-8eed-4b03fdd53a99">

## App previews 💻

### Before starting a node 🎬

<img width="912" alt="Screenshot 2023-06-03 at 10 39 38 PM" src="https://github.com/jcstein/node-app/assets/46639943/5327a02d-b592-4d20-92ce-938393d9a765">

### Initializing a node 🟣

<img width="912" alt="Screenshot 2023-06-03 at 11 09 24 PM" src="https://github.com/jcstein/node-app/assets/46639943/e70b4e2b-8271-4308-a103-8745f37ecc40">

### Running a node 🟢

<img width="912" alt="Screenshot 2023-06-03 at 10 41 25 PM" src="https://github.com/jcstein/node-app/assets/46639943/5384f05e-6b19-4aa7-bf39-2a825e4b4cf2">

## Features ⚙️

v0.1.5-alpha of this app runs on the [Arabica devnet](https://docs.celestia.org/nodes/arabica-devnet/) and has the following functions:

* `🟣 Initialize your Celestia light node`: this initializes a Celestia light node in the application's local storage
* `🟢 Start your node`: this starts the light node
* `🔴 Stop your node`: this stops the light node
* `🪙 Check your balance`: this now displays a balance in TIA to 6 decimal places
* `⛓️ Chain height`: fetches the chain height every 3s
* `🗑️ Delete your data store`: deletes the data store for the node (use with caution)
* `🔐 Delete your key store`: deletes the key store for the node, the accoutn `my_celes_key` (use with caution)
* `🔥 Delete entire node store`: deletes both the data and key store ((use with caution)

## Xcode project 🔨

The Xcode project can be found in [node-app](./node-app/).

## Prerequisites 🧱

The current version requires:

* macOS 13.1 or higher
* Macs equipped with M1 or M2 chips (as the `celestia` binary is built specifically for ARM Macs in the alpha versions)

## Application dependencies ⬇️

* `celestia-node` ("CN") binary version: [v0.11.0-rc2](https://github.com/celestiaorg/celestia-node/releases/tag/v0.11.0-rc2)

### Developer dependencies 👩‍💻

* Xcode
