# Celestia light node macOS app

This repository is for the Celestia light node macOS app, written in Swift.

## Installation

### macOS download

The latest release with `Celestia_light_node_Installer-v0.1.4-alpha.dmg`
images for Mac can be found on the
[latest release](https://github.com/jcstein/node-app/releases/latest) page.

Download the `.dmg` to your computer, and open it from the downloads folder.
Then, drag the "node-app" icon to the "Applications" folder.

<img width="912" alt="Screenshot 2023-06-03 at 5 36 32 PM" src="https://github.com/jcstein/node-app/assets/46639943/f6241f1f-905a-4096-b24d-f4d8e8375cad">

## Features

v0.1.4-alpha of this app runs on the [Arabica devnet](https://docs.celestia.org/nodes/arabica-devnet/) and has the following functions:

* `Initialize your Celestia light node`: this initializes a Celestia light node in the application's local storage
* `Start your node`: this starts the light node
* `Stop your node`: this stops the light node
* `Check your balance`: this now displays a balance in TIA to 6 decimal places
* `Chain height`: fetches the chain height every 3s

## Xcode project

The Xcode project can be found in [node-app](./node-app/).

## Prerequisites

The current version requires:

* macOS 13.1 or higher
* Macs equipped with M1 or M2 chips (as the `celestia` binary is built specifically for ARM Macs in the alpha versions)

## Application dependencies

* `celestia-node` ("CN") binary version: [v0.11.0-rc2](https://github.com/celestiaorg/celestia-node/releases/tag/v0.11.0-rc2)

### Developer dependencies

* Xcode

## App previews

### Before starting a node

<img width="912" alt="Screenshot 2023-06-03 at 5 19 25 PM" src="https://github.com/jcstein/node-app/assets/46639943/fccc280b-7d79-427f-9d0a-1a2dc255b887">

### A running node

<img width="912" alt="Screenshot 2023-06-03 at 5 19 23 PM" src="https://github.com/jcstein/node-app/assets/46639943/0135adbc-9136-47ec-b9d7-b6eaaa1b7aa9">
