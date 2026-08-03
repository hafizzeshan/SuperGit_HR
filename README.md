# supergithr

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
## Mobile Employee Profile API

### 1. Update Personal Information

PUT /api/employees/{employee_id}
Authorization: Bearer <token>
Content-Type: application/json

Payload:

{
  "name": "Ahmed Ali",
  "national_id": "1234567890",
  "nationality": "Saudi",
  "gender": "Male",
  "phone": "+966501234567",
  "email": "ahmed@example.com",
  "date_of_birth": "1995-04-20"
}

Supported fields:

Arabic Label | API Field | Notes
---|---|---
الاسم | name | Full employee name
رقم الهويه | national_id | Maps to employee document_id
الجنسيه | nationality | Employee nationality
الجنس | gender | Male or Female
رقم الهاتف | phone | Maps to employee mobile_number
الايميل | email | Valid email format
تاريخ الميلاد | date_of_birth | Format: YYYY-MM-DD

Also supported aliases:

- `document_id` instead of `national_id`
- `mobile_number` or `phone_number` instead of `phone`
- `avatar_url` if uploading image separately is not needed

### 2. Upload/Edit Profile Image

PUT /api/employees/{employee_id}/avatar
Authorization: Bearer <token>
Content-Type: multipart/form-data

Also supported:

POST /api/employees/{employee_id}/avatar

Accepted file field names:

- `avatar`
- `profile_image`
- `image`

Example multipart field:

profile_image: <image-file>

Backend uploads the image to Cloudinary and updates:

{
  "avatar_url": "https://res.cloudinary.com/.../employee-image.jpg"
}

### 3. Example Success Response

{
  "message": "Employee updated successfully",
  "data": {
    "id": "employee-uuid",
    "name": "Ahmed Ali",
    "document_id": "1234567890",
    "nationality": "Saudi",
    "gender": "Male",
    "mobile_number": "+966501234567",
    "email": "ahmed@example.com",
    "date_of_birth": "1995-04-20",
    "avatar_url": "https://res.cloudinary.com/.../employee-image.jpg"
  }
}
