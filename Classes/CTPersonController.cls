public with sharing class CTPersonController {
    public CTPersonController() {

    }

    public static String getToken(String mobile) {
        //generate unique hash using md5 algorithm
        Blob targetBlob = Blob.valueOf(mobile);
        Blob hash = Crypto.generateDigest('MD5', targetBlob);

        // returns string value of hash blob
        return EncodingUtil.base64Encode(hash);
    }

    public static List<Person__c> getRecentHealthChanges() {
        List<Person__c> peopleChanges = [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c
                                             FROM Person__c ORDER BY Status_Update_Date__c DESC LIMIT 100];

        return peopleChanges;
    }

    public static List<Person__c> searchPeople(String searchTerm) {
        //appending the wildcard is useful since the user could get the result/s without having to write the whole searchTerm
        //searchTerm = searchTerm.toLowerCase();
        if(String.isEmpty(searchTerm)){
            return null;
        } else{
            searchTerm = searchTerm + '%';
            List<Person__c> searchPeople = [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c FROM Person__c 
                                            WHERE Name LIKE :searchTerm OR Mobile__c LIKE :searchTerm OR Token__c LIKE :searchTerm 
                                            ORDER BY Status_Update_Date__c DESC];
            return searchPeople;
        }      
    }

    public static Person__c getPersonById(String personId){
        List<Person__c> findPerson = [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c
                                    FROM Person__c WHERE Id=:personId];
        if(findPerson != null && findPerson.size()>0){
            return findPerson[0];
        } else {
            return null;
        }
    }

    public static Map<String, Integer> getHealthStatusCount() {

        Map<String, Integer> healthStatusCount = new Map<String, Integer>();
        AggregateResult [] countPeople = [SELECT Health_Status__c, COUNT(Id) countStatus FROM Person__c GROUP BY Health_Status__c];

        if(countPeople != null && countPeople.size()>0){
            for(AggregateResult agg : countPeople){
                String status = String.valueOf(agg.get('Health_Status__c'));
                Integer count = Integer.valueOf(agg.get('countStatus'));
                if(!healthStatusCount.containsKey(status)){                   
                    healthStatusCount.put(status, count);
                }
              }
            
        }
        return healthStatusCount; 

    }
    
}