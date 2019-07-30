public with sharing class AutoCompleteController{

    @RemoteAction
    public static List<String> remoteContacts(){
        
        list<Contact> contList = [Select Id,name FROM Contact LIMIT 100];
        List<String> conNameList = new List<String>();
        String name = '';
        Integer count = 0;
        
        for(Contact con:contList){
           
           conNameList.add(con.name);
           
        }
        return conNameList;
        
    }

}