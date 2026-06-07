import secrets # Used to generate nonce
from flask import Flask, request, jsonify, render_template, g, session, redirect, url_for, flash # Flask is used for the web app
from werkzeug.security import check_password_hash, generate_password_hash
from flask_sqlalchemy import SQLAlchemy # Lets us add to the db using Python classes instead of using SQL
from google.cloud import secretmanager # To get secrets from Secret Manager
from google.cloud.sql.connector import Connector, IPTypes # For connecting to GCP Cloud SQL db
import pymysql # For db
import requests # requests for API calls
from ipwhois import IPWhois # Used for a whois lookup
import pycountry # Used to get full country name from country code
import json

# Get secrets from Secret Manager
def get_secret(secret_id):
    client = secretmanager.SecretManagerServiceClient()

    # Replace 'PROJECT_ID' with the actual GCP Project ID
    project_id = "PROJECT_ID"


    name = f"projects/{project_id}/secrets/{secret_id}/versions/latest"
    response = client.access_secret_version(request={"name": name})
    return response.payload.data.decode("UTF-8")

app = Flask(__name__, static_folder='static')

# Get API keys and db creds from Secret Manager
VT_API_KEY = get_secret("VT_API_KEY")
IPDB_API_KEY = get_secret("IPDB_API_KEY")
DB_USER = get_secret("DB_USER")
DB_PASS = get_secret("DB_PASS")
DB_NAME = get_secret("DB_NAME")
# Format: "project:region:instance-name"
INSTANCE_CONNECTION_NAME = get_secret("INSTANCE_CONNECTION_NAME")

AUTH_DATA = json.loads(get_secret("APP_AUTH"))
USERS = {
    AUTH_DATA['user']: generate_password_hash(AUTH_DATA['pass'])
}

# Cloud SQL connector setup
connector = Connector()

def getconn() -> pymysql.connections.Connection:
    conn: pymysql.connections.Connection = connector.connect(
        INSTANCE_CONNECTION_NAME,
        "pymysql",
        user=DB_USER,
        password=DB_PASS,
        db=DB_NAME,
        ip_type=IPTypes.PUBLIC
    )
    return conn

