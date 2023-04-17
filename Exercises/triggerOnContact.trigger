trigger triggerOnContact on Contact (after insert, after update, after delete, after undelete) {
    switch on Trigger.operationType {
        when AFTER_INSERT {
            for (Contact con : Trigger.new) {
                if(String.isNotBlank(con.AccountId)){
                    String AccountId = con.AccountId;
                    List<AggregateResult> results = new List<AggregateResult>();[SELECT AccountId, COUNT(Id) totalContacts FROM Contact WHERE Active__c = true AND AccountId = :AccountId GROUP BY AccountId];
                    for(AggregateResult result : results){
                        String accId = String.valueOf(result.get('AccountId'));
                        Integer totalContacts = Integer.valueOf(result.get('totalContacts'));

                        Account acc = new Account(Id=accountId, Active_Contacts__c=totalContacts);
                        update acc;
                    }
                }
            }
        }
    }
}