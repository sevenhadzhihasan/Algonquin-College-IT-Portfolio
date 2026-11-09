# Lab Report: Azure Cloud Infrastructure & Services

## 01 - Create Blob Storage
In this task, a globally unique storage account and a private blob container were provisioned to host static file storage.
*   **Storage Account Name:** `storageaccounthadz0024`
*   **Container Name:** `container1hadz0024`

![Lab 06-01](path/to/Lab_06-01.png)

---

## 02 - Implement an Azure IoT Hub
An Azure IoT Hub instance was deployed to securely connect, manage, and scale messages from a simulated remote device.
*   **IoT Hub Name:** `my-hub-grouphadz0024`
*   **Device Identity:** `myRaspberryPi`

### Simulated Device Stream Data
The Raspberry Pi web simulator authenticated successfully using the Primary Connection String and initiated telemetry ingestion.

![Lab 06-02](path/to/Lab_06-02.png)

### Telemetry Performance Metrics
The Azure Portal metric dashboard tracked message usage, telemetry limits, and server response delivery.

![Lab 06-03](path/to/Lab_06-03.png)

---

## 03 - Create a Web App
An automated Azure App Service instance running a public containerized Docker app from Docker Hub was created.
*   **Web App App Service URL:** `hadz0024-cfdwbug2cbhab6ap.westus3-01.azurewebsites.net`
*   **Docker Container Image:** `dockercloud/hello-world`

![Lab 06-04](path/to/Lab_06-04.png)

---

## 04 - Create a VM with PowerShell
An automated infrastructure deployment using the Cloud Shell Azure PowerShell module provisioned an isolated compute instance.
*   **Resource Group:** `myRGPSXXXX`
*   **Virtual Machine:** `myVMPSXXXX`

![Lab 06-06](path/to/Lab_06-06.png)

---

## 05 - Create a VM with the CLI
Cross-platform provisioning was executed inside the Cloud Shell Bash terminal utilizing structured Azure CLI operations.
*   **Resource Group:** `myRGCLIXXXX`
*   **Virtual Machine:** `myVMCLIXXXX`

![Lab 06-07](path/to/Lab_06-07.png)
