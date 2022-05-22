import datetime
import os
import requests
import boto3
from botocore.exceptions import ClientError
from bs4 import BeautifulSoup


def handler(event, context):
    print("[INFO] Starting")
    bucket_name = os.getenv("BUCKET_NAME")
    # Scrapping web
    requested_website = requests.get("https://coinmarketcap.com/currencies/bitcoin/").text
    soup = BeautifulSoup(requested_website, 'html.parser')
    price_div = soup.find("div", class_="priceValue")
    print("[INFO] Website parsed, proceeding to data modification")
    # # Data modification
    price = price_div.get_text().strip()[1:].replace(',', "")
    date = str(datetime.datetime.today())[:-7].split()
    # Editing html template
    html_file = open("indexTemplate.html", "r")
    lines = html_file.readlines()
    html_file.close()
    lines[22] = f"""            <td>{date[0]}</td>
                <td>{date[1]}</td>
                <td>{price}</td>
    """

    # Saving modified html file
    print("[INFO] Saving modified html template")
    with open("/tmp/modifiedHtml.html", "a+") as new_html_file:
        new_html_file.writelines(lines)
    new_html_file.close()

    # Uplading html file to s3
    print("[INFO] Uploading to s3")
    s3_client = boto3.client('s3')
    try:
        s3_client.delete_object(Bucket=bucket_name, Key='index.html')
    except ClientError as e:
        print(e)
    try:
        s3_client.upload_file("/tmp/modifiedHtml.html", bucket_name, "index.html",
                              ExtraArgs={'ContentType': 'text/html'})
        print("[INFO] File uploaded")
        os.remove("/tmp/modifiedHtml.html")
        print("[INFO] Success!")
        return True
    except ClientError as e:
        return e
