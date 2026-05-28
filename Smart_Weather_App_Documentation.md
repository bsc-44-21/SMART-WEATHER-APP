# SMART WEATHER APP - SYSTEM DOCUMENTATION
**Format:** Formal University Project Documentation

---

## PRELIMINARY PAGES

### Cover Page
**Project Title:** Smart Weather App: An AI-Powered Agricultural Weather and Farm Management System
**Prepared For:** University of Malawi
**Purpose:** Submitted in partial fulfillment of the requirements for the degree
**Student Name:** [Insert Name]
**Student ID:** [Insert ID]

### Abstract
Agriculture remains the backbone of the Malawian economy and a vital sector globally, yet it is significantly impacted by climate variability, pest infestations, and unpredictable weather patterns. The "Smart Weather App" is an AI-powered agricultural mobile application built with Flutter, designed to bridge the gap between hyper-local weather forecasting and actionable farm management. By integrating real-time weather data from the Open-Meteo API, pest and disease detection using the Google Gemini AI API, and GPS-based plot mapping, the system empowers farmers to make precise, data-driven decisions. The app also features digital digital activity logging, robust backend services using Firebase (Authentication and Firestore), and premium subscriptions processed via PayChangu. This documentation outlines the system's analysis, design, implementation, testing, and evaluation, ultimately presenting a comprehensive solution that modernizes agricultural practices and optimizes crop yields.

---

## Chapter 1: Introduction

### 1.1 Background of the Study
Agriculture is a weather-dependent industry. Farmers constantly face the challenge of making daily operational decisions based on incomplete or generalized weather forecasts. With the advent of mobile technology and artificial intelligence (AI), there is an unprecedented opportunity to provide hyper-local, actionable insights directly to farmers. The Smart Weather App represents a convergence of Precision Agriculture and Artificial Intelligence, providing specialized tools like AI-driven recommendations, real-time pest detection, and precise plot mapping. 

### 1.2 Problem Statement
Despite access to generic weather data, farmers often lack actionable intelligence tailored to their specific farm locations and crop types. Generic weather apps do not provide agricultural context, and traditional farming methods lack digital integration for tracking plot activities and identifying diseases in real-time. This leads to suboptimal crop yields, vulnerability to pest outbreaks, and inefficient resource allocation.

### 1.3 Aim of the Project
The primary aim of this project is to develop a comprehensive mobile application that leverages AI and hyper-local weather data to provide farmers with actionable agricultural insights, real-time pest detection, and digital farm management capabilities.

### 1.4 Specific Objectives
1. To develop a cross-platform mobile application using Flutter and Dart.
2. To integrate Open-Meteo API for accurate, real-time, and localized weather forecasting.
3. To implement AI-based agricultural advice and real-time pest detection using Google Gemini AI.
4. To provide GPS-enabled plot management for tracking farm areas and conditions.
5. To develop a digital ledger for farm activity logging and management.
6. To integrate Firebase for secure backend operations and PayChangu for premium subscription processing.

### 1.5 Research Questions
1. How can hyper-local weather data be utilized to optimize daily farming activities?
2. To what extent does the integration of LLM-based AI (like Gemini) improve pest and disease detection in the field?
3. What is the impact of precision plot mapping on resource allocation for smallholder and commercial farmers?

### 1.6 Scope of the System
The system is scoped to provide mobile access on Android and iOS platforms. It covers user authentication, weather retrieval, AI image analysis for pest detection, GPS plot area calculation, digital task logging, and subscription management. It does not control actual hardware (like automated irrigation systems) but focuses on decision-support.

### 1.7 Limitations
- **Internet Dependency**: Real-time weather and AI features require an active internet connection.
- **GPS Accuracy**: Plot mapping is constrained by the accuracy of the mobile device's built-in GPS module.
- **Hardware Integration**: The system operates as software-only and does not integrate with physical IoT farm sensors.

### 1.8 Significance of the Project
This project contributes to the digital transformation of agriculture. For farmers, it minimizes risks associated with erratic weather and pest outbreaks. It modernizes farm management by shifting from paper-based records to a centralized digital ledger. Academically, it serves as a robust case study on integrating LLMs (Gemini) into localized agricultural advisory systems.

---

## Chapter 2: Literature Review

