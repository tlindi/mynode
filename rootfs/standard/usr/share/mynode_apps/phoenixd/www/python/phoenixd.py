from flask import Blueprint, render_template, redirect
from user_management import check_logged_in
from enable_disable_functions import *
from device_info import *
from application_info import *
from systemctl_info import *
import subprocess
import os

mynode_phoenixd = Blueprint('mynode_phoenixd', __name__)

### Page functions (have prefix /app/<app name/)
@mynode_phoenixd.route("/info")
def phoenixd_page():
    check_logged_in()

    app = get_application("phoenixd")
    app_status = get_application_status("phoenixd")
    app_status_color = get_application_status_color("phoenixd")

    # Load page
    templateData = {
        "title": "myNode - " + app["name"],
        "ui_settings": read_ui_settings(),
        "app_status": app_status,
        "app_status_color": app_status_color,
        "app": app
    }
    return render_template('/app/phoenixd/phoenixd.html', **templateData)

import base64
import requests

@mynode_phoenixd.route("/getinfo")
def getinfo_page():
    check_logged_in()

    try:
        # PhoenixD API endpoint and authentication credentials
        server_url = "http://127.0.0.1:9740/getinfo"
        http_password = "ea6a5465a786c9c7ee78ecbc80c6d01ef6cd11fe9707a1dc16c05aa8495436e9"

        # Create the Basic Auth header with password only
        encoded_credentials = base64.b64encode(f":{http_password}".encode()).decode()
        headers = {"Authorization": f"Basic {encoded_credentials}"}

        # Sending the GET request
        response = requests.get(server_url, headers=headers)

        # Checking the response
        if response.status_code == 200:
            data = response.json()  # Parse JSON response

            # Function to shorten long *Id values
            def shorten_id(value):
                if isinstance(value, str) and len(value) > 15:  # Threshold for long values
                    return f"{value[:5]}*****{value[-5:]}"
                return value

            # Generate one unified HTML table without the first column
            unified_table = "<h3>GetInfo</h3><table border='1' style='width:100%; border-collapse:collapse;'>"

            # Add separator for General Info
            unified_table += "<tr><td colspan='2' text-align:center; font-weight:bold;'>General Info</td></tr>"
            for key, value in data.items():
                if key != "channels" and not key.endswith("Sat"):
                    unified_table += f"<tr><td>{key}</td><td>{shorten_id(value)}</td></tr>"

            # Add separator for Satoshi Values
            unified_table += "<tr><td colspan='2' text-align:center; font-weight:bold;'>Satoshi Values</td></tr>"
            for key, value in data.items():
                if key.endswith("Sat") and key != "channels":
                    unified_table += f"<tr><td>{key}</td><td>{value}</td></tr>"
            for channel in data.get("channels", []):
                for key, value in channel.items():
                    if key.endswith("Sat"):
                        unified_table += f"<tr><td>{key}</td><td>{value}</td></tr>"

            # Add separator for Channel Info
            unified_table += "<tr><td colspan='2' text-align:center; font-weight:bold;'>Channel Info</td></tr>"
            for channel in data.get("channels", []):
                for key, value in channel.items():
                    if not key.endswith("Sat"):
                        unified_table += f"<tr><td>{key}</td><td>{shorten_id(value)}</td></tr>"

            unified_table += "</table>"

            # Return the unified HTML table
            return unified_table
        else:
            return f"Error: Failed to fetch getinfo data, Status Code: {response.status_code}", 500
    except Exception as e:
        # Handle unexpected errors
        return f"Error: {str(e)}", 500