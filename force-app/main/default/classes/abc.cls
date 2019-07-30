public with sharing class abc{

    public void testAbc(){
      List<string> testString = new List<string>();
      testString.add('a');
      testString.add('b');
      
      for(String ts:testString){
          testString.add('c');
      }
    }

}