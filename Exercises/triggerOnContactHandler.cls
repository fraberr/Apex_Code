public with sharing class triggerOnContactHandler {
	
    public static void afterInsertHandler(List<Contact> newRecords, Map<Id,Contact> newRecordsMap){
            
        	List<Contact> trigContacts = [SELECT Id, AccountId, Active__c FROM Contact WHERE Id IN :newRecordsMap.keySet()];
            Set<Id> idsForAcc = new Set<Id>();
                
            for(Contact con : trigContacts){
                idsForAcc.add(con.AccountId);
            }
            
            List<Account> accsToUpdate = [SELECT Id, Active_Contacts__c FROM Account WHERE Id IN :idsForAcc];
			
            for(Contact cont : newRecords){             
                    for(Account acc : accsToUpdate){
                        if(acc.Id == cont.AccountId && cont.Active__c==true){
                            if(acc.Active_Contacts__c == null){
                                acc.Active_Contacts__c = 0;
                                acc.Active_Contacts__c++;
                            }else {
                                acc.Active_Contacts__c++;
                            }							
                        }
                    }                
            }
            update accsToUpdate;   
    }

    
    public static void afterUpdateHandler(List<Contact> newRecords, List<Contact> oldRecords, Map<Id,Contact> newRecordsMap){
            
        	List<Contact> trigContacts = [SELECT Id, AccountId, Active__c FROM Contact WHERE Id IN :newRecordsMap.keySet()];
            Set<Id> idsForAcc = new Set<Id>();
                
            for(Contact con : trigContacts){
                idsForAcc.add(con.AccountId);
            }
            
            List<Account> accsToUpdate = [SELECT Id, Active_Contacts__c FROM Account WHERE Id IN :idsForAcc];
            
            for(Contact con: oldRecords){
                if(con.Active__c == false){
                    for(Contact cont : newRecords){
                        for(Account acc : accsToUpdate){
                            if(acc.Id == cont.AccountId && cont.Active__c==true){
                                acc.Active_Contacts__c++;
                            }
                        }
                    }             
                }
                if(con.Active__c == true){
                    for(Contact cont : newRecords){
                        for(Account acc : accsToUpdate){
                            if(acc.Id == cont.AccountId && cont.Active__c==false){
                                acc.Active_Contacts__c--;
                            }
                        }
                    }             
                }
            }
            
            update accsToUpdate;                
    }
    
    
    public static void beforeDeleteHandler(List<Contact> oldRecords, Map<Id, Contact> oldRecordsMap){
        
            List<Contact> trigContacts = [SELECT Id, AccountId, Active__c FROM Contact WHERE Id IN :oldRecordsMap.keySet()];
            Set<Id> idsForAcc = new Set<Id>();
                
            for(Contact con : trigContacts){
                idsForAcc.add(con.AccountId);
            }
            
            List<Account> accsToUpdate = [SELECT Id, Active_Contacts__c FROM Account WHERE Id IN :idsForAcc];
            
            for(Contact cont : oldRecords){
            	if(cont.Active__c == true){  
                	for(Account acc : accsToUpdate){
                        --acc.Active_Contacts__c;
                    }             
                }
            }
            update accsToUpdate;
    }
    
    
    public static void afterUndeleteHandler(List<Contact> newRecords, Map<Id, Contact> newRecordsMap){
        
        	List<Contact> trigContacts = [SELECT Id, AccountId, Active__c FROM Contact WHERE Id IN :newRecordsMap.keySet()];
            Set<Id> idsForAcc = new Set<Id>();
                
            for(Contact con : trigContacts){
                idsForAcc.add(con.AccountId);
            }
            
            List<Account> accsToUpdate = [SELECT Id, Active_Contacts__c FROM Account WHERE Id IN :idsForAcc];
            
            for(Contact cont : newRecords){
            	if(cont.Active__c == true){  
                	for(Account acc : accsToUpdate){
                        acc.Active_Contacts__c++;
                    }             
                }
            }
            update accsToUpdate;
    }   
}