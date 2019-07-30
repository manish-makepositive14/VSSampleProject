/*
Date:8/10/2014
Author:Manish Chandra
Description: This class is controller for Entitlement Criteria Page which is a custom page for creating milestone criteria.

*/

public with sharing class EntitlementCriteriaController{
    
    //getter setter for Current Milestone Selected
    public string selectedMilestone{get;set;}
    
    //getter setter for Current Milestone Selected
    public List<SelectOption> optionList{get;set;}
    
    //getter setter for Case Object Fields picklist
    public List<SelectOption> optionListCaseField{get;set;}
    public Case caseObject{get;set;}
    
    //getter setter for milestone line item row counter
    public Integer rowNum{get;set;}
    
    //getter setter for filter Logic
    public string filterLogic{get;set;}
    
    //getter setter for showing link for creating filter logic
    public boolean filterCreatable{get;set;}
    public List<Milestone_Criteria__c> mcList{get;set;}
    
    //boolean for showing edit panel for milestone criteria
    public boolean isModifyPanel{get;set;}
    public boolean isData{get;set;}
    public boolean isMilestoneCriteriaEdited{get;set;}
    public Id milestoneCriteriaId{get;set;}
    public boolean isListPanel{get;set;}
    public List<SelectOption> milestoneOptions{get;set;}
    public List<Milestone_Criteria_Line_Item__c> mcLineList = new List<Milestone_Criteria_Line_Item__c>();
    public Milestone_Criteria__c mCriteriaObject = new Milestone_Criteria__c();
    public boolean updateRecords{get;set;}
    public List<wrapper> milestoneCriteriaList{get;set;}
    public List<MilestoneType> milestoneList = new List<MilestoneType>();
    public List<Milestone_Criteria__c> mCriteriaList = new List<Milestone_Criteria__c>();
    public Set<String> mCriteriaSet = new Set<String>();
    
    public EntitlementCriteriaController(){
        rowNum = 0;
        filterCreatable = false;
        updateRecords = false;
        isData = true;
        optionList = new List<SelectOption>();
        optionListCaseField = new List<SelectOption>();
        milestoneOptions = new List<SelectOption>();
        mcList = new List<Milestone_Criteria__c>();
        //Populate Milestone Criteria picklist
        populateMilestoneOptions();
        
        if(milestoneCriteriaList == null)
            milestoneCriteriaList = new List<wrapper>();
            
         optionList.add(new SelectOption('','---None---'));
         optionList.add(new SelectOption('=','Equals'));
         optionList.add(new SelectOption('!=','Not Equals'));
         optionList.add(new SelectOption('>', 'Greater Than'));
         optionList.add(new SelectOption('<', 'Less Than'));

        //get all filterable case fields on page load  
        Map<String,Schema.SObjectField> casefields = getAllCaseFields();
        optionListCaseField.add(new SelectOption('','---None---'));
        for(String cFields:casefields.KeySet()){
            if(casefields.get(cFields).getDescribe().isFilterable()){
                optionListCaseField.add(new SelectOption(cFields,casefields.get(cFields).getDescribe().getLabel()));
            }
        }
        
        isModifyPanel = false;
        isListPanel = true;
        
    }
    
    /*
    Date: 24/09/2014
    Author:Manish Chandra
    Description: This method processes filter logic and replaces it with milestone criteria line item values.
    */
    boolean errorFlag ;
    public void applyFilterLogic(){
        Integer mlisSize = milestoneCriteriaList.size();
        String criteria;
        errorFlag = false;
        system.debug(filterlogic+'=======filterLogic===');

        
        Map<Integer,Integer> MapIndexes = new Map<Integer,Integer>();
        Map<String, String> MapCriteria = new Map<String,String>();
        List<Integer> mapIndexList = new List<Integer>();

        system.debug('//Milestone Criteria//'+milestoneCriteriaList);
        
        //Replacing integers in filter logic with actual values
        //Creating criteria string or each line item a9910671684
        for(Integer i = 0; i < mlisSize; i++){
            Map<String,Schema.SObjectField> casefields = getAllCaseFields();
            if(milestoneCriteriaList.get(i).selectedField !=null){
                String fieldType = String.valueOf(casefields.get(milestoneCriteriaList.get(i).selectedField).getDescribe().getType());
                /*
                    NOTE: Special handling for time, date and date time needs to be implemented

                    Available data types
                    anytype, base64, Boolean, Combobox, Currency, DataCategoryGroupReference, Date, DateTime, Double, 
                    Email, EncryptedString, ID, Integer, MultiPicklist, Percent, Phone, Picklist, Reference, String, TextArea, Time, URL                     
                */

                // DATE FIELDS CAN NOT BE HANDLED
                if( fieldType == 'Double' || fieldType == 'Integer' || fieldType == 'Boolean' || fieldType == 'Currency' || fieldType == 'Percent'){
                    if((fieldType == 'Boolean' && (milestoneCriteriaList.get(i).textvalue.toLowerCase() != 'true' 
                                                    && milestoneCriteriaList.get(i).textvalue.toLowerCase() != 'false')) 
                        || (fieldType == 'Integer' && !milestoneCriteriaList.get(i).textvalue.isNumeric()) 
                        || (fieldType == 'Double' && (!milestoneCriteriaList.get(i).textvalue.replace('.','').isNumeric() 
                            || milestoneCriteriaList.get(i).textvalue.countMatches('.') > 1) )) {
                        errorFlag = true;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Value For: '+ milestoneCriteriaList.get(i).selectedField));
                    }

                    criteria = milestoneCriteriaList.get(i).selectedField +' '+ milestoneCriteriaList.get(i).selectedOperator + ' '+ String.escapeSingleQuotes(milestoneCriteriaList.get(i).textvalue);
                    
                }
                else{                   
                    criteria = milestoneCriteriaList.get(i).selectedField +' '+ milestoneCriteriaList.get(i).selectedOperator + '\''+ String.escapeSingleQuotes(milestoneCriteriaList.get(i).textvalue)+'\'';
                }
            
                //Logic for processing integers in Values field
                if(filterLogic.indexOf(String.valueOf(i+1)) > -1){
                    MapIndexes.put(filterLogic.indexOf(String.valueOf(i+1)),i+1);
                    mapIndexList.add(filterLogic.indexOf(String.valueOf(i+1)));
                    mapIndexList.sort();
                    MapCriteria.put(string.valueOf(i+1),criteria);
                }
            }   
            
        }

        if(filterlogic.contains('AND'))
            filterlogic = filterlogic.replace('AND','::AND::');
        if(filterlogic.contains('OR')) 
            filterlogic = filterlogic.replace('OR','::OR::'); 
        if(filterlogic.contains('('))
            filterlogic  = filterlogic.replace('(','::(::');

        if(filterlogic.contains(')'))
            filterlogic  = filterlogic.replace(')','::)::');

        String[] filterArray = filterlogic.split('::');
        
        filterlogic = '';
        for(Integer index = 0;index<filterArray.size();index++){

            if(MapCriteria.containsKey(filterArray[index].trim())){
                filterArray[index] = MapCriteria.get(filterArray[index].trim());
                filterlogic = filterlogic +' ' +filterArray[index];
            }

           else{
                filterlogic = filterlogic +' '+ filterArray[index];
            }
        }
    }
    
    /*
    Date: 24/9/2014
    Author:Manish Chandra
    Description: This method returns all case fields.
    */
    
    public Map<String,Schema.SObjectField> getAllCaseFields(){
        SObjectType caseType = Schema.getGlobalDescribe().get('Case');
        Map<String,Schema.SObjectField> casefields = caseType.getDescribe().fields.getMap();
        
        return casefields;
    }
    
    /*
    Date: 25/9/2014
    Author:Manish Chandra
    Description: This method gets executed when user creates or updates a record.
    */
    String filter ;
    public pagereference save(){
        String fieldType;
        boolean noError = true;
        Integer criteriaRowCountCurrent = 0;
        Milestone_Criteria__c mCriteria = new Milestone_Criteria__c();
        List<Integer> rowNumberList = new List<Integer>();
        Set<Integer> rowNumSet = new Set<Integer>();
        List<Case> cas = new List<Case>();
        Savepoint sp = Database.setSavepoint();

        //Get existing milestone criteria and milestone criteria line item

        mcLineList = [Select m.Value__c, m.Operator__c,m.id,
                         m.Milestone_Criteria__c, m.Field_API_Name__c
                          From Milestone_Criteria_Line_Item__c m 
                          where m.Milestone_Criteria__c =:mCriteriaObject.id ORDER BY m.Order__c ASC];

        //Throwing exception on page if operator is not selected for any selected field
        for(wrapper wrap : milestoneCriteriaList){
            if(wrap.selectedOperator == null  && wrap.selectedField !=null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select an operator'));
                return null; 
            }
        }


        system.debug('//FilterLogic//'+filterLogic);

        filterLogic = filterLogic.toUpperCase();
        if(filterLogic == '' || filterLogic == null)
            addFilterLogic();
 
        for(wrapper wrap : milestoneCriteriaList){
           if(wrap.selectedOperator != null && wrap.selectedField !=null){
                criteriaRowCountCurrent++;
                rowNumberList.add(wrap.rowNum);
           } 
           
        }

        rowNumberList.sort();

        for(Integer rowNum:rowNumberList){
            rowNumSet.add(rowNum);
        }

        criteriaRowCount = criteriaRowCountCurrent;

        for(Integer i = 1 ; i <= criteriaRowCount ; i++ ){
            if(!filterLogic.contains(string.valueOf(i))){
                if(i == rowNumberList[rowNumberList.size()-1]){
                    filterLogic += (' AND '+ i);
                }

                else if(rowNumSet.contains(i)){
                    filterLogic += (' AND '+ i);
                }

                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Leaving blank rows before any non-blank row is not allowed.'));
                    return null; 
                }
            }
        }

        
        mCriteriaObject.Filter_Logic__c = filterLogic;
        filter = filterLogic; // FilterLogic: 1 AND 2 OR 3
        applyFilterLogic(); // FilterLogic = Filter1= x AND Field2 = y ....        
        //Checking filter logic format else throw error
        if(errorFlag != null && errorFlag){
            filterLogic = filter; 
            return null;            
        }
        try{

            string queryString = 'select id from Case where '+ filterLogic; 
            cas = Database.query(queryString);
        }
        catch(System.QueryException e){
            filterLogic = filter; 
            if((e.getMessage().contains('unexpected token: OR')) || (e.getMessage().contains('unexpected token: AND'))){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please add paranthesis between AND and' 
                + ' OR operators to resolve the expression, e.g (1 AND 2) OR 3'));
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }
        

        //Creating milestone criteria for new records
        if(updateRecords == false){
            
            List<Milestone_Criteria__c> mCriteriaList = new List<Milestone_Criteria__c>();
            List<Milestone_Criteria_Line_Item__c> mLineList = new List<Milestone_Criteria_Line_Item__c>();
            List<String> criteriaList = new List<String>();
            List<String> typeString = new List<string>();
    
            mCriteriaObject.Name = selectedMilestone;
            mCriteriaObject.Criteria__c = filterLogic;

                
            if(mCriteriaObject !=null && noError == true){
                try{
                    insert mCriteriaObject;
                }
                catch(Exception e){
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                     return null;
                }
            }
            
            for(wrapper wrap:milestoneCriteriaList){
                Milestone_Criteria_Line_Item__c mLineItem = new Milestone_Criteria_Line_Item__c();
                
                if(wrap.selectedField !=null){
                    Map<String,Schema.SObjectField> casefields = getAllCaseFields();
                    for(String cFields:casefields.KeySet()){
                        if(cFields == mLineItem.Field_API_Name__c){
                            fieldType = String.valueof(casefields.get(cFields).getDescribe().getType());
                        }
                    }
                    mLineItem.Field_API_Name__c = wrap.selectedField;
                    mLineItem.Operator__c = wrap.selectedOperator;
                    mLineItem.value__c = wrap.textValue;
                    mLineItem.Order__c = wrap.rowNum;
                    mLineItem.Milestone_Criteria__c = mCriteriaObject.id;
                    mLineList.add(mLineItem);
                   
                }
        
            }
            
            if(mLineList.size() > 0){
                try{
                    insert mLineList;
                }
                catch(Exception e ){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                    return null;
                }   
            }
        }
        
        //Updating Existing milestone records 
        
        if(updateRecords == true){
            mCriteriaObject.Name = selectedMilestone;
            mCriteriaObject.criteria__c = filterLogic;
           if(mcLineList.size() > 0){
                try{
                    delete mcLineList;
                }

                catch(Exception e){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                    filterLogic = filter;
                    Database.rollback(sp);
                    return null;
                }
            }

            mcLineList.clear();
               
            criteriaRowCount = 0;
            for(wrapper wrap:milestoneCriteriaList){
                
                if(wrap.selectedField !=null){
                    criteriaRowCount ++;
                    Milestone_Criteria_Line_Item__c mLineItem = new Milestone_Criteria_Line_Item__c();
                    Map<String,Schema.SObjectField> casefields = getAllCaseFields();
                    for(String cFields:casefields.KeySet()){
                        if(cFields == mLineItem.Field_API_Name__c){
                            fieldType = String.valueof(casefields.get(cFields).getDescribe().getType());
                        }    
                    }
                    mLineItem.Field_API_Name__c = wrap.selectedField;
                    mLineItem.Operator__c = wrap.selectedOperator;
                    mLineItem.Value__c = wrap.textValue;
                    mLineItem.Order__c = wrap.rowNum;
                    mLineItem.Milestone_Criteria__c = mCriteriaObject.id;
                    mcLineList.add(mLineItem);
                }
            }
            
            for(Integer i = 1 ; i <= criteriaRowCount ; i++ ){
                if(filter != null && !filter.contains(string.valueOf(i))){
                    filter += (' AND '+ i);
                }
            }

            
            if(mCriteriaObject !=null & noError == true){
                mCriteriaObject.Criteria__c = filterLogic;

                try{
                    update mCriteriaObject;
                }

                catch(Exception e){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                    filterLogic = filter;
                    Database.rollback(sp);
                    return null;
                }
            }

            if(mcLineList.size() > 0){
                try{
                    insert mcLineList;
                }
                catch(Exception e ){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                    filterLogic = filter;
                    Database.rollback(sp);
                    return null;
                }   
            }

            filterLogic = filter;
            applyFilterLogic();

        }

        isListPanel = true;
        isModifyPanel = false;

        if(getMilestoneCriteriaValues().size() > 0)
           isData = true; 
        
        return null;
    }
    
    /*
    Date: 25/9/2014
    Author:Manish Chandra
    Description: This method sets filter logic based on line items selected.
    */

    Integer criteriaRowCount;
    public void addFilterLogic(){
        filterCreatable = true;
        Integer count = 0;
        filterLogic = '';
        
        //Appending row number to filter logic
        for(wrapper wrap:milestoneCriteriaList){
            if(wrap.selectedField != null){
                if(count > 0)
                    filterLogic = filterLogic + ' AND ' +string.valueOf(wrap.rowNum);
                else 
                    filterLogic = string.valueOf(wrap.rowNum);
                count++;
            }
        }
        criteriaRowCount = count;
    }
    
    /*
    Date: 25/9/2014
    Author:Manish Chandra
    Description: This method sets filter logic based on line items selected.
    */
    
    public pagereference del(){

        try{
            if(milestoneCriteriaId !=null){
                mCriteriaObject = [Select m.id FROM Milestone_Criteria__c m where m.id =:milestoneCriteriaId];
            }

            delete mCriteriaObject;
            populateMilestoneOptions();
            if(getMilestoneCriteriaValues().size() == 0)
               isData = false; 
            return null;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }
    }
    
    /*
    Date: 27/9/2014
    Author:Manish Chandra
    Description: This method is executed when user tries to edit a record.
    */
    
    
    public pagereference edit(){
        
        rowNum = 0;
        filterLogic = '';
        updateRecords = true;
        milestoneCriteriaList.clear();
        isListPanel = false;
        isModifyPanel = true;
        
        //Get existing milestone criteria and milestone criteria line item
        mCriteriaObject = [Select Name,id,criteria__c,Filter_Logic__c FROM Milestone_Criteria__c where id =:milestoneCriteriaId];

        mcLineList = [Select m.Value__c, m.Operator__c,m.id,
                         m.Milestone_Criteria__c, m.Field_API_Name__c
                          From Milestone_Criteria_Line_Item__c m 
                          where m.Milestone_Criteria__c =:mCriteriaObject.id ORDER BY m.Order__c ASC];

        milestoneOptions.add(new SelectOption(mCriteriaObject.Name,mCriteriaObject.Name));
        selectedMilestone = mCriteriaObject.Name;
        
        //set selected field,operator and values
        for(Milestone_Criteria_Line_Item__c mList:mcLineList){
            rowNum ++;
            wrapper wrap = new wrapper(rowNum,optionListCaseField,optionList);
            wrap.rowNum = rowNum;
            wrap.selectedField = mList.Field_API_Name__c;
            wrap.selectedOperator = mList.Operator__c;
            wrap.textValue = mList.Value__c;
            milestoneCriteriaList.add(wrap);   
        }

        if(mcLineList.size() < 4){
            for(Integer i = mcLineList.size() ;i<4; i++){
                rowNum++;
                milestoneCriteriaList.add(new wrapper(rowNum,optionListCaseField,optionList));
            }
        }
        
        filterCreatable = true;
        filterLogic = mCriteriaObject.Filter_Logic__c;
        return null;
    } 
    
    
    /*
    Date: 3/9/2014
    Author:Manish Chandra
    Description: This method displays list of all records and cancels the current operation
    */
    
    public pagereference cancel(){
        isListPanel = true;
        isModifyPanel = false;
        return null;
    }
    
    public void populateMilestoneOptions(){
        try{
            mCriteriaSet.clear();
            mCriteriaList = [Select Id,Name FROM Milestone_Criteria__c];
            milestoneList = [SELECT Id,Name FROM MilestoneType];
        }
        catch(Exception e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Currently There is No Milestone'));
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }
        milestoneOptions.Clear(); 

        
        if(mCriteriaList.size() > 0){
            for(Milestone_Criteria__c mCriteria : mCriteriaList){
                mCriteriaSet.add(mCriteria.Name);
            }
        }

        //checking if milestone name is already used and adding to option list to appear on visualforce page
        if(milestoneList.size() > 0){
            for(MilestoneType ms:milestoneList){
                if(!mCriteriaSet.contains(ms.Name) || mCriteriaSet.size() == 0){
                    milestoneOptions.add(new SelectOption(ms.Name, ms.Name));
                }
            }
        }
        
    }
  
   /*
    Date: 27/09/2014
    Author:Manish Chandra
    Description: This method is executed when user creates a new milestone criteria
    */
     
   public void newMilestone(){
        rowNum = 0;
        filterLogic = '';
        milestoneCriteriaList = new List<wrapper>();
        milestoneOptions.clear();
        mCriteriaList.clear();
        milestoneList.clear();
        mCriteriaObject = new Milestone_Criteria__c();        
        updateRecords = false;

        //populating existing milestones
        populateMilestoneOptions();
        for(Integer i = 1; i<=4 ;i++){
            rowNum++;
            milestoneCriteriaList.add(new wrapper(rowNum,optionListCaseField,optionList));
        }
        //set isNewMilestoneCriteria to true
        isModifyPanel = true;
        isListPanel = false;
        
   }
   
   /*
    Date: 27/09/2014
    Author:Manish Chandra
    Description: This method populates all milestone criteria values.
    */
    
    public List<Milestone_Criteria__c> getMilestoneCriteriaValues(){
         //create a list of milestone criteria record
        mcList = [select Id, Name, Criteria__c from Milestone_Criteria__c Order By CreatedDate DESC];
        return mcList;
        
    }
    
    /*
    Date: 28/9/2014
    Author:Manish Chandra
    Description: This method increments the line item rows 
    */

    public pageReference isDataAvailable(){
        List<Milestone_Criteria__c> mcListData = getMilestoneCriteriaValues();
        if(mcListData.size() == 0)
            isData = false;
        return null;
    }

    /*
    Date: 29/9/2014
    Author:Manish Chandra
    Description: This method adds new rows to existing line items.
    */
    
    public void addRow(){
        rowNum ++;
        milestoneCriteriaList.add(new wrapper(rowNum,optionListCaseField,optionList));
    }
    
    /*
    Date: 29/9/2014
    Author:Manish Chandra
    Description: This method removes existing rows of line items.
    */
    
    public void delRow(){
        milestoneCriteriaList.remove(rowNum-1);
        rowNum--;   
    }
    
    /*
    Date: 29/9/2014
    Author:Manish Chandra
    Description: This is a wrapper class created for dynamically adding or removing fields
    */
    
    public class wrapper{
        public string selectedField{get;set;}
        public string selectedOperator{get;set;}
        public Integer rowNum{get;set;}
        public List<SelectOption> operator{get;set;}
        public List<SelectOption> CaseFields{get;set;}
        public string textValue{get;set;}
        public wrapper(Integer rowNum, List<SelectOption> CaseFields,List<SelectOption> operator){
            this.rowNum = rowNum;
            this.CaseFields = CaseFields;
            this.operator = operator;
        }
   }
}