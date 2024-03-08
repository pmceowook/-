from flask import Flask,request,jsonify
import werkzeug
from PIL import Image
import json
from io import BytesIO
import io
import base64
import cv2
import numpy as np

app =  Flask(__name__)

# route folder

@app.route('/', methods = ['POST']) 
def handle_request():
    imagefile = request.files['image']
    filename = werkzeug.utils.secure_filename(imagefile.filename)
    imagefile.save("uploaded/"+filename)
    img = cv2.imread("uploaded/"+filename,cv2.IMREAD_COLOR)
    #gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
    blur = cv2.GaussianBlur(img,(5,5),3)
    canny = cv2.Canny(blur,100,200)
    cv2.imwrite("uploaded/"+filename,canny)
    
    return jsonify({"message":"Image Uploaded Successfuly"})

@app.route('/uploaded',methods = ['POST'])
def view_Images():
    data = request.get_json()
    parameter = data.get('param')
    
    img = open('uploaded/'+parameter, 'rb')
    base64_str = base64.b64encode(img.read())
    imgdata = base64.b64decode(base64_str)
    return imgdata

@app.route('/postTest',methods = ['POST'])
def post_Test():
    data = request.get_json()
    parameter = data.get('param')
    return { 'result' : 'Hello '+parameter+'!' }

@app.route('/test')
def test():
    return "Hello World Test"



if __name__ == "__main__":
   app.run()
