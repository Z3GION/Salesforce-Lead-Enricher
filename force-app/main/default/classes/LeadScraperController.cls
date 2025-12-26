public with sharing class LeadScraperController {

    @AuraEnabled
    public static List<Map<String, String>> fetchNews(String searchTerm) {
        List<Map<String, String>> results = new List<Map<String, String>>();
        Scraper_Log__c log = new Scraper_Log__c(Search_Term__c = searchTerm, Status__c = 'Processing');
        
        try {
            insert log;

            // In a real scenario, we would use a Named Credential here.
            // HttpRequest req = new HttpRequest();
            // req.setEndpoint('callout:NewsAPI/everything?q=' + EncodingUtil.urlEncode(searchTerm, 'UTF-8'));
            // req.setMethod('GET');
            // Http http = new Http();
            // HttpResponse res = http.send(req);
            
            // MOCK RESPONSE for Demonstration without API Key
            // Simulating a successful API call
            log.Status__c = 'Success';
            
            Map<String, String> article1 = new Map<String, String>();
            article1.put('title', 'Salesforce Announces New AI Features');
            article1.put('source', 'TechCrunch');
            article1.put('description', 'Salesforce has launched new agentic AI capabilities...');
            article1.put('url', 'https://techcrunch.com/example');
            results.add(article1);
            
            Map<String, String> article2 = new Map<String, String>();
            article2.put('title', 'Market Trends in ' + searchTerm);
            article2.put('source', 'Bloomberg');
            article2.put('description', 'Latest trends show a surge in...');
            article2.put('url', 'https://bloomberg.com/example');
            results.add(article2);

            log.Results_Count__c = results.size();
            update log;
            
        } catch (Exception e) {
            log.Status__c = 'Error';
            log.Error_Message__c = e.getMessage();
            upsert log;
            throw new AuraHandledException('Error fetching news: ' + e.getMessage());
        }

        return results;
    }

    @AuraEnabled
    public static Id createLead(Map<String, Object> leadData) {
        try {
            Lead newLead = new Lead();
            newLead.FirstName = (String) leadData.get('FirstName');
            newLead.LastName = (String) leadData.get('LastName');
            newLead.Company = (String) leadData.get('Company');
            newLead.Description = 'Source URL: ' + (String) leadData.get('SourceUrl');
            
            // Default required fields if missing
            if (String.isEmpty(newLead.LastName)) newLead.LastName = 'Unknown';
            if (String.isEmpty(newLead.Company)) newLead.Company = 'Unknown';
            if (String.isEmpty(newLead.Status)) newLead.Status = 'Open - Not Contacted';

            insert newLead;
            return newLead.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating Lead: ' + e.getMessage());
        }
    }
}