### 2.1 Smart Agriculture Systems
Smart agriculture encompasses the use of ICT, AI, and IoT to optimize farm processes. The literature highlights that digital intervention significantly reduces input waste (water, fertilizer) while increasing total farm output. Systems prioritizing mobile accessibility show the highest adoption rates in developing regions.

### 2.2 Weather Forecasting in Agriculture
Weather data integration is critical for scheduling planting, irrigation, and harvesting. Traditional systems rely on regional forecasts, whereas modern precision agriculture demands hyper-local data. APIs like Open-Meteo allow micro-level precision, leading to better operational foresight.

### 2.3 AI in Farming Systems
AI in agriculture has evolved from simple rule-based expert systems to complex integrations of computer vision and Large Language Models. Leveraging generative AI offers contextual reasoning, translating raw weather metrics into conversational, actionable advice tailored for specific crops.

### 2.4 Pest and Disease Detection Systems
Early detection of crop diseases is paramount. Traditional methods require human experts. Recently, image recognition via neural networks has been employed. This project utilizes the Google Gemini AI, leveraging its multimodal capabilities to analyze images dynamically and provide comprehensive mitigation strategies based on real-world knowledge constraints.

### 2.5 GPS & Precision Agriculture
GPS technology allows for accurate mapping of farm boundaries, essential for estimating fertilizer and seed requirements per hectare. Mobile GPS provides an accessible entry point to precision agriculture without requiring expensive standalone GPS equipment.

### 2.6 Mobile Farming Applications
A review of existing platforms reveals a fragmented market. Most applications specialize in either weather, or disease detection, or record-keeping. There is a lack of cohesive "all-in-one" ecosystems that tie weather data directly into task management and AI analysis.

### 2.7 Existing Systems Review
- **Plantix**: Excels in disease detection but lacks deep integration with weather-driven planning.
- **Climate FieldView**: Highly robust but tailored for large-scale operations with expensive IoT integrations.
- **Generic Weather Apps**: Provide weather but lack the agricultural translation of data.

### 2.8 Research Gap Analysis
The critical gap identified is the lack of cohesive, AI-driven advisory systems that combine localized weather data with pest diagnostics and digital management in a single affordable mobile app footprint suitable for regions like Malawi.

---

## Chapter 3: System Analysis

### 3.1 Existing System Analysis
Current solutions are largely fragmented. Farmers either rely on intuition and general radio broadcasts for weather, use rudimentary notebooks for farm task tracking, and depend on slow extension worker visits for disease diagnosis.

### 3.2 Proposed System
The proposed Smart Weather App consolidates these features. It uses mobile cloud computing (Firebase) securely, aggregates weather data via API (Open-Meteo), processes user input (images, farm stats) through AI (Gemini), and handles local economics via a trusted regional payment gateway (PayChangu).

### 3.3 Functional Requirements
- **FR1:** The system shall authenticate users via Firebase Authentication.
- **FR2:** The system shall fetch and display localized current weather, hourly, and daily forecasts.
- **FR3:** The system shall capture GPS coordinates to map farm plots and calculate hectares.
- **FR4:** The system shall allow users to upload images of crops for AI-based pest/disease diagnosis.
- **FR5:** The system shall provide an interactive digital ledger for farming activities.
- **FR6:** The system shall process secure premium subscriptions through PayChangu to unlock advanced analytics.

### 3.4 Non-functional Requirements
- **Performance:** App screens must load within 3 seconds; API calls should resolve in under 5 seconds.
- **Usability:** The UI must be intuitive, employing standard material/cupertino guidelines with high-contrast accessibility.
- **Reliability:** 99.9% uptime for cloud data synchronization via Firestore.
- **Security:** User data must be encrypted; payment handling must comply with payment provider security standards.

### 3.5 Feasibility Study
- **Technical:** Feasible. Flutter enables cost-effective cross-platform development; Firebase and Gemini APIs are robust and well-documented.
- **Economic:** Feasible. Cloud functions are scalable (pay-as-you-go). Subscriptions can offset server and API costs.
- **Operational:** Feasible. Designed for mobile interfaces recognizable to everyday smartphone users.

### 3.6 Requirement Gathering Techniques
Requirements were gathered through analyzing competitive applications, consulting literature on modern agricultural challenges, and evaluating structural workflow pain points of potential end users.

### 3.7 Business Rules
- A user can register multiple plots but only premium users have unlimited plot registration.
- Pest detection limits apply to free tier users; premium unlocks higher daily request quotas.
- Weather alerts are pushed based on severity indices defined in the logic.

