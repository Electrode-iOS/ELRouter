# ELRouter 

[![Build Status](https://travis-ci.org/Electrode-iOS/ELRouter.svg?branch=master)](https://travis-ci.org/Electrode-iOS/ELRouter)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

**Note:** This framework has been deprecated. It is no longer being actively maintained and will not be updated for future versions of Swift or iOS.

ELRouter.framework. A URL router for UIKit.

## Requirements

ELRouter requires Swift 4, Xcode 9.2, and depends on [`ELFoundation`](https://github.com/Electrode-iOS/ELFoundation).

## Installation

Install by adding `ELRouter.xcodeproj` to your project and configuring your target to link `ELRouter.framework` from `ELRouter` target.
There are two target that builds `ELRouter.framework`.
1. `ELRouter`: Creates dynamicly linked `ELRouter.framework.`
2. `ELRouter_static`: Creates staticly linked `ELRouter.framework`.
