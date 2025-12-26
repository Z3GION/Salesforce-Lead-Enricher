public with sharing class LeadEnrichmentController {

    @AuraEnabled
    public static List<Map<String, String>> fetchNews(String searchTerm) {
        List<Map<String, String>> results = new List<Map<String, String>>();
        Scraper_Log__c log = new Scraper_Log__c(Search_Term__c = searchTerm, Status__c = 'Processing');
        
        try {
            // Real NewsAPI HTTP Callout - MUST happen before DML
            String apiKey = '9069b2d2af38488685d062a8313430a1';
            String endpoint = 'https://newsapi.org/v2/everything?q=' + 
                             EncodingUtil.urlEncode(searchTerm, 'UTF-8') + 
                             '&apiKey=' + apiKey;
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setTimeout(60000);
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                // Parse JSON response
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                String status = (String) responseMap.get('status');
                
                if (status == 'ok') {
                    List<Object> articles = (List<Object>) responseMap.get('articles');
                    
                    for (Object articleObj : articles) {
                        Map<String, Object> article = (Map<String, Object>) articleObj;
                        
                        Map<String, String> articleMap = new Map<String, String>();
                        articleMap.put('title', (String) article.get('title'));
                        articleMap.put('description', (String) article.get('description'));
                        articleMap.put('url', (String) article.get('url'));
                        
                        // Extract source name
                        Map<String, Object> source = (Map<String, Object>) article.get('source');
                        if (source != null) {
                            articleMap.put('source', (String) source.get('name'));
                        } else {
                            articleMap.put('source', 'Unknown');
                        }
                        
                        results.add(articleMap);
                    }
                    
                    log.Status__c = 'Success';
                    log.Results_Count__c = results.size();
                } else {
                    log.Status__c = 'Error';
                    log.Error_Message__c = 'API returned status: ' + status;
                }
            } else {
                log.Status__c = 'Error';
                log.Error_Message__c = 'HTTP ' + res.getStatusCode() + ': ' + res.getStatus();
            }
            
            // Insert log AFTER callout completes
            insert log;
            
        } catch (Exception e) {
            log.Status__c = 'Error';
            log.Error_Message__c = e.getMessage();
            // Use upsert in case log was partially created
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