---

## Chapter 4: System Design

### 4.1 System Architecture & High-Level Architecture
The system adopts a modular Client-Server Architecture utilizing serverless BaaS (Backend as a Service). The Flutter frontend communicates with Firebase for authentication and database operations. External integrations (Meteo API, Gemini API, PayChangu) operate as third-party RESTful and SDK-based microservices invoked by the client or serverless cloud functions.

### 4.2 Database Design (Firestore Collections Structure)
Since Firestore is a NoSQL document database, the schema is defined by collections and documents:
- **`users` Collection**: 
  - Fields: `uid`, `email`, `name`, `subscription_status`, `created_at`
- **`plots` Sub-collection** (Under Users):
  - Fields: `plot_id`, `plot_name`, `area_hectares`, `coordinates`, `crop_type`, `date_added`
- **`activity_logs` Sub-collection** (Under Plots/Users):
  - Fields: `activity_id`, `type` (e.g., Planting, Weeding, Harvesting), `description`, `date`, `cost`
- **`disease_scans` Collection**:
  - Fields: `scan_id`, `user_id`, `image_url`, `ai_diagnosis`, `recommendation`, `timestamp`

*Note: For the documentation report, you will include standard visual artifacts here like an ER schema representing these collections.*

### 4.3 UML Diagrams Overview (Placeholders for student creation)
- **Use Case Diagram:** Shows Actors (Farmer, System, Admin) interacting with use cases (View Weather, Map Plot, Scan Crop, Upgrade to Premium).
- **Sequence Diagram:** Depicts the flow. Example: User initiates Pest Scan -> App sends Image to Gemini API -> Gemini Returns JSON -> App displays data and logs to Firestore.
- **Activity Diagram:** Outlines the logical step-by-step decision pathway for calculating a farm plot perimeter using GPS.
- **DFD (Data Flow Diagram):** Shows the data transformation from Weather API metrics into natural language "farming advice" via AI.
- **UI/UX Wireframes:** Draft screens mapped to app implementations (Plots Screen, User Dashboards).

---

## Chapter 5: System Implementation

### 5.1 Flutter + Dart Implementation
The client application is built with the Flutter framework. State management is handled by Provider, isolating UI code from business logic. The user interface leverages customized Widgets tailored for an agricultural aesthetic.

### 5.2 Firebase Authentication
Implemented using `firebase_auth` package spanning Email/Password. Ensures user sessions are securely managed.

### 5.3 Firestore Database Integration
Using the `cloud_firestore` package, offline caching is enabled so farmers can view their plots and activity logs even when network connectivity drops in rural areas.

### 5.4 Open-Meteo Weather API Integration
An HTTP Client constructs GET requests to the Open-Meteo REST API utilizing the latitude and longitude of the user's mapped plots, retrieving specific json nodes (`temperature_2m`, `precipitation_probability`, `windspeed_10m`).

### 5.5 GPS Plot Location Capture
The `geolocator` and `google_maps_flutter` packages capture real-time geofencing perimeters. A computational geometry algorithm calculates the enclosed polygon area to derive the exact hectare footprint.

### 5.6 Weather-Based Farming Advice Logic
Algorithms parse incoming weather JSON (e.g., consecutive days of 0mm precipitation combined with high temperatures) to trigger automated drought warnings and optimal irrigation scheduling.

### 5.7 Pest & Disease Detection using Gemini AI
Integration with Google's generative AI involves encoding images to base64 or sending image bitstreams alongside a crafted prompt: *"Analyze this leaf image. Identify any pests or diseases and recommend an agricultural mitigation strategy."*

### 5.8 Alerts and Notifications
Firebase Cloud Messaging (FCM) is utilized for delivering push notifications relating to severe weather changes or scheduled farm activities.

### 5.9 Premium Subscription using PayChangu
Integration via the PayChangu API/SDK. Webhooks handle transaction verification logic. Upon successful transaction, User Firestore document flags `is_premium = true`.

---

## Chapter 6: Testing and Evaluation

### 6.1 Unit Testing
Individual Dart functions, specifically the algorithm calculating polygon area (hectares) and the JSON parser formatting weather data, underwent parameter-based unit testing.

### 6.2 Integration Testing
Ensured that API modules successfully communicate. Tested the transition state between Firebase Auth logins validating against Firestore user setups.

