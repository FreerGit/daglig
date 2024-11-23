docker run -p 80:80 -e "PGADMIN_DEFAULT_EMAIL=user@domain.com" -e "PGADMIN_DEFAULT_PASSWORD=supersecret" -d dpage/pgadmin4

to get pgAdmin

ip addr show docker0

to get ip


# todo
When handling requests and identifying users, it's generally a better idea to use a unique identifier from your users table (e.g., user_id) rather than relying on the user's email. Here's why:

Why use user_id instead of email?
Emails can change: Users may update their email addresses. If your system relies on email as the primary identifier, it could lead to complications when users update their emails.
Database indexing and performance: Using a numeric user_id for lookups is generally faster and more efficient than a text field like email, especially as the database grows.
Security considerations: Exposing email addresses in URLs, logs, or responses can inadvertently leak sensitive user information.
Recommended Approach:
Store user_id in sessions or tokens: When a user logs in, store their user_id in the session or generate a token (e.g., JWT) that includes the user_id. Use this ID to look up user data when processing requests.
Retrieve user details by user_id: Use user_id to query both the users table and any related tables like oauth_accounts.
Adjusting your schema for best practices
Your current schema already supports this approach because:

The users table has a user_id as a primary key.
The oauth_accounts table links back to users via the user_id.
Implementation Example
When a user logs in:

Use their OAuth provider's unique provider_account_id to find or create their account in oauth_accounts.
If this is the first login, create a new row in users and store the resulting user_id in oauth_accounts.
Store the user_id in the session or token.
When handling a request:

Extract the user_id from the session or token.
Query the database to retrieve user information using the user_id.
Example Query Flow
Login Flow:

```sql
-- Check if OAuth account exists
SELECT user_id FROM oauth_accounts 
WHERE provider = ? AND provider_account_id = ?;

-- If it doesn't exist, create the user
INSERT INTO users (email, username, image) VALUES (?, ?, ?)
RETURNING user_id;

-- Link the OAuth account to the new user
INSERT INTO oauth_accounts (user_id, provider, provider_account_id, access_token) 
VALUES (?, ?, ?, ?);
```

```sql
-- Retrieve user details by user_id
SELECT * FROM users WHERE user_id = ?;
By centralizing everything around user_id, you create a stable, reliable identifier for users across your system.```