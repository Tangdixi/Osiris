# Osiris
Osiris is a image processing library using Metal 2, written in Swift

* [Features](#Features)
* [Usage](#Usage)
* [More](#More)
* [Lisence](#Lisence)

## Features

There is lots of work to do ... 👀

- [x] Image rendering
- [x] Image processing
  - [x] Chain filters
  - [ ] Transform
  - [ ] More built-in filters
- [x] Live camera processing
- [ ] Video processing
  - [ ] Format converting
  - [ ] Video playing
- [ ] OpenGL support

## Usage

Osiris prefer dot(.) syntax 🖖

### Image rendering

Create an instance from `Osiris`

```Swift
// Non-traisient object
let processor = Osiris(label: "My image processor")
```

For rendering an image, we need an  `MTKView` first:

```Swift
let metalView = MTKView()
// rendering
let image = UIImage(named: "originImage")
processor.processImage(image).presentOn(metalView)	
```

### Filters

First, we need some filters:

```Swift
// Non-traisient object
//
// Create a filte
let reverse = Filter(kernalName: "reverseKernal")
let luma = Filter(kernalName: "lumaKernal")
```

then add them to the processor

```swift
// Non-traisient object
let processor = Osiris(label: "My video processor")
processor.addFilters([reverse, luma])	
```

Last we use it for processing images then present it

## More

Open an [issue](https://github.com/Tangdixi/Osiris/issues/new) when you need 👍

## License

Osiris is released under the MIT license. [See LICENSE](https://github.com/Tangdixi/Osiris/blob/master/LICENSE) for details.