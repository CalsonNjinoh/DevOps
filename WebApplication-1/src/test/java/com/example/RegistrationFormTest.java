package com.example;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.firefox.FirefoxDriver;

public class RegistrationFormTest {
    public static void main(String[] args) {
        // Set the path to your ChromeDriver executable
        System.setProperty("webdriver.gecko.driver", "G:\\FIVERR_PROJECTS\\WebApplication\\geckodriver.exe");

        // Initialize ChromeDriver
        WebDriver driver = new FirefoxDriver();
        // Maximize the browser window
        driver.manage().window().maximize();

        // Open the web page containing the registration form
        driver.get("http://localhost:3000/WebApplication-1.0-SNAPSHOT/");

        // Fill in the form fields
        WebElement firstNameField = driver.findElement(By.name("firstName"));
        firstNameField.sendKeys("John");

        WebElement lastNameField = driver.findElement(By.name("lastName"));
        lastNameField.sendKeys("Doe");

        WebElement addressField = driver.findElement(By.name("address"));
        addressField.sendKeys("123 Main St");

        WebElement emailField = driver.findElement(By.name("email"));
        emailField.sendKeys("john@example.com");

        WebElement phoneField = driver.findElement(By.name("phoneNumber"));
        phoneField.sendKeys("1234567890");

        WebElement courseSelectionField = driver.findElement(By.name("course"));
        courseSelectionField.sendKeys("Selenium Testing");

        // Submit the form
        WebElement submitButton = driver.findElement(By.cssSelector("input[type='submit']"));
        submitButton.click();


        // Wait for a few seconds to see the result (you might want to use proper waits in a real scenario)
        try {
            Thread.sleep(3000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        // Close the browser
        driver.quit();
    }
}
