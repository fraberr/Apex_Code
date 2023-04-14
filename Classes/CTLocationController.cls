public with sharing class CTLocationController {
    public CTLocationController() {

    }


    public static List<Location__c> getRecentStatusChanges() {
        List<Location__c> locations = [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status__c, Status_Update_Date__c 
                                            FROM Location__c ORDER BY Status_Update_Date__c DESC LIMIT 100];
        return locations;
    }


    public static List<Location__c> searchLocations(String searchTerm) {
        if(String.isEmpty(searchTerm)){
            return null;
        } else {
            searchTerm = searchTerm + '%';
            List<Location__c> searchLocation = [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status__c, Status_Update_Date__c 
                                                    FROM Location__c  WHERE Name LIKE :searchTerm OR Pincode__c LIKE :searchTerm OR Address__c LIKE :searchTerm 
                                                    ORDER BY Status_Update_Date__c DESC];
            

            return searchLocation;
        }
    }

    public static Location__c getLocationById(String locationId) {
        List<Location__c> locationsById = [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status__c, Status_Update_Date__c  
                                                FROM Location__c  WHERE Id=:locationId];
                                                                                         
        if(locationsById != null  && locationsById.size()>0){
            return locationsById[0];
        } else {
            return null;
        }
    }
    
    public static Map<String, Integer> getStatusCount(){
        
    	Map<String, Integer> locationStatusCount = new Map<String, Integer>();
   		AggregateResult [] countLocations = [SELECT Status__c, COUNT(Id) countStatus FROM Location__c GROUP BY Status__c];

        if(countLocations != null && countLocations.size()>0){
            for(AggregateResult agg : countLocations){
                if(!locationStatusCount.containsKey(String.valueOf(agg.get('Status__c')))){
                    locationStatusCount.put(String.valueOf(agg.get('Status__c')), Integer.valueOf(agg.get('countStatus')));
                }
            }
        }
        return locationStatusCount;
    }
}