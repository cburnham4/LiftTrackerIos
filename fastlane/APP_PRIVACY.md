# App Privacy nutrition labels (Lift Tracker)

Live App Store listing currently shows **Data Not Collected**, which is incorrect: the app uses **Firebase Auth / Realtime Database** (account + lift sync) and **Google AdMob** (banner ads).

## In this repo

| File | Purpose |
| --- | --- |
| `fastlane/app_privacy_details.json` | Source-of-truth answers for ASC Privacy Nutrition Labels (Firebase + AdMob) |
| `fastlane/metadata/en-US/privacy_url.txt` | Privacy policy URL (`http://letshang.us/html/lhprivacypolicy.html`) |
| `fastlane/metadata/en-US/description.txt` | Listing copy that mentions cloud sync + ads honestly |

## Applying labels in App Store Connect

`deliver` / `submit_lift_tracker` **does not** upload Privacy Nutrition Labels.

fastlane’s `upload_app_privacy_details_to_app_store` can upload `app_privacy_details.json`, but it requires an **Apple ID with Owner/Admin** (not an App Store Connect API key).

```sh
fastlane run upload_app_privacy_details_to_app_store \
  username:"cburnhamiv@gmail.com" \
  app_identifier:"letshang.Lift-Tracker" \
  json_path:"fastlane/app_privacy_details.json"
```

Or paste the same categories manually in **App Store Connect → App Privacy** (no binary resubmit required for label-only changes).

## Declared categories (summary)

| Category | Why | Linked / tracking |
| --- | --- | --- |
| User ID, Email, Name | Firebase Auth / Google Sign-In | Linked to you · App Functionality |
| Other User Content, Fitness | Lift sets / routines in RTDB | Linked to you · App Functionality |
| Device ID, Advertising Data | AdMob | Not linked · Used to Track You · Third-Party Advertising |
| Product Interaction | AdMob / analytics signals | Not linked · Advertising / Analytics |

Review AdMob’s current disclosure guidance before upload and adjust JSON if SDK behavior changes.
