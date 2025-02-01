# zig-app

## Overview
This is just a little fun project that i tried in zig. :D

## Supported Algorithms
- **rot13**
- **reverse**
- **upper**
- **sha256**
- **sha512**
- **blake256**

## Usage
Run the application:
```
./zigenc <input> [--algo|-a <algorithm>]
```
To see supported algorithms, use:
```
./zigenc --list
```

## Building and Testing
Build the project:
```bash
zig build
```
Run the application:
```bash
zig build run -- <input> [--algo|-a <algorithm>]
```
Run tests:
```bash
zig build test
```
