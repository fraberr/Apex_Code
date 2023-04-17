public class CTPersonTriggerHandler {

    public static void beforeInsertHandler(List<Person__c> people){
        for(Person__c person : people){
            person.Health_Status__c = 'Green';
            person.Token__c = CTPersonController.getToken(person.Mobile__c);
        }
    }
    
    public static void beforeUpdateHandler(List<Person__c> people, Map<Id, Person__c> oldPeople){
        for(Person__c person : people){
            if(person.Health_Status__c != oldPeople.get(person.Id).Health_Status__c){
                person.Status_Update_Date__c = Date.today();
            }
        }
    }

    public static void afterUpdateHandler (List<Person__c> people, Map<Id, Person__c> oldPeople){

        Set<Id> statusChange = new Set<Id>();
        Set<Id> redStatus = new Set<Id>();
        for(Person__c person : people){
            if(person.Health_Status__c != oldPeople.get(person.Id).Health_Status__c){
                statusChange.add(person.Id);
            }
            if(person.Health_Status__c == 'Red' && oldPeople.get(person.Id).Health_Status__c != 'Red'){
                redStatus.add(person.Id);
            }
        }

        Set<Id> alreadyProcessed = new Set<Id>();
        alreadyProcessed.addAll(redStatus);

        Set<Id> orangeStatus = new Set<Id>();
        Set<Id> yellowStatus = new Set<Id>();

        List<Person__c> personToUpdate = new List<Person__c>();

        orangeStatus.addAll(CTPersonController.getCohabitants(redStatus, alreadyProcessed));

        Set<Id> primaryContacts = CTPersonController.getPrimaryContacts(redStatus, alreadyProcessed);
        orangeStatus.addAll(primaryContacts);

        yellowStatus.addAll(CTPersonController.getNeighbours(redStatus, alreadyProcessed));

        yellowStatus.addAll(CTPersonController.getSecondaryContacs(redStatus, alreadyProcessed));


        for(Id pid : orangeStatus) {
            personToUpdate.add(new Person__c(Id=pid, Health_Status__c = 'Orange'));
        }
        for(Id pid : yellowStatus){
            personToUpdate.add(new Person__c(Id=pid, Health_Status__c = 'Yellow'));
        }

        if(personToUpdate.size()>0){
            update personToUpdate;
        }

        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationsByPersonIds(statusChange);
        if(locationTraces != null && locationTraces.size()>0){
            Set<Id> locationIds = new Set<Id>();
            for(Location_Tracing__c trace : locationTraces){
                locationIds.add(trace.Location__c); 
            }
            CTLocationController.updateRedScore(locationIds);
        }
        
    }
    
}