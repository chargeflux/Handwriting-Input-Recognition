# Handwriting Input Recognition
Handwriting Input Recognition is a Swift app that allows the user to draw characters from a specified language and present the character in a text field. Character recognition is based on Tesseract OCR.

## Compilation
1) Launch `Handwriting Input Recognition.xcodeproj`
2) Add your signing certificate under the Target **Handwriting Input Recognition** → **General** → **Signing**
3) Build

## Usage
1) Draw character in bottom canvas
2) Press `Enter` to start OCR or `Escape` to clear canvas
3) Choose the character that best matches your intended input above the canvas
4) Continue to draw if results don't match and press `Enter` to perform OCR again
5) Hold down `C` to copy the results in the text field to clipboard
6) Hold down `Escape` to reset the app

## TODO
1) Dynamically update possible character options as user draws
2) Multiple character input + recognition
3) Overlays for function running (Copied, Cleared etc) 
4) Add more languages
5) Specify language (Currently recognition language is set to Japanese)
6) Improve UI

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## Libraries Used
- Tesseract (v3.05.01)
    - [Tesseract macOS](https://github.com/scott0123/Tesseract-macOS) by [scott0123](https://github.com/scott0123)
- Leptonica (v1.75.3)
    - LibPNG (v1.6.34)
    - LibTIFF (v4.0.9)
    - LibJPEG (v9c)
    - LibZ (v1.2.11)

## License
[MIT](./LICENSE.txt)