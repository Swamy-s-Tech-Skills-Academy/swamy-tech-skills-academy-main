Radio Station

Across India

1. Different states broad casting different programs
2. Web Application 
   1. Display the program information (Live) - Not a streaming
   2. Once the program ends, it should take that off the screen
   3. Users will login to Web App
   4. User will be able to Comment on the program


Identity:
---------------
1. Auth


Admin Web Application:
-----------------------
Internal

User Web Application:
---------------------
1. User Registration

CDN:
----

Caching:
---------
*************** DMZ ***************

API Gateways:
--------------


Middletier:
-----------
User

Shows
    Country/Programs?filter=&Page=5
    [Policies]
    State/Programs?filter=&Page=5
    State/Programs/{id}/users/{id}/comments

Admin
POST api/State/Programs

Data Stores:
--------------
SQL: Live Shows for Week
Caching - 
No SQL: Reproting

   ESB:
---------
Compoteled Program

Reporting/Analytics:

Observability (Alerts and Monitoring)