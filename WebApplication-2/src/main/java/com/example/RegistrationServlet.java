package com.example;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.ServletException;

//import javax.servlet.ServletException;
//import javax.servlet.annotation.WebServlet;
//import javax.servlet.http.HttpServlet;
//import javax.servlet.http.HttpServletRequest;
//import javax.servlet.http.HttpServletResponse;
import org.bson.Document;
import java.io.IOException;

//@WebServlet("/registration")
public class RegistrationServlet extends HttpServlet {
    private static final String MONGO_CONNECTION_STRING = "mongodb+srv://pheonix:sorrycom69@cluster0.2lycm.mongodb.net/JOBIFY-DATABASE";
    private static final String DB_NAME = "JOBIFY-DATABASE";
    private static final String collectionName = "JOBIFY-COLLECTION";
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String address = request.getParameter("address");
        String email = request.getParameter("email");
        String phoneNumber = request.getParameter("phoneNumber");
        String course = request.getParameter("course");

        // Create a MongoDB document with the form data
        Document document = new Document()
                .append("firstName", firstName)
                .append("lastName", lastName)
                .append("lastName", lastName)
                .append("address", address)
                .append("email", email)
                .append("phoneNumber", phoneNumber)
                .append("courseSelection", course);

        // Handle the data as required, e.g., store in a database
        MongoDBConnection mongoDBConnection = new MongoDBConnection(MONGO_CONNECTION_STRING, DB_NAME, collectionName);
        mongoDBConnection.InsertOne(document);
        mongoDBConnection.close();
        // For now, let's print the received data to the console
        System.out.println("Received data:");
        System.out.println("Full Name: " + firstName + " " + lastName);
        System.out.println("Address: " + address);
        System.out.println("Email: " + email);
        System.out.println("Phone Number: " + phoneNumber);
        System.out.println("Course Selection: " + course);

        // Redirect to a thank you page or any other page as needed
        response.sendRedirect("registration.jsp");
    }
}
