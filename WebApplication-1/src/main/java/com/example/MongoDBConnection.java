package com.example;

import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import org.bson.Document;
public class MongoDBConnection {
    private final MongoClient mongoClient;
    private final MongoDatabase database;
    private final MongoCollection<Document> collection;
    public MongoDBConnection(String connectionString, String dbName, String collectionName){
        this.mongoClient = MongoClients.create(connectionString);
        this.database = mongoClient.getDatabase(dbName);
        this.collection = database.getCollection(collectionName);
    }
    public void InsertOne(Document document){
        collection.insertOne(document);
    }
    public void close() {
        mongoClient.close();
    }
    public MongoDatabase getDatabase() {
        return database;
    }
}