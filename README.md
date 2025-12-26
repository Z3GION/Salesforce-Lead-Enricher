# ⚡ Salesforce Lead Enricher
A real-time lead generation tool built with **Apex**, **LWC**, and **NewsAPI**.

## 🚀 Features
- **Live News Fetching:** Integrated with NewsAPI.org to pull trending business news.
- **One-Click Lead Creation:** Seamlessly convert news articles into Salesforce Leads.
- **Audit Logging:** Custom `Scraper_Log__c` object to track API activity and errors.
- **Secure Configuration:** API keys stored in Custom Metadata (GitHub-safe).
- **Agentic Dev Flow:** Developed using **Google Antigravity** & **Gemini 2.0 Flash Thinking**.

## 🛠️ Technical Stack
- **Apex:** HTTP Callouts, JSON Parsing, DML Transaction Management.
- **LWC:** Reactive UI, SLDS (Salesforce Lightning Design System).
- **CLI:** Salesforce DX (SFDX) for metadata deployment.

## 📦 Project Structure
```
salesforce/
├── force-app/main/default/
│   ├── classes/
│   │   ├── LeadEnrichmentController.cls
│   │   └── LeadEnrichmentController.cls-meta.xml
│   ├── lwc/leadEnricher/
│   │   ├── leadEnricher.html
│   │   ├── leadEnricher.js
│   │   ├── leadEnricher.js-meta.xml
│   │   └── leadEnricher.css
│   └── objects/Scraper_Log__c/
│       ├── Scraper_Log__c.object-meta.xml
│       └── fields/
│           ├── Search_Term__c.field-meta.xml
│           ├── Results_Count__c.field-meta.xml
│           ├── Status__c.field-meta.xml
│           └── Error_Message__c.field-meta.xml
└── sfdx-project.json
```

## 🔧 Setup Instructions

### Prerequisites
- Salesforce CLI installed (`npm install -g @salesforce/cli`)
- Salesforce Org (Sandbox/Playground/Developer Edition)
- NewsAPI.org API Key

### Deployment Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd salesforce
   ```

2. **Authenticate with your Salesforce Org**
   ```bash
   sf org login web --instance-url https://test.salesforce.com --set-default
   ```

3. **Configure Custom Metadata for API Key**
   - In Salesforce Setup, search for **Custom Metadata Types**
   - Create a new type: `App_Setting` (API Name: `App_Setting__mdt`)
   - Add a custom field: `Value` (API Name: `Value__c`, Type: Text)
   - Create a record named `NewsAPI_Key` with your NewsAPI.org API key in the `Value__c` field

4. **Deploy the metadata**
   ```bash
   sf project deploy start --metadata ApexClass:LeadEnrichmentController LightningComponentBundle:leadEnricher
   ```

5. **Configure Remote Site Setting**
   - Go to **Setup** → **Remote Site Settings**
   - Click **New Remote Site**
   - **Remote Site Name:** `NewsAPI`
   - **Remote Site URL:** `https://newsapi.org`
   - **Active:** ✅ Check

6. **Add the component to a Lightning page**
   - Go to any App Builder page
   - Drag the **Lead Enricher** component onto the page
   - Save and activate

## 🎯 Usage

1. Enter a search term (e.g., "Technology", "AI", "Finance")
2. Click **Search News**
3. Browse the news article cards
4. Click **Create Lead** on any article to generate a Lead record

## 📊 Features Deep Dive

### Modern UI
- **Box shadows** with hover effects for depth
- **Source badges** with color-coded styling
- **Bold headlines** for visual hierarchy
- **Empty state** with SLDS illustration and friendly messaging

### Error Handling
- DML operations execute after HTTP callouts (Salesforce best practice)
- Comprehensive error logging in `Scraper_Log__c`
- User-friendly toast notifications

### Security
- **No hardcoded secrets:** API keys retrieved from Custom Metadata Type
- **GitHub-safe:** Source code contains no sensitive credentials
- **Org-level configuration:** Each Salesforce org stores its own API key

### Audit Trail
All searches are logged in the `Scraper_Log__c` custom object with:
- Search term
- Results count
- Status (Success/Error)
- Error messages (if any)

## 🤖 Development Notes

This project was developed using **Google Antigravity** with **Gemini 2.0 Flash Thinking**, demonstrating:
- Agentic code generation
- Real-time API integration
- Salesforce best practices
- Modern Lightning Web Component patterns
- Security-first design (Custom Metadata for secrets)

## 📝 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- **NewsAPI.org** for providing the news data API
- **Salesforce** for the Lightning platform
- **Google Antigravity** for agentic development capabilities
