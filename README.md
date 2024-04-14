# ShArpChat
An [arpchat](https://github.com/kognise/arpchat) library written in C#.

The main goal of this library is to implement the functionality of [arpchat](https://github.com/kognise/arpchat) in C# in a MAUI library, so that it can be used with a cross-platform MAUI GUI.

## Related Projects
- [arpchat](https://github.com/kognise/arpchat), the main inspiration for this project.
- [ShArpChat.Gui](https://github.com/NathanielJS1541/ShArpChat.Gui), the MAUI GUI frontend for this library.
- Possibly a TUI coming soon?

## Repository Structure
```
ShArpChat/                   - Main repository folder
├── docs/                    - Library documentation
│   └── api/                 - API documentation
├── src/
│   ├── ShArpChat/           - ShArpChat MAUI library root folder
│   │   ├── Platforms/       - Platform specific code
│   │   │   ├── Android/
│   │   │   ├── iOS/
│   │   │   ├── MacCatalyst/
│   │   │   └── Windows/
│   │   └── ShArpChat.csproj - ShArpChat MAUI library project file
│   └── ShArpChat.sln        - Main library solution file
├── tests/                   - Library unit tests
└── utils/                   - Utility scripts
```

## Inspiration
I wanted an excuse to use MAUI for something... Yeah that's pretty much it.

## Notes
### Platform Compatability
While I will do my best to keep the library and app as cross-platform as possible, Apple's toolchain restrictions effectively mean I won't be able to build the app at all for iOS / MacCatalyst. Therefore I will not be able to do any testing for Apple's platforms. If you'd like those platforms to work you can fix them and PR the work yourself if you have the hardware for it :).