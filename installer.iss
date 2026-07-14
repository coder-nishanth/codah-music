[Setup]
AppId={{CODAH-MUSIC-2024}}
AppName=Codah Music
AppVersion=2.0.1
AppPublisher=coder-nishanth
DefaultDirName={autopf}\Codah Music
DefaultGroupName=Codah Music
OutputDir=C:\Users\Nishanth JP\Desktop
OutputBaseFilename=Codah Music v2.0.1 Setup
Compression=lzma2
SolidCompression=yes
SetupIconFile=C:\Users\Nishanth JP\Desktop\codah-music\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\codah-music.exe
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "C:\Users\Nishanth JP\Desktop\codah-music\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Codah Music"; Filename: "{app}\codah-music.exe"
Name: "{autodesktop}\Codah Music"; Filename: "{app}\codah-music.exe"

[Run]
Filename: "{app}\codah-music.exe"; Description: "Launch Codah Music"; Flags: nowait postinstall skipifsilent