### 6.3 System Testing
End-to-end testing performed on physical Android and iOS devices mimicking a farmer's full workflow: Registering -> Adding Plot via GPS -> Checking Weather -> Scanning Fake diseased leaf -> Adding Log.

### 6.4 Security Testing
Evaluated Firestore security rules to ensure users can only read/write documents restricted to their `uid`. Assessed API keys (Gemini, Open-Meteo, PayChangu) ensuring they are properly hidden in the environment (`.env`) system mapping.

### 6.5 Usability Testing
Beta testing with agricultural workers highlighted the need for larger typography and distinct offline capabilities, leading to UX iterations improving navigation flows.

### 6.6 Performance Testing
Simulated slow 3G network conditions (common in rural areas) to measure application response. Added loading skeletons and image compression to prevent UI locking.

---

## Chapter 7: Security and Audit

### 7.1 Authentication Security
Stringent password policies and token validation on the Firebase backend protect user identity. Sessions correctly expire, and state persistence relies on encrypted secure storage on iOS/Android.

### 7.2 Data Security
In-transit data relies on HTTPS/SSL. Data at rest in Firestore is encrypted by Google's backend.

### 7.3 API Security
Keys for third-party services are secured through Flutter `.env` configuration and backend proxy functions, preventing malicious key scraping from the frontend codebase.

### 7.4 User Access Control & Premium Restrictions
Route guarding ensures premium pages are locked. Subscriptions are verified server-side to prevent client app tampering.

### 7.5 Audit Trail Logging
System captures diagnostic events and user state changes for monitoring platform health and troubleshooting bug errors effectively.

---

## Chapter 8: Project Management

### 8.1 9-week Milestones
- **Week 1-2:** Requirement analysis, UI Wireframing, System Architecture setup.
- **Week 3-4:** Frontend Flutter UI implementation, Firebase backend initialization.
- **Week 5-6:** API Integrations (Open-Meteo, Gemini AI) and GPS functional mapping.
- **Week 7:** PayChangu integration, Subscription logic, and local database syncing.
- **Week 8:** System testing, debugging, UI refining.
- **Week 9:** Documentation gathering, manual compilation, project defense prep.

### 8.2 Team Responsibilities
(Project lead outlines design, backend, frontend tasks based on individual strengths if in a group, or delineates time management if working solo.)

### 8.3 Risk Management
- *Risk:* API downtime. *Mitigation:* Fallback mechanisms and cached data structures.
- *Risk:* GPS inaccuracy on cheap phones. *Mitigation:* Allowing manual correction markers on the map.

---

## Chapter 9: Conclusion and Recommendations

### 9.1 Summary
The Smart Weather App bridges the gap between sophisticated data and the everyday farmer. By unifying weather forecasting, AI diagnostics, and robust farm management, it successfully digitizes crucial farming practices.

### 9.2 Achievements
The project successfully implemented a cross-platform architecture that correctly maps farm perimeters, accurately forecasts weather dependencies, analyzes plant diseases via AI, and monetizes sustainably through PayChangu.

### 9.3 Challenges
Challenges encountered included device-dependent compass/GPS calibration anomalies during testing and the prompt-engineering constraints required to get consistent JSON-styled responses from the Gemini AI. 

### 9.4 Recommendations
Institutions should push for integrations connecting such software natively with the Ministry of Agriculture’s national databases to feed larger predictive crop yield models. 

### 9.5 Future Improvements
Future iterations should introduce:
- Offline-first localized Machine Learning models (TensorFlow Lite) to reduce reliance on Gemini APIs in highly remote areas.
- Community forums connecting neighboring farmers for agricultural exchange.
- IoT integrations connecting to smart soil moisture sensors.

---

## References
1. Documentation for Flutter: https://flutter.dev/docs
2. Firebase Documentation: https://firebase.google.com/docs
3. Open-Meteo API Guidelines: https://open-meteo.com
4. Google Gemini API Best Practices for Multi-Modal AI.
5. precision Agriculture Journal articles regarding GPS plotting methodologies.

---

## Appendices
*(Note: To complete the physical document, generate and paste the following items in this section)*
- **Appendix A:** Screenshots of User Interface (Login, Weather View, Gemini Diagnosis)
- **Appendix B:** API Endpoint sample queries (Open-Meteo GET parameters)
- **Appendix C:** Sample Weather logical threshold sets 
- **Appendix D:** Core code snippets for `geolocator` logic and `Gemini REST` calls.
