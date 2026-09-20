; RAG-only per-user installer. Does not set CREXX_HOME or touch CREXX's install.
Unicode true
RequestExecutionLevel user
SetCompressor /SOLID lzma
ManifestDPIAware true
!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "x64.nsh"
!include "WinMessages.nsh"

!ifdef RAG_SIGN_HELPER
  !system '"${RAG_SIGN_HELPER}" --nsis-plugins "${NSISDIR}/Plugins/x86-unicode" "${RAG_SIGNED_PLUGINS}"' = 0
  !addplugindir /x86-unicode "${RAG_SIGNED_PLUGINS}"
  !uninstfinalize '"${RAG_SIGN_HELPER}" "%1"' = 0
!endif

Name "cREXX-RAG ${RAG_VERSION}"
OutFile "${RAG_OUTPUT}"
InstallDir "$LOCALAPPDATA\Programs\crexxrag"
InstallDirRegKey HKCU "Software\crexxrag" "InstallDir"
VIProductVersion "${RAG_FILE_VERSION}"
VIAddVersionKey "ProductName" "cREXX-RAG"
VIAddVersionKey "FileDescription" "cREXX-RAG Windows x64 Installer"
VIAddVersionKey "FileVersion" "${RAG_VERSION}"
VIAddVersionKey "LegalCopyright" "cREXX-RAG contributors"
!define MUI_ABORTWARNING
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"

Function .onInit
  ${IfNot} ${RunningX64}
    MessageBox MB_ICONSTOP "cREXX-RAG requires 64-bit Windows."
    Abort
  ${EndIf}
  SetRegView 64
FunctionEnd

Function un.onInit
  SetRegView 64
FunctionEnd

; Registry API preserves long PATH values and their original representation.
; The directory is environment data, never PowerShell source interpolation.
!macro UpdatePath ACTION
  System::Call 'kernel32::SetEnvironmentVariable(t "RAG_INSTALL_BIN", t "$INSTDIR\bin")'
  System::Call 'kernel32::SetEnvironmentVariable(t "RAG_PATH_ACTION", t "${ACTION}")'
  nsExec::ExecToStack `"$WINDIR\Sysnative\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "$INSTDIR\share\crexxrag\installer\update-user-path.ps1"`
  Pop $0
  Pop $1
  System::Call 'kernel32::SetEnvironmentVariable(t "RAG_INSTALL_BIN", p 0)'
  System::Call 'kernel32::SetEnvironmentVariable(t "RAG_PATH_ACTION", p 0)'
  ${If} $0 != 0
    DetailPrint "PATH update failed: $1"
    SetErrorLevel 1
    Abort
  ${EndIf}
  SendMessage ${HWND_BROADCAST} ${WM_SETTINGCHANGE} 0 "STR:Environment" /TIMEOUT=5000
!macroend

Section "cREXX-RAG"
  SetOutPath "$INSTDIR"
  File /r "${RAG_PAYLOAD}\*"
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  WriteRegStr HKCU "Software\crexxrag" "InstallDir" "$INSTDIR"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\crexxrag" "DisplayName" "cREXX-RAG ${RAG_VERSION}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\crexxrag" "DisplayVersion" "${RAG_VERSION}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\crexxrag" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\crexxrag" "QuietUninstallString" '"$INSTDIR\Uninstall.exe" /S'
  !insertmacro UpdatePath add
SectionEnd

Section "Uninstall"
  !insertmacro UpdatePath remove
  !include "${RAG_UNINSTALL_FILES}"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir "$INSTDIR"
  DeleteRegKey HKCU "Software\crexxrag"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\crexxrag"
SectionEnd
