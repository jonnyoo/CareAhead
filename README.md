# CareAhead

A native iOS health-monitoring app that uses your phone's front-facing camera to measure vital signs in real time, then leverages AI to deliver personalized health insights — all without wearables.

Built at **DeltaHacks**.

---

## Features

- **Camera-Based Vital Scanning** — Uses the SmartSpectra rPPG SDK to capture heart rate and breathing rate from a 20-second face scan via the front camera. No wearable hardware required.
- **AI Health Insights** — Sends today's vitals plus historical baselines to Google Gemini (gemini-2.5-flash), which returns a structured, personalized insight report covering heart rate trends, breathing patterns, and actionable suggestions.
- **Risk Score** — Computes a 1–100 risk score by measuring how far today's readings deviate from the user's personal normal band (15th–85th percentile over the last 30–60 days).
- **7-Day Trends** — Interactive Swift Charts showing heart rate, breathing rate, and stress over the past week, with tap-to-expand detail views and trend summaries.
- **Healthcare Map** — MapKit-powered search for nearby hospitals, clinics, urgent care, and pharmacies with distance display, one-tap directions, calling, saving, and sharing.
- **Family Sharing** — Share health updates with family contacts and view their heart rate trends and mood indicators.

## Tech Stack

| Layer | Technology |
|---|---|
| **iOS App** | SwiftUI, SwiftData, Swift Charts, MapKit, CoreLocation, AVFoundation |
| **Vital Signs SDK** | SmartSpectra Swift SDK (remote photoplethysmography) |
| **AI** | Google Gemini API (gemini-2.5-flash) |
| **Backend** | Node.js, Express.js, MongoDB / Mongoose |
| **Auth** | JWT, bcrypt |
| **Deployment** | AWS Lambda via Serverless Framework |


## Setup

### iOS App

1. Open `CareAhead.xcodeproj` in Xcode.
2. Create a `Secrets.xcconfig` file with your API key:

GEMINI_API_KEY = your_gemini_api_key_here

3. Build and run on a physical iOS device (camera required).

### Backend

1. `cd serverless_cloud_deployment/Express-Backend`
2. `npm install`
3. Create a `.env` file:

MONGODB_URI=your_mongodb_connection_string 
jwt_secret=your_jwt_secret

4. `npm run dev` for local development, or `npx serverless deploy` for AWS Lambda.

## Disclaimer

CareAhead is not a replacement for medical professionals. It is a basic tool for personal health awareness. All AI-generated insights include a "Not medical advice" disclaimer.
