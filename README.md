# Sales Allocation App
Visualforce/APEX/SOQL application to allocate incoming clients to the sales representative. Using standard object (<em>Account, Opportunity, Event</em>) and some custom objects (<em>Allocation__c, Reservation__c, Sales_Staff__c</em>).

<b>How it works:</b> Managers with the App, can check the list of reservations of clients who are interested in the product presentation, based on those reservations, managers allocate clients to the right sales representative. Once allocations is done, they book an specific day on the Calendar(Event is registered on the SalesForce Calendar).

<b>Allocations.page</b> Is the App frontend, a Visualforce page, with the visual interface to magage de data.
