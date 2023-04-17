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
                String status = String.valueOf(agg.get('Status__c'));
                Integer count = Integer.valueOf(agg.get('countStatus'));
                if(!locationStatusCount.containsKey(status)){
                    locationStatusCount.put(status, count);
                }
            }
        }
        return locationStatusCount;
    }

    public static void updateRedScore(Set<Id> locationIds){
        List<Location__c> locationToUpdate = new List<Location__c>();
        AggregateResult[] redPeoplePerLocation = [SELECT Location__c, COUNT(Id) total FROM Location_Tracing__c
                                                    WHERE Person__r.Health_Status__c = 'Red'
                                                    AND Visit_Date__c = LAST_N_DAYS:10
                                                    AND Location__c IN :locationIds
                                                    GROUP BY Location__c];
        for(AggregateResult ar : redPeoplePerLocation){
            String locationID = String.valueOf(ar.get('Loction__c'));
            Integer redScore = Integer.valueOf(ar.get('total')); 
            String status = getStatus(redScore);
            locationToUpdate.add(new Location__c(Id=locationID, Red_Score__c=redScore, Status__c=status));
        }
        
        if(locationToUpdate != null && locationIds.size()>0){
            update locationToUpdate;
        }
    }

    public static String getStatus(Integer redScore){
        if(redScore==0){
            return 'Green';
        } else if(redScore<=5){
            return 'Yellow';
        } else if(redScore <= 10){
            return 'Orange';
        } else{
            return 'Red';
        }
    }
}