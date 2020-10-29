import ballerina/http;
import ballerina/java.jdbc;
import ballerina/io;
import ballerina/sql;

jdbc:Client employeeDB = check new("jdbc:mysql://localhost:3306/Bussiness","sachini","Rootpw@1995");

type Customer record {|
    string name;
    int age;
    string gender;
|};

type UpdateCustomer record {|
    int id;
    string name;
    int age;
    string gender;
|};

@http:ServiceConfig {
    basePath:"/"
}
service simpleService on new http:Listener(8080) {


    @http:ResourceConfig {
        path:"/customer/{id}",
        methods: ["GET"]
    }
    resource function getResource(http:Caller caller, http:Request request,int id) returns @tainted error? { //why??

        io:println(id);
        string? returnName = ();
        json updateStatus = {};

        http:Response response = new;

        stream<record{},error> rs = employeeDB->query(`SELECT * FROM Customers WHERE id=${<@untainted>id}`);
        //var dbresult = employeeDB->query(`SELECT * FROM customer WHERE id=${<@untainted>id}`);

       record{|record{} value;|}?  entry = check rs.next();
                io:println(entry);

       if entry is record{|record{} value;|}{
            returnName = <@untainted> <string> entry.value["name"];
            //check caller-> ok(returnName);
            //io:println(returnName);
            response.statusCode = 200;
            response.setPayload({"name": returnName});

        }else{
            //check caller-> badRequest();

            response.statusCode = 400;
            updateStatus = { "Status": "Error: Please send params  in the correct format"};

            response.setPayload(updateStatus);
        }


        var respondRet = caller->respond(response);
        if (respondRet is error) {
            // Log the error for the service maintainers.
            io:println("Error responding to the client", respondRet);
        }

    }


    @http:ResourceConfig {
        path:"/customer",
        methods:["POST"],
        body: "customer"
    }
    resource function storeResource(http:Caller caller, http:Request request,Customer customer) returns @tainted error? {
        json updateStatus = {};
        http:Response response = new;
        //io:println(customer);
        var dbresult =  employeeDB->execute(`INSERT INTO Customers (name,age,gender) VALUES (${<@untainted> <string>customer.name},${<@untainted> <int> customer.age},${<@untainted> <string> customer.gender})`);

        if dbresult is sql:ExecutionResult{
            updateStatus = { "Status": "Data Inserted Successfully"};
            //check caller->ok(updateStatus);

        }else{
            //check caller->badRequest();
            response.statusCode = 400;
            updateStatus = { "Status": "Data insert was not succsessful"};
        }

        response.setPayload(updateStatus);

        var respondRet = caller->respond(response);
        if (respondRet is error) {
            // Log the error for the service maintainers.
            io:println("Error responding to the client", respondRet);
        }
    }


    @http:ResourceConfig {
        path:"/customer",
        methods:["PUT"],
        body:"customer" 
    }
    resource function updateResource(http:Caller caller, http:Request request,UpdateCustomer customer) returns @tainted error? {

        io:println(customer);

        json updateStatus = {};
        http:Response response = new;
        //check the update
        var dbresult =  employeeDB->execute(`UPDATE Customers SET name=${<@untainted><string>customer.name},age=${<@untainted><int>customer.age},gender=${<@untainted><string>customer.gender} WHERE id = ${<@untainted>customer.id}`);

        if dbresult is sql:ExecutionResult{
            updateStatus = { "Status": "Data Updated Successfully" };
            response.statusCode = 200;
            response.setPayload({"status": updateStatus});
            //check caller->ok(updateStatus);
        }else{
            
            updateStatus = { "Status": "Data insert was not succsessful"};
            response.statusCode = 400;
            response.setPayload({"status": updateStatus});

            //check caller->badRequest();
        }
        var respondRet = caller->respond(response);
        if (respondRet is error) {
            // Log the error for the service maintainers.
            io:println("Error responding to the client", respondRet);
        }
    }

    @http:ResourceConfig {
        path:"/customer/{id}",
        methods:["DELETE"]
    }
    resource function deleteResource(http:Caller caller, http:Request request,int id)returns @tainted error? {
        //io:println(id);
        json updateStatus = {};
        http:Response response = new;
        
        var dbresult =  employeeDB->execute(`DELETE FROM Customers WHERE id = ${<@untainted>id}`);

        if dbresult is sql:ExecutionResult{

            updateStatus = { "Status": "Data Deleted Successfully" };
            response.statusCode = 200;
            response.setPayload({"status": updateStatus});
 
            //check caller->ok(updateStatus);
        }else{

            updateStatus = { "Status": "Data not deleted Successfully" };
            response.statusCode = 400;
            response.setPayload({"status": updateStatus});

            //check caller->badRequest();
        }
        var respondRet = caller->respond(response);
        if (respondRet is error) {
            // Log the error for the service maintainers.
            io:println("Error responding to the client", respondRet);
        }    
    }
}