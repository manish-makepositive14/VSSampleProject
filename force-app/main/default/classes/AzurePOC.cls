public class AzurePOC {
    
        public void azurePOCMethod(){
        
            string storageKey = 'Z7yhAnPUt8iYXSkMK3lvHqQEDS92kR2h5hbZWn6oAjTFrpcsDhEbobcuBxpVtTyHcCTZfds1UnrtUtIESMGJBQ==';
        
            Datetime dt = Datetime.now().addMinutes(-5);
           
            string formattedDate = dt.formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
            //string stringToSign = 'GET\n\napplication/xml\n\n\n' +'/testcontainer/2016';
            //string stringToSign = 'GET\n\napplication/xml\n\nx-ms-date:' + formattedDate + '\n/testaccount5678/bill';
            string stringToSign = 'GET\n\n\n\n\n\n\n\n\n\n\n\nx-ms-date:'+formattedDate+'\nx-ms-version:2009-09-19\n/testaccount5678/bill\ncomp:metadata\nrestype:container\ntimeout:20';
        
            // Sign the request
            Blob temp = EncodingUtil.base64Decode(storageKey);
            Blob hmac = Crypto.generateMac('HMacSHA256', Blob.valueOf(stringToSign), temp);
            string signature = EncodingUtil.base64Encode(hmac);
          
        
            // This ends up being the exact same as the console app
            system.debug('SIGNATURE==>SharedKey myqueue:' + signature);
            system.debug('formattedDate:'+formattedDate);
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
           req.setHeader('content-type', 'application/xml');
            req.setHeader('x-ms-date', formattedDate);
            string authHeader = 'SharedKey testaccount5678:' + signature;
            req.setHeader('Authorization', authHeader);
            req.setHeader('x-ms-version', '2009-09-19');
            //req.setHeader('Content-Length', '0');
       
            req.setEndpoint('https://testaccount5678.blob.core.windows.net/bill/test567');
        
           // req.setBody('<QueueMessage><MessageText>' + EncodingUtil.base64Encode(Blob.valueOf('This is a test from salesforce')) + '</MessageText></QueueMessage>');
        
            system.debug(req);
        
            Http http = new Http();
        
            try
            {
                HTTPResponse res = http.send(req);
        
                system.debug(res.toString());
                system.debug(res.getStatus());
                system.debug(res.getStatusCode());
        
            }
            catch (system.CalloutException ce)
            {
                system.debug(ce);
            }
    }
}