app.config['SQLALCHEMY_DATABASE_URI'] = "mysql+pymysql://"
app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {"creator": getconn}
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Database table definition
class SearchLog(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    ip_address = db.Column(db.String(45), nullable=False)
    time_added = db.Column(db.DateTime, server_default=db.func.now())

# Initialize table on startup
with app.app_context():
    db.create_all()


# Function for Virus Total API call
def virus_total_lookup(IP):

    # Virus Total API url
    url = f"https://www.virustotal.com/api/v3/ip_addresses/{IP}"

    # Headers, pulling Virus Total API key from config.py
    headers = {
        "accept":   "application/json",
        "x-apikey": VT_API_KEY
        }

    # Try API connection
    try:
        # Save reponse to vt_data
        vt_data = requests.get(url, headers = headers).json()

    # Returns error if the API can't be reached
    except requests.ConnectionError:
        return "Connection Error"

    # Get the analysis stats from the json data (vt_data)
    analysis_stats = (
        vt_data.get("data", {})
               .get("attributes", {})
               .get("last_analysis_stats", {})
        ) 

    # Get the community score from the json data (vt_data)
    reputation = (
        vt_data.get("data", {})
               .get("attributes", {})
               .get("reputation", {})
        )

    # Get the number of malicious detections
    malicious_count = analysis_stats.get("malicious", 0)

    # Get the number of suspicious detections
    suspicious_count = analysis_stats.get("suspicious", 0)

    # Get the undetected count
    undetected_count = analysis_stats.get("undetected", 0)

    # Get the number of harmless detections
    harmless_count = analysis_stats.get("harmless", 0)

    # Total number of vendors
    total = harmless_count + undetected_count + suspicious_count + malicious_count

    # Decide color for each count
    # If the number of malicious detections is greater than 0, the color is set to red. Otherwise it's set to green
    malicious_color = "red" if malicious_count > 0 else "green"

    # If the number of suspicious connections is greater than 0, set the color to yellow. Otherwise it's set to green
    suspicious_color = "rgb(177, 177, 0)" if suspicious_count > 0 else "green" if malicious_count == 0 else ""

    # If the IP has a positive community score/reputation the color of the number of harmless detections is green, otherwise it has no color
    harmless_color = "green" if malicious_count <= 0 else ""

    # If the reputation is greater than 0, color is set to green. If its less than 0, its set to red. If the reputation is 0, it has no color
    reputation_color = "green" if reputation > 0 else "red" if reputation < 0 else ""

    vt_results = {
        "mal_count":      malicious_count,
        "sus_count":      suspicious_count,
        "harmless_count": harmless_count,
        "und_count":      undetected_count,
        "total":          total,
        "comm_score":     reputation,
        "m_color":        malicious_color,
        "s_color":        suspicious_color,
        "h_color":        harmless_color,
        "r_color":        reputation_color
    }

    return vt_results

# Function for AbuseIPDB
def abuse_ipdb_lookup(IP):

    # AbuseIPDB API url
    url = "https://api.abuseipdb.com/api/v2/check"

    # API parameters 
    params = {
        # settting ipAddress parameter to the IP address provided in the function call/command line argument
        "ipAddress": IP,
        
        # Gets stats from the last year
        "maxAgeInDays": 365
    }

    # Headers, pulling AbseIPDB API key from config.py
    headers = {
        "Accept": "application/json",
        "Key":    IPDB_API_KEY
    }

    # Try API connection
    try:
        # Save API reponse as variable named ipdb_data
        ipdb_data = requests.get(url, headers=headers, params=params).json()

    except requests.ConnectionError:
        # Return error if API can't be reached
        return "Connection Error"

    # Get the abuse confidence score from the json data (ipdb_data)
    abuse_score = ipdb_data.get("data", {}).get("abuseConfidenceScore", 0)

    # Get the total number of reports from the json data (ipdb_data)
    total_reports = ipdb_data.get("data", {}).get("totalReports", 0)

    # Get the domain name if AbuseIPDB has one listed.
    domain_name = ipdb_data.get("data", {}).get("domain", 0)

    # Get hostnames(s)
    hostnames = ipdb_data.get("data", {}).get("hostnames", 0)
    if len(hostnames) == 0:
        hostnames = "N/A"

    # Get usage type
    usage_type = ipdb_data.get("data", {}).get("usageType", 0)

    # Decide color for the abuse confidence score
    a_color = "green" if abuse_score == 0 else "rgb(255, 193, 7)" if abuse_score <= 50 else "red"

    adb_results = {
        "total_reports": total_reports,
        "abuse_score":   abuse_score,
        "a_color":       a_color,
        "a_domain":      domain_name,
        "a_hostnames":   hostnames,
        "a_utype":       usage_type
    }

    return adb_results

# Function for whois lookup
def whois_lookup(IP):

    flagged_countries = ["Russia", "RU"]
    cn_color = "#64748b"
    cn_badge = "badge bg-secondary-subtle"
    
    try:
        # Make IPWhois object
        obj = IPWhois(IP)

        # Perform a WHOIS lookup
        lookup = obj.lookup_whois()

        country = pycountry.countries.get(alpha_2=lookup.get('asn_country_code')).name

        for cn in flagged_countries:
            if cn == lookup.get('asn_country_code') or cn == country:
                cn_color = "red"
                cn_badge = "badge bg-danger-subtle text-danger"
                break



        whois_results = {
            "description": lookup.get('asn_description'),
            "country":     country,
            "asn":         lookup.get('asn'),
            "date":        lookup.get('asn_date'),
            "cn_color":    cn_color,
            "cn_badge":    cn_badge
        }
        return whois_results
    
    except Exception as e:
        return f"Error: {e}"

# Flask app security code from the labs slightly modified for our use case
# ── Generate a CSP nonce per request ─────────────────────────────────────────
@app.before_request
def generate_nonce():
    g.nonce = secrets.token_hex(16)


# ── Security headers on every response ───────────────────────────────────────
@app.after_request
def set_security_headers(response):
    nonce = getattr(g, 'nonce', '')

    # CSP — no unsafe-inline; style-src uses per-request nonce
    # form-action 'self' prevents form hijacking (fixes ZAP form-action finding)
    response.headers['Content-Security-Policy'] = (
        f"default-src 'self'; "
        f"script-src 'self' https://cdn.jsdelivr.net; "
        f"style-src 'self' https://fonts.googleapis.com https://cdn.jsdelivr.net 'unsafe-inline'; "
        f"img-src 'self' data:; "
        f"font-src 'self' https://fonts.gstatic.com https://cdn.jsdelivr.net; "
        f"connect-src 'self' https://cdn.jsdelivr.net; "
        f"form-action 'self'; "
        f"frame-ancestors 'none';"
    )
    response.headers['X-Frame-Options']               = 'DENY'
    response.headers['X-Content-Type-Options']        = 'nosniff'
    response.headers['Cross-Origin-Embedder-Policy']  = 'require-corp'
    response.headers['Cross-Origin-Opener-Policy']    = 'same-origin'
    response.headers['Cross-Origin-Resource-Policy']  = 'same-origin'
    response.headers['Permissions-Policy']            = (
        'camera=(), microphone=(), geolocation=(), payment=()'
    )
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate, private'
    response.headers['Pragma']        = 'no-cache'
    response.headers['Expires']       = '0'
    return response


# ── WSGI middleware to override Server header ─────────────────────────────────
# after_request cannot override the Server header — Werkzeug sets it at the
# WSGI layer after Flask has finished. This middleware intercepts it correctly.
class HideServerVersion:
    def __init__(self, wsgi_app):
        self.wsgi_app = wsgi_app

    def __call__(self, environ, start_response):
        def custom_start_response(status, headers, exc_info=None):
            headers = [(k, v) for k, v in headers if k.lower() != 'server']
            headers.append(('server', 'CheckIP'))
            return start_response(status, headers, exc_info)
        return self.wsgi_app(environ, custom_start_response)

app.wsgi_app = HideServerVersion(app.wsgi_app)


# Login
@app.route('/login', methods=['GET', 'POST'])
def login():
    # If already logged in, go to home
    if 'user_id' in session:
        return redirect(url_for('check_reputation'))

    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        user_hash = USERS.get(username)
        
        if user_hash and check_password_hash(user_hash, password):
            session['user_id'] = username
            session.permanent = True # Session lasts until browser close
            return redirect(url_for('check_reputation'))
        else:
            flash("Invalid username or password.", "danger")
            
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.pop('user_id', None)
    flash("You have been logged out.", "success")
    return redirect(url_for('login'))

# Main page
@app.route('/', methods=["GET", "POST"])
@app.route('/checkip', methods=["GET", "POST"])
def check_reputation():

    if 'user_id' not in session:
        return redirect(url_for('login'))

    whois_results = None
    vt_results = None
    adb_results = None
    ip_list = []
    
    # Get user input, url_ip (post) and text_ip (post)
    url_ip = request.args.get('ip')
    text_ip = request.form.get("ip") if request.method == "POST" else None
    
    # If they used the search bar/url
    search_target = text_ip or url_ip
    if search_target and search_target.strip():
        ip_list.append(search_target.strip())
        
    # Only look at the file upload if the search bar is empty
    elif request.method == "POST":
        if 'ip_file' in request.files and request.files['ip_file'].filename != '':
            uploaded_file = request.files['ip_file']
            for line in uploaded_file.stream:
                ip_str = line.decode('utf-8').strip()
                if ip_str:
                    ip_list.append(ip_str)
    
    # Set variables for front end
    target_ip = None
    display_list = ip_list 

    if len(ip_list) == 1:
        target_ip = ip_list[0]
        
        # Run API calls
        whois_results = whois_lookup(target_ip)
        vt_results = virus_total_lookup(target_ip)
        adb_results = abuse_ipdb_lookup(target_ip)
        
        # display_list is empty, front end logic only shows the list of IPs of it exists/has data
        display_list = [] 

    return render_template(
        'checkip.html', 
        whois_results=whois_results, 
        vt_results=vt_results, 
        adb_results=adb_results, 
        ip=target_ip, 
        ip_list=display_list
    )


# Save IP route
@app.route('/save_ip', methods=['POST'])
def save_ip():
    data = request.get_json()
    ip_to_save = data.get('ip')
    
    if not ip_to_save:
        return jsonify({"status": "error", "message": "No IP provided"}), 400

    try:
        new_log = SearchLog(ip_address=ip_to_save)
        db.session.add(new_log)
        db.session.commit()
        return jsonify({"status": "success", "message": f"IP {ip_to_save} saved!"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
