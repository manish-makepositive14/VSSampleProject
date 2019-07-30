public class TestController{
    Public List<TestWrapper> tWrapList{get;set;}
    Public TestWrapper appWrapObj{get;set;}
    public TestController(){
       
           tWrapList = new List<TestWrapper>();
           for(integer i = 2; i<=4;i++){
                appWrapObj = new TestWrapper();
                appWrapObj.xyz= i;
                tWrapList.add(appWrapObj);
            }  
    }
    
    Public pagereference testValues(){
        for(TestWrapper t:tWrapList){
            system.debug('###'+t);
        }
        return null;
    }
    
    public class TestWrapper{
        public string abc{get;set;}
        public integer xyz{get;set;}
    }
}