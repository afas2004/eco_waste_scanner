# EcoScan

A Flutter app that uses your phone's camera and an on-device image classification model to identify what an item is, to help with sorting waste for recycling.

## Screenshots

| Homepage | Scan | History |
| :---: | :---: | :---: |
| <img width="300" alt="image" src="https://github.com/user-attachments/assets/c005d298-de01-4d94-a305-7c98574033c6" /> | <img width="300" alt="image" src="https://github.com/user-attachments/assets/7920e02a-dd5b-4722-8fe2-9e4b1078ba6b" /> | <img width="300" alt="image" src="https://github.com/user-attachments/assets/3b504abd-0283-4ec4-ae19-c72df1ecf858" /> |

## Features

- **Live camera scanning** — point the camera at an item and classify it on the spot, fully on-device
- **Scan history** — past scans are saved locally with the result, confidence score, and date
- **Light and dark theme**

## Tech stack

Flutter · `camera` for capture · `flutter_tflite` (TensorFlow Lite) for on-device classification · `shared_preferences` for local history and theme

## Getting started

```bash
git clone https://github.com/afas2004/eco_waste_scanner.git
cd eco_waste_scanner
flutter pub get
flutter run
```

Needs a physical device with a camera — TFLite camera classification generally doesn't work well on a simulator/emulator.

## Known limitations

- The bundled model is a general-purpose MobileNet image classifier, not one trained on waste categories, so results are the model's raw object label (for example "water bottle") rather than a Plastic/Paper/Glass/Metal/Cardboard classification. Swapping in a model fine-tuned on those five categories would get the app closer to the "sorts your waste" pitch in the repo description.
