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


    public static Set<Id> getCohabitants(Set<Id> personIds, Set<Id> alreadyProcessed){
        List<String> healthStatuses = new List<String>{'Green', 'Yellow'};        
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c 
                                                    WHERE (Person_1__c IN: personIds OR Person_2__c IN :personIds) 
                                                    AND Contact_Type__c = 'Cohabitant'
                                                    AND (Person_1__r.Health_Status__c IN :healthStatuses OR Person_2__r.Health_Status__c IN :healthStatuses)];

        Set<Id> cohabitants = new Set<Id>();                                            
        for(People_Tracing__c pt : peopleTraces){
            if(!alreadyProcessed.contains(pt.Person_1__c)){
                cohabitants.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }
            if(!personIds.contains(pt.Person_2__c)){
                cohabitants.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }
        return cohabitants;
    }


    public static Set<Id> getNeighbours(Set<Id> personIds, Set<Id> alreadyProcessed){
             
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c 
                                                    WHERE (Person_1__c IN: personIds OR Person_2__c IN :personIds) 
                                                    AND Contact_Type__c = 'Neighbours'
                                                    AND (Person_1__r.Health_Status__c = 'Green' OR Person_2__r.Health_Status__c = 'Green')];

        Set<Id> neighbours = new Set<Id>();                                            
        for(People_Tracing__c pt : peopleTraces){
            if(!alreadyProcessed.contains(pt.Person_1__c)){
                neighbours.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }
            if(!alreadyProcessed.contains(pt.Person_2__c)){
                neighbours.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }
        return neighbours;
    }

    
    public static Set<Id> getPrimaryContacts(Set<Id> personIds, Set<Id> alreadyProcessed){
        List<String> healthStatuses = new List<String>{'Green', 'Yellow'};      
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c 
                                                    WHERE (Person_1__c IN: personIds OR Person_2__c IN :personIds) 
                                                    AND Contact_Type__c = 'Other'
                                                    AND (Person_1__r.Health_Status__c IN :healthStatuses OR Person_2__r.Health_Status__c IN :healthStatuses)
                                                    AND Contact_Date__c = LAST_N_DAYS:10];

        Set<Id> primaryContacts = new Set<Id>();                                            
        for(People_Tracing__c pt : peopleTraces){
            if(!alreadyProcessed.contains(pt.Person_1__c)){
                primaryContacts.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }
            if(!alreadyProcessed.contains(pt.Person_2__c)){
                primaryContacts.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }
        return primaryContacts;
    }

    
    public static Set<Id> getSecondaryContacs(Set<Id> primaryContactsIds, Set<Id> alreadyProcessed){
             
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c 
                                                    WHERE (Person_1__c IN :primaryContactsIds OR Person_2__c IN :primaryContactsIds) 
                                                    AND Contact_Type__c = 'Other'
                                                    AND Contact_Date__c = LAST_N_DAYS:10
                                                    AND (Person_1__r.Health_Status__c = 'Green' OR Person_2__r.Health_Status__c = 'Green')];

        Set<Id> secondaryContacts = new Set<Id>();                                            
        for(People_Tracing__c pt : peopleTraces){
            if(!alreadyProcessed.contains(pt.Person_1__c)){
                secondaryContacts.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }
            if(!alreadyProcessed.contains(pt.Person_2__c)){
                secondaryContacts.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }
        return secondaryContacts;
    }
   
}