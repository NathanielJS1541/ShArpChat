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