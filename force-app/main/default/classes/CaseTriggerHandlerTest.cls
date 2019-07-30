@isTest (seeAllData = true)
private class CaseTriggerHandlerTest {
	
	static testMethod void checkFilterCriteriaMethod() {
		// Implement test code
		
	  	Account acc = new account(name = 'TestCoverage');
        insert acc;

        SlaProcess sProcess = [SELECT Id,Name FROM SlaProcess];
   
        Entitlement ent = new Entitlement(name = 'CoverageEntitlement', AccountId = acc.Id, SlaProcessId = sProcess.id,startDate = system.today(),endDate = system.today()+2); 
        insert ent;

  		Case cseA = new case(accountId = acc.id, subject = 'TestCoverage1', Priority = 'High',status = 'New',type = 'Mechanical');
        insert cseA;


        Test.startTest();

        List<Milestone_Criteria__c> mCriteriaList = new List<Milestone_Criteria__c>();
        List<MilestoneType> milTypeList = new List<MilestoneType>();
        Set<string> criteriaStringSet = new Set<string>();
        Set<String> criteriaStringNameSet = new Set<String>();

        try{
        	milTypeList = [SELECT Id,LastModifiedById,LastModifiedDate,Name FROM MilestoneType];
        	system.debug('::milTypeList::'+milTypeList);
    	}

    	catch(Exception e){
    		System.debug('Exception::'+e.getMessage());  
    	}

    	List<string> filterString = new List<string>();
    	filterString.add('( type =\'Electrical\' AND reason !=\'My Reason\' ) OR ( subject =\'subject\' OR status =\'New\' )');
    	filterString.add('( type =\'Electrical\' AND reason !=\'My Reason\') OR status =\'New\')');
    	filterString.add('status = \'New\' AND (type =\'Electrical\' AND reason !=\'My Reason\')');

    	if(milTypeList.size() > 0){
    		for(MilestoneType mList:milTypeList){	
        		for(String fString:filterString){
        			if((!criteriaStringSet.contains(fString)) && (!criteriaStringNameSet.contains(mList.name))){
        				Milestone_Criteria__c mCriteria = new Milestone_Criteria__c();
        				system.debug('Entered'+mList.name); 
        				criteriaStringSet.add(fString); 
        				mCriteria.Name = mList.name;
        				mCriteria.Criteria__c = fString; 
        				criteriaStringNameSet.add(mList.name);
        				mCriteriaList.add(mCriteria);
        			}
        		}
    		}

    		system.debug('::Milestone Criteria List::'+mCriteriaList);
    		insert mCriteriaList;
    	}

        
        List<case> caseList = [Select Id,Subject,reason,type,Status FROM CASE];
        for(Case c:caseList){
        	c.type = 'Electrical';
        	c.reason = 'Test reason';
        	c.subject = 'subject';
        }

        update caseList;

        List<CaseMilestone> casMilestoneList = [Select Id,CaseId,CompletionDate,IsCompleted FROM CaseMilestone where CaseId=:caseList[0].id]; 

        System.debug('//casMilestone//'+casMilestoneList);

        for(CaseMilestone cMilestone:casMilestoneList){
        	System.assert(cMilestone.IsCompleted,true);
        }

        Test.stopTest();
	}
}