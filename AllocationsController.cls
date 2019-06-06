public with sharing class AllocationsController {
    //Global variables
    public Transient List<Sales_Staff__c> salesStaff {get;set;}
    public List<Allocation__c> allocations {get;set;}  
    public List<Allocation__c> allocTour {get;set;}    
    public List<Event> tourEvents {get;set;}    
    public Transient List<Reservation__c> reservations {get;set;}    
    public String repId{ get; set; }  
    public String selectedRepId{ get; set; }  

    public String allocStatus{ get; set; }
    public String allocReps{ get; set; }              
    
    //Search valiables    
    public String searchStatus {get;set;}        
    public String searchName {get;set;}
    public String searchLang {get;set;}
    public String searchHotel {get;set;}
    public String searchReps {get;set;}
    public String searchType {get;set;}
    public String searchMkSegment {get;set;}
    public String searchCountry {get;set;}
    public String searchRepName {get;set;}
    public String searchRoom {get;set;}
    public String searchAllocRoom {get;set;}
    public String searchWeek {get;set;}
    public Date checkInDateFrom {get; set;}  
    public Date checkInDateTo {get; set;}  
    public DateTime startTourDayTime {get; set;}  
    public DateTime endTourDayTime {get; set;}    
    public Date startTourDay {get; set;}  
    public Time startTime {get; set;} 
    public Time endTime {get; set;}   
    public String tourDescription {get; set;}  
    public Integer recordsLimit {get;set;}   
    public Integer reservRecordsLimit {get;set;}    
    public String tourEventAllocId {get;set;}    

    public Date checkInDateFromReps {get; set;}     
    private Boolean updateReps = false;
       
    //Constructor
    public AllocationsController(){
        searchStatus = '';
        searchName = '';
        searchLang = '';
        searchHotel = '';
        searchReps = '';
        searchType = 'Rep';
        searchMkSegment = '';
        searchCountry = '';
        searchRepName = '';
        searchRoom = '';
        searchAllocRoom = '';
        searchWeek = '';

        updateReps = false;

        Integer daysToFriday = getLastFriday();

        checkInDateFromReps = checkInDateFrom = date.today()-daysToFriday;
        checkInDateTo = null; 

        recordsLimit = 200;
        reservRecordsLimit = 200;

        startTourDay = date.today();       

        startTime = datetime.now().time();
        endTime =  datetime.now().time().addHours(4);   
        
        //Do first query for all aobjects
        doReservQuery();
        doAllocQuery();
        doSalesStaffQuery();   
        doAllocTourQuery(); 
        doEventsQuery();            
    }    
        
    //Get previous Thusrday    
    // private Integer getLastThursday(){
    //     Integer thurdayDay;
    //     Date startWeekDay = Date.today().toStartofWeek();
    //     Integer toDayNumber = Date.today().daysBetween(startWeekDay);

    //     switch on toDayNumber {
    //         when  0 { thurdayDay =  4; }
    //         when -1 { thurdayDay =  5; }
    //         when -2 { thurdayDay =  6; }
    //         when -3 { thurdayDay =  0; }
    //         when -4 { thurdayDay =  1; }
    //         when -5 { thurdayDay =  2; }
    //         when -6 { thurdayDay =  3; }
    //         when else { thurdayDay = 0; }
    //     }

    //     return thurdayDay;
    // }
    //Get previous Friday 
    private Integer getLastFriday(){
        Integer fridayDay;
        Date startWeekDay = Date.today().toStartofWeek();
        Integer toDayNumber = Date.today().daysBetween(startWeekDay);

        switch on toDayNumber {
            when  0 { fridayDay =  3; }
            when -1 { fridayDay =  4; }
            when -2 { fridayDay =  5; }
            when -3 { fridayDay =  6; }
            when -4 { fridayDay =  0; }
            when -5 { fridayDay =  1; }
            when -6 { fridayDay =  2; }
            when else { fridayDay = 0; }            
        }
        return fridayDay;
    }

    public void doAllocQueryStart(){    
        String queryStatus = '';         
        Integer rLimit = 200;     
        String queryAlloc = '';            
               
        if (!String.isBlank(searchStatus)) {
            queryStatus  = searchStatus + '%';
            queryAlloc += ' AND Status__c LIKE  :queryStatus'; 
        }
        
        //To avoid empty query, (Show All button)
        if (queryAlloc.length() == 0) queryAlloc = ' AND CheckIn__c >= :checkInDateFrom'; 
        List<String> mktSegments = getMkSegments();
        //System.debug('ALLOCATIONS QUERY: ' + queryAlloc);
        String excludeTourOp =  '\'0010O0000276QxA\', \'0010O0000276Qxy\', \'0010O0000276QuW\''; //Booking, Expedia, Hotelbeds 
        String queryAllocFinal = 'SELECT Id,Account__r.Id,Account__c,Reservation__r.Id, Account__r.Name, Account__r.Language__pc, Account__r.Country_Name__pc, Toured__c,' +
                                ' Reservation__r.Adults__c,Reservation__r.Children__c,Reservation__r.RoomNo__c,Reservation__r.HotelId__c, Reservation__r.MktSegment__c,' +
                                ' Account__r.IsPersonAccount, CheckIn__c, CheckOut__c, SalesRep__c, SalesTO__c, SalesISA__c, Status__c, CreatedDate, AppointmentDate__c,' + 
                                ' AppointmentDay__c, AppointmentTime__c, RoomNumbers__c, Reservation__r.Week__c,AllocatedDate__c ' +
                                ' FROM Allocation__c WHERE Reservation__r.MktSegment__c in :mktSegments AND Account__c NOT IN(' + excludeTourOp + ')' +
                                queryAlloc +
                                ' AND Status__c != \'S\' AND Status__c != \'NQ\' ORDER BY CreatedDate, CheckIn__c DESC LIMIT ' +
                                rLimit;
        //System.debug('ALLOCATIONS QUERY: ' + queryAllocFinal);        
        allocations = Database.query(queryAllocFinal);    

        List<SourceCodes__c> sourceCode = [SELECT Id, Name, Group__c FROM SourceCodes__c];             

        for (Allocation__c alloc : allocations) {  
            for (SourceCodes__c source : sourceCode) {  
                if (alloc.Reservation__r.MktSegment__c == source.Name) 
                alloc.Reservation__r.MktSegment__c = source.Group__c;
            }             
        }
    }  

    //Getting list of Allocations
    public void doAllocQuery(){    
        String queryStatus = ''; 
        String queryName = '';
        String queryLang = ''; 
        String queryHotel = '';
        String queryRoom = '';
        String queryWeek = '';
        String queryMkSegment = '';  
        String queryConutry = '';
        Date queryCheckInFrom = null;   
        Date queryChecInTo = null;  
        Integer rLimit = 0;     
        String queryAlloc = '';            

        //Create dynamic query
        if (recordsLimit != null) {
            if (recordsLimit > 300 ) recordsLimit = 300;
            rLimit  = recordsLimit;    
        }

        if (!String.isBlank(searchName)) {
            queryName = '%' + searchName + '%';
            queryAlloc += ' AND (Account__r.Name LIKE :queryName OR Reservation__r.OccupantName__c LIKE :queryName)';
        }        
        if (!String.isBlank(searchLang)) {
            queryLang = '%' + searchLang + '%';
            queryAlloc += ' AND Account__r.Language__pc LIKE :queryLang';
        } 
        if (!String.isBlank(searchHotel)) {
            queryHotel = '%' + searchHotel + '%';
            queryAlloc += ' AND Reservation__r.HotelId__c LIKE :queryHotel';
        }  
        if (!String.isBlank(searchWeek)) {
            queryWeek = '%' + searchWeek + '%';
            queryAlloc += ' AND Reservation__r.Week__c LIKE :queryWeek';
        }                
        if (!String.isBlank(searchStatus)) {
            queryStatus  = searchStatus + '%';
            queryAlloc += ' AND Status__c LIKE  :queryStatus'; 
        }
        if (checkInDateFrom != null) {
            queryCheckInFrom  = checkInDateFrom;
            queryAlloc += ' AND CheckIn__c >= :queryCheckInFrom'; 
        }
        if (checkInDateTo != null) {
            queryChecInTo  = checkInDateTo;
            queryAlloc += ' AND CheckIn__c <= :queryChecInTo'; 
        }         
        
        if (!String.isBlank(searchAllocRoom)) {
            queryRoom = '%' + searchAllocRoom + '%';
            queryAlloc += ' AND Allocation__c.RoomNumbers__c LIKE :queryRoom';          
        } 
        if (!String.isBlank(searchCountry)) {
            queryConutry  = '%' + searchCountry + '%';
            queryAlloc += ' AND Account__r.Country_Name__pc LIKE :queryConutry';          
        }
        
        //To avoid empty query, (Show All button)
        if (queryAlloc.length() == 0) queryAlloc = ' AND CheckIn__c >= :queryCheckInFrom'; 
        List<String> mktSegments = getMkSegments();
        //System.debug('ALLOCATIONS QUERY: ' + queryAlloc);
        String excludeTourOp =  '\'0010O0000276QxA\', \'0010O0000276Qxy\', \'0010O0000276QuW\''; //Booking, Expedia, Hotelbeds 
        String queryAllocFinal = 'SELECT Id,Account__r.Id,Account__c,Reservation__r.Id, Account__r.Name, Account__r.Language__pc, Account__r.Country_Name__pc, Toured__c,' +
                                ' Reservation__r.Adults__c,Reservation__r.Children__c,Reservation__r.RoomNo__c,Reservation__r.HotelId__c, Reservation__r.MktSegment__c,' +
                                ' Account__r.IsPersonAccount, CheckIn__c, CheckOut__c, SalesRep__c, SalesTO__c, SalesISA__c, Status__c, CreatedDate, AppointmentDate__c,' + 
                                ' AppointmentDay__c, AppointmentTime__c, RoomNumbers__c, Reservation__r.Week__c,AllocatedDate__c, Reservation__r.OccupantName__c' +
                                ' FROM Allocation__c WHERE Reservation__r.MktSegment__c in :mktSegments AND Account__c NOT IN(' + excludeTourOp + ')' +
                                queryAlloc +
                                ' AND Status__c != \'S\' AND Status__c != \'NQ\' ORDER BY CreatedDate, CheckIn__c DESC LIMIT ' +
                                rLimit;
        //System.debug('ALLOCATIONS QUERY: ' + queryAllocFinal);        
        allocations = Database.query(queryAllocFinal);    

        List<SourceCodes__c> sourceCode = [SELECT Id, Name, Group__c FROM SourceCodes__c];             

        for (Allocation__c alloc : allocations) {  
            for (SourceCodes__c source : sourceCode) {  
                if (alloc.Reservation__r.MktSegment__c == source.Name) 
                alloc.Reservation__r.MktSegment__c = source.Group__c;
            }             
        }          

        if(updateReps) {
            updateAllRepsAllocations();                      
        } else {
            updateReps = true; 
        }        
    }    

    //Get Sales Reps and TOs
    public void doSalesStaffQuery(){  
      
        String queryName = '';
        String queryType = '';
        
        if (searchReps != null) queryName = '%' + searchReps + '%';          
        if (searchReps != null) queryType = '%' + searchType + '%';  
        
        salesStaff = [SELECT Id, Name, NoOfAllocations__c, Active__c, Staff_Type__c FROM Sales_Staff__c 
                     WHERE Active__c = true AND Name LIKE :queryName AND Staff_Type__c LIKE :queryType 
                     ORDER By Name];        
    }                 

    //Update Allocations using visualforce parameters     
    public void updateAllAllocation(){  
        String repName;
        try{   
            for(Allocation__c alloc  :allocations){
                //System.debug('ALLOCATIONS RECORD: ' + '-' + alloc.Status__c);
                if (alloc.Status__c == 'Unallo' && alloc.SalesRep__c == null && alloc.SalesISA__c == null ) {
                    alloc.SalesRep__c = null;
                    alloc.SalesTO__c = null;
                    alloc.SalesISA__c = null;
                    alloc.AppointmentDate__c = null;
                    alloc.AppointmentDay__c = '';
                    alloc.AppointmentTime__c = null;    
                    alloc.Toured__c = false;  
                } 

                if (alloc.Status__c == 'Unallo' && (alloc.SalesRep__c != null || alloc.SalesISA__c != null )) {
                    alloc.Status__c = 'Alloc'; 
                    alloc.AllocatedDate__c = Date.Today(); 
                } 
                if (alloc.Status__c == 'Alloc' && (alloc.SalesRep__c != null || alloc.SalesISA__c != null )) {
                    alloc.AllocatedDate__c = Date.Today();
                }                                 

                if ((alloc.Status__c == 'Alloc' ) && alloc.SalesRep__c == null && alloc.SalesISA__c == null) {
                    alloc.Status__c = 'Unallo';
                    alloc.AppointmentDate__c = null;
                    alloc.AppointmentDay__c = '';
                    alloc.AppointmentTime__c = null;
                    alloc.SalesTO__c = null;
                    alloc.SalesISA__c = null;                    
                    alloc.Toured__c = false; 
                } 
               
                if (alloc.Toured__c == true && alloc.SalesRep__c != null) {
                    alloc.Status__c = 'Toured';
                } else if (alloc.Toured__c == true && alloc.SalesRep__c == null && alloc.SalesISA__c == null){
                    alloc.Status__c = 'Unallo'; 
                    alloc.SalesRep__c = null;
                    alloc.SalesTO__c = null;
                     alloc.SalesISA__c = null;
                    alloc.AppointmentDate__c = null;
                    alloc.AppointmentDay__c = '';
                    alloc.AppointmentTime__c = null;    
                    alloc.Toured__c = false;                    
                }           

                if (alloc.AppointmentDate__c != null){                    
                    Date monday = Date.newInstance(1900, 1, 1);
                    Integer numberDays = Math.mod(monday.daysBetween(alloc.AppointmentDate__c), 7);

                    switch on numberDays {
                        when 0 { 
                            if (alloc.AppointmentDay__c != 'Monday *')
                                alloc.AppointmentDay__c = 'Monday'; 
                            }
                        when 1 { 
                            if (alloc.AppointmentDay__c != 'Tuesday *')
                                alloc.AppointmentDay__c = 'Tuesday'; 
                            }
                        when 2 { 
                            if (alloc.AppointmentDay__c != 'Wednesday *')
                                alloc.AppointmentDay__c = 'Wednesday'; 
                            }
                        when 3 { 
                            if (alloc.AppointmentDay__c != 'Thursday *')
                                alloc.AppointmentDay__c = 'Thursday'; 
                            }
                        when 4 { 
                             if (alloc.AppointmentDay__c != 'Friday *')
                                alloc.AppointmentDay__c = 'Friday'; 
                            }
                        when 5 { 
                            if (alloc.AppointmentDay__c != 'Saturday *')
                                alloc.AppointmentDay__c = 'Saturday'; 
                            }
                        when 6 { 
                            if (alloc.AppointmentDay__c != 'Sunday *')
                                alloc.AppointmentDay__c = 'Sunday'; 
                            }
                    }         
                }                
            }
           
            update allocations;

            doAllocTourQuery();
             
            updateAllRepsAllocations();     
 
        } catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Controller:Allocation - Function:updateAllAllocations' + ex));        
        } finally{}             
                                                 
    }   
 
    //Update bulk allocations status
    public void updateBulkAllocation(){ 
        try{   
            for(Allocation__c alloc  :allocations){ 
                alloc.Status__c =  allocStatus;   
            }
            update allocations;

            searchStatus = allocStatus;
            
            doAllocQuery();
        } catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Controller:Allocation - Function:updateAllAllocations' + ex));        
        } finally{}               
    }  
     
    //Get Sales Reps and TOs
    public void selectAllocatedByRep(){  
        allocations = [SELECT Id,Account__r.Id,Account__c,Reservation__r.Id, Account__r.Name, Account__r.Language__pc, Account__r.Country_Name__pc, Toured__c,
                        Reservation__r.Adults__c,Reservation__r.Children__c,Reservation__r.RoomNo__c,Reservation__r.HotelId__c,Reservation__r.MktSegment__c,
                        Account__r.IsPersonAccount, CheckIn__c, CheckOut__c, SalesRep__c, SalesTO__c, SalesISA__c, Status__c, CreatedDate, 
                        AppointmentDate__c, AppointmentDay__c, AppointmentTime__c,RoomNumbers__c,Reservation__r.Week__c,AllocatedDate__c FROM Allocation__c                        
                        WHERE (SalesRep__c = :repId OR SalesTO__c = :repId OR SalesISA__c = :repId) AND AllocatedDate__c >= :checkInDateFromReps AND LastModifiedDate <= :checkInDateFromReps.addDays(7) LIMIT 100];  
         
         List<SourceCodes__c> sourceCode = [SELECT Id, Name, Group__c FROM SourceCodes__c];             

         for (Allocation__c alloc : allocations) {  
             for (SourceCodes__c source : sourceCode) {  
                 if (alloc.Reservation__r.MktSegment__c == source.Name) 
                    alloc.Reservation__r.MktSegment__c = source.Group__c;
             }             
         }                        
    }
 
    //Calculate weekly amount fo allocations by reps
    public void updateAllRepsAllocations(){    
        Integer counterRep = 0;     
        Integer counterTo = 0;
        Integer counterIsa = 0;    
        try { 
            List<Allocation__c> allocByReps = [SELECT Id,Status__c,SalesRep__c,SalesTO__c,SalesISA__c FROM Allocation__c WHERE Status__c = 'Alloc' AND AllocatedDate__c >= :checkInDateFromReps AND LastModifiedDate <= :checkInDateFromReps.addDays(7)];
            
            List<Sales_Staff__c> salesReps = [SELECT Id, NoOfAllocations__c, Staff_Type__c FROM Sales_Staff__c]; 
        
            for(Sales_Staff__c rep :salesReps){

                 if (rep.Staff_Type__c == 'Rep'){  
                    rep.NoOfAllocations__c = findAllocationsByReps(rep.id, 'Rep', allocByReps);
                 }   
                 if (rep.Staff_Type__c == 'TO'){
                    rep.NoOfAllocations__c = findAllocationsByReps(rep.id, 'TO', allocByReps);
                 } 
                 if (rep.Staff_Type__c == 'ISA'){
                    rep.NoOfAllocations__c = findAllocationsByReps(rep.id, 'ISA', allocByReps);
                 }                                                         
            }   
            
            update salesReps; 
             
            doSalesStaffQuery();  

        } catch(DmlException ex){
            //System.debug('updateAllRepsAllocations error: ' + '-' + ex.getMessage());
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, ex.getMessage()));               
        }                            
    } 


    //Calculate amount of Allocations by Reps, ISA, TOs
    private Integer findAllocationsByReps(String id, String type, List<Allocation__c> allocList){
        Integer counterRep = 0;
        for (Allocation__c alloc :allocList){            
            if (alloc.SalesRep__c == id && type == 'Rep') counterRep++;
            if (alloc.SalesTO__c == id && type == 'TO') counterRep++;
            if (alloc.SalesISA__c == id && type == 'ISA') counterRep++;
        }
        return counterRep;        
    }         
   
    //Reservations functions
    //Getting list of Reservations
    public void doReservQuery(){    
        String queryStatus = ''; 
        String queryName = '';
        String queryLang = ''; 
        String queryMkSegment = ''; 
        String queryConutry = '';
        String queryRoom = '';
        String queryWeek = '';
        Date queryCheckInFrom = null;   
        Date queryChecInTo = null;  
        Integer rLimit = 0;                         
        String queryRes = '';
        
        //Create dynamic query
        if (!String.isBlank(searchName)) {
            queryName = '%' + searchName + '%';
            queryRes += ' AND (Account__r.Name LIKE :queryName OR OccupantName__c LIKE :queryName)';
        }        
        if (!String.isBlank(searchLang)) {
            queryLang = '%' + searchLang + '%';
            queryRes += ' AND Account__r.Language__pc LIKE :queryLang';
        } 
        if (!String.isBlank(searchStatus)) {
            queryStatus  = searchStatus + '%';
            queryRes += ' AND Status__c LIKE :queryStatus'; 
        }

        if (!String.isBlank(searchWeek)) {
            queryWeek = '%' + searchWeek + '%';
            queryRes += ' AND Week__c LIKE :queryWeek';
        }         
        if (checkInDateFrom != null) {
            queryCheckInFrom  = checkInDateFrom;
            queryRes += ' AND Arrival__c >= :queryCheckInFrom'; 
        }
        if (checkInDateTo != null) {
            queryChecInTo  = checkInDateTo;
            queryRes += ' AND Arrival__c <= :queryChecInTo'; 
        }        
     
        if (!String.isBlank(searchRoom)) {
            queryRoom = '%' + searchRoom + '%';
            queryRes += ' AND RoomNo__c LIKE :queryRoom';      
        } 
        if (!String.isBlank(searchCountry)) {
            queryConutry  = '%' + searchCountry + '%';
            queryRes += ' AND Account__r.Country_Name__pc LIKE :queryConutry'; 
        }
        if (reservRecordsLimit != null) {
            rLimit  = reservRecordsLimit;
        }
        
        //To avoid empty query, (Show All button)
        if (queryRes.length() == 0) queryRes = ' AND Arrival__c >= :queryCheckInFrom'; 
        List<String> mktSegmentes = getMkSegments();
        String excludeTourOp =  '\'0010O0000276QxA\', \'0010O0000276Qxy\', \'0010O0000276QuW\''; //Booking, Expedia, Hotelbeds 
        String queryResFinal = 'SELECT Id,Account__c,Opportunity__c, Account__r.Language__pc, Account__r.Country_Name__pc,' +
                           'Account__r.PROREF1__pc, Account__r.Employment_Type__pc,HotelId__c,RoomNo__c, Week__c,OccupantName__c,'+
                           'Adults__c, Children__c, MktSegment__c, Account__r.IsPersonAccount,'+
                           'Arrival__c, Departure__c, Status__c, CreatedDate FROM Reservation__c WHERE MktSegment__c in :mktSegmentes AND Account__c NOT IN(' + excludeTourOp + ')' + 
                           queryRes + 
                           ' ORDER BY CreatedDate DESC LIMIT ' + 
                           rLimit;
                
        reservations = Database.query(queryResFinal);      
        
         List<SourceCodes__c> sourceCode = [SELECT Id, Name, Group__c FROM SourceCodes__c];             

          for (Reservation__c reserv : reservations) {   
             for (SourceCodes__c source : sourceCode) {  
                 if (reserv.MktSegment__c == source.Name) 
                    reserv.MktSegment__c = source.Group__c;
             }             
         }                                                                 
    }  

    //Get Sales Reps and TOs
    public void doEventsQuery(){                        
                 
        tourEvents = [SELECT Id, StartDateTime, EndDateTime, Description, Allocation__r.Account__c,
                     Allocation__r.SalesRep__c, Status__c, Subject 
                     FROM Event WHERE Allocation__r.SalesRep__c = :selectedRepId 
                     AND Allocation__c = :tourEventAllocId 
                     AND Allocation__r.SalesRep__c != null
                     ORDER By StartDateTime DESC LIMIT 100];
    } 

    //Getting list of Allocations Tour
    public void doAllocTourQuery(){
    
        String queryStatus = ''; 
        String queryName = '';
        String queryLang = ''; 
        String queryHotel = '';
        String queryRepName = '';
        String queryMkSegment = '';  
        String queryConutry = '';
        Integer rLimit = 0; 
        String queryTour = '';        

        if (recordsLimit != null) rLimit  = recordsLimit;    

        //Create dynamic query
        if (!String.isBlank(searchName)) {
            queryName = '%' + searchName + '%';
            queryTour += ' AND (Account__r.Name LIKE :queryName OR Reservation__r.OccupantName__c = :queryName)';
        }        
        if (!String.isBlank(searchLang)) {
            queryLang = '%' + searchLang + '%';
            queryTour += ' AND Account__r.Language__pc LIKE :queryLang';
        } 
        if (!String.isBlank(searchHotel)) {
            queryHotel = '%' + searchHotel + '%';
            queryTour += ' AND Reservation__r.HotelId__c LIKE :queryHotel';
        }         
        if (!String.isBlank(searchStatus)) {
            queryStatus  = searchStatus + '%';
            queryTour += ' AND Status__c LIKE :queryStatus'; 
        }
        if (!String.isBlank(searchRepName)) {
            queryRepName = '%' + searchRepName + '%';
            queryTour += ' AND SalesRep__r.Name LIKE :queryRepName';
        }       
        if (!String.isBlank(searchMkSegment)) {
           queryMkSegment = '%' + searchMkSegment + '%'; 
           List<String> mktsegs = getMkSegments();
           queryTour += ' AND Reservation__r.MktSegment__c in :mktsegs';           
           queryTour += ' AND Reservation__r.MktSegment__c LIKE :queryMkSegment';          
        }        

        if (!String.isBlank(searchCountry)) {
            queryConutry  = '%' + searchCountry + '%';
            queryTour += ' AND Account__r.Country_Name__pc LIKE :queryConutry'; 
        }

        List<String> mktSegments = getMkSegments();
        String excludeTourOp =  '\'0010O0000276QxA\', \'0010O0000276Qxy\', \'0010O0000276QuW\''; //Booking, Expedia, Hotelbeds 
        String queryTourFinal = 'SELECT Id,Account__r.Id,Account__c,Reservation__r.Id, Account__r.Name, Account__r.Language__pc, Account__r.Country_Name__pc, SalesRep__r.Name,' +
                                'Reservation__r.Adults__c,Reservation__r.Children__c,Reservation__r.RoomNo__c,Reservation__r.HotelId__c, Reservation__r.MktSegment__c, Reservation__r.Week__c,'+
                                'Account__r.IsPersonAccount,CheckIn__c, CheckOut__c, SalesRep__c, SalesTO__c, Status__c, SalesISA__c, CreatedDate, AppointmentDate__c, AppointmentDay__c,' + 
                                'AppointmentTime__c,RoomNumbers__c,Toured__c, Reservation__r.OccupantName__c FROM Allocation__c ' + 
                                'WHERE Reservation__r.MktSegment__c in :mktSegments AND (Status__c = \'Alloc\' OR Status__c = \'Toured\') AND Account__c NOT IN(' + excludeTourOp + ')' +
                                queryTour + 
                                ' AND Status__c != \'S\' ORDER BY AppointmentDate__c DESC LIMIT ' +
                                rLimit;
        //System.debug('TOUR QUERY: ' + queryTourFinal);         
        allocTour = Database.query(queryTourFinal);      
                     
    }  

    //Create new Calendar Event
    public void CreateTourEvent(){
        String paramRepId = Apexpages.currentPage().getParameters().get('tourRepId');
        String paramAllocId = Apexpages.currentPage().getParameters().get('tourAllocId');
        String paramTourDescrip = Apexpages.currentPage().getParameters().get('tourDescrip');
        String paramRepName = Apexpages.currentPage().getParameters().get('tourRepName');
        String paramTourStartDate = Apexpages.currentPage().getParameters().get('tourStartDate');
        String paramTourStartTime = Apexpages.currentPage().getParameters().get('tourStartTime');
           
        try {        
            if (!String.isBlank(paramAllocId) 
                && !String.isBlank(paramTourStartDate)
                && !String.isBlank(paramTourStartTime)) {  
                //System.debug('TourEndTime: ' + '-' + endTime);  

                String[] dateParts = paramTourStartDate.split('-'); 
                String newDate = dateParts[2] + '/' + dateParts[1] + '/' + dateParts[0];   

                String[] timeParts = paramTourStartTime.split(':');

                Integer hours = Integer.valueOf(timeParts[0]);
                Integer min = Integer.valueOf(timeParts[1]);                

                startTourDay = date.parse(newDate); 
                startTime = Time.newInstance(hours, min,0,0);

                if (endTime != null)
                    endTime =  datetime.now().time().addHours(4);

                startTourDayTime = datetime.newInstance(startTourDay, startTime);
                endTourDayTime = datetime.newInstance(startTourDay, endTime);                  

                Event event = new Event(
                    OwnerId = '0230O000006SfhS', //Calendar Id
                    StartDateTime = startTourDayTime,
                    EndDateTime = endTourDayTime,
                    Subject = 'Tour - ' + paramRepName,
                    Location = 'Aspirantco Office',
                    Description = paramTourDescrip,
                    Sales_Staff__c = paramRepId,
                    Allocation__c = paramAllocId,
                    Status__c = 'Appointed'
                );
                event.Subject = event.Subject + ' - ' + event.Status__c;
                Insert event;       
                
                checkAllocationTour(paramAllocId, false);
                
                //Get event record set with the new added record
                doEventsQuery();
                doAllocTourQuery();
                doAllocQuery();
            }

        } catch(DmlException ex){           
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, ex.getMessage()));               
        } catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage())); 
        }
        finally{}
    } 

    //Delete Event from Calendar
    public void doDeleteTourEvent(){
        String tourEventId = Apexpages.currentPage().getParameters().get('tourEventId');
        String tourEventStatus = Apexpages.currentPage().getParameters().get('tourEventStatus');
        String tourAllocId = Apexpages.currentPage().getParameters().get('tourAllocId');
        try{
            List<Event> lstEventsToDelete = new List<Event>();

            Event eventDel = new Event(
                Id=tourEventId
            );

            lstEventsToDelete.add(eventDel);
            Delete lstEventsToDelete;
            if (tourEventStatus == 'Completed'){
                //System.debug('Alloc status: ' + tourEventStatus);         
                changeAllocation(tourAllocId, 'Alloc');
            }

            Integer count = [SELECT count() FROM Event WHERE Allocation__c = :tourAllocId];             
            //System.debug('Evento count: ' + count);
            if (count == 0 && !String.isBlank(tourAllocId) ){
                checkAllocationTour(tourAllocId, true);
            }

            doEventsQuery();
            doAllocTourQuery();
            doAllocQuery();
        } catch(DmlException ex){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, ex.getMessage()));               
        } 
    }   

    //Update Calendar Tour Event
    public void doUpdateTourEvent(){
        try{  
            String allocId;
            Boolean completed = false;
            for (Event tourEvent : tourEvents) {  
                String evSubject = tourEvent.Subject;
                String[] subjectLine = evSubject.split('-');
                subjectLine[2] = tourEvent.Status__c;    
                tourEvent.Subject = subjectLine[0] + ' - ' + subjectLine[1] + ' - ' + subjectLine[2];     

                if (tourEvent.Status__c == 'Completed') {                              
                    changeAllocation(tourEvent.Allocation__c, 'Toured');  
                    completed = true;  
                   
                } else {
                    if (!completed)
                        changeAllocation(tourEvent.Allocation__c, 'Alloc'); 
                }
                allocId = tourEvent.Allocation__c;
            }   
            update tourEvents;        

            checkAllocationTour(allocId, false);
            doAllocTourQuery();
        } catch(DmlException ex){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, ex.getMessage()));               
        }     
    }      

    private void changeAllocation(Id allocId, String status){
        List<Allocation__c> allocs = new List<Allocation__c>();
        allocs = [SELECT Id, Status__c, Toured__c FROM Allocation__c  WHERE Id = :allocId];    
            if (!allocs.isEmpty()){    
            allocs[0].Status__c = status;        
            if (status == 'Toured') allocs[0].Toured__c = true;
            if (status == 'Alloc') allocs[0].Toured__c = false;
            update allocs;
        }
    }  

    private void checkAllocationTour(Id allocId, boolean reset){
        List<Allocation__c> allocs = new List<Allocation__c>();
        allocs = [SELECT Id, Status__c, Toured__c, AppointmentDay__c FROM Allocation__c  WHERE Id = :allocId];   
        if (!allocs.isEmpty()){
            if (reset) {
                if (allocs[0].AppointmentDay__c != null)
                    allocs[0].AppointmentDay__c = allocs[0].AppointmentDay__c.replace(' *','');     
            } else {  
                if (allocs[0].AppointmentDay__c != null)
                    allocs[0].AppointmentDay__c = allocs[0].AppointmentDay__c.replace(' *','') + ' *';        
            }
            update allocs;
        }
    }     
    
    private List<String> getMkSegments(){
        List<String> segments = new List<String>();
        List<SourceCodes__c> sourceCode = [SELECT Id, Name, Group__c FROM SourceCodes__c];             
        for (SourceCodes__c source : sourceCode) {  
            segments.add(source.Name);
        }                       
        return segments;
    }

    public PageReference ShowError() {
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Save Complete!', 'And I totally could have redirected you or something.');
          ApexPages.addMessage(myMsg);
          return null;
   }
                 
}