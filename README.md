# pat - the fastest way to run a Celestia light node

Pat is f.k.a. Quazar, f.k.a. Quasar

## quazar ✨ a Celestia light node macOS app

Introducing quazar ✨ [v0.3.0-alpha](https://github.com/jcstein/node-app/releases/tag/quazar_v0.3.0-alpha_CN-v0.11.0-rc10_Arabica),
a [Celestia light node](https://docs.celestia.org/nodes/light-node/) macOS app, written in Swift.

A quasar (quasi-stellar object) is a very luminous object in space,
powered by an active galactic nucleus (a light node).

## Features ⚙️

v0.3.0-alpha of this app runs on the [Arabica devnet](https://docs.celestia.org/nodes/arabica-devnet/) (chain ID `arabica-10`) and has the following functions:

* `🟣 Initialize your Celestia light node`: this initializes a Celestia light node in the application's local storage
* `🟢 Start your node`: this starts the light node
* `🔴 Stop your node`: this stops the light node
* `🪙 Check your balance`: this displays the node's balance in TIA to 6 decimal places
* `📋 Account address: copy to clipboard`: this is to make it easy to use the faucet and check your balance
* `🗑️ Delete your data store`: deletes the data store for the node (use with caution)
* `🔐 Delete your key store`: deletes the key store for the node, the account `my_celes_key` (use with caution)
* `🔥 Delete entire node store`: deletes both the data and key store (use with caution)
* `🚰 Faucet`: a direct link to an Arabica faucet
* `🔎 Block explorer`: a direct link to a block explorer for Arabica

### DASer sampling statistics

* `🧪 Sampled chain head`: the head of the chain that the light node has sampled
* `🎣 Catchup head`: the head of the chain the node has synchronized
* `🌐 Network head height`: the head of chain of the network

## Installation 🏗️

### macOS download 💾

The latest release with `quazar.dmg`
images for Mac can be found on the
[latest release](https://github.com/jcstein/node-app/releases/latest) page.

Download `quazar.dmg` to your computer and open it from your downloads folder.
Then, drag the "quazar" icon to the "Applications" folder.

<img width="912" alt="Screenshot 2023-06-07 at 1 03 06 AM" src="https://github.com/jcstein/node-app/assets/46639943/d5eee61f-bdbc-43da-85c0-b1b15b1af97b">

### Video tutorial 📺

You can view the latest video tutorial [here](https://twitter.com/JoshCStein/status/1666328587400630272?s=20).

### Troubleshooting 🛠️

If you encounter a warning when you open the app, you will need to go to your
System Preferences > Privacy & Security > Security and select "App Store and identified developers".

<img width="827" alt="Screenshot 2023-06-20 at 4 07 52 PM" src="https://github.com/jcstein/node-app/assets/46639943/4027fcb2-fad2-436a-a051-9cca6f5b9742">

## Prerequisites 🧱

The current version requires:

* macOS 13.1 or higher
* Macs equipped with M1 or M2 chips (as the `celestia` binary is built specifically for ARM Macs in the 
versions)

## Application dependencies ⬇️

* `celestia-node` ("CN") binary version: [v0.11.0-rc10](https://github.com/celestiaorg/celestia-node/releases/tag/v0.11.0-rc10)

## Xcode project 🔨

The Xcode project can be found in [node-app](./node-app/).

### Developer dependencies 👩‍💻

* Xcode

## App previews 💻

### Before starting a node 🎬

<img width="912" alt="Screenshot 2023-06-07 at 12 45 44 AM" src="https://github.com/jcstein/node-app/assets/46639943/49be0441-c1e5-4673-94de-95ef75f2a4c1">

### Initializing a node 🟣

<img width="912" alt="Screenshot 2023-06-07 at 12 46 18 AM" src="https://github.com/jcstein/node-app/assets/46639943/4557617b-19cf-450d-93bb-9bddbfad23aa">

### Running a node 🟢

<img width="912" alt="Screenshot 2023-06-07 at 12 46 59 AM" src="https://github.com/jcstein/node-app/assets/46639943/710a6147-346b-4ab4-8984-5c11863c805f">
