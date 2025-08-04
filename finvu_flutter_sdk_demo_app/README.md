# Finvu flutter demo Demo App

This demo application showcases the implementation and flows of the Finvu flutter SDK. It demonstrates account discovery, linking, and consent management functionalities.

## Getting Started

1. **Clone the Repository**: 
   ```bash
   git clone https://github.com/Cookiejar-technologies/finvu-flutter-sdk-demo-app.git
   cd finvu_flutter_sdk_demo_app
   ```

2. **Install Dependencies**: 
   ```bash
   flutter pub get
   ```

3. **Add the username and personal access token of you githu account**: 
   ```gradle
    // Inside finvu-react-native-demo-app/android/build.gradle update the below details 
    maven { 
          url 'https://maven.pkg.github.com/Cookiejar-technologies/finvu_android_sdk' 
          credentials {
              username = "username"
              password = "pat"
          }
    }
   ```

4 **Run and Follow the Sequential Flows**: 
   Navigate through the application from login to consent management.

## Key Flows

### 1. Authentication Flow
- Initial login screen where user enters:
    - Username
    - Mobile number
    - Consent Handle ID
- OTP verification
- On successful verification, user is redirected to main dashboard

### 2. Main Dashboard Flow
- Displays list of linked accounts
- Provides options to:
    - Add new account
    - Process consent
- Fetches and displays all linked accounts in a recycler view

### 3. Account Discovery & Linking Flow
1. Popular Search
    - Displays list of available FIPs (Financial Information Providers)
    - User selects a FIP to proceed

2. Account Discovery
    - User enters mobile number (mandatory)
    - Optional PAN number input
    - Fetches available accounts from selected FIP
    - Shows both unlinked and already linked accounts
    - Allows selection of multiple accounts for linking

3. Account Linking Confirmation
    - OTP verification for selected accounts
    - On successful verification, accounts are linked
    - Redirects back to main dashboard

### 4. Consent Management Flow

#### Pre-defined Consent Handle IDs
For demonstration purposes, the app uses predefined consent handle ID:

#### A. Consent Details Display
- Shows comprehensive consent information:
    - Purpose
    - Data fetch frequency
    - Data usage period
    - Date ranges
    - Account types requested

#### B. Account Selection
- Lists linked accounts
- Allows selection of accounts for consent

#### C. Consent Actions
1. **Multi Consent Flow**
    - Uses a single consent handle ID (index 0) for all selected accounts.
    - Processes all accounts in one API call.
    - Simpler implementation for basic use cases.
    

2. **Reject Consent**
    - Denies the consent request using the first consent handle ID.
    - Cancels the entire consent process.

#### Important Implementation Notes
##### Consent Handle ID Management:

    - Demo uses predefined IDs for simplicity
    - In production, generate new consent handle IDs for each selected account
    - Number of selected accounts must match available consent handle IDs

## Dependencies

The app uses the following Finu react native module:
-  ```
dependencies:
  finvu_flutter_sdk:
    git:
      url: https://github.com/Cookiejar-technologies/finvu_flutter_sdk.git
      path: client
      ref: 1.0.4                                    
  finvu_flutter_sdk_core:
    git:
      url: https://github.com/Cookiejar-technologies/finvu_flutter_sdk.git
      path: core
      ref: 1.0.4
   ```

## Production Considerations
1. Replace hardcoded consent handle ID with dynamically generated ones.
2. Implement proper validation for consent expiry and other parameters.

**Note**: This is a demo application intended to showcase the Finvu react native SDK implementation. For production use, please refer to the official documentation and implement appropriate security measures.