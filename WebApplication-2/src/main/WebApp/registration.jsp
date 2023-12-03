<!DOCTYPE html>
<html>
<head>
    <title>Welcome to Team4Tech Registration Form</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }
        header {
            background-image: url('banner1.png'); /* Replace 'your_banner_image.jpg' with your image path */
            background-size: cover;
            color: #fff;
            padding: 60px 20px;
            text-align: center;
            position: relative; /* Added for positioning */
        }
        header img {
            max-width: 150px;
            height: auto;
        }
        .contact-info {
            margin-top: 20px;
            font-size: 18px;
            color: #fff;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .contact-info a {
            color: black; /* Social text color */
            text-decoration: none;
            margin: 0 10px;
        }
        .contact-info a:hover {
            text-decoration: underline;
        }
        form {
            max-width: 600px;
            margin: 20px auto;
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            font-size: 16px;
            line-height: 1.6;
            color: #333; /* Form text color */
        }
        form input[type="text"] {
            width: calc(100% - 20px);
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 16px;
        }
        form input[type="submit"] {
            background-color: #007bff;
            color: #fff;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
        }
        form input[type="submit"]:hover {
            background-color: #0056b3;
        }
        form label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .text-on-right {
            position: absolute;
            top: 5%;
            right: 20px; /* Adjust the right position as needed */
            transform: translateY(-50%);
            text-align: right;
            color: black; /* Text color */
            font-style: italic;
        }
        .text-on-right h3 {
            font-size: 24px;
            margin-bottom: 10px;
        }
        .text-on-right p {
            font-size: 18px;
            margin-bottom: 5px;
        }
    </style>
</head>
<body>
<header>
    <!-- Replace 'path/to/your/logo.png' with your actual logo path -->
    <img src="logo 2.png" alt="Team4Tech Solutions Logo">

    <h2 style="text-align: center; margin-top: 30px;">Registration Form</h2>
    <form action="registration" method="post" style="text-align: center;">
        <label for="firstName">First Name:</label>
        <input type="text" id="firstName" name="firstName"><br>
        <label for="lastName">Last Name:</label>
        <input type="text" id="lastName" name="lastName"><br>
        <label for="address">Address:</label>
        <input type="text" id="address" name="address"><br>
        <label for="email">Email:</label>
        <input type="text" id="email" name="email"><br>
        <label for="phoneNumber">Phone Number:</label>
        <input type="text" id="phoneNumber" name="phoneNumber"><br>
        <label for="course">Course Selection:</label>
        <input type="text" id="course" name="course"><br>
        <input type="submit" value="Submit">
    </form>

    <div class="contact-info">
        <a href="https://www.instagram.com/team4techsolutions/?next=%2F">
            <img src="insta.png" alt="Instagram">
        </a>
        <a href="https://www.linkedin.com/company/team4tech-solutions/?viewAsMember=true">
            <img src="link.png" alt="LinkedIn">
        </a>
        <a href="https://team4techsolutions.com/">
            <img src="web.png" alt="Website">
        </a>
        <a href="mailto:info@team4techsolutions.com">
            <img src="mail.png" alt="E-mail">
        </a>
        <a href="tel:+16476414509">
            <img src="phone.png" alt="Phone">
        </a>
    </div>

    <div class="text-on-right">
        <h3>Welcome to Team4Tech Solutions DevOps / Cloud Master Program</h3>
        <p>“Beyond Code: Breathing Life Into Software Dreams”</p>
    </div>
</header>
</body>
</html>
