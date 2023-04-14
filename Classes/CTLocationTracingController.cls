public with sharing class CTLocationTracingController {
    public CTLocationTracingController() {

    }
    

    public static List<Location_Tracing__c> getVisitors (String locationId) {
        List<Location_Tracing__c> locations = [SELECT Id, Person__c, Location__c, Visit_Date__c, Person__r.Token__c, Person__r.Health_Status__c
                                                    FROM Location_Tracing__c WHERE Id =:locationId ORDER BY Visit_Date__c DESC];
        return locations;
    }


    public static List<Location_Tracing__c> getLocationsByPersonIds(Set<Id> personIds) {
        
       // Date parameter = Date.today() - 10;
        List<Location_Tracing__c> getlocByPersId = [SELECT Id, Person__c, Location__c, Visit_Date__c
                                                        FROM Location_Tracing__c 
                                                            WHERE Person__c IN :personIds AND Visit_Date__c= LAST_N_DAYS:10 ] ;
        return getlocByPersId;
    }


    public static List<Location_Tracing__c> getLocationsByLocationIds(Set<Id> locationIds) {
        
        Date parameter = Date.today() - 10;
        List<Location_Tracing__c> getlocByLocId = [SELECT Id, Person__c, Location__c, Visit_Date__c, Person__r.Health_Status__c
                                                    FROM Location_Tracing__c 
                                                        WHERE Location__c IN :locationIds AND Person__r.Health_Status__c='Green' AND Visit_Date__c= LAST_N_DAYS:10];
        return getlocByLocId;
    }


    public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> locationTraces){

        Set<Id> locationIds = new Set<Id>();
        Set<Id> personIds = new Set<Id>();
        Map<Id, Set<Id>> mapOfExistingRecords = new Map<Id,Set<Id>>();

        for(Location_Tracing__c trace : locationTraces){
            locationIds.add(trace.Location__c);
            personIds.add(trace.Person__c);
        }

        List<Location_Tracing__c> existingRecords = [SELECT Id, Person__c, Location__c FROM Location_Tracing__c
                                                        WHERE Location__c IN :locationIds
                                                        AND Person__c IN :personIds];

        List<Location_Tracing__c> duplicates = new List<Location_Tracing__c>();

        if(existingRecords != null && existingRecords.size()>0){
            for(Location_Tracing__c trace : existingRecords){
                if(! mapOfExistingRecords.containsKey(trace.Location__c)){
                    mapOfExistingRecords.put(trace.Location__c, new Set<Id>());
                }
                mapOfExistingRecords.get(trace.Location__c).add(trace.Person__c);
            }

            for(Location_Tracing__c trace : locationTraces){                
                if(mapOfExistingRecords.containsKey(trace.Location__c) 
                    && mapOfExistingRecords.get(trace.Location__c).contains(trace.Person__c)){
                        duplicates.add(trace);
                    }
            }
        }
        return duplicates;
    }
}