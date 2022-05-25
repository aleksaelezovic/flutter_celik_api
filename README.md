# flutter_celik_api

A Flutter plugin for reading Serbian ID Cards. Works on Windows/Linux/MacOS.
Written from scratch (APDU Commands).  

Connection to card-reader is done through `flutter_pcsc` but you may use your own custom provider.

## Usage

### Pre-requisite  
`flutter_pcsc` needs:  

- A PCSC smartcard reader.

 - On linux, `pcscd` & `libpcsclite1` needs to be installed.

 - For macOS application to be able to use smartcard, the following entitlement should be set: `com.apple.security.smartcard` (in DebugProfile.entitlements & Release.entitlements files).   
 If not set correctly, the context won't be able to be established.  


### Example
``` dart

CelikAPIAllData result = await CelikAPI().readAllData();
print(result.data); 
print(result.image); // base64

```