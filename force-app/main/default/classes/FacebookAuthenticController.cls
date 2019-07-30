public with sharing class FacebookAuthenticController {
	public FacebookAuthenticController() {
		code = '';
	}

	public string clientId = '1516132742043976';
	public string clientSecret = '96a904d58488507d3605ae1e45fea783';
	public string code{get;set;}
	public string token{get;set;}
	public string body{get;set;}
	public PageReference getAuthURI() {
    	string scope = '&scope=read_stream,publish_stream';
    	
        System.debug('Facebook OAuth Step 1');
    
        String state = '&state='+getPageURL();
            
        String authURI = 'https://graph.facebook.com/oauth/authorize?client_id='+
                        clientId+'&redirect_uri='+getRedirectURI();
        code = Apexpages.currentPage().getHeaders().get('code');
        pagereference pr = new PageReference(authURI);
        return pr;
    }
    public void getPosts(){
    	
    	system.debug('##code'+code);
	  	
	    http h = new http();
	  	HttpRequest req = new HttpRequest();
		HttpResponse res = new HttpResponse(); 

        req.setEndpoint('https://graph.facebook.com/oauth/access_token?code='+code+'&client_secret='+clientSecret+'&client_id='+clientId+'&grant_type=client_credentials');
        req.setMethod('GET');
        res = h.send(req);
        token = res.getBody();

        system.debug('##token##'+token);
        system.debug('##status##'+res.getStatus());

        http h1 = new http();
	  	HttpRequest req1 = new HttpRequest();
		HttpResponse res1 = new HttpResponse();

		req1.setEndpoint('https://graph.facebook.com/1442540512735937/statuses?'+token);
        req1.setMethod('GET');
        res1 = h1.send(req1);
        body = res1.getBody();

        system.debug('##body##'+body);
        system.debug('##status##'+res.getStatus());

      
    }




  

    public String getPageURL() {
        // Get a URL for the page without any query params    
        String url = ApexPages.currentPage().getUrl().split('\\?')[0];        
        System.debug('url is '+url);
        
    	return url;
    }

      public String getRedirectURI() {
        String redirectURI = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/apex/FacebookAuthentication';
        System.debug('redirectURI is:'+redirectURI);
        
        return redirectURI;
    }
}