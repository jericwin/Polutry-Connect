import requests

url = 'http://localhost:5000/auth/reset_password_request'
data = {'email': 'luxparradon@gmail.com'}

print("Sending POST request to reset password for luxparradon@gmail.com...")
try:
    response = requests.post(url, data=data, allow_redirects=False)
    print(f"Status Code: {response.status_code}")
    print(f"Response Headers: {response.headers}")
    print("Test finished.")
except Exception as e:
    print(f"Error: {e}")
