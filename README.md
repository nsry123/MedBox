## Medbox

This project aims to provide a highly manageable medicine intake regulator for those in need. Users can register their required medicine easily and get daily notifications at desired times. During medicine registration, users can use multiple images of the medicine container as input. Through using OCR to extract disordered texts and GPT to summarize the key properties in given order, the application provides assitance to those with difficulties mannually registering the medicine. Based on interview results, many senoir citizens actually prefer a stand-alone device that would reliably yield alarms and notifications. Thus, I constructed [MedMinder](https://github.com/nsry123/MedMinder), a portable notifier for medicine intake based on ESP32 that can synchronise with the MedBox application.

## Quick Start
1. Clone this repositor
```bash
git clone https://github.com/nsry123/MedBox
```
2.  Build and run using flutter (latest stable channel required)

```bash
flutter run --profile
```
