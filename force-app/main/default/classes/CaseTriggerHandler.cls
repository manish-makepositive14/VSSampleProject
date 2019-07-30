/**
* @author: Manish Chandra
* @purpose: This class is a handler class for case Trigger,This is fired whenever any case is created or updated.
* @creationdate: 2/4/2015
*/

public with sharing class CaseTriggerHandler{

    public Set<id> caseToBeUpdated = new Set<id>(); 
    public List<CaseMilestone> caseMilestonesToUpdate = new List<CaseMilestone>();


    //This method attaches an entitlement to the created case, the entitlement attached to the case's account is getting pulled and being attached to case.
    
    public void onBeforeInsert(List<Case> newCaseList) {
        List<Id> accountIds = new List<Id>(); // Set of account Ids related to cases
        Map<Id, Id> accountEntitlementIdsMap = new Map<Id, Id>(); // Account Id => related oldest Active Entitlement
        for (Case cs : newCaseList) {
            if (cs.AccountId != null) {
                accountIds.add(cs.AccountId);
            }
        }
        if (accountIds.size() > 0) {
        
            //Pulling oldest Entitlement if there are more than one
            for (Entitlement ent : [SELECT Id, AccountId, LastModifiedDate, CreatedDate FROM Entitlement
                                    WHERE AccountId = : accountIds AND Status = 'Active' ORDER BY CreatedDate ASC]) {
                if (!accountEntitlementIdsMap.containsKey(ent.AccountId)) {
                    accountEntitlementIdsMap.put(ent.AccountId, ent.Id);
                }
            }
            
            //Associating Entitlement
            for (Case cs : newCaseList) {
                if (accountEntitlementIdsMap.containsKey(cs.AccountId) && cs.EntitlementId != accountEntitlementIdsMap.get(cs.AccountId)) {
                    cs.EntitlementId = accountEntitlementIdsMap.get(cs.AccountId);//ent.id;
                }
            }
        }
    }

    //This method updates the case milestones attached to the case being updated and populates the completion date into case milestones.
    public void onAfterUpdate(final Map<Id, Case> casesOldMap,final List<Case> updatedCases, final Map<Id, Case> casesNewMap){

        //List to store milestone criteria
        List<Milestone_Criteria__c> mcList = new List<Milestone_Criteria__c>();

        //Map to store milestone criteria against milestone name
        Map<String,String> milestoneCriteriaMap = new Map<String,String>();
        EntitlementCriteriaController enController = new EntitlementCriteriaController();

        //Getting all fields of cases dynamically by accesing method in EntitlementCriteriaController class 
        Map<String,Schema.SObjectField> caseFieldsInHandler = enController.getAllCaseFields();

        //Boolean to check if the condition matches from the filter criteria string
        boolean flagTwo = false;
        String filterCriteria = '';
        String conditionString = '';
        Set<String> milestoneSet = new Set<String>();
        
        //Fetching Milestone Criterias from Milestone criteria custom object, created by user using Milestone Completion Criteria page, which are being stored in
        mcList = [SELECT Id, Name, Criteria__c FROM Milestone_Criteria__c limit 200];

         //add milestone name and criteria to the map
        for(Milestone_Criteria__c m : mcList){
            milestoneCriteriaMap.put(m.Name,m.Criteria__c);
        }

        system.debug('milestoneCriteriaMap::'+milestoneCriteriaMap);


        // Iterating over all cases being updated
        for(Case cas:updatedCases){

            //Iterating over all milestone criteria records for each milestone retrieved from the milestone criteria object
            for(String mCriteria:milestoneCriteriaMap.KeySet()){

                filterCriteria = milestoneCriteriaMap.get(mCriteria);
            
                //Checking if the filter string contains just one filter in the string
                if((!filterCriteria.contains('AND')) && (!filterCriteria.contains('OR'))){
                    if(filterCriteria.contains('(')){
                        filterCriteria = filterCriteria.replace('(',' '); 
                        filterCriteria = filterCriteria.replace(')',' '); 
                    }
                    system.debug('::filterCriteria::'+filterCriteria);
                    flagTwo = returnBooleanScenarioOne(filterCriteria,cas,caseFieldsInHandler);

                    system.debug('::milestoneSet::'+milestoneSet);
                }

                //Checking if the operator between two filters is AND & it just contains two operands & upadting flag if the filter criteria matches for case record
                else if((filterCriteria.contains('AND')) && (!filterCriteria.contains('OR'))){
                    flagTwo = returnBooleanScenarioAND(filterCriteria,cas,caseFieldsInHandler);
                }

                //Checking if the operator between two filters is OR & it just contains two operands & upadting flag if the filter criteria matches for case record
                else if((filterCriteria.contains('OR')) && (!filterCriteria.contains('AND'))){
                    flagTwo = returnBooleanScenarioOR(filterCriteria,cas,caseFieldsInHandler);               
                }

                //Checking if the filter contains more than two operands and also it contains both OR & AND operators & upadting flag if the filter criteria matches for case record
                else if((filterCriteria.contains('OR')) && (filterCriteria.contains('AND'))){
                   flagTwo = returnBooleanScenariorORAND(filterCriteria,cas,caseFieldsInHandler);
                }

                //If flag is true the capture the case id and also the current milestone name
                if(flagTwo == true){
                    if(!caseToBeUpdated.contains(cas.id)){
                        caseToBeUpdated.add(cas.id);
                    }
                    if(!milestoneSet.contains(mCriteria)){
                        milestoneSet.add(mCriteria); 
                    }
                }
            }
        }

        //Create a list of caseMilestones having caseId in the caseToBeUpdated set created above
        caseMilestonesToUpdate = [select Id, completionDate, CaseId, MilestoneTypeId, MilestoneType.Name from CaseMilestone
                                         where caseId IN : caseToBeUpdated AND completionDate = null AND MilestoneType.Name IN : milestoneSet];

        //check if the caseMilestones list created above is not empty
        if (!caseMilestonesToUpdate.isEmpty()){
            //for ceach case milestone on case check if for same case Id the milestone Name matches from the milestone name fetched in caseIdAndMilestoneNameMap
            //on a match update its completion date
            for (CaseMilestone cm : caseMilestonesToUpdate){
                cm.CompletionDate = system.now();
            }
            //update case milestones list
            if(caseMilestonesToUpdate.size() > 0){ 
                update caseMilestonesToUpdate;
            }   
        }
    }

    //This method is executed whenever a filter string contains both OR and AND operators and it also parses the filter string based on the paranthesis placed before and after the operands
    public boolean returnBooleanScenariorORAND(String filterCriteria,Case cObject,Map<String,Schema.SObjectField> caseFields){
        //string filterCriteria = '1 OR (1 AND 3)';
        string partOneOfFilter = '';
        string partTwoOfFilter = '';
        string operator = '';
        boolean flagORAND = false;
        Set<boolean> flagORANDSet = new Set<boolean>();

        //geting indexes of paranthesis opening and closing, length of filter string
        integer length = filterCriteria.length();
        integer openingParanthesisPosition = filterCriteria.indexOf('(');
        integer closingParanthesisPosition = filterCriteria.indexOf(')');
        integer openingParanthesisPositionTwo = 0;
        integer closingParanthesisPositionTwo = 0;

        // If the first operand of string contains any paranthesis then this piece of code will be executed & this separates two operands
        if((closingParanthesisPosition+1) != length){
            partOneOfFilter = filterCriteria.substring(openingParanthesisPosition+1,closingParanthesisPosition);
            partTwoOfFilter = filterCriteria.substring(closingParanthesisPosition+1,length);
            if(partTwoOfFilter.contains('(')){
                operator = partTwoOfFilter.substring(0,partTwoOfFilter.indexOf('('));
            }
        }

        // If only second operand is containing the paranthesis then this piece of code will be executed
        else if((closingParanthesisPosition+1) == length){
            partTwoOfFilter = filterCriteria.substring(openingParanthesisPosition,length);
            partOneOfFilter = filterCriteria.substring(0,length-(length-(openingParanthesisPosition)));

        }

        //if second operand contains any paranthesis then extract the filter criteria
        if(partTwoOfFilter.contains('(')){
            openingParanthesisPositionTwo = partTwoOfFilter.indexOf('(');
            closingParanthesisPositionTwo = partTwoOfFilter.indexOf(')');
            partTwoOfFilter = partTwoOfFilter.substring(openingParanthesisPositionTwo+1,closingParanthesisPositionTwo);
        }

        //if second operand does not contains any paranthesis then remove any existing operator and extract the filter criteria in string
        else if(partTwoOfFilter.containsNone('(')){
            partTwoOfFilter = partTwoOfFilter.trim();
            if((partTwoOfFilter.endsWith('AND')) || (partTwoOfFilter.startsWith('AND'))){
                partTwoOfFilter = partTwoOfFilter.replace('AND','');
                operator = 'AND';
            }
            else if((partTwoOfFilter.endsWith('OR')) || (partTwoOfFilter.startsWith('OR'))){
                partTwoOfFilter = partTwoOfFilter.replace('OR','');
                operator = 'OR';
            }
            partTwoOfFilter = partTwoOfFilter.trim();
        }

        //if first operand contains any paranthesis then extract the filter criteria
        if(partOneOfFilter.contains('(')){
            openingParanthesisPositionTwo = partOneOfFilter.indexOf('(');
            closingParanthesisPositionTwo = partOneOfFilter.indexOf(')');
            partOneOfFilter = partOneOfFilter.substring(openingParanthesisPositionTwo+1,closingParanthesisPositionTwo);
        }

        //if first operand does not contains any paranthesis then remove any existing operator and extract the filter criteria in string
        else if(partOneOfFilter.containsNone('(')){
            partOneOfFilter = partOneOfFilter.trim();
            if((partOneOfFilter.endsWith('AND')) || (partOneOfFilter.startsWith('AND'))){
                partOneOfFilter = partOneOfFilter.replace('AND','');
                operator = 'AND';
            }
            else if((partOneOfFilter.endsWith('OR')) || (partOneOfFilter.startsWith('OR'))){
                partOneOfFilter = partOneOfFilter.replace('OR',' ');
                operator = 'OR';
            }
            partOneOfFilter = partOneOfFilter.trim();
        }

        //process string and check if condition matches from the filter criteria
        if(partOneOfFilter.contains('AND')){
           flagORAND = returnBooleanScenarioAND(filterCriteria,cObject,caseFields);
           flagORANDSet.add(flagORAND);

        }

        else if(partOneOfFilter.contains('OR')){
            flagORAND = returnBooleanScenarioOR(filterCriteria,cObject,caseFields);
            flagORANDSet.add(flagORAND);
        }

        if(partTwoOfFilter.contains('AND')){
           flagORAND = returnBooleanScenarioAND(filterCriteria,cObject,caseFields);
           flagORANDSet.add(flagORAND);

        }

        else if(partTwoOfFilter.contains('OR')){
            flagORAND = returnBooleanScenarioOR(filterCriteria,cObject,caseFields);
            flagORANDSet.add(flagORAND);
        }

        if(operator.trim() == 'OR'){
            if(flagORANDSet.contains(true)){
                return true;
            }
        }

        else if(operator.trim() == 'AND'){
            if(!flagORANDSet.contains(false)){
                return true;
            }
        }

        return false;
    }


    //This method is executed whenever a filter string contains just AND operator.
    public boolean returnBooleanScenarioAND(String filterCriteria,Case cObject,Map<String,Schema.SObjectField> caseFields){
        Set<boolean> flagSet = new Set<boolean>();
        if(filterCriteria.contains('(')){
            filterCriteria = filterCriteria.replace('(',' '); 
            filterCriteria = filterCriteria.replace(')',' '); 
        }

        boolean flag = false;
        List<String> filterCriteriaList = filterCriteria.split('AND');

        //processing all filters operands by passing into method to check each filter condition
        for(Integer i =0 ;i< filterCriteriaList.size();i++){
            flag = returnBooleanScenarioOne(filterCriteriaList[i],cObject,caseFields);
            flagSet.add(flag);
        }
        if(!flagSet.contains(false)){
            return true;
        } 

        return false;
    }

    //This method is executed whenever a filter string contains just OR operator.
    public boolean returnBooleanScenarioOR(String filterCriteria,Case cObject,Map<String,Schema.SObjectField> caseFields){
        Set<boolean> flagSet = new Set<boolean>();
        boolean flag = false;
        if(filterCriteria.contains('(')){
            filterCriteria = filterCriteria.replace('(',' '); 
            filterCriteria = filterCriteria.replace(')',' '); 
        }
        if(filterCriteria.contains('(')){
            filterCriteria = filterCriteria.replace('(',' '); 
            filterCriteria = filterCriteria.replace(')',' '); 
        }

        List<String> filterCriteriaList = filterCriteria.split('OR');

        //processing all filters operands by passing into method to check each filter condition
        for(Integer i =0 ;i< filterCriteriaList.size();i++){
            flag = returnBooleanScenarioOne(filterCriteriaList[i],cObject,caseFields);
            flagSet.add(flag);
        }
        if(flagSet.contains(true)){
            return true;
        }

        return false;
    }

    //This method is executed to match each condition from a complex filter criteria string 
    public boolean returnBooleanScenarioOne(String filterCriteria,Case cObject, Map<String,Schema.SObjectField> caseFields){


        List<String> filterCriteriaList;
        if((filterCriteria.contains('=')) && (!filterCriteria.contains('!'))){
            filterCriteriaList = filterCriteria.split('='); 
                   
            for(String cField:caseFields.KeySet()){
                if(cField.trim() == filterCriteriaList[0].trim()){
                    if(cObject.get(cField) == filterCriteriaList[1].replace('\'','').trim()){
                        return true;
                    }
                }
            }
        }

        else if(filterCriteria.trim().contains('!=')){
            filterCriteriaList = filterCriteria.split('!='); 
            for(String cField:caseFields.KeySet()){
                if(cField.trim() == filterCriteriaList[0].trim()){
                    if(cObject.get(cField) != filterCriteriaList[1].replace('\'','').trim()){
                       return true;
                    }   
                }
            }
        }

        else if(filterCriteria.trim().contains('>')){
            filterCriteriaList = filterCriteria.split('>'); 
            for(String cField:caseFields.KeySet()){
                if(cField.trim() == filterCriteriaList[0].trim()){
                    if(Integer.valueOf(cObject.get(cField)) > integer.valueOf(filterCriteriaList[1].replace('\'','').trim())){
                       return true;
                    }   
                }
            }
        }

        else if(filterCriteria.trim().contains('<')){
            filterCriteriaList = filterCriteria.split('<'); 
            for(String cField:caseFields.KeySet()){
                if(cField.trim() == filterCriteriaList[0].trim()){
                    if(Integer.valueOf(cObject.get(cField)) < integer.valueOf(filterCriteriaList[1].replace('\'','').trim())){
                       return true;
                    }   
                }
            }
        }
        return false;
    }
}