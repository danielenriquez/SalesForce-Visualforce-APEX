@isTest
private class tst_AllocationController
{
	//@isTest
	static testMethod void AllocationController_test(){

		Account account = new Account();
		account.FirstName = 'FirstName';
		account.LastName = 'LastName';         
		account.Phone = '123456789';                 
		account.PersonEmail = 'mail@mail.com';           
		account.Language__pc = 'ENG';      
		account.Nationality__pc = 'British';          
		account.PersonMailingStreet = 'Street'; 
		account.PersonMailingPostalCode = 'PostalCode';      
		account.PersonMailingCity = 'City';  
		account.PersonMailingCountry = 'Country';  
		account.CurrencyIsoCode = 'GBP';  
		account.SihotGuestObjId__pc = '333333333';
		Insert account;	

		Opportunity opportunity = new Opportunity();
		opportunity.AccountId = account.Id;
		opportunity.Description = 'SIHOT Opportunity'; 
		opportunity.StageName = 'Qualification';
		opportunity.CloseDate = Date.Today();
		opportunity.CurrencyIsoCode = account.CurrencyIsoCode;
		opportunity.Name = 'FirstName - LastName';
		opportunity.Adults__c = 4;
		opportunity.Children__c =  2;
		opportunity.Room_Number__c = '22222';
		opportunity.REQ_Acm_Arrival_Date__c = Date.today();
		opportunity.REQ_Acm_Departure_Date__c = Date.today();
		opportunity.Resort__c =  '4';		
		Insert opportunity;	

		Reservation__c reserv = new Reservation__c();
		reserv.Account__c = account.Id;
		reserv.Opportunity__c = opportunity.Id;
		reserv.MktSegment__c = 'FB';
		reserv.HotelId__c = '4';
		reserv.Number__c = '1';
		reserv.SubNumber__c = '2';
		reserv.Arrival__c = date.today();
		Insert reserv;

		Allocation__c alloc = new Allocation__c();
		alloc.Account__c = account.Id;
		alloc.AppointmentDate__c = date.today();
		alloc.AppointmentDay__c = 'Monday *';
		alloc.Status__c = 'Alloc';	
		alloc.CheckIn__c =  Date.today();
		alloc.Reservation__c = reserv.Id;	
		alloc.Toured__c = true;
		alloc.SalesRep__c = null;
		alloc.SalesISA__c = null;        
		Insert alloc;		

		Allocation__c alloc1 = new Allocation__c();
		alloc1.Account__c = account.Id;
		alloc1.AppointmentDate__c = date.today();
		alloc1.AppointmentDay__c = 'Monday *';
		alloc1.Status__c = 'Unallo';	
		alloc1.CheckIn__c =  Date.today();
		alloc1.Reservation__c = reserv.Id;
		alloc1.SalesRep__c = null;
		alloc1.SalesISA__c = null;
		Insert alloc1;

		Allocation__c alloc2 = new Allocation__c();
		alloc2.Account__c = account.Id;
		alloc2.AppointmentDate__c = date.today();
		alloc2.AppointmentDay__c = 'Monday *';
		alloc2.Status__c = 'Alloc';	
		alloc2.CheckIn__c = null;
		alloc2.Reservation__c = reserv.Id;	
		alloc2.Toured__c = true;
		alloc2.SalesRep__c = null;
		alloc2.SalesISA__c = null;
		Insert alloc2;             

		Event eve = new Event();
		eve.EndDateTime = datetime.now()+10;
		eve.StartDateTime = datetime.now();
		Insert eve;

		Sales_Staff__c staff = new Sales_Staff__c();
		staff.Name = 'test';
		staff.Active__c = true;
		Insert staff;

		Test.setCurrentPage(Page.Allocations);

        ApexPages.currentPage().getParameters().put('tourRepId',staff.Id);
        ApexPages.currentPage().getParameters().put('tourAllocId', alloc.Id);
        ApexPages.currentPage().getParameters().put('tourDescrip', 'Tour description');
        ApexPages.currentPage().getParameters().put('tourRepName', 'Rep Name');
        ApexPages.currentPage().getParameters().put('tourEventId', eve.Id);
        ApexPages.currentPage().getParameters().put('tourStartDate','2019-01-01');
        ApexPages.currentPage().getParameters().put('tourStartTime','15:00');				

		AllocationsController controller = new AllocationsController();   

        controller.allocations.add(alloc);
		controller.allocations.add(alloc1);
		controller.allocations.add(alloc2);
        
        controller.updateAllAllocation();
		controller.updateAllRepsAllocations();
		controller.updateBulkAllocation();        
        
		controller.searchStatus = 'Alloc';
		controller.searchName = 'Test';
		controller.searchLang = 'ENG';
		controller.searchHotel = '4';
		controller.searchReps = 'Test';
		controller.searchType = 'Test';
		controller.searchMkSegment = 'FB';
		controller.searchCountry = 'GB';
		controller.searchRepName = 'Test';
		controller.searchRoom = '1111';
		controller.searchAllocRoom = '1111';

		controller.checkInDateFrom = date.today()-365; //'2017-08-10T00:00:00Z';  
		controller.checkInDateTo = date.today()+10;   
		
		controller.recordsLimit = 10; 
		controller.reservRecordsLimit = 10;

		controller.tourDescription='';

		controller.doReservQuery();
		controller.doAllocQuery();
		controller.doAllocQueryStart();

		controller.selectAllocatedByRep();
		controller.CreateTourEvent();
        controller.doUpdateTourEvent();
		controller.doDeleteTourEvent();

	}
}