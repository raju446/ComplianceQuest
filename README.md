**Test Scenarios**

Activate the batch process by scheduling it using the following method:

1. Open the Developer Console.
2. Navigate to **Execute Anonymous**.
3. Run the following command:-

    **PartToProductScheduler.scheduleJob();**

1. Admin User with Permission Set

•	Scenario: System Admin user with CQ Product Admin permission set executes the batch.
•	Expected: Batch executes successfully.

2. Standard User Without Permission

•	Scenario: A standard user (non-admin) tries to execute the batch.
•	Expected: Access denied or no records are processed.

**Functional Test Cases**

3. Part with No Product Reference, Matching Product Exists

•	Setup:
•	Create a SQX_Part__c record (with Name = "Test Part", Part Number = "Test Part - 1234").
•	Create a Product2 record (Name = " Test Part", ProductCode = " Test Part - 1234").
•	Expected: Part gets updated with the correct Product lookup.

4. Part with No Product Reference, No Matching Product

•	Setup:
•	Create a SQX_Part__c record (Name = "Sensor", Part Number = "S456").
•	Ensure no Product2 exists with Name = "Sensor" and ProductCode = "S456".
•	Expected:
•	A new Product2 is created.
•	IsActive = true on Product2.
•	Part’s Product__c is updated with this new Product.

5. Part with Existing Product Lookup

•	Setup:
•	Create a SQX_Part__c with Product__c already populated.
•	Expected: The part is skipped and not updated again.

6. Inactive Parts Should Be Ignored

•	Setup:
•	Create a SQX_Part__c with Active = false.
•	Expected: No changes are made to this record.

**Security & Access Test Cases**

7. Permission Set Behavior

•	Validate that only users with the CQ Product Admin permission set and System Admin profile  can execute or schedule the job.
