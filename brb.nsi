UniCode true

# define name of installer
OutFile "../brb-installer.exe"
 
# define installation directory
!define APPNAME "brb"
InstallDir "$PROGRAMFILES64\${APPNAME}\"

!define LICENSE_TITLE "MIT License"
PageEx license
    licensetext "${LICENSE_TITLE}"
    licensedata "LICENSE.md"
PageExEnd
Page instfiles

# Include the logic library for checking file exists.
!include LogicLib.nsh

# For removing Start Menu shortcut in Windows 7
RequestExecutionLevel admin

!include i2p-zero.nsi

# start default section
Section
    Exec 'CheckNetIsolation.exe LoopbackExempt -a -n="Microsoft.Win32WebViewHost_cw5n1h2txyewy"'
    # set the installation directory as the destination for the following actions
    Call buildZero
    Call installZero
    SetOutPath $INSTDIR
    File brb.exe
    File WebView2Loader.dll
    File webview.dll
    File README.md
    File LICENSE.md
    File config.json
    File /a /r ".\content\"
    File /a /r ".\built-in\"

    # create the uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"

    # create a shortcut named "new shortcut" in the start menu programs directory
    # point the new shortcut at the program uninstaller
    CreateShortcut "$SMPROGRAMS\Chat with brb.lnk" "$INSTDIR\brb.exe"
    CreateShortcut "$SMPROGRAMS\Uninstall brb Chat.lnk" "$INSTDIR\uninstall.exe"
SectionEnd
 
# uninstaller section start
Section "uninstall"

    # first, delete the uninstaller
    Delete "$INSTDIR\uninstall.exe"
    RmDir "$INSTDIR\"

    # second, remove the link from the start menu

    Delete "$SMPROGRAMS\Chat with brb.lnk"
    Delete "$SMPROGRAMS\Uninstall brb Chat.lnk" "$INSTDIR\uninstall.exe"

    Call un.installZero

    RMDir $INSTDIR
# uninstaller section end
SectionEnd