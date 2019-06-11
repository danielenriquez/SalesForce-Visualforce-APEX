# Sales Allocation App
<b>Visualforce/APEX/SOQL</b> application to allocate incoming clients to the sales representative. Using standard object (<em>Account, Opportunity, Event</em>) and some custom objects (<em>Allocation__c, Reservation__c, Sales_Staff__c</em>).

<b>How it works:</b> Managers with the App, can check the list of reservations of clients who are interested in the product presentation, based on those reservations, managers allocate clients to the right sales representative. Once allocations is done, they book an specific day on the Calendar(Event is registered on the SalesForce Calendar).

<b>Allocations.page</b> Is the App frontend, a Visualforce page with the visual interface to create, update or filter the data. It is based on three tabs, "Reservations", "Allocations", "Tour Appointment".

<b>AllocationsController.cls</b> Is the App controller, an APEX class with the functions and procedures to manage and retrive data from SalesForce objects.

<b>Reservations Screenshot</b>

![reservations-1](https://user-images.githubusercontent.com/8003697/59267851-31efb000-8c43-11e9-9257-4fdecf791afb.jpg)

<b>Allocations Screenshot</b>

![allocation-1](https://user-images.githubusercontent.com/8003697/59267812-1389b480-8c43-11e9-90bc-1fc7ceb7fdaa.jpg)

<b>Tour Appointments Screenshot</b>

![tour-1](https://user-images.githubusercontent.com/8003697/59267892-48960700-8c43-11e9-8af7-6db40ac51359.jpg)
