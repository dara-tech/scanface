# 👤 How to Create Admin Account

## Method 1: Through Registration Screen (Recommended)

1. **Open the Registration Screen** from the login page
2. **Fill in the form**:
   - Name
   - Email
   - Phone (optional)
   - Password (at least 6 characters)
   - Confirm Password
3. **Select Role**: Choose **"Admin"** from the role dropdown
4. **Click Register**

The account will be created with admin privileges and you'll be automatically logged in.

## Method 2: Direct API Call

You can create an admin account directly via the backend API:

```bash
curl -X POST http://192.168.0.107:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Admin User",
    "email": "admin@example.com",
    "password": "admin123",
    "role": "admin"
  }'
```

## Method 3: MongoDB Direct (Advanced)

If you have MongoDB access:

```javascript
// Connect to MongoDB
use attendance_db

// Create admin user
db.users.insertOne({
  name: "Admin User",
  email: "admin@example.com",
  password: "$2a$10$...", // Hashed password (use bcrypt)
  role: "admin",
  isActive: true,
  createdAt: new Date(),
  updatedAt: new Date()
})
```

**Note**: For MongoDB method, you'll need to hash the password using bcrypt first.

## Method 4: Using MongoDB Compass or CLI

1. Connect to your MongoDB database
2. Navigate to the `users` collection
3. Insert a new document with:
   ```json
   {
     "name": "Admin User",
     "email": "admin@example.com",
     "password": "<bcrypt_hashed_password>",
     "role": "admin",
     "isActive": true,
     "createdAt": ISODate(),
     "updatedAt": ISODate()
   }
   ```

## Password Hashing

If creating directly in MongoDB, you need to hash the password. You can use Node.js:

```javascript
const bcrypt = require('bcryptjs');
const hashedPassword = await bcrypt.hash('yourpassword', 10);
console.log(hashedPassword);
```

## Quick Test

After creating an admin account, test login:

```bash
curl -X POST http://192.168.0.107:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "admin123"
  }'
```

## ⚠️ Security Note

- Admin accounts have full access to the system
- Only create admin accounts for trusted users
- Use strong passwords for admin accounts
- Consider implementing admin account creation restrictions in production

