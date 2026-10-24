import urllib.request
import urllib.parse
import http.cookiejar
import ssl

ctx = ssl.create_default_context()
cj = http.cookiejar.CookieJar()
opener = urllib.request.build_opener(
    urllib.request.HTTPCookieProcessor(cj),
    urllib.request.HTTPSHandler(context=ctx)
)

print("Testing POST /auth/login with username=jdelacruz...")
login_data = urllib.parse.urlencode({
    'username': 'jdelacruz',
    'password': 'password123'
}).encode('utf-8')

req = urllib.request.Request(
    'https://polutry-connect.vercel.app/auth/login',
    data=login_data,
    headers={'User-Agent': 'Mozilla/5.0'}
)

resp = opener.open(req)
print("Login HTTP Response Code:", resp.status)
print("Final Destination URL:", resp.geturl())
body = resp.read().decode('utf-8')
print("Contains Dashboard/Farm Info:", ("Dashboard" in body or "Farm" in body or "Juan" in body))
print("Session cookies set:", [c.name for c in cj])
