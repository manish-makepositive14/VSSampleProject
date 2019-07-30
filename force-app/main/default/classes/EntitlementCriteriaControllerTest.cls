/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class EntitlementCriteriaControllerTest {

    static testMethod void entitlementCriteriaMethod() {
        
        
        User use = [Select u.Id FROM User u where u.id=:UserInfo.getUserId()];
        
        System.runAs(use){
            MilestoneType mileType = new MilestoneType();
            mileType.Name = 'Test Milestone 2';
            insert mileType;  
        }
            
        Milestone_Criteria__c mCriteria = new Milestone_Criteria__c();
        mCriteria.Name = 'Test Milestone 1';
        insert mCriteria;
        
        Test.startTest();
        
        EntitlementCriteriaController enCriteria = new EntitlementCriteriaController();
        enCriteria.selectedMilestone = 'Test Milestone 2';
        enCriteria.newMilestone();
        enCriteria.milestoneCriteriaId = mCriteria.id;
        
        for(EntitlementCriteriaController.wrapper eC:enCriteria.milestoneCriteriaList){
            eC.selectedField = 'Status';
            eC.selectedOperator = '=';
            eC.textValue = 'Closed';
        }
        
        
        enCriteria.addFilterLogic();
        enCriteria.save();
        List<Milestone_Criteria__c> mCriteriaExisting = new List<Milestone_Criteria__c>();
        mCriteriaExisting = [Select m.Criteria__c,m.Id From Milestone_Criteria__c m  where m.Name = 'Test Milestone 2'];
        System.assertNotEquals(mCriteriaExisting.size(),0);
        enCriteria.selectedMilestone = 'Test Milestone 2';
        enCriteria.edit();
        for(EntitlementCriteriaController.wrapper eC:enCriteria.milestoneCriteriaList){
            eC.selectedField = 'Status';
            eC.selectedOperator = '=';
            eC.textValue = 'Open';
        }
  
        
        enCriteria.addFilterLogic();
        enCriteria.save();
        mCriteriaExisting.clear();
        mCriteriaExisting = [Select m.Criteria__c,m.Id From Milestone_Criteria__c m  where m.Name = 'Test Milestone 2'];
        //System.assertNotEquals(mCriteriaExisting.size(),0);
        
        enCriteria.addRow();
        enCriteria.delRow();
        
        Test.stopTest();
    }
}