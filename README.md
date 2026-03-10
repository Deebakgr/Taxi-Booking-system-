# Taxi Booking System – ABAP RAP Managed Scenario

## Project Overview

The **Taxi Booking System** is developed using the **ABAP RESTful Application Programming Model (RAP)** with a **Managed Scenario**. This application allows users to book taxis, manage booking records, and track ride details through a **SAP Fiori-based interface**.

The project demonstrates how the RAP managed framework simplifies enterprise application development by automatically handling **Create, Read, Update, and Delete (CRUD)** operations without requiring extensive manual coding.

---

## Objectives

The primary objectives of this project are:

* To develop a **Taxi Booking System using SAP ABAP RAP**.
* To demonstrate the **Managed Scenario implementation**.
* To manage taxi ride booking records efficiently.
* To create a **Fiori-based UI** for taxi booking management.
* To understand the RAP architecture and development workflow.

---

## Technologies Used

* **ABAP RESTful Application Programming Model (RAP)**
* **Core Data Services (CDS)**
* **Behavior Definition (Managed Implementation)**
* **Behavior Projection**
* **Service Definition**
* **Service Binding (OData V4)**
* **SAP Fiori Elements**

---

## System Architecture

The application follows the **RAP layered architecture**:

1. **Database Table**

   * Stores taxi booking information.

2. **Interface CDS View**

   * Defines the business object interface.

3. **Behavior Definition (Managed Scenario)**

   * Handles CRUD operations automatically.

4. **Projection CDS View**

   * Used for UI consumption.

5. **Behavior Projection**

   * Exposes operations to the UI layer.

6. **Service Definition**

   * Exposes the business object.

7. **Service Binding**

   * Connects the application to SAP Fiori through OData services.

---

## Key Features

* Taxi booking creation
* View taxi booking details
* Update ride information
* Cancel taxi bookings
* Fiori-based user interface
* Automatic CRUD operations using RAP managed behavior

---

## Booking Data Fields

| Field Name      | Description                             |
| --------------- | --------------------------------------- |
| Booking_ID      | Unique identifier for each taxi booking |
| Customer_Name   | Name of the customer                    |
| Pickup_Location | Starting location of the ride           |
| Drop_Location   | Destination of the ride                 |
| Booking_Time    | Time of booking                         |
| Fare            | Total ride fare                         |

---